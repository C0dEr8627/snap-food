part of '../main.dart';

class OrdersPage extends StatefulWidget{
  const OrdersPage({super.key, this.searchQuery = ''});
  final String searchQuery;
  @override State<OrdersPage> createState()=>_OrdersPageState();
}

class _AdminOrder {
  const _AdminOrder({required this.id,required this.customer,required this.phone,required this.address,required this.total,required this.items,required this.payment,required this.time,required this.status,required this.lines,this.partner,this.vehicle});
  factory _AdminOrder.fromJson(Map<String,dynamic> j){
    final customer=j['customer'] is Map?Map<String,dynamic>.from(j['customer'] as Map):<String,dynamic>{};
    final address=j['delivery_address_snapshot'] is Map?Map<String,dynamic>.from(j['delivery_address_snapshot'] as Map):<String,dynamic>{};
    final assignment=j['assignment'] is Map?Map<String,dynamic>.from(j['assignment'] as Map):<String,dynamic>{};
    final dp=assignment['delivery_partner'] is Map?Map<String,dynamic>.from(assignment['delivery_partner'] as Map):<String,dynamic>{};
    final dpUser=dp['user'] is Map?Map<String,dynamic>.from(dp['user'] as Map):<String,dynamic>{};
    final rawItems=j['items'] is List?j['items'] as List:const [];
    final lines=rawItems.whereType<Map>().map((x)=>_OrderLine(_toInt(x['quantity']),x['product_name']?.toString()??'Item','',_toDouble(x['line_total']))).toList();
    return _AdminOrder(
      id:(j['id']??'').toString(),customer:customer['name']?.toString()??'Customer',
      phone:customer['phone']?.toString()??'',address:[address['line1'],address['line2'],address['city'],address['state']].whereType<String>().where((v)=>v.isNotEmpty).join(', '),
      total:_toDouble(j['total']),items:lines.fold(0,(n,x)=>n+x.qty),payment:j['payment_method']?.toString()??'UNKNOWN',
      time:j['created_at']?.toString()??'',status:j['status']?.toString()??'PLACED',lines:lines,
      partner:dpUser['name']?.toString());
  }
  final String id,customer,phone,address,payment,time,status;
  final double total;
  final int items;
  final List<_OrderLine> lines;
  final String? partner,vehicle;
  _AdminOrder withStatus(String value)=>_AdminOrder(id:id,customer:customer,phone:phone,address:address,total:total,items:items,payment:payment,time:time,status:value,lines:lines,partner:partner,vehicle:vehicle);
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

  Future<void> status(String id,String next)async{
    if(!configured)throw StateError('No authenticated admin session. Please sign in again.');
    final r=await http.patch(
      Uri.parse(base+'/admin/orders/'+Uri.encodeComponent(id)+'/status'),
      headers:headers,
      body:jsonEncode({'status':next}),
    );
    if(r.statusCode<200||r.statusCode>=300)throw StateError('Order status update failed ('+r.statusCode.toString()+').');
  }

  Future<String?> invoice(String id)async{
    if(!configured)throw StateError('No authenticated admin session. Please sign in again.');
    final r=await http.get(Uri.parse(base+'/admin/orders/'+Uri.encodeComponent(id)+'/invoice'),headers:headers);
    if(r.statusCode<200||r.statusCode>=300)throw StateError('Invoice request failed ('+r.statusCode.toString()+').');
    final body=jsonDecode(r.body);
    return body is Map&&body['data'] is Map?body['data']['file_reference']?.toString():null;
  }
}

class _OrdersPageState extends State<OrdersPage>{
  final api=const _AdminOrderApi(),search=TextEditingController();
  final orders=< _AdminOrder>[];
  String filter='ALL';String? selectedId;int page=1;bool busy=false;bool loading=true;String? loadError;
  @override void initState(){super.initState();search.text=widget.searchQuery;search.addListener(()=>setState(()=>page=1));_loadOrders();}
  @override void didUpdateWidget(covariant OrdersPage oldWidget){super.didUpdateWidget(oldWidget);if(oldWidget.searchQuery!=widget.searchQuery && search.text!=widget.searchQuery){search.text=widget.searchQuery;_loadOrders();}}
  Future<void> _loadOrders() async {
    setState(()=>loading=true);
    try {
      final live=await api.list(search:search.text,status:filter);
      if(!mounted)return;
      setState(() { orders..clear()..addAll(live); selectedId=live.isNotEmpty?live.first.id:null; loading=false; loadError=null; });
    } catch(e) {
      if(!mounted)return;
      setState(() { loading=false; loadError=e.toString(); });
    }
  }
  @override void dispose(){search.dispose();super.dispose();}
  List<_AdminOrder> get filtered=>orders.where((o){final q=search.text.trim().toLowerCase();final qok=q.isEmpty||o.id.toLowerCase().contains(q)||o.customer.toLowerCase().contains(q)||o.phone.contains(q);return qok&&(filter=='ALL'||_orderFilter(o.status)==filter);}).toList();
  _AdminOrder? get selected{for(final o in orders){if(o.id==selectedId)return o;}return filtered.isEmpty?null:filtered.first;}
  int count(String f)=>orders.where((o)=>f=='ALL'||_orderFilter(o.status)==f).length;

  @override Widget build(BuildContext context){
    if(loading) return const Center(
      child: Padding(
        padding: EdgeInsets.all(AdminSpacing.xl),
        child: SfLoadingState(
          title: 'Loading orders',
          message: 'Fetching the latest order queue and delivery assignment data.',
        ),
      ),
    );
    if(loadError!=null) return Padding(
      padding: const EdgeInsets.all(AdminSpacing.xl),
      child: SfErrorState(
        title: 'Unable to load orders',
        message: loadError!,
        onRetry: _loadOrders,
      ),
    );
    final list=filtered,order=selected,desktop=MediaQuery.sizeOf(context).width>=1120;
    final pages=list.isEmpty?1:((list.length-1)~/10)+1;if(page>pages)page=pages;
    final queue=_OrderQueue(orders:list,selectedId:order?.id,page:page,onPage:(v)=>setState(()=>page=v),onSelect:(v)=>setState(()=>selectedId=v));
    final details=_OrderDetails(order:order,busy:busy,apiConfigured:api.configured,onAdvance:order==null?null:()=>advance(order),onInvoice:order==null?null:()=>invoice(order),onCancel:order==null?null:()=>cancel(order));
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _OrdersHeader(apiConfigured:api.configured,onExport:()=>exportCsv(list)),
      const SizedBox(height:AdminSpacing.xxl),
      _OrderFilters(controller:search,active:filter,count:count,onChange:(v)=>setState((){filter=v;page=1;if(filtered.isNotEmpty)selectedId=filtered.first.id;})),
      const SizedBox(height:AdminSpacing.lg),
      if(list.isEmpty)_EmptyOrders(onClear:()=>setState((){search.clear();filter='ALL';page=1;}))
      else if(desktop)Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(flex:62,child:queue),const SizedBox(width:AdminSpacing.lg),Expanded(flex:38,child:details)])
      else Column(children:[queue,const SizedBox(height:AdminSpacing.lg),details]),
    ]);
  }

  Future<void> advance(_AdminOrder order)async{
    final next=_nextStatus(order.status);if(next==null){_notice(context,'No valid next transition for '+order.status);return;}
    setState(()=>busy=true);try{await api.status(order.id,next);final i=orders.indexWhere((o)=>o.id==order.id);if(i>=0)orders[i]=order.withStatus(next);if(mounted)setState(()=>busy=false);if(mounted)SfFeedback.showSuccess(context,order.id+' advanced to '+next);}catch(e){if(mounted){setState(()=>busy=false);SfFeedback.showError(context,api.configured?e.toString():'No authenticated admin session is available for this status transition.');}}
  }
  Future<void> invoice(_AdminOrder order)async{
    setState(()=>busy=true);try{final ref=await api.invoice(order.id);if(mounted)setState(()=>busy=false);if(mounted)SfFeedback.showInfo(context,ref==null?'Invoice endpoint returned no file reference.':'Invoice reference: '+ref);}catch(e){if(mounted){setState(()=>busy=false);SfFeedback.showError(context,e.toString());}}
  }
  Future<void> cancel(_AdminOrder order)async{
    final ok=await SfConfirmDialog.show(context,title:'Cancel order?',message:'Confirm cancellation for '+order.id+'.',confirmLabel:'Confirm cancel',destructive:true);if(!ok)return;
    setState(()=>busy=true);try{await api.status(order.id,'CANCELLED');final i=orders.indexWhere((o)=>o.id==order.id);if(i>=0)orders[i]=order.withStatus('CANCELLED');if(mounted)setState(()=>busy=false);if(mounted)SfFeedback.showSuccess(context,order.id+' cancelled.');}catch(e){if(mounted){setState(()=>busy=false);_notice(context,api.configured?e.toString():'Preview Data Mode: configure API_TOKEN for cancellation requests.');}}
  }
  void exportCsv(List<_AdminOrder> list){
    final rows=<List<String>>[['Order ID','Customer','Phone','Address','Items','Total','Payment','Time','Status'],...list.map((o)=>[o.id,o.customer,o.phone,o.address,o.items.toString(),o.total.toStringAsFixed(2),o.payment,o.time,o.status])];
    String cell(String s)=>'"'+s.replaceAll('"','""')+'"';final csv=rows.map((r)=>r.map(cell).join(',')).join('\n');
    final blob=html.Blob([utf8.encode(csv)],'text/csv;charset=utf-8');final url=html.Url.createObjectUrlFromBlob(blob);final a=html.AnchorElement(href:url)..download='snap-foodd-orders.csv'..style.display='none';html.document.body?.children.add(a);a.click();a.remove();html.Url.revokeObjectUrl(url);
  }
}

class _OrdersHeader extends StatelessWidget{
  const _OrdersHeader({required this.apiConfigured,required this.onExport});
  final bool apiConfigured;final VoidCallback onExport;
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(c,box){
    final title=const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('LIVE ORDERS',style:AdminTypography.pageTitle),
      Text('MANAGEMENT',style:AdminTypography.pageTitle),
      SizedBox(height:8),Text('Operational order queue with live status updates, delivery assignment and billing access.',style:AdminTypography.small),
    ]);
    final actions=Wrap(spacing:8,runSpacing:8,children:[
      Container(padding:const EdgeInsets.symmetric(horizontal:AdminSpacing.sm,vertical:AdminSpacing.xs),decoration:BoxDecoration(color:apiConfigured?AdminDesignColors.successSoft:AdminDesignColors.errorSoft,borderRadius:BorderRadius.circular(AdminRadii.control),border:Border.all(color:AdminDesignColors.border)),child:Row(mainAxisSize:MainAxisSize.min,children:[_StatusDot(color:apiConfigured?AdminDesignColors.success:AdminDesignColors.error),const SizedBox(width:AdminSpacing.xs),Text(apiConfigured?'API connected':'Authentication required',style:AdminTypography.small.copyWith(fontWeight: FontWeight.w700))])),
      shad.OutlineButton(onPressed:onExport,leading:const AdminIcon(HugeIcons.strokeRoundedDownload01,size:16),child:const Text('Export CSV')),
    ]);
    return box.maxWidth<760?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[title,const SizedBox(height:14),actions]):Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Expanded(child:title),const SizedBox(width:AdminSpacing.lg),Flexible(child:actions)]);
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
  const _OrderQueue({required this.orders,required this.selectedId,required this.page,required this.onPage,required this.onSelect});
  final List<_AdminOrder> orders;final String? selectedId;final int page;final ValueChanged<int> onPage;final ValueChanged<String> onSelect;
  @override Widget build(BuildContext context){
    final start=(page-1)*10,visible=orders.skip(start).take(10).toList(),pages=orders.isEmpty?1:((orders.length-1)~/10)+1;
    return AdminCard(child:Padding(padding:const EdgeInsets.fromLTRB(14,14,14,10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('ORDER QUEUE',style:AdminTypography.small.copyWith(fontWeight: FontWeight.w700)),const SizedBox(height:3)])),Text('Showing '+visible.length.toString()+' of '+orders.length.toString()+' active tickets',style:AdminTypography.small),const SizedBox(width:AdminSpacing.sm),Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:7),decoration:BoxDecoration(color:AdminDesignColors.canvas,borderRadius:BorderRadius.circular(8),border:Border.all(color:AdminDesignColors.border)),child:Row(children:[const AdminIcon(HugeIcons.strokeRoundedSortingUp,size:15,color:AdminDesignColors.secondaryText),const SizedBox(width:4),Text('Latest first',style: AdminTypography.small.copyWith(fontWeight: FontWeight.w600))]))]),
      const SizedBox(height:AdminSpacing.md),
      Scrollbar(
        thumbVisibility:true,
        child:SingleChildScrollView(
          scrollDirection:Axis.horizontal,
          child:ConstrainedBox(
            constraints:const BoxConstraints(minWidth:720),
            child:Column(children:[
              const _OrderTableHeader(),
              const Divider(height:1,color:AdminDesignColors.border),
              ...visible.map((o)=>_OrderRow(order:o,selected:o.id==selectedId,onTap:()=>onSelect(o.id))),
              const Divider(height:1,color:AdminDesignColors.border),
            ]),
          ),
        ),
      ),
      Row(children:[const Text('10 rows per page',style:AdminTypography.small),const Spacer(),Text((start+1).toString()+'–'+(start+visible.length).toString()+' of '+orders.length.toString(),style:AdminTypography.small.copyWith(fontWeight:FontWeight.w700)),shad.IconButton.ghost(onPressed:page>1?()=>onPage(page-1):null,icon:const AdminIcon(HugeIcons.strokeRoundedArrowLeft01,size:18)),shad.IconButton.ghost(onPressed:page<pages?()=>onPage(page+1):null,icon:const AdminIcon(HugeIcons.strokeRoundedArrowRight01,size:18))]),
    ])));
  }
}

class _OrderTableHeader extends StatelessWidget{
  const _OrderTableHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10,8,10,8),
    child: Row(children:[
      const SizedBox(width:30),
      Expanded(flex:13,child:Text('ORDER ID & TIME',style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w700))),
      Expanded(flex:17,child:Text('CUSTOMER & PHONE',style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w700))),
      Expanded(flex:20,child:Text('ADDRESS',style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w700))),
      Expanded(flex:12,child:Text('ITEMS / TOTAL',style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w700))),
      Expanded(flex:12,child:Text('STATUS',style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w700))),
    ]),
  );
}

class _OrderRow extends StatelessWidget{
  const _OrderRow({required this.order,required this.selected,required this.onTap});
  final _AdminOrder order;final bool selected;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>shad.Button.ghost(
    onPressed:onTap,
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      SizedBox(width:44,height:44,child:Center(child:shad.Checkbox(state:selected?shad.CheckboxState.checked:shad.CheckboxState.unchecked,onChanged:(_)=>onTap()))),
      Expanded(flex:13,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(order.id,style:AdminTypography.small.copyWith(fontWeight: FontWeight.w700)),const SizedBox(height:3),Text(order.time,style:AdminTypography.small)])),
      Expanded(flex:17,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(order.customer,maxLines:1,overflow:TextOverflow.ellipsis,style:AdminTypography.small.copyWith(fontWeight: FontWeight.w600)),const SizedBox(height:3),Text(order.phone,maxLines:1,overflow:TextOverflow.ellipsis,style:AdminTypography.small)])),
      Expanded(flex:20,child:Text(order.address,maxLines:2,overflow:TextOverflow.ellipsis,style:AdminTypography.small.copyWith(height:1.35))),
      Expanded(flex:12,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('₹'+order.total.toStringAsFixed(2),style:AdminTypography.small.copyWith(fontWeight: FontWeight.w700)),const SizedBox(height:3),Text(order.items.toString()+' items • '+order.payment,style:AdminTypography.small)])),
      Expanded(flex:12,child:Align(alignment:Alignment.topLeft,child:_OrderStatusBadge(order.status))),
    ]),
  ).sized(width:double.infinity);
}

class _OrderStatusBadge extends StatelessWidget{
  const _OrderStatusBadge(this.status);final String status;
  @override Widget build(BuildContext context){final s=_statusStyle(status);return Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:6),decoration:BoxDecoration(color:s.$1,borderRadius:BorderRadius.circular(7)),child:Row(mainAxisSize:MainAxisSize.min,children:[_StatusDot(color:s.$2),const SizedBox(width:5),Text(_prettyStatus(status),style:AdminTypography.small.copyWith(fontWeight:FontWeight.w700,color:s.$2))]));}
}

class _OrderDetails extends StatelessWidget{
  const _OrderDetails({required this.order,required this.busy,required this.apiConfigured,required this.onAdvance,required this.onInvoice,required this.onCancel});
  final _AdminOrder? order;final bool busy,apiConfigured;final VoidCallback? onAdvance,onInvoice,onCancel;
  @override Widget build(BuildContext context){
    final o=order;
    if(o==null){
      return AdminCard(child:Padding(padding:const EdgeInsets.all(30),child:Center(child:Text('Select an order to view details',style:AdminTypography.body.copyWith(fontWeight:FontWeight.w700)))));
    }
    final next=_nextStatus(o.status);
    return AdminCard(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(o.id,style:AdminTypography.sectionTitle),const SizedBox(height:AdminSpacing.xs),Row(children:[_OrderStatusBadge(o.status),const SizedBox(width:AdminSpacing.xs),if(apiConfigured)Text('LIVE ACTIVE',style:AdminTypography.small.copyWith(color:AdminDesignColors.success,fontWeight:FontWeight.w700))]))])]),
      const SizedBox(height:5),Text('Placed at '+o.time,style:AdminTypography.small),const SizedBox(height:AdminSpacing.lg),
      LayoutBuilder(builder:(context,c)=>c.maxWidth>=500?Row(children:[Expanded(child:_PersonCard('CUSTOMER',o.customer,[o.phone,o.address],HugeIcons.strokeRoundedUser)),const SizedBox(width:AdminSpacing.sm),Expanded(child:_PersonCard('DELIVERY PARTNER',o.partner??'Unassigned',[o.vehicle??'Awaiting partner assignment'],HugeIcons.strokeRoundedDeliveryTruck01,badge:o.partner==null?'UNASSIGNED':'ON DUTY'))]):Column(children:[_PersonCard('CUSTOMER',o.customer,[o.phone,o.address],HugeIcons.strokeRoundedUser),const SizedBox(height:10),_PersonCard('DELIVERY PARTNER',o.partner??'Unassigned',[o.vehicle??'Awaiting partner assignment'],HugeIcons.strokeRoundedDeliveryTruck01,badge:o.partner==null?'UNASSIGNED':'ON DUTY')])),
      const SizedBox(height:AdminSpacing.md),
      _Panel(title:'ORDER ITEMS',trailing:o.items.toString()+' items',child:Column(children:o.lines.map((l)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Container(width:24,height:24,alignment:Alignment.center,decoration:BoxDecoration(color:AdminDesignColors.warningSoft,borderRadius:BorderRadius.circular(6)),child:Text(l.qty.toString()+'x',style:AdminTypography.small.copyWith(fontWeight:FontWeight.w700))),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(l.name,style:AdminTypography.small.copyWith(fontWeight:FontWeight.w600)),if(l.modifier.isNotEmpty)Text(l.modifier,style:AdminTypography.small)])),Text('₹'+l.price.toStringAsFixed(2),style:AdminTypography.small.copyWith(fontWeight:FontWeight.w700))]))).toList())),
      const SizedBox(height:AdminSpacing.md),
      _Bill(o),
      const SizedBox(height:AdminSpacing.md),
      shad.PrimaryButton(onPressed:busy||next==null?null:onAdvance,leading:const AdminIcon(HugeIcons.strokeRoundedMotorbike02,size:18),child:Text(busy?'Updating…':'Advance to '+_prettyStatus(next??o.status))).sized(width:double.infinity,height:46),
      const SizedBox(height:AdminSpacing.sm),
      Wrap(spacing:7,runSpacing:7,children:[
        shad.OutlineButton(onPressed:onInvoice,leading:const AdminIcon(HugeIcons.strokeRoundedInvoice01,size:15),child:const Text('Tax Invoice')),
        shad.OutlineButton(onPressed:onCancel,leading:const AdminIcon(HugeIcons.strokeRoundedCancel01,size:15,color:AdminDesignColors.error),child:const Text('Cancel order')),
      ]),
    ])));
  }
}
class _Panel extends StatelessWidget{
  const _Panel({required this.title,required this.child,required this.trailing});final String title,trailing;final Widget child;
  @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AdminDesignColors.canvas,borderRadius:BorderRadius.circular(11),border:Border.all(color:AdminDesignColors.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(title,style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w700,letterSpacing:.5))),Text(trailing,style:AdminTypography.caption.copyWith(fontWeight:FontWeight.w700))]),const SizedBox(height:9),child]));
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
