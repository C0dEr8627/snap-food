part of '../main.dart';

class OrdersPage extends StatefulWidget{
  const OrdersPage({super.key, this.searchQuery = ''});
  final String searchQuery;
  @override State<OrdersPage> createState()=>_OrdersPageState();
}

class _AdminOrder {
  const _AdminOrder({required this.id,required this.customer,required this.phone,this.customerEmail='',required this.address,required this.total,required this.items,required this.payment,required this.time,required this.status,required this.lines,this.partner,this.partnerPhone,this.partnerEmail,this.vehicle,this.cancellationReason});
  factory _AdminOrder.fromJson(Map<String,dynamic> j){
    final customer=j['customer'] is Map?Map<String,dynamic>.from(j['customer'] as Map):<String,dynamic>{};
    final address=j['delivery_address_snapshot'] is Map?Map<String,dynamic>.from(j['delivery_address_snapshot'] as Map):<String,dynamic>{};
    final assignment=j['assignment'] is Map?Map<String,dynamic>.from(j['assignment'] as Map):<String,dynamic>{};
    final dp=assignment['delivery_partner'] is Map?Map<String,dynamic>.from(assignment['delivery_partner'] as Map):<String,dynamic>{};
    final rawItems=j['items'] is List?j['items'] as List:const [];
    final lines=rawItems.whereType<Map>().map((x)=>_OrderLine(_toInt(x['quantity']),x['product_name']?.toString()??'Item','',_toDouble(x['line_total']))).toList();
    return _AdminOrder(
      id:(j['id']??'').toString(),customer:customer['name']?.toString()??'Customer',
      phone:customer['phone']?.toString()??'',customerEmail:customer['email']?.toString()??'',address:[address['line1'],address['line2'],address['city'],address['state']].whereType<String>().where((v)=>v.isNotEmpty).join(', '),
      total:_toDouble(j['total']),items:lines.fold(0,(n,x)=>n+x.qty),payment:j['payment_method']?.toString()??'UNKNOWN',
      time:j['created_at']?.toString()??'',status:j['status']?.toString()??'PLACED',lines:lines,
      partner:dp['name']?.toString(),partnerPhone:dp['phone']?.toString(),partnerEmail:dp['email']?.toString(),cancellationReason:j['cancellation_reason']?.toString());
  }
  final String id,customer,phone,customerEmail,address,payment,time,status;
  final double total;
  final int items;
  final List<_OrderLine> lines;
  final String? partner,partnerPhone,partnerEmail,vehicle,cancellationReason;
  _AdminOrder withStatus(String value)=>_AdminOrder(id:id,customer:customer,phone:phone,customerEmail:customerEmail,address:address,total:total,items:items,payment:payment,time:time,status:value,lines:lines,partner:partner,partnerPhone:partnerPhone,partnerEmail:partnerEmail,vehicle:vehicle,cancellationReason:cancellationReason);
}


int _toInt(dynamic value){
  if(value is int)return value;
  return int.tryParse(value?.toString()??'')??0;
}

double _toDouble(dynamic value){
  if(value is num)return value.toDouble();
  return double.tryParse(value?.toString()??'')??0;
}

class _OrderLine{const _OrderLine(this.qty,this.name,this.modifier,this.price);final int qty;final String name,modifier;final double price;}


class _AdminOrderApi{
  const _AdminOrderApi();
  String get base{
    final v=apiBaseUrl.trim();
    return (v.isEmpty?'https://api.snapfoodd.in/api/v1':v).replaceFirst(RegExp(r'/$'),'');
  }
  String get token=>html.window.localStorage['snap_foodd_admin_token'] ?? '';
  bool get configured=>token.isNotEmpty;
  Map<String,String> get headers=>{'Accept':'application/json','Content-Type':'application/json',if(configured)'Authorization':'Bearer '+token};

  Future<List<_AdminOrder>> list({String search='',String status='ALL'}) async {
    if(!configured) throw StateError('No authenticated admin session. Please sign in again.');
    final q=<String,String>{
      'per_page':'100',
      if(search.trim().isNotEmpty)'search':search.trim(),
      if(status!='ALL')'status':status,
    };
    final r=await http.get(Uri.parse(base+'/admin/orders').replace(queryParameters:q),headers:headers);
    if(r.statusCode<200||r.statusCode>=300) throw StateError('Order list request failed ('+r.statusCode.toString()+').');
    final body=jsonDecode(r.body);
    final page=body is Map&&body['data'] is Map?body['data']:null;
    final rows=page is Map&&page['data'] is List?page['data'] as List:const [];
    return rows.whereType<Map>().map((e)=>_AdminOrder.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  Future<void> status(String id,String next,{String? cancellationReason})async{
    if(!configured)throw StateError('No authenticated admin session. Please sign in again.');
    final r=await http.patch(
      Uri.parse(base+'/admin/orders/'+Uri.encodeComponent(id)+'/status'),
      headers:headers,
      body:jsonEncode({'status':next,if(cancellationReason!=null)'cancellation_reason':cancellationReason}),
    );
    if(r.statusCode<200||r.statusCode>=300)throw StateError('Order status update failed ('+r.statusCode.toString()+').');
  }

  Future<List<_DeliveryPartnerOption>> availablePartners() async {
    if(!configured) throw StateError('No authenticated admin session.');
    final r=await http.get(Uri.parse(base+'/admin/delivery-partners?page=1&per_page=100'),headers:headers);
    if(r.statusCode<200||r.statusCode>=300) throw StateError('Delivery partner request failed ('+r.statusCode.toString()+').');
    final body=jsonDecode(r.body);
    final page=body is Map&&body['data'] is Map?body['data'] as Map:null;
    final rows=page!=null&&page['data'] is List?page['data'] as List:const [];
    return rows.whereType<Map>().map((x)=>_DeliveryPartnerOption.fromJson(x)).where((p)=>p.available).toList();
  }

  Future<String> assign(String orderId,int partnerId) async {
    if(!configured) throw StateError('No authenticated admin session.');
    final r=await http.post(
      Uri.parse(base+'/admin/orders/'+Uri.encodeComponent(orderId)+'/assignment'),
      headers:headers,
      body:jsonEncode({'delivery_partner_id':partnerId}),
    );
    if(r.statusCode<200||r.statusCode>=300) throw StateError(_orderApiMessage(r.body,'Delivery assignment failed'));
    final body=jsonDecode(r.body);
    final data=body is Map&&body['data'] is Map?body['data'] as Map:{};
    final partner=data['delivery_partner'] is Map?data['delivery_partner'] as Map:{};
    return (partner['name']??'Delivery partner').toString();
  }

  static String _orderApiMessage(String body,String fallback){
    try{
      final value=jsonDecode(body);
      if(value is Map&&value['message']!=null)return value['message'].toString();
    }catch(_){}
    return fallback;
  }

  Future<String?> invoice(String id)async{
    if(!configured)throw StateError('No authenticated admin session. Please sign in again.');
    final r=await http.get(Uri.parse(base+'/admin/orders/'+Uri.encodeComponent(id)+'/invoice'),headers:headers);
    if(r.statusCode<200||r.statusCode>=300)throw StateError('Invoice request failed ('+r.statusCode.toString()+').');
    final body=jsonDecode(r.body);
    if(body is Map&&body['data'] is Map){final data=body['data'] as Map;return (data['file_reference']??data['invoice_number'])?.toString();}return null;
  }
}

class _DeliveryPartnerOption{
  const _DeliveryPartnerOption({required this.id,required this.name,required this.email,required this.available});
  factory _DeliveryPartnerOption.fromJson(Map json){
    return _DeliveryPartnerOption(
      id:_toInt(json['id']),
      name:(json['name']??'Unnamed partner').toString(),
      email:(json['email']??'').toString(),
      available:json['is_available']==true&&json['is_approved']==true&&json['is_active']==true,
    );
  }
  final int id;final String name,email;final bool available;
}

class _OrdersPageState extends State<OrdersPage>{
  final api=const _AdminOrderApi(),search=TextEditingController();
  final orders=< _AdminOrder>[];
  String filter='ALL';String? selectedId;bool busy=false;bool loading=true;String? loadError;

  @override void initState(){super.initState();search.text=widget.searchQuery;search.addListener(_refresh);_loadOrders();}
  @override void didUpdateWidget(covariant OrdersPage oldWidget){super.didUpdateWidget(oldWidget);if(oldWidget.searchQuery!=widget.searchQuery&&search.text!=widget.searchQuery){search.text=widget.searchQuery;_loadOrders();}}
  @override void dispose(){search.removeListener(_refresh);search.dispose();super.dispose();}
  void _refresh(){if(mounted)setState((){});}

  Future<void> _loadOrders()async{
    setState(()=>loading=true);
    try{
      final live=await api.list(search:search.text);
      if(!mounted)return;
      setState((){orders..clear()..addAll(live);final view=filtered;selectedId=view.isNotEmpty?view.first.id:null;loading=false;loadError=null;});
    }catch(e){
      if(!mounted)return;
      setState((){loading=false;loadError=e.toString().replaceFirst('Bad state: ','');});
    }
  }

  List<_AdminOrder> get filtered=>orders.where((o){
    final q=search.text.trim().toLowerCase();
    final matchesSearch=q.isEmpty||o.id.toLowerCase().contains(q)||o.customer.toLowerCase().contains(q)||o.phone.contains(q);
    return matchesSearch&&_matchesFilter(o.status);
  }).toList();

  bool _matchesFilter(String status){
    switch(filter){
      case 'ACTION_REQUIRED':return ['PLACED','ACCEPTED','PREPARING','READY_FOR_PICKUP'].contains(status);
      case 'DELIVERY':return ['ASSIGNED','PICKED_UP','OUT_FOR_DELIVERY'].contains(status);
      case 'COMPLETED':return status=='DELIVERED';
      case 'REJECTED':return status=='CANCELLED';
      default:return true;
    }
  }

  int count(String value){
    return orders.where((o){
      if(value=='ALL')return true;
      if(value=='ACTION_REQUIRED')return ['PLACED','ACCEPTED','PREPARING','READY_FOR_PICKUP'].contains(o.status);
      if(value=='DELIVERY')return ['ASSIGNED','PICKED_UP','OUT_FOR_DELIVERY'].contains(o.status);
      if(value=='COMPLETED')return o.status=='DELIVERED';
      if(value=='REJECTED')return o.status=='CANCELLED';
      return false;
    }).length;
  }

  _AdminOrder? get selected{for(final o in orders){if(o.id==selectedId)return o;}return filtered.isEmpty?null:filtered.first;}

  Future<void> _transition(_AdminOrder order,String next)async{
    setState(()=>busy=true);
    try{
      await api.status(order.id,next);
      await _loadOrders();
      if(mounted){setState(()=>busy=false);SfFeedback.showSuccess(context,order.id+' moved to '+_prettyStatus(next)+'.');}
    }catch(e){if(mounted){setState(()=>busy=false);SfFeedback.showError(context,e.toString().replaceFirst('Bad state: ',''));}}
  }

  Future<void> _reject(_AdminOrder order)async{
    final reasonController=TextEditingController();
    final reasons=['Item out of stock','Kitchen capacity unavailable','Delivery service unavailable','Unable to fulfil requested items','Other'];
    String reason=reasons.first;
    final confirmed=await shad.showOverlay<bool>(
      context,shad.DialogConfiguration(),
      builder:(dialogContext)=>Material(
        color:Colors.transparent,
        child:shad.AlertDialog(
          title:const Text('Reject order'),
          content:StatefulBuilder(builder:(context,setDialogState)=>SizedBox(
            width:440,
            child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Record why '+order.id+' cannot be fulfilled. This reason is saved with the cancelled order.',style:AdminTypography.body.copyWith(color:AdminDesignColors.secondaryText)),
              const SizedBox(height:AdminSpacing.md),
              Wrap(spacing:8,runSpacing:8,children:reasons.map((item)=>(item==reason?shad.Button.secondary:shad.Button.ghost)(onPressed:()=>setDialogState(()=>reason=item),child:Text(item))).toList()),
              const SizedBox(height:AdminSpacing.md),
              Material(color:Colors.transparent,child:TextField(controller:reasonController,maxLines:3,decoration:const InputDecoration(labelText:'Additional note (optional)',border:OutlineInputBorder()))),
            ]),
          )),
          actions:[
            shad.OutlineButton(onPressed:()=>Navigator.pop(dialogContext,false),child:const Text('Keep order')),
            shad.PrimaryButton(onPressed:()=>Navigator.pop(dialogContext,true),child:const Text('Reject order')),
          ],
        ),
      ),
    ).future;
    final note=reasonController.text.trim();reasonController.dispose();
    if(confirmed!=true||!mounted)return;
    final finalReason=note.isEmpty?reason:reason+' — '+note;
    setState(()=>busy=true);
    try{
      await api.status(order.id,'CANCELLED',cancellationReason:finalReason);
      await _loadOrders();
      if(mounted){setState(()=>busy=false);SfFeedback.showSuccess(context,order.id+' was rejected.');}
    }catch(e){if(mounted){setState(()=>busy=false);SfFeedback.showError(context,e.toString().replaceFirst('Bad state: ',''));}}
  }

  Future<void> _assign(_AdminOrder order)async{
    setState(()=>busy=true);
    try{
      final partners=await api.availablePartners();
      if(!mounted)return;
      setState(()=>busy=false);
      if(partners.isEmpty){SfFeedback.showError(context,'No approved, active and available delivery partners are currently available.');return;}
      final partner=await shad.showOverlay<_DeliveryPartnerOption>(
        context,shad.DialogConfiguration(),
        builder:(dialogContext)=>Material(
          color:Colors.transparent,
          child:shad.AlertDialog(
            title:const Text('Assign delivery partner'),
            content:SizedBox(
              width:460,
              child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('Select an available partner. Assignment will move the order to ASSIGNED.',style:AdminTypography.small.copyWith(color:AdminDesignColors.secondaryText)),
                const SizedBox(height:AdminSpacing.md),
                ...partners.map((p)=>Padding(
                  padding:const EdgeInsets.only(bottom:8),
                  child:shad.Button.ghost(
                    onPressed:()=>Navigator.pop(dialogContext,p),
                    child:Row(children:[
                      Container(width:36,height:36,alignment:Alignment.center,decoration:const BoxDecoration(color:AdminDesignColors.yellowSoft,shape:BoxShape.circle),child:Text(p.name.isEmpty?'?':p.name.characters.first.toUpperCase(),style:AdminTypography.small.copyWith(fontWeight:FontWeight.w800))),
                      const SizedBox(width:10),
                      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.name,style:AdminTypography.body.copyWith(fontWeight:FontWeight.w700)),if(p.email.isNotEmpty)Text(p.email,style:AdminTypography.small)])),
                      const AdminIcon(HugeIcons.strokeRoundedArrowRight01,size:17),
                    ]),
                  ),
                )),
              ]),
            ),
            actions:[shad.OutlineButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('Cancel'))],
          ),
        ),
      ).future;
      if(partner==null||!mounted)return;
      setState(()=>busy=true);
      final assignedName=await api.assign(order.id,partner.id);
      await _loadOrders();
      if(mounted){setState(()=>busy=false);SfFeedback.showSuccess(context,order.id+' assigned to '+assignedName+'.');}
    }catch(e){if(mounted){setState(()=>busy=false);SfFeedback.showError(context,e.toString().replaceFirst('Bad state: ',''));}}
  }

  void _showCustomerDetails(_AdminOrder order){
    showDialog<void>(context:context,builder:(dialogContext)=>AlertDialog(
      title:const Text('Customer details'),
      content:SizedBox(width:460,child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
        _detailLine('Name',order.customer),
        _detailLine('Contact number',order.phone.isEmpty?'Not provided':order.phone),
        _detailLine('Email',order.customerEmail.isEmpty?'Not provided':order.customerEmail),
        const Divider(height:24),
        _detailLine('Delivery address',order.address.isEmpty?'No delivery address on record':order.address),
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('Close'))],
    ));
  }

  void _showPartnerDetails(_AdminOrder order){
    showDialog<void>(context:context,builder:(dialogContext)=>AlertDialog(
      title:const Text('Delivery partner details'),
      content:SizedBox(width:460,child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
        _detailLine('Name',order.partner??'Not assigned'),
        _detailLine('Contact number',(order.partnerPhone??'').isEmpty?'Not provided':order.partnerPhone!),
        _detailLine('Email',(order.partnerEmail??'').isEmpty?'Not provided':order.partnerEmail!),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('Close'))],
    ));
  }

  Widget _detailLine(String label,String value)=>Padding(
    padding:const EdgeInsets.only(bottom:12),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(label,style:AdminTypography.caption.copyWith(color:AdminDesignColors.secondaryText,fontWeight:FontWeight.w700)),
      const SizedBox(height:3),SelectableText(value,style:AdminTypography.body),
    ]),
  );

  Future<void> _invoice(_AdminOrder order)async{
    setState(()=>busy=true);
    try{final ref=await api.invoice(order.id);if(mounted){setState(()=>busy=false);SfFeedback.showInfo(context,ref==null?'Invoice endpoint returned no file reference.':'Invoice reference: '+ref);}}
    catch(e){if(mounted){setState(()=>busy=false);SfFeedback.showError(context,e.toString().replaceFirst('Bad state: ',''));}}
  }

  @override Widget build(BuildContext context){
    if(loading)return const Center(child:Padding(padding:EdgeInsets.all(AdminSpacing.xl),child:SfLoadingState(title:'Loading orders',message:'Preparing the operational order queue.')));
    if(loadError!=null)return Padding(padding:const EdgeInsets.all(AdminSpacing.xl),child:SfErrorState(title:'Unable to load orders',message:loadError!,onRetry:_loadOrders));
    final list=filtered,order=selected;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _OrdersHeader(apiConfigured:api.configured,onExport:()=>exportCsv(orders),onRefresh:_loadOrders),
      const SizedBox(height:AdminSpacing.xl),
      _OrderFilters(controller:search,active:filter,count:count,onChange:(v)=>setState((){filter=v;selectedId=filtered.isNotEmpty?filtered.first.id:null;})),
      const SizedBox(height:AdminSpacing.lg),
      _OrderQueue(orders:list,selectedId:selectedId,onSelect:(v)=>setState(()=>selectedId=v)),
      if(order!=null)...[
        const SizedBox(height:AdminSpacing.lg),
        _OrderWorkspace(
          order:order,busy:busy,apiConfigured:api.configured,
          onAccept:()=>_transition(order,'ACCEPTED'),onReject:()=>_reject(order),
          onPreparing:()=>_transition(order,'PREPARING'),onReady:()=>_transition(order,'READY_FOR_PICKUP'),
          onAssign:()=>_assign(order),onPickedUp:()=>_transition(order,'PICKED_UP'),
          onOut:()=>_transition(order,'OUT_FOR_DELIVERY'),onDelivered:()=>_transition(order,'DELIVERED'),
          onInvoice:()=>_invoice(order),
          onCustomerDetails:(selected)=>_showCustomerDetails(selected),onPartnerDetails:(selected)=>_showPartnerDetails(selected),
        ),
      ],
      if(list.isEmpty)const Padding(padding:EdgeInsets.only(top:AdminSpacing.lg),child:SfEmptyState(title:'No orders in this workflow stage',message:'Change the operational filter or clear the search.')),
    ]);
  }

  void exportCsv(List<_AdminOrder> list){
    final rows=<List<String>>[['Order ID','Customer','Phone','Address','Items','Total','Payment','Time','Status','Cancellation reason'],...list.map((o)=>[o.id,o.customer,o.phone,o.address,o.items.toString(),o.total.toStringAsFixed(2),o.payment,o.time,o.status,o.cancellationReason??''])];
    String cell(String s)=>'"'+s.replaceAll('"','""')+'"';final csv=rows.map((r)=>r.map(cell).join(',')).join('\\n');
    final blob=html.Blob([utf8.encode(csv)],'text/csv;charset=utf-8');final url=html.Url.createObjectUrlFromBlob(blob);final a=html.AnchorElement(href:url)..download='snap-foodd-orders.csv'..style.display='none';html.document.body?.children.add(a);a.click();a.remove();html.Url.revokeObjectUrl(url);
  }
}

class _OrdersHeader extends StatelessWidget{
  const _OrdersHeader({required this.apiConfigured,required this.onExport,required this.onRefresh});
  final bool apiConfigured;final VoidCallback onExport,onRefresh;
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(c,box){
    final title=Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('ORDER OPERATIONS',style:AdminTypography.pageTitle),
      const SizedBox(height:5),
      Text('Review → accept or reject → prepare → ready → assign → dispatch → deliver.',style:AdminTypography.body.copyWith(color:AdminDesignColors.secondaryText)),
    ]);
    final actions=Wrap(spacing:AdminSpacing.sm,runSpacing:AdminSpacing.sm,children:[
      SfStatusBadge(label:apiConfigured?'API connected':'Authentication required',status:apiConfigured?'success':'fail'),
      SfIconButton(icon:HugeIcons.strokeRoundedRefresh,tooltip:'Refresh orders',onPressed:onRefresh),
      shad.OutlineButton(onPressed:onExport,leading:const AdminIcon(HugeIcons.strokeRoundedDownload01,size:16),child:const Text('Export')),
    ]);
    return box.maxWidth<760?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[title,const SizedBox(height:AdminSpacing.md),actions]):Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Expanded(child:title),const SizedBox(width:AdminSpacing.lg),actions]);
  });
}

class _OrderFilters extends StatelessWidget {
  const _OrderFilters({
    required this.controller,
    required this.active,
    required this.count,
    required this.onChange,
  });

  final TextEditingController controller;
  final String active;
  final int Function(String) count;
  final ValueChanged<String> onChange;

  static const data = [
    ('ALL', 'All Orders'),
    ('PLACED', 'Pending'),
    ('PREP', 'Preparing'),
    ('OUT', 'Out for Delivery'),
    ('DELIVERED', 'Delivered'),
    ('DISPUTED', 'Disputed'),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 225,
                child: shad.TextField(
                  controller: controller,
                  placeholder: const Text('Search by Order ID'),
                  style: AdminTypography.small,
                  filled: true,
                  border: const Border.fromBorderSide(BorderSide(color: AdminDesignColors.border)),
                  borderRadius: BorderRadius.circular(9),
                  features: const [
                    shad.InputLeadingFeature(AdminIcon(HugeIcons.strokeRoundedSearch01, size: 17)),
                    shad.InputClearFeature(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ...data.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: _FilterChip(
                    label: d.$2,
                    value: d.$1,
                    active: active == d.$1,
                    count: count(d.$1),
                    onTap: () => onChange(d.$1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget{
  const _FilterChip({required this.label,required this.value,required this.active,required this.count,required this.onTap});
  final String label,value;final bool active;final int count;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>Semantics(
    button:true,
    selected:active,
    label:label+' ('+count.toString()+')',
    child:(active ? shad.Button.secondary : shad.Button.ghost)(
      onPressed:onTap,
      child: Row(mainAxisSize:MainAxisSize.min,children:[
        Text(label,style:AdminTypography.small.copyWith(fontWeight:FontWeight.w700,color:active?AdminDesignColors.primaryText:AdminDesignColors.secondaryText)),
        const SizedBox(width:AdminSpacing.xs),
        Container(
          padding:const EdgeInsets.symmetric(horizontal:6,vertical:3),
          decoration:BoxDecoration(color:active?AdminDesignColors.brandYellow:AdminDesignColors.canvas,borderRadius:BorderRadius.circular(6)),
          child:Text(count.toString(),style:AdminTypography.small.copyWith(fontWeight: FontWeight.w700)),
        ),
      ]),
    ).sized(height:44),
  );
}

class _OrderQueue extends StatelessWidget{
  const _OrderQueue({required this.orders,required this.selectedId,required this.onSelect});
  final List<_AdminOrder> orders;final String? selectedId;final ValueChanged<String> onSelect;

  @override Widget build(BuildContext context)=>AdminCard(
    child:Padding(
      padding:const EdgeInsets.all(AdminSpacing.md),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('ORDER QUEUE',style:AdminTypography.cardTitle),
            const SizedBox(height:3),
            Text('Select an order to open its operational workspace below.',style:AdminTypography.small.copyWith(color:AdminDesignColors.secondaryText)),
          ])),
          SfBadge(label:orders.length.toString()+' orders',backgroundColor:AdminDesignColors.yellowSoft,foregroundColor:AdminDesignColors.ink),
        ]),
        const SizedBox(height:AdminSpacing.md),
        if(orders.isEmpty)
          const Padding(padding:EdgeInsets.all(AdminSpacing.xl),child:Center(child:Text('No orders in this queue.')))
        else
          ...orders.map((o)=>_OrderQueueRow(order:o,selected:o.id==selectedId,onTap:()=>onSelect(o.id))),
      ]),
    ),
  );
}

class _OrderQueueRow extends StatelessWidget{
  const _OrderQueueRow({required this.order,required this.selected,required this.onTap});
  final _AdminOrder order;final bool selected;final VoidCallback onTap;

  @override Widget build(BuildContext context)=>InkWell(
    onTap:onTap,
    borderRadius:BorderRadius.circular(10),
    child:Container(
      margin:const EdgeInsets.only(bottom:8),
      padding:const EdgeInsets.symmetric(horizontal:12,vertical:12),
      decoration:BoxDecoration(
        color:selected?AdminDesignColors.yellowSoft:AdminDesignColors.surface,
        borderRadius:BorderRadius.circular(10),
        border:Border.all(color:selected?AdminDesignColors.ink:AdminDesignColors.border,width:selected?1.3:1),
      ),
      child:LayoutBuilder(builder:(context,constraints){
        if(constraints.maxWidth<680)return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[Expanded(child:Text(order.id,style:AdminTypography.cardTitle)),_OrderStatusBadge(order.status)]),
          const SizedBox(height:7),
          Text(order.customer,style:AdminTypography.body.copyWith(fontWeight:FontWeight.w700)),
          const SizedBox(height:3),
          Text(order.items.toString()+' items · ₹'+order.total.toStringAsFixed(2)+' · '+_prettyStatus(order.status),style:AdminTypography.small),
        ]);
        return Row(children:[
          SizedBox(width:120,child:Text(order.id,style:AdminTypography.body.copyWith(fontWeight:FontWeight.w800))),
          Expanded(flex:3,child:Text(order.customer,maxLines:1,overflow:TextOverflow.ellipsis,style:AdminTypography.body.copyWith(fontWeight:FontWeight.w700))),
          Expanded(flex:2,child:Text(order.items.toString()+' items',style:AdminTypography.small)),
          SizedBox(width:130,child:Text('₹'+order.total.toStringAsFixed(2),style:AdminTypography.body.copyWith(fontWeight:FontWeight.w800))),
          SizedBox(width:150,child:_OrderStatusBadge(order.status)),
          const AdminIcon(HugeIcons.strokeRoundedArrowRight01,size:17),
        ]);
      }),
    ),
  );
}

class _OrderWorkspace extends StatelessWidget{
  const _OrderWorkspace({
    required this.order,required this.busy,required this.apiConfigured,
    required this.onAccept,required this.onReject,required this.onPreparing,required this.onReady,
    required this.onAssign,required this.onPickedUp,required this.onOut,required this.onDelivered,
    required this.onInvoice,required this.onCustomerDetails,required this.onPartnerDetails,
  });
  final _AdminOrder order;final bool busy,apiConfigured;
  final VoidCallback onAccept,onReject,onPreparing,onReady,onAssign,onPickedUp,onOut,onDelivered,onInvoice;final ValueChanged<_AdminOrder> onCustomerDetails,onPartnerDetails;

  @override Widget build(BuildContext context){
    final action=_action(order.status);
    return AdminCard(child:Padding(padding:const EdgeInsets.all(AdminSpacing.lg),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('ORDER WORKSPACE',style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w800,letterSpacing:.8)),
          const SizedBox(height:4),Text(order.id,style:AdminTypography.pageTitle),
          const SizedBox(height:4),Text('Review the order, take the next operational action, and keep the status moving.',style:AdminTypography.small.copyWith(color:AdminDesignColors.secondaryText)),
        ])),
        _OrderStatusBadge(order.status),
      ]),
      const SizedBox(height:AdminSpacing.lg),
      _OrderProgress(status:order.status),
      const SizedBox(height:AdminSpacing.xl),
      LayoutBuilder(builder:(context,constraints){
        final wide=constraints.maxWidth>=820;
        final cards=[
          InkWell(onTap:()=>onCustomerDetails(order),borderRadius:BorderRadius.circular(AdminRadii.control),child:_WorkspaceInfo(title:'CUSTOMER',icon:HugeIcons.strokeRoundedUser,children:[
            Text(order.customer,style:AdminTypography.body.copyWith(fontWeight:FontWeight.w800)),
            if(order.phone.isNotEmpty)Text(order.phone,style:AdminTypography.small),
            if(order.address.isNotEmpty)Text(order.address,style:AdminTypography.small),
          ])),
          _WorkspaceInfo(title:'PAYMENT',icon:HugeIcons.strokeRoundedWallet01,children:[
            Text(order.payment,style:AdminTypography.body.copyWith(fontWeight:FontWeight.w800)),
            Text('₹'+order.total.toStringAsFixed(2)+' total',style:AdminTypography.small),
          ]),
          InkWell(onTap:order.partner==null?null:()=>onPartnerDetails(order),borderRadius:BorderRadius.circular(AdminRadii.control),child:_WorkspaceInfo(title:'DELIVERY',icon:HugeIcons.strokeRoundedDeliveryTruck01,children:[
            Text(order.partner??'Not assigned yet',style:AdminTypography.body.copyWith(fontWeight:FontWeight.w800)),
            Text(order.partner==null?'Assignment is available after the order is ready for pickup.':'Partner assigned',style:AdminTypography.small),
          ])),
        ];
        return wide?Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Expanded(child:cards[0]),const SizedBox(width:10),Expanded(child:cards[1]),const SizedBox(width:10),Expanded(child:cards[2]),
        ]):Column(children:[cards[0],const SizedBox(height:10),cards[1],const SizedBox(height:10),cards[2]]);
      }),
      const SizedBox(height:AdminSpacing.lg),
      _WorkspaceSection(title:'ORDER ITEMS',trailing:order.items.toString()+' items',child:Column(children:[
        for(final line in order.lines)Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Row(children:[
          Container(width:32,height:32,alignment:Alignment.center,decoration:BoxDecoration(color:AdminDesignColors.yellowSoft,borderRadius:BorderRadius.circular(8)),child:Text(line.qty.toString()+'×',style:AdminTypography.small.copyWith(fontWeight:FontWeight.w800))),
          const SizedBox(width:10),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(line.name,style:AdminTypography.body.copyWith(fontWeight:FontWeight.w700)),
            if(line.modifier.isNotEmpty)Text(line.modifier,style:AdminTypography.small),
          ])),
          Text('₹'+line.price.toStringAsFixed(2),style:AdminTypography.body.copyWith(fontWeight:FontWeight.w800)),
        ])),
      ])),
      if(order.cancellationReason!=null&&order.cancellationReason!.isNotEmpty)...[
        const SizedBox(height:AdminSpacing.md),
        _WorkspaceSection(title:'REJECTION REASON',child:Text(order.cancellationReason!,style:AdminTypography.body.copyWith(color:AdminDesignColors.error))),
      ],
      const SizedBox(height:AdminSpacing.lg),
      Container(
        padding:const EdgeInsets.all(AdminSpacing.md),
        decoration:BoxDecoration(color:AdminDesignColors.ink,borderRadius:BorderRadius.circular(AdminRadii.card)),
        child:LayoutBuilder(builder:(context,constraints){
          final stacked=constraints.maxWidth<700;
          final copy=Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('NEXT OPERATION',style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:Colors.white70,letterSpacing:.8)),
            const SizedBox(height:4),Text(action.label,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:Colors.white)),
            const SizedBox(height:3),Text(action.description,style:const TextStyle(fontSize:12,color:Colors.white70)),
          ]);
          final button=action.callback==null?const SizedBox.shrink():_ActionButton(busy:busy,enabled:apiConfigured,label:action.buttonLabel,onPressed:action.callback);
          return stacked?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[copy,const SizedBox(height:12),button]):Row(children:[Expanded(child:copy),const SizedBox(width:16),button]);
        }),
      ),
      const SizedBox(height:AdminSpacing.md),
      Wrap(spacing:8,runSpacing:8,children:[
        if(action.allowReject)shad.OutlineButton(onPressed:busy||!apiConfigured?null:onReject,leading:const AdminIcon(HugeIcons.strokeRoundedCancel01,size:15,color:AdminDesignColors.error),child:const Text('Reject / cancel')),
        shad.OutlineButton(onPressed:busy||!apiConfigured?null:onInvoice,leading:const AdminIcon(HugeIcons.strokeRoundedInvoice01,size:15),child:const Text('Invoice')),
      ]),
    ])));
  }

  _OrderAction _action(String status){
    switch(status){
      case 'PLACED':return _OrderAction('Review order','Verify the requested items and stock before accepting.','Accept order',onAccept,true);
      case 'ACCEPTED':return _OrderAction('Start preparation','The order is accepted and can move into kitchen preparation.','Start preparing',onPreparing,true);
      case 'PREPARING':return _OrderAction('Finish preparation','Confirm every item is ready before dispatch.','Mark ready for pickup',onReady,true);
      case 'READY_FOR_PICKUP':return _OrderAction('Dispatch handoff','Choose an eligible delivery partner. Assignment changes the order to ASSIGNED.','Assign delivery partner',onAssign,true);
      case 'ASSIGNED':return _OrderAction('Pickup handoff','Confirm the delivery partner has collected the order.','Mark picked up',onPickedUp,true);
      case 'PICKED_UP':return _OrderAction('Start delivery','The order is with the delivery partner.','Out for delivery',onOut,true);
      case 'OUT_FOR_DELIVERY':return _OrderAction('Complete delivery','Confirm the customer has received the order.','Mark delivered',onDelivered,true);
      default:return _OrderAction('Order closed','No further operational action is required.','Completed',null,false);
    }
  }
}

class _OrderAction{
  const _OrderAction(this.label,this.description,this.buttonLabel,this.callback,this.allowReject);
  final String label,description,buttonLabel;final VoidCallback? callback;final bool allowReject;
}

class _ActionButton extends StatelessWidget{
  const _ActionButton({required this.busy,required this.enabled,required this.label,required this.onPressed});
  final bool busy,enabled;final String label;final VoidCallback? onPressed;
  @override Widget build(BuildContext context)=>shad.PrimaryButton(onPressed:enabled&&!busy?onPressed:null,child:Text(busy?'Updating…':label)).sized(height:44);
}

class _WorkspaceInfo extends StatelessWidget{
  const _WorkspaceInfo({required this.title,required this.icon,required this.children});
  final String title;final AdminIconData icon;final List<Widget> children;
  @override Widget build(BuildContext context)=>Container(
    width:double.infinity,padding:const EdgeInsets.all(AdminSpacing.md),
    decoration:BoxDecoration(color:AdminDesignColors.canvas,borderRadius:BorderRadius.circular(AdminRadii.control),border:Border.all(color:AdminDesignColors.border)),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      AdminIcon(icon,size:18,color:AdminDesignColors.warning),const SizedBox(width:9),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w800)),
        const SizedBox(height:5),...children.map((child)=>Padding(padding:const EdgeInsets.only(bottom:2),child:child)),
      ])),
    ]),
  );
}

class _WorkspaceSection extends StatelessWidget{
  const _WorkspaceSection({required this.title,required this.child,this.trailing});
  final String title;final Widget child;final String? trailing;
  @override Widget build(BuildContext context)=>Container(
    width:double.infinity,padding:const EdgeInsets.all(AdminSpacing.md),
    decoration:BoxDecoration(color:AdminDesignColors.surface,borderRadius:BorderRadius.circular(AdminRadii.card),border:Border.all(color:AdminDesignColors.border)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Text(title,style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w800,letterSpacing:.5))),if(trailing!=null)Text(trailing!,style:AdminTypography.small.copyWith(fontWeight:FontWeight.w700))]),
      const SizedBox(height:9),child,
    ]),
  );
}

class _OrderProgress extends StatelessWidget{
  const _OrderProgress({required this.status});final String status;
  static const steps=['PLACED','ACCEPTED','PREPARING','READY_FOR_PICKUP','ASSIGNED','PICKED_UP','OUT_FOR_DELIVERY','DELIVERED'];
  @override Widget build(BuildContext context){
    final current=steps.indexOf(status);
    return SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[
      for(var i=0;i<steps.length;i++)...[
        SizedBox(width:92,child:Column(children:[
          Container(width:25,height:25,alignment:Alignment.center,decoration:BoxDecoration(
            color:i<current?AdminDesignColors.brandYellow:i==current?AdminDesignColors.ink:AdminDesignColors.surface,
            shape:BoxShape.circle,border:Border.all(color:i<=current?Colors.transparent:AdminDesignColors.border),
          ),child:i<current?const AdminIcon(HugeIcons.strokeRoundedCheckmarkCircle01,size:14,color:AdminDesignColors.ink):Text('•',style:TextStyle(color:i==current?Colors.white:AdminDesignColors.secondaryText,fontWeight:FontWeight.w900))),
          const SizedBox(height:5),
          Text(_prettyStatus(steps[i]),maxLines:2,textAlign:TextAlign.center,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:i==current?AdminDesignColors.primaryText:AdminDesignColors.secondaryText)),
        ])),
        if(i<steps.length-1)Container(width:28,height:2,margin:const EdgeInsets.only(bottom:21),color:current>=0&&i<current?AdminDesignColors.brandYellow:AdminDesignColors.border),
      ],
    ]));
  }
}

class _OrderStatusBadge extends StatelessWidget{
  const _OrderStatusBadge(this.status);
  final String status;
  @override Widget build(BuildContext context){
    final style=_statusStyle(status);
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),
      decoration:BoxDecoration(color:style.$1,borderRadius:BorderRadius.circular(AdminRadii.pill)),
      child:Text(_prettyStatus(status),style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:style.$2)),
    );
  }
}

class _Progression extends StatelessWidget {
  const _Progression(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      'PLACED',
      'ACCEPTED',
      'PREPARING',
      'OUT_FOR_DELIVERY',
      'DELIVERED',
    ];
    final current = _progressStep(status) - 1;

    return Row(
      children: [
        for (var i = 0; i < statuses.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: i < current
                        ? AdminDesignColors.brandYellow
                        : i == current
                            ? AdminDesignColors.error
                            : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i <= current
                          ? Colors.transparent
                          : AdminDesignColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: i < current
                      ? const AdminIcon(
                          HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 14,
                          color: AdminDesignColors.primaryText,
                        )
                      : Text(
                          (i + 1).toString(),
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w900,
                            color: i == current
                                ? Colors.white
                                : AdminDesignColors.secondaryText,
                          ),
                        ),
                ),
                const SizedBox(height: 5),
                Text(
                  _prettyStatus(statuses[i]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: i == current
                        ? AdminDesignColors.error
                        : AdminDesignColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          if (i < statuses.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 22),
                color: i < current
                    ? AdminDesignColors.brandYellow
                    : AdminDesignColors.border,
              ),
            ),
        ],
      ],
    );
  }
}

class _PersonCard extends StatelessWidget{
  const _PersonCard(this.title,this.name,this.lines,this.icon,{this.badge});final String title,name;final List<String> lines;final AdminIconData icon;final String? badge;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(11),border:Border.all(color:AdminDesignColors.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[AdminIcon(icon,size:16,color:AdminDesignColors.warning),const SizedBox(width:6),Text(title,style:const TextStyle(fontSize: 12, fontWeight: FontWeight.w900,color:AdminDesignColors.secondaryText)),const Spacer(),if(badge!=null)Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:4),decoration:BoxDecoration(color:badge=='ON DUTY'?AdminDesignColors.successSoft:AdminDesignColors.errorSoft,borderRadius:BorderRadius.circular(6)),child:Text(badge!,style:TextStyle(fontSize: 12, fontWeight: FontWeight.w900,color:badge=='ON DUTY'?AdminDesignColors.success:AdminDesignColors.error)))]),
    const SizedBox(height:AdminSpacing.sm),Text(name,style:AdminTypography.small.copyWith(fontWeight: FontWeight.w700)),const SizedBox(height:4),...lines.map((l)=>Padding(padding:const EdgeInsets.only(top:2),child:Text(l,maxLines:2,overflow:TextOverflow.ellipsis,style:AdminTypography.small.copyWith(height:1.3)))),
  ]));
}

class _Bill extends StatelessWidget{
  const _Bill(this.o);
  final _AdminOrder o;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AdminSpacing.md),
    decoration: BoxDecoration(
      color: AdminDesignColors.surface,
      borderRadius: BorderRadius.circular(AdminRadii.card),
      border: Border.all(color: AdminDesignColors.border),
    ),
    child: Column(
      children: [
        Row(children: [
          Expanded(child: Text('Order total', style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600))),
          Text('₹${o.total.toStringAsFixed(2)}', style: AdminTypography.cardTitle),
        ]),
        const Divider(height: AdminSpacing.xxl),
        Row(children: [
          Expanded(child: Text('Payment method', style: AdminTypography.small)),
          Text(o.payment, style: AdminTypography.small.copyWith(fontWeight: FontWeight.w700)),
        ]),
      ],
    ),
  );
}

class _EmptyOrders extends StatelessWidget{const _EmptyOrders({required this.onClear});final VoidCallback onClear;@override Widget build(BuildContext context)=>AdminCard(child:Padding(padding:const EdgeInsets.all(34),child:Center(child:Column(children:[const AdminIcon(HugeIcons.strokeRoundedInbox,size:34,color:AdminDesignColors.secondaryText),const SizedBox(height:9),const Text('No orders match this view',style:AdminTypography.body),const SizedBox(height:5),const Text('Try another status filter or clear the order search.',style:AdminTypography.small),const SizedBox(height:AdminSpacing.md),shad.OutlineButton(onPressed:onClear,child:const Text('Clear filters'))]))));}

const _previewOrders=<_AdminOrder>[
  _AdminOrder(id:'#SFD-9042',customer:'Aarav Mehra',phone:'+919820144521',address:'Flat 402 Wing B, Sea Green Apts, Juhu Beach Ext.',total:849,items:3,payment:'UPI',time:'14:32 (4m ago)',status:'PREPARING',partner:'Ramesh Patil',vehicle:'Ather 450X (MH-02-EH-4819)',lines:[_OrderLine(1,'Truffle Melt Burger','Extra Cheese',480),_OrderLine(1,'Peri Peri Crinkle Fries','Jalapeño Dip',160),_OrderLine(1,'Alphonso Mango Shake','No Sugar Added',140)]),
  _AdminOrder(id:'#SFD-9041',customer:'Pooja Sharma',phone:'+919769012098',address:'Bungalow 7, Silver Beach Colony, Juhu Beach Rd.',total:1240,items:5,payment:'Card',time:'14:29 (7m ago)',status:'ACCEPTED',partner:'Neha Kulkarni',vehicle:'Ather 450X (MH-01-KD-2208)',lines:[_OrderLine(2,'Classic Veg Burger','No onion',360),_OrderLine(1,'Loaded Fries','',180),_OrderLine(2,'Cold Coffee','',280)]),
  _AdminOrder(id:'#SFD-9040',customer:'Devendra Rao',phone:'+919137089234',address:'Flat 1201, Oberoi Sky Gardens, Andheri West.',total:540,items:2,payment:'Cash',time:'14:24 (12m ago)',status:'PLACED',lines:[_OrderLine(1,'Paneer Tikka Wrap','Mint chutney',220),_OrderLine(1,'Masala Fries','',120)]),
  _AdminOrder(id:'#SFD-9039',customer:'Nisha Varghese',phone:'+919930048110',address:'Office 4B, Peninsula Business Park, Santacruz West.',total:2180,items:8,payment:'Corporate',time:'14:18 (18m ago)',status:'OUT_FOR_DELIVERY',partner:'Sameer Khan',vehicle:'TVS iQube (MH-03-FP-9182)',lines:[_OrderLine(4,'Corporate Lunch Bowl','Paneer',1200),_OrderLine(4,'Fresh Lime Soda','',320)]),
  _AdminOrder(id:'#SFD-9038',customer:'Karan Johar',phone:'+919821055190',address:'Penthouse 3, Palm Court, Juhu Tara Rd.',total:1850,items:4,payment:'UPI',time:'14:12 (24m ago)',status:'READY_FOR_PICKUP',lines:[_OrderLine(1,'Truffle Feast Platter','Chef special',980),_OrderLine(1,'Mango Shake','',180),_OrderLine(2,'Crinkle Fries','',320)]),
  _AdminOrder(id:'#SFD-9037',customer:'Ishita Kapoor',phone:'+919810330221',address:'A-602, Emerald Heights, Bandra West.',total:760,items:3,payment:'UPI',time:'14:05 (31m ago)',status:'ASSIGNED',partner:'Vikram Joshi',vehicle:'Ola S1 Pro (MH-02-GA-5514)',lines:[_OrderLine(1,'Smoky Chicken Burger','',390),_OrderLine(1,'Fries','',120),_OrderLine(1,'Iced Tea','',90)]),
  _AdminOrder(id:'#SFD-9036',customer:'Rahul Menon',phone:'+919820881120',address:'Tower C 1804, Powai Lake View.',total:1120,items:4,payment:'Card',time:'13:58 (38m ago)',status:'PICKED_UP',partner:'Priya Nair',vehicle:'Ather 450X (MH-04-PL-3009)',lines:[_OrderLine(2,'Biryani Bowl','Extra raita',640),_OrderLine(2,'Mango Lassi','',180)]),
  _AdminOrder(id:'#SFD-9035',customer:'Meera Shah',phone:'+919811044902',address:'Flat 805, Sea Face Towers, Worli.',total:980,items:3,payment:'UPI',time:'13:51 (45m ago)',status:'DELIVERED',lines:[_OrderLine(1,'Paneer Bowl','',420),_OrderLine(1,'Garlic Bread','',180),_OrderLine(1,'Brownie','',140)]),
  _AdminOrder(id:'#SFD-9034',customer:'Kabir Singh',phone:'+919821772210',address:'Villa 12, Palm Springs, Andheri East.',total:670,items:2,payment:'Cash',time:'13:44 (52m ago)',status:'CANCELLED',lines:[_OrderLine(1,'Classic Burger','',280),_OrderLine(1,'Loaded Fries','',180)]),
  _AdminOrder(id:'#SFD-9033',customer:'Ananya Rao',phone:'+919769445510',address:'Office 1102, One BKC, Bandra East.',total:1540,items:6,payment:'Corporate',time:'13:38 (58m ago)',status:'ACCEPTED',lines:[_OrderLine(3,'Chicken Wrap','',720),_OrderLine(3,'Cold Coffee','',420)]),
];

String _orderFilter(String s){if(s=='PLACED')return 'PLACED';if(['ACCEPTED','PREPARING','READY_FOR_PICKUP','ASSIGNED','PICKED_UP'].contains(s))return 'PREP';if(s=='OUT_FOR_DELIVERY')return 'OUT';if(s=='DELIVERED')return 'DELIVERED';if(s=='DISPUTED')return 'DISPUTED';return s;}
String? _nextStatus(String s)=>const {'PLACED':'ACCEPTED','ACCEPTED':'PREPARING','PREPARING':'READY_FOR_PICKUP','READY_FOR_PICKUP':'ASSIGNED','ASSIGNED':'PICKED_UP','PICKED_UP':'OUT_FOR_DELIVERY','OUT_FOR_DELIVERY':'DELIVERED'}[s];
int _progressStep(String s){if(s=='PLACED')return 1;if(s=='ACCEPTED')return 2;if(s=='PREPARING')return 3;if(['READY_FOR_PICKUP','ASSIGNED','PICKED_UP','OUT_FOR_DELIVERY'].contains(s))return 4;if(s=='DELIVERED')return 5;return 1;}
String _prettyStatus(String? s)=>(s??'UNKNOWN').replaceAll('_',' ');
(Color,Color) _statusStyle(String s){if(['CANCELLED','DISPUTED','PREPARING'].contains(s))return(AdminDesignColors.errorSoft,AdminDesignColors.error);if(['OUT_FOR_DELIVERY','DELIVERED'].contains(s))return(AdminDesignColors.successSoft,AdminDesignColors.success);return(AdminDesignColors.warningSoft,AdminDesignColors.warning);}
