part of '../main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final api = const _DashboardApi();
  _DashboardData? data;
  bool loading = true;
  String? error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final value = await api.load();
      if (!mounted) return;
      setState(() { data = value; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { loading = false; error = e.toString().replaceFirst('Bad state: ', ''); });
    }
  }

  @override Widget build(BuildContext context) {
    if (data == null && loading) return const _DashboardLoading();
    if (data == null) return _DashboardError(message: error ?? 'Unable to load dashboard.', onRetry: _load);
    final d = data!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _DashboardHeader(loading: loading, onRefresh: _load),
      const SizedBox(height: AdminSpacing.lg),
      if (error != null) ...[_DashboardWarning(error!), const SizedBox(height: AdminSpacing.md)],
      LayoutBuilder(builder: (context, c) {
        final n = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 700 ? 2 : 1;
        return GridView.count(
          crossAxisCount: n, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AdminSpacing.md, mainAxisSpacing: AdminSpacing.md,
          childAspectRatio: n == 4 ? 1.45 : n == 2 ? 1.9 : 3,
          children: [
            _KpiCard("TODAY'S REVENUE", _money(d.todayRevenue), d.deliveredToday.toString() + ' delivered orders', HugeIcons.strokeRoundedWallet01, AdminColors.amberSoft),
            _KpiCard('ACTIVE ORDERS', d.activeOrders.toString(), d.placed.toString() + ' new • ' + d.preparing.toString() + ' preparing • ' + d.out.toString() + ' out', HugeIcons.strokeRoundedShoppingBag01, AdminColors.redSoft, alert: d.placed > 0),
            _KpiCard('DELIVERY FLEET', d.onlinePartners.toString(), d.approvedPartners.toString() + ' approved • ' + d.pendingPartners.toString() + ' pending approval', HugeIcons.strokeRoundedMotorbike02, AdminColors.greenSoft),
            _KpiCard('WEEKLY REVENUE', _money(d.weekRevenue), d.weekOrders.toString() + ' orders • ' + _change(d.weekRevenue, d.previousWeekRevenue) + ' vs previous week', HugeIcons.strokeRoundedTimer02, AdminColors.blueSoft),
          ],
        );
      }),
      const SizedBox(height: AdminSpacing.lg),
      _AttentionCard(items: d.attention),
      const SizedBox(height: AdminSpacing.lg),
      LayoutBuilder(builder: (context, c) => c.maxWidth >= 980
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 7, child: _SalesCard(points: d.sales)),
              const SizedBox(width: AdminSpacing.lg),
              Expanded(flex: 4, child: _FlowCard(data: d)),
            ])
          : Column(children: [_SalesCard(points: d.sales), const SizedBox(height: AdminSpacing.lg), _FlowCard(data: d)])),
      const SizedBox(height: AdminSpacing.lg),
      _RecentOrdersCard(orders: d.recentOrders),
    ]);
  }
}

class _DashboardApi {
  const _DashboardApi();
  String get base {
    final v = apiBaseUrl.trim();
    return (v.isEmpty ? 'https://api.snapfoodd.in/api/v1' : v).replaceFirst(RegExp(r'/$'), '');
  }
  Map<String,String> get headers => {
    'Accept':'application/json', 'Content-Type':'application/json',
    if ((html.window.localStorage['snap_foodd_admin_token'] ?? '').isNotEmpty)
      'Authorization':'Bearer ' + (html.window.localStorage['snap_foodd_admin_token'] ?? ''),
  };
  Future<_DashboardData> load() async {
    if (!headers.containsKey('Authorization')) throw StateError('No authenticated admin session. Please sign in again.');
    final r = await http.get(Uri.parse(base + '/admin/dashboard'), headers: headers);
    if (r.statusCode < 200 || r.statusCode >= 300) throw StateError('Dashboard request failed (' + r.statusCode.toString() + ').');
    final body = jsonDecode(r.body);
    if (body is! Map || body['data'] is! Map) throw StateError('Dashboard response was empty or invalid.');
    return _DashboardData.fromJson(Map<String,dynamic>.from(body['data'] as Map));
  }
}

class _DashboardData {
  const _DashboardData({required this.todayRevenue,required this.deliveredToday,required this.activeOrders,required this.placed,required this.preparing,required this.out,required this.weekRevenue,required this.weekOrders,required this.previousWeekRevenue,required this.onlinePartners,required this.approvedPartners,required this.pendingPartners,required this.sales,required this.attention,required this.recentOrders});
  factory _DashboardData.fromJson(Map<String,dynamic> j) {
    final k = j['kpis'] is Map ? Map<String,dynamic>.from(j['kpis'] as Map) : <String,dynamic>{};
    final s = j['status_counts'] is Map ? Map<String,dynamic>.from(j['status_counts'] as Map) : <String,dynamic>{};
    final sales = j['daily_sales'] is List ? j['daily_sales'] as List : const [];
    final attention = j['attention'] is List ? j['attention'] as List : const [];
    final orders = j['recent_orders'] is List ? j['recent_orders'] as List : const [];
    return _DashboardData(
      todayRevenue:_toDouble(k['today_revenue']), deliveredToday:_toInt(k['delivered_today']), activeOrders:_toInt(k['active_orders']),
      placed:_toInt(s['PLACED']), preparing:_toInt(s['ACCEPTED'])+_toInt(s['PREPARING'])+_toInt(s['READY_FOR_PICKUP'])+_toInt(s['ASSIGNED'])+_toInt(s['PICKED_UP']), out:_toInt(s['OUT_FOR_DELIVERY']),
      weekRevenue:_toDouble(k['week_revenue']), weekOrders:_toInt(k['week_orders']), previousWeekRevenue:_toDouble(k['previous_week_revenue']),
      onlinePartners:_toInt(k['online_partners']), approvedPartners:_toInt(k['approved_partners']), pendingPartners:_toInt(k['pending_partner_approvals']),
      sales:sales.whereType<Map>().map((x)=>_SalesPoint.fromJson(Map<String,dynamic>.from(x))).toList(),
      attention:attention.whereType<Map>().map((x)=>_Attention.fromJson(Map<String,dynamic>.from(x))).toList(),
      recentOrders:orders.whereType<Map>().map((x)=>_RecentOrder.fromJson(Map<String,dynamic>.from(x))).toList(),
    );
  }
  final double todayRevenue,weekRevenue,previousWeekRevenue;
  final int deliveredToday,activeOrders,placed,preparing,out,weekOrders,onlinePartners,approvedPartners,pendingPartners;
  final List<_SalesPoint> sales; final List<_Attention> attention; final List<_RecentOrder> recentOrders;
}

class _SalesPoint {
  const _SalesPoint({required this.label,required this.revenue,required this.orders});
  factory _SalesPoint.fromJson(Map<String,dynamic> j)=>_SalesPoint(label:j['label']?.toString()??'',revenue:_toDouble(j['revenue']),orders:_toInt(j['orders']));
  final String label; final double revenue; final int orders;
}
class _Attention {
  const _Attention({required this.severity,required this.count,required this.title,required this.detail});
  factory _Attention.fromJson(Map<String,dynamic> j)=>_Attention(severity:j['severity']?.toString()??'medium',count:_toInt(j['count']),title:j['title']?.toString()??'Operational update',detail:j['detail']?.toString()??'');
  final String severity,title,detail; final int count;
}
class _RecentOrder {
  const _RecentOrder({required this.id,required this.customer,required this.total,required this.status,required this.payment,this.partner});
  factory _RecentOrder.fromJson(Map<String,dynamic> j){
    final c=j['customer'] is Map?Map<String,dynamic>.from(j['customer'] as Map):<String,dynamic>{};
    final a=j['assignment'] is Map?Map<String,dynamic>.from(j['assignment'] as Map):<String,dynamic>{};
    final p=a['delivery_partner'] is Map?Map<String,dynamic>.from(a['delivery_partner'] as Map):<String,dynamic>{};
    return _RecentOrder(id:(j['id']??'').toString(),customer:c['name']?.toString()??'Customer',total:_toDouble(j['total']),status:j['status']?.toString()??'UNKNOWN',payment:j['payment_method']?.toString()??'UNKNOWN',partner:p['name']?.toString());
  }
  final String id,customer,status,payment; final double total; final String? partner;
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.loading,required this.onRefresh});
  final bool loading; final VoidCallback onRefresh;
  @override Widget build(BuildContext context)=>Row(children:[
    const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Good morning, Admin',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900,letterSpacing:-.3)),
      SizedBox(height:4),Text('A live view of Snap Foodd orders, revenue and delivery operations.',style:TextStyle(fontSize:12.5,color:AdminColors.muted)),
    ])),
    if(loading)const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)),const SizedBox(width:10),
    shad.OutlineButton(onPressed:loading?null:onRefresh,child:Row(mainAxisSize:MainAxisSize.min,children:[const AdminIcon(HugeIcons.strokeRoundedRefresh,size:16),const SizedBox(width:6),const Text('Refresh',style:TextStyle(fontSize:12,fontWeight:FontWeight.w800))])),
  ]);
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.label,this.value,this.detail,this.icon,this.tone,{this.alert=false});
  final String label,value,detail; final AdminIconData icon; final Color tone; final bool alert;
  @override Widget build(BuildContext context)=>AdminCard(child:Padding(padding:const EdgeInsets.all(17),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900,letterSpacing:.55,color:AdminColors.muted))),Container(width:32,height:32,decoration:BoxDecoration(color:tone,borderRadius:BorderRadius.circular(9)),child:AdminIcon(icon,size:17,color:AdminColors.ink))]),
    const SizedBox(height:12),Text(value,style:const TextStyle(fontSize:26,fontWeight:FontWeight.w900,height:1)),const SizedBox(height:7),
    Row(children:[if(alert)...[const _Dot(color:AdminColors.red),const SizedBox(width:5)],Expanded(child:Text(detail,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:11,color:alert?AdminColors.red:AdminColors.muted,fontWeight:alert?FontWeight.w800:FontWeight.w500)))]),
  ])));
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.items}); final List<_Attention> items;
  @override Widget build(BuildContext context)=>AdminCard(child:Padding(padding:const EdgeInsets.all(17),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const _Dot(color:AdminColors.red),const SizedBox(width:8),const Expanded(child:Text('Operations attention',style:TextStyle(fontSize:14,fontWeight:FontWeight.w900))),Text(items.where((x)=>x.severity=='high').fold<int>(0,(n,x)=>n+x.count).toString()+' high priority',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AdminColors.muted))]),
    const SizedBox(height:12),
    LayoutBuilder(builder:(context,c){final n=c.maxWidth>=900?3:c.maxWidth>=600?2:1;return GridView.count(crossAxisCount:n,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:n==1?4.2:2.8,children:items.map((x)=>_AttentionTile(item:x)).toList());}),
  ])));
}
class _AttentionTile extends StatelessWidget {
  const _AttentionTile({required this.item}); final _Attention item;
  @override Widget build(BuildContext context){
    final good=item.severity=='good', high=item.severity=='high';
    final bg=good?AdminColors.greenSoft:high?AdminColors.redSoft:AdminColors.amberSoft;
    final fg=good?AdminColors.green:high?AdminColors.red:AdminColors.amber;
    return Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(10)),child:Row(children:[
      Container(width:30,height:30,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8)),child:AdminIcon(good?HugeIcons.strokeRoundedCheckmarkCircle01:high?HugeIcons.strokeRoundedAlert02:HugeIcons.strokeRoundedTask01,size:16,color:fg)),
      const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(item.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(item.detail,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,color:AdminColors.muted))])),
      if(item.count>0)...[const SizedBox(width:8),Text(item.count.toString(),style:TextStyle(fontSize:15,fontWeight:FontWeight.w900,color:fg))],
    ]));
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.points}); final List<_SalesPoint> points;
  @override Widget build(BuildContext context){
    final max=points.fold<double>(0,(m,x)=>x.revenue>m?x.revenue:m);
    return AdminCard(child:Padding(padding:const EdgeInsets.fromLTRB(19,18,19,16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Revenue & order volume',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900)),SizedBox(height:3),Text('Delivered revenue across the last seven days',style:TextStyle(fontSize:11,color:AdminColors.muted))])),Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:6),decoration:BoxDecoration(color:AdminColors.canvas,borderRadius:BorderRadius.circular(7)),child:const Text('Live data',style:TextStyle(fontSize:11,fontWeight:FontWeight.w800)))]),
      const SizedBox(height:18),
      if(points.every((x)=>x.revenue==0))const SizedBox(height:205,child:Center(child:Text('No delivered revenue recorded yet.',style:TextStyle(fontSize:12,color:AdminColors.muted))))
      else SizedBox(height:205,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:points.map((p){
        final factor=max==0?0:p.revenue/max;
        return Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:5),child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[
          Text(p.revenue==0?'—':_compactMoney(p.revenue),style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:AdminColors.muted)),const SizedBox(height:5),
          Expanded(child:Align(alignment:Alignment.bottomCenter,child:FractionallySizedBox(heightFactor:factor.clamp(.05,1.0),widthFactor:.62,child:Container(decoration:BoxDecoration(color:AdminColors.amber,borderRadius:BorderRadius.circular(6)))))),
          const SizedBox(height:7),Text(p.label,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:AdminColors.muted)),Text(p.orders.toString(),style:const TextStyle(fontSize:10)),
        ])));
      }).toList())),
      const SizedBox(height:8),Row(children:[const _Dot(color:AdminColors.amber),const SizedBox(width:6),const Text('Delivered revenue',style:TextStyle(fontSize:11,color:AdminColors.muted)),const Spacer(),Text(points.fold<int>(0,(n,x)=>n+x.orders).toString()+' orders',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AdminColors.muted))]),
    ])));
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({required this.data}); final _DashboardData data;
  Widget _item(String name,int count,AdminIconData icon,int total)=>Padding(padding:const EdgeInsets.only(bottom:13),child:Row(children:[
    Container(width:36,height:36,decoration:BoxDecoration(color:AdminColors.amberSoft,borderRadius:BorderRadius.circular(9)),child:AdminIcon(icon,size:17,color:AdminColors.amber)),const SizedBox(width:9),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Text(name,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900))),Text(count.toString(),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900))]),
      const SizedBox(height:6),ClipRRect(borderRadius:BorderRadius.circular(5),child:LinearProgressIndicator(value:(count/(total==0?1:total)).clamp(0.0,1.0),minHeight:5,backgroundColor:AdminColors.canvas,valueColor:const AlwaysStoppedAnimation<Color>(AdminColors.amber))),
    ])),
  ]));
  @override Widget build(BuildContext context)=>AdminCard(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Expanded(child:Text('Live order flow',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900))),const Text('NOW',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,color:AdminColors.green))]),
    const SizedBox(height:5),Text(data.activeOrders.toString()+' orders currently in flight',style:const TextStyle(fontSize:11,color:AdminColors.muted)),const SizedBox(height:14),
    _item('New orders',data.placed,HugeIcons.strokeRoundedShoppingBag01,data.activeOrders),
    _item('Preparing',data.preparing,HugeIcons.strokeRoundedTask01,data.activeOrders),
    _item('Out for delivery',data.out,HugeIcons.strokeRoundedDeliveryTruck01,data.activeOrders),
    const Divider(height:8),Row(children:[const AdminIcon(HugeIcons.strokeRoundedMotorbike02,size:17,color:AdminColors.green),const SizedBox(width:8),Expanded(child:Text(data.onlinePartners.toString()+' partners available now',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800))),if(data.pendingPartners>0)Text(data.pendingPartners.toString()+' pending',style:const TextStyle(fontSize:11,color:AdminColors.red,fontWeight:FontWeight.w800))]),
  ])));
}

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({required this.orders}); final List<_RecentOrder> orders;
  @override Widget build(BuildContext context)=>AdminCard(child:Padding(padding:const EdgeInsets.fromLTRB(18,17,18,7),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Recent orders',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900)),SizedBox(height:3),Text('Latest activity across the Snap Foodd order lifecycle',style:TextStyle(fontSize:11,color:AdminColors.muted))])),Text(orders.length.toString()+' shown',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AdminColors.muted))]),
    const SizedBox(height:8),
    if(orders.isEmpty)const Padding(padding:EdgeInsets.all(24),child:Center(child:Text('No orders yet.',style:TextStyle(fontSize:12,color:AdminColors.muted))))
    else ...orders.map((o){final s=_dashboardStatusStyle(o.status);return Container(padding:const EdgeInsets.symmetric(vertical:11),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:AdminColors.line))),child:Row(children:[
      Container(width:36,height:36,decoration:BoxDecoration(color:AdminColors.canvas,borderRadius:BorderRadius.circular(9)),child:const AdminIcon(HugeIcons.strokeRoundedShoppingBag01,size:17,color:AdminColors.ink)),const SizedBox(width:9),
      Expanded(flex:3,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('#'+o.id,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900)),const SizedBox(height:2),Text(o.customer,style:const TextStyle(fontSize:11,color:AdminColors.muted))])),
      Expanded(flex:2,child:Text(o.partner??'Unassigned',maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,color:AdminColors.muted))),
      Expanded(flex:2,child:Text(o.payment,style:const TextStyle(fontSize:11,color:AdminColors.muted))),
      Expanded(flex:2,child:Text(_money(o.total),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900))),
      Container(constraints:const BoxConstraints(minWidth:82),alignment:Alignment.center,padding:const EdgeInsets.symmetric(horizontal:7,vertical:5),decoration:BoxDecoration(color:s.$1,borderRadius:BorderRadius.circular(20)),child:Text(o.status.replaceAll('_',' '),style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,color:s.$2))),
    ]);}),
  ])));
}

class _DashboardWarning extends StatelessWidget {
  const _DashboardWarning(this.message); final String message;
  @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:AdminColors.redSoft,borderRadius:BorderRadius.circular(9)),child:Row(children:[const AdminIcon(HugeIcons.strokeRoundedAlert02,size:16,color:AdminColors.red),const SizedBox(width:8),Expanded(child:Text(message,style:const TextStyle(fontSize:11,color:AdminColors.red,fontWeight:FontWeight.w700)))]));
}
class _Dot extends StatelessWidget {
  const _Dot({required this.color}); final Color color;
  @override Widget build(BuildContext context)=>Container(width:7,height:7,decoration:BoxDecoration(color:color,shape:BoxShape.circle));
}
class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();
  @override Widget build(BuildContext context)=>Column(children:[const LinearProgressIndicator(minHeight:3),const SizedBox(height:18),LayoutBuilder(builder:(context,c){final n=c.maxWidth>=1100?4:c.maxWidth>=700?2:1;return GridView.count(crossAxisCount:n,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:AdminSpacing.md,mainAxisSpacing:AdminSpacing.md,childAspectRatio:1.6,children:List.generate(n*2,(_)=>AdminCard(child:const SizedBox())));})]);
}
class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message,required this.onRetry}); final String message; final VoidCallback onRetry;
  @override Widget build(BuildContext context)=>AdminCard(child:Padding(padding:const EdgeInsets.all(32),child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const AdminIcon(HugeIcons.strokeRoundedAlert02,size:34,color:AdminColors.red),const SizedBox(height:10),const Text('Dashboard unavailable',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text(message,textAlign:TextAlign.center,style:const TextStyle(fontSize:11,color:AdminColors.muted)),const SizedBox(height:14),shad.OutlineButton(onPressed:onRetry,child:const Text('Try again'))]))));
}

String _money(double v)=>'₹'+v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+$)'),(m)=>',');
String _compactMoney(double v)=>v>=100000?'₹'+(v/100000).toStringAsFixed(1)+'L':v>=1000?'₹'+(v/1000).toStringAsFixed(0)+'k':'₹'+v.toStringAsFixed(0);
String _change(double current,double previous){if(previous==0)return current==0?'0%':'new';final p=(current-previous)/previous*100;return (p>=0?'+':'')+p.toStringAsFixed(1)+'%';}
(Color,Color) _dashboardStatusStyle(String s){if(s=='DELIVERED')return(AdminColors.greenSoft,AdminColors.green);if(s=='CANCELLED')return(AdminColors.redSoft,AdminColors.red);if(s=='OUT_FOR_DELIVERY')return(AdminColors.blueSoft,AdminColors.blue);if(s=='PLACED')return(AdminColors.amberSoft,AdminColors.amber);return(AdminColors.canvas,AdminColors.ink);}
