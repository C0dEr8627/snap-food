import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class RestaurantDashboardScreen extends StatelessWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 1024;
        return Row(children: [
          if (wide) const _Sidebar(),
          Expanded(child: Column(children: [
            _Header(wide: wide),
            Expanded(child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(wide ? 24 : 16, 20, wide ? 24 : 16, 32),
              child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: SnapFoodSpacing.desktopMaxContentWidth),
                child: const _DashboardContent(),
              )),
            )),
          ])),
        ]);
      })),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good afternoon, Mumbai Spice Kitchen 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          SizedBox(height: 5),
          Text('Here’s what’s happening with your restaurant today.', style: TextStyle(fontSize: 13, color: SnapFoodColors.onSurfaceVariant)),
        ])),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_today_outlined, size: 15), label: const Text('Today')),
      ]),
      const SizedBox(height: 20),
      const _Stats(),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, c) {
        if (c.maxWidth >= 900) return const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: _LiveOrders()), SizedBox(width: 16), Expanded(flex: 2, child: _Performance())]);
        return const Column(children: [_LiveOrders(), SizedBox(height: 16), _Performance()]);
      }),
      const SizedBox(height: 24),
      const _PopularItems(),
    ],
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();
  @override
  Widget build(BuildContext context) => Container(
    width: 224,
    decoration: const BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, border: Border(right: BorderSide(color: SnapFoodColors.softBorder))),
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        CircleAvatar(radius: 18, backgroundColor: SnapFoodColors.secondary, child: Icon(Icons.restaurant, color: Colors.white, size: 19)),
        SizedBox(width: 9), Text('SNAP FOOD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 32),
      const _Nav(label: 'Dashboard', icon: Icons.dashboard_rounded, selected: true),
      const _Nav(label: 'Live Orders / KDS', icon: Icons.receipt_long_rounded),
      const _Nav(label: 'Menu & Stock', icon: Icons.restaurant_menu_rounded),
      const _Nav(label: 'Analytics', icon: Icons.analytics_outlined),
      const _Nav(label: 'Settings', icon: Icons.settings_outlined),
      const Spacer(),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: SnapFoodColors.softYellow, borderRadius: BorderRadius.circular(SnapFoodRadii.md)), child: const Row(children: [Icon(Icons.support_agent, size: 20, color: SnapFoodColors.primary), SizedBox(width: 8), Expanded(child: Text('Partner support\nAvailable 24×7', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))])),
    ]),
  );
}

class _Nav extends StatelessWidget {
  const _Nav({required this.label, required this.icon, this.selected = false});
  final String label; final IconData icon; final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(color: selected ? SnapFoodColors.softYellow : Colors.transparent, borderRadius: BorderRadius.circular(SnapFoodRadii.md)),
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
    child: Row(children: [Icon(icon, size: 19, color: selected ? SnapFoodColors.primary : SnapFoodColors.onSurfaceVariant), const SizedBox(width: 10), Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600))]),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.wide});
  final bool wide;
  @override
  Widget build(BuildContext context) => Material(
    color: SnapFoodColors.surfaceContainerLowest, elevation: 1,
    child: Padding(padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 16, vertical: 12), child: Row(children: [
      if (!wide) IconButton(onPressed: () {}, icon: const Icon(Icons.menu_rounded)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Restaurant Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        if (wide) const Text('Manage today’s orders and kitchen activity', style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: SnapFoodColors.softYellow, borderRadius: BorderRadius.circular(SnapFoodRadii.full)), child: const Row(children: [Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)), SizedBox(width: 6), Text('OPEN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))])),
      const SizedBox(width: 8), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
      const CircleAvatar(radius: 18, backgroundColor: SnapFoodColors.primaryContainer, child: Icon(Icons.storefront, size: 19, color: SnapFoodColors.warmBlack)),
    ])),
  );
}

class _Stats extends StatelessWidget {
  const _Stats();
  static const data = [('Today’s Orders','48','+12.5%',Icons.receipt_long_rounded),('Revenue','₹18,420','+8.2%',Icons.currency_rupee_rounded),('Avg. Prep Time','18 min','-3 min',Icons.timer_outlined),('Rating','4.8','+0.1',Icons.star_rounded)];
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final n = c.maxWidth >= 850 ? 4 : c.maxWidth >= 520 ? 2 : 1; final w = (c.maxWidth - (n - 1) * 12) / n;
    return Wrap(spacing: 12, runSpacing: 12, children: [for (final d in data) SizedBox(width: w, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg), border: Border.all(color: SnapFoodColors.softBorder)), child: Row(children: [Container(width: 42, height: 42, decoration: const BoxDecoration(color: SnapFoodColors.softYellow, shape: BoxShape.circle), child: Icon(d.$4, size: 21, color: SnapFoodColors.warmBlack)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.$1, style: const TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant)), const SizedBox(height: 3), Text(d.$2, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(d.$3, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)))]))])))]);
  });
}

class _LiveOrders extends StatelessWidget {
  const _LiveOrders();
  static const data = [('SF10248','2 items • ₹630','Preparing'),('SF10247','3 items • ₹540','Ready for pickup'),('SF10246','1 item • ₹320','New order')];
  @override
  Widget build(BuildContext context) => _Panel(title: 'Live Orders', trailing: TextButton(onPressed: () {}, child: const Text('View KDS')), child: Column(children: [for (var i=0; i<data.length; i++) ...[if (i>0) const Divider(height: 1), Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: SnapFoodColors.surfaceContainer, borderRadius: BorderRadius.circular(SnapFoodRadii.md)), child: const Icon(Icons.receipt_long, size: 19, color: SnapFoodColors.secondary)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('#${data[i].$1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(data[i].$2, style: TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: SnapFoodColors.softYellow, borderRadius: BorderRadius.circular(SnapFoodRadii.full)), child: Text(data[i].$3, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)))])]]));
  );
}

class _Performance extends StatelessWidget {
  const _Performance();
  @override
  Widget build(BuildContext context) => _Panel(title: 'Today’s Performance', trailing: const Icon(Icons.more_horiz, size: 20, color: SnapFoodColors.outline), child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 18), child: Column(children: [SizedBox(height: 118, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [for (final h in <double>[46.0, 64.0, 90.0, 72.0, 104.0, 82.0]) Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 18, height: h, decoration: const BoxDecoration(color: SnapFoodColors.primaryContainer, borderRadius: BorderRadius.vertical(top: Radius.circular(5)))), const SizedBox(height: 5), const Text('•', style: TextStyle(fontSize: 8, color: SnapFoodColors.outline))]))])), const SizedBox(height: 8), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Orders by hour', style: TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant)), Text('48 total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))])])));
  );
}

class _PopularItems extends StatelessWidget {
  const _PopularItems();
  static const items = [('Chicken Tikka Dum Biryani','128 sold','₹320',Icons.rice_bowl),('Butter Chicken & 2 Naan','96 sold','₹280',Icons.lunch_dining),('Paneer Butter Masala','74 sold','₹240',Icons.restaurant_menu)];
  @override
  Widget build(BuildContext context) => _Panel(title: 'Popular Items', trailing: TextButton(onPressed: () {}, child: const Text('Manage Menu')), child: Column(children: [for (var i=0; i<items.length; i++) ...[if(i>0) const Divider(height: 1), Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [Container(width:44,height:44,decoration:BoxDecoration(color:i==0?SnapFoodColors.softRed:SnapFoodColors.surfaceContainer,borderRadius:BorderRadius.circular(SnapFoodRadii.md)),child:Icon(items[i].$4,size:21,color:SnapFoodColors.secondary)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(items[i].$1,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),const SizedBox(height:2),Text(items[i].$2,style:const TextStyle(fontSize:10,color:SnapFoodColors.onSurfaceVariant))])),Text(items[i].$3,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900))])]]));
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});
  final String title; final Widget child; final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(decoration:BoxDecoration(color:SnapFoodColors.surfaceContainerLowest,borderRadius:BorderRadius.circular(SnapFoodRadii.lg),border:Border.all(color:SnapFoodColors.softBorder)),clipBehavior:Clip.antiAlias,child:Column(children:[Padding(padding:const EdgeInsets.fromLTRB(16,14,10,9),child:Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800))),if(trailing!=null) trailing!]),),child]));
}