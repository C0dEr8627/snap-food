import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

part 'pages/dashboard_page.dart';
part 'pages/orders_page.dart';
part 'pages/catalogue_page.dart';
part 'pages/partners_page.dart';
part 'pages/invoices_page.dart';

void main() => runApp(const SnapFooddAdminApp());

abstract final class AdminColors {
  static const ink = Color(0xFF201B17);
  static const muted = Color(0xFF4E4634);
  static const canvas = Color(0xFFFFF8F5);
  static const surface = Colors.white;
  static const line = Color(0xFFD1C5AE);
  static const yellow = Color(0xFFE4B935);
  static const yellowDark = Color(0xFF755B00);
  static const red = Color(0xFFD54126);
  static const redSoft = Color(0xFFFBE3DC);
  static const green = Color(0xFF2D7A4B);
  static const greenSoft = Color(0xFFE7F5EC);
  static const blue = Color(0xFF3867D6);
  static const blueSoft = Color(0xFFEAF0FF);
  static const amberSoft = Color(0xFFFFF4CE);
}

class SnapFooddAdminApp extends StatelessWidget {
  const SnapFooddAdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Snap Foodd Admin',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AdminColors.canvas,
      colorScheme: ColorScheme.fromSeed(seedColor: AdminColors.yellowDark),
      fontFamily: 'Plus Jakarta Sans',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 40, height: 1.2, fontWeight: FontWeight.w800, color: AdminColors.ink, letterSpacing: -.8),
        headlineSmall: TextStyle(fontSize: 26, height: 1.25, fontWeight: FontWeight.w800, color: AdminColors.ink),
        titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AdminColors.ink),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AdminColors.ink),
        bodyMedium: TextStyle(fontSize: 13, color: AdminColors.ink, height: 1.45),
        bodySmall: TextStyle(fontSize: 11, color: AdminColors.muted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AdminColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AdminColors.line)),
      ),
    ),
    home: const AdminShell(),
  );
}

enum AdminSection { dashboard, orders, catalogue, partners, invoices }

extension on AdminSection {
  String get label => switch (this) {
    AdminSection.dashboard => 'Dashboard',
    AdminSection.orders => 'Orders',
    AdminSection.catalogue => 'Catalogue',
    AdminSection.partners => 'Delivery partners',
    AdminSection.invoices => 'Invoices & billing',
  };
  IconData get icon => switch (this) {
    AdminSection.dashboard => Icons.space_dashboard_rounded,
    AdminSection.orders => Icons.receipt_long_rounded,
    AdminSection.catalogue => Icons.inventory_2_rounded,
    AdminSection.partners => Icons.delivery_dining_rounded,
    AdminSection.invoices => Icons.receipt_rounded,
  };
  String get subtitle => switch (this) {
    AdminSection.dashboard => 'A clear view of today’s business and operations.',
    AdminSection.orders => 'Track every order from checkout to delivery.',
    AdminSection.catalogue => 'Manage menu items, categories and availability.',
    AdminSection.partners => 'Review delivery partners and KYC status.',
    AdminSection.invoices => 'Keep order billing and invoice access organized.',
  };
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminSection section = AdminSection.dashboard;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1050;
    final tablet = width >= 720;
    return Scaffold(
      drawer: desktop ? null : Drawer(
        width: tablet ? 300 : width * .84,
        child: _Sidebar(selected: section, onSelect: _select, compact: true),
      ),
      body: Row(children: [
        if (desktop) SizedBox(width: 248, child: _Sidebar(selected: section, onSelect: _select)),
        Expanded(child: Column(children: [
          _Header(desktop: desktop),
          Expanded(child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(desktop ? 24 : 16, 24, desktop ? 24 : 16, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (!desktop) Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(children: [
                      Builder(builder: (context) => IconButton.filledTonal(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu_rounded),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: Text(section.label, style: Theme.of(context).textTheme.headlineSmall)),
                    ]),
                  ),
                  _PageHeading(section: section, desktop: desktop),
                  const SizedBox(height: 24),
                  switch (section) {
                    AdminSection.dashboard => const DashboardPage(),
                    AdminSection.orders => const OrdersPage(),
                    AdminSection.catalogue => const CataloguePage(),
                    AdminSection.partners => const PartnersPage(),
                    AdminSection.invoices => const InvoicesPage(),
                  },
                  const SizedBox(height: 28),
                  const Center(child: Text('Snap Foodd Admin  •  Preview data  •  Laravel API integration pending', style: TextStyle(fontSize: 10, color: AdminColors.muted))),
                ]),
              ),
            ),
          ))),
        ])),
      ]),
    );
  }

  void _select(AdminSection value) {
    setState(() => section = value);
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect, this.compact = false});
  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 22 : 24, 24, 20, 22),
            child: const Row(
              children: [
                _BrandMark(),
                SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Snap Foodd', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AdminColors.ink)),
                  SizedBox(height: 2),
                  Text('ADMIN PORTAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AdminColors.muted)),
                ])),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.line)),
            child: const Row(children: [
              _StatusDot(color: AdminColors.red),
              SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('IN-BLR-01', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AdminColors.ink)),
                SizedBox(height: 2),
                Text('Preview Data Mode', style: TextStyle(fontSize: 9.5, color: AdminColors.muted)),
              ])),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 18, 9),
            child: Align(alignment: Alignment.centerLeft, child: Text('NAVIGATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: AdminColors.muted))),
          ),
          ...AdminSection.values.map((item) {
            final active = item == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => onSelect(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                  decoration: BoxDecoration(color: active ? AdminColors.amberSoft : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                  child: Row(children: [
                    Icon(item.icon, size: 18, color: active ? AdminColors.yellowDark : AdminColors.muted),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item.label, style: TextStyle(fontSize: 12.5, fontWeight: active ? FontWeight.w900 : FontWeight.w700, color: AdminColors.ink))),
                    if (active) const Icon(Icons.chevron_right_rounded, size: 16, color: AdminColors.yellowDark),
                  ]),
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Flutter Engine', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AdminColors.muted)),
              const SizedBox(height: 4),
              const Text('api.snapfoodd.in/v1', style: TextStyle(fontSize: 9.5, color: AdminColors.ink, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(7), border: Border.all(color: AdminColors.line)),
                child: const Text('v3.22 Web', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AdminColors.muted)),
              ),
            ]),
          ),
        ],
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 42, height: 42,
    decoration: BoxDecoration(color: AdminColors.yellow, borderRadius: BorderRadius.circular(12)),
    child: const Icon(Icons.restaurant_rounded, color: AdminColors.ink, size: 23),
  );
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _Header extends StatelessWidget {
  const _Header({required this.desktop});
  final bool desktop;

  @override
  Widget build(BuildContext context) => Container(
    height: desktop ? 78 : 64,
    padding: EdgeInsets.symmetric(horizontal: desktop ? 24 : 16),
    decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AdminColors.line))),
    child: Row(children: [
      if (desktop)
        Expanded(
          flex: 3,
          child: Container(
            height: 42,
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(11), border: Border.all(color: AdminColors.line)),
            child: const Row(children: [
              Icon(Icons.search_rounded, size: 19, color: AdminColors.muted),
              SizedBox(width: 9),
              Expanded(child: Text('Search orders, delivery partners, GST invoices...', style: TextStyle(fontSize: 11, color: AdminColors.muted))),
            ]),
          ),
        )
      else
        const Expanded(child: Text('Snap Foodd Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
      if (desktop) const SizedBox(width: 16),
      if (desktop)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(color: AdminColors.greenSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xFFCBE8D6))),
          child: const Row(children: [
            _StatusDot(color: AdminColors.green),
            SizedBox(width: 7),
            Text('api.snapfoodd.in/v1', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AdminColors.ink)),
            SizedBox(width: 7),
            Text('• Live Connected', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AdminColors.green)),
          ]),
        ),
      const SizedBox(width: 10),
      IconButton(tooltip: 'Notifications', onPressed: () => _notice(context, 'No new notifications in preview mode.'), icon: const Icon(Icons.notifications_none_rounded, size: 21, color: AdminColors.ink)),
      const SizedBox(width: 2),
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AdminColors.ink, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: const Text('SA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
      if (desktop) ...[
        const SizedBox(width: 9),
        const Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Super Admin', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
          SizedBox(height: 2),
          Text('HQ Control', style: TextStyle(fontSize: 9, color: AdminColors.muted)),
        ]),
        const SizedBox(width: 8),
        IconButton(tooltip: 'Logout', onPressed: null, icon: Icon(Icons.logout_rounded, size: 18, color: AdminColors.muted)),
      ],
    ]),
  );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.section, required this.desktop});
  final AdminSection section;
  final bool desktop;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (desktop) Text(section.label, style: Theme.of(context).textTheme.headlineLarge),
      if (desktop) const SizedBox(height: 5),
      Text(section.subtitle, style: const TextStyle(fontSize: 12.5, color: AdminColors.muted)),
    ])),
    if (desktop) FilledButton.icon(
      onPressed: () => _notice(context, section == AdminSection.catalogue ? 'Product creation will connect to the Laravel API.' : 'This action will connect to the Laravel API.'),
      icon: const Icon(Icons.add_rounded, size: 17),
      label: Text(section == AdminSection.catalogue ? 'Add product' : 'Quick action'),
      style: FilledButton.styleFrom(backgroundColor: AdminColors.ink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ),
  ]);
}

void _notice(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));



class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AdminColors.greenSoft, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.cloud_done_outlined, size: 18, color: AdminColors.green)),
        const SizedBox(width: 11),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Laravel API v1 Connected', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
          SizedBox(height: 2),
          Text('https://api.snapfoodd.in/api/v1', style: TextStyle(fontSize: 9.5, color: AdminColors.muted)),
          SizedBox(height: 2),
          Text('Demo / Preview Data Mode Active (Phase 1 Baseline • Flutter Web Engine v3.22)', style: TextStyle(fontSize: 9.5, color: AdminColors.muted)),
        ])),
        if (MediaQuery.sizeOf(context).width >= 650) ...[
          const Text('Ping: 34ms', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AdminColors.muted)),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _notice(context, 'Sync state is ready for the live API connection.'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), side: const BorderSide(color: AdminColors.line)),
            child: const Text('Sync State', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
          ),
        ],
      ]),
    ),
  );
}

class _RevenueKpi extends StatelessWidget {
  const _RevenueKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: "TODAY'S REVENUE", value: '₹1,42,850', secondary: '+14.8% vs last week',
    footer: 'Settled Orders: 382    •    AOV: ₹374', icon: Icons.account_balance_wallet_outlined, iconTone: AdminColors.amberSoft,
  );
}

class _ActiveOrdersKpi extends StatelessWidget {
  const _ActiveOrdersKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: 'ACTIVE ORDERS', value: '64', secondary: 'In-flight',
    footer: '18 New   •   26 Kitchen   •   20 Out', icon: Icons.local_mall_outlined, iconTone: AdminColors.redSoft, progress: .72,
  );
}

class _FleetKpi extends StatelessWidget {
  const _FleetKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: 'FLEET STATUS', value: '42', secondary: 'Partners Online',
    footer: 'Zone: Koramangala – HSR   •   36 on Trip', icon: Icons.two_wheeler_outlined, iconTone: AdminColors.greenSoft,
    progress: .85, progressLabel: '85% Utilized    •    6 Available',
  );
}

class _SlaKpi extends StatelessWidget {
  const _SlaKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: 'AVG SLA DELIVERY', value: '24.2 mins', secondary: 'Target: < 30 mins (Optimal)',
    footer: 'Prep SLA: 12.4m    •    Transit: 11.8m', icon: Icons.timer_outlined, iconTone: AdminColors.blueSoft,
  );
}

class _DashboardKpi extends StatelessWidget {
  const _DashboardKpi({required this.label, required this.value, required this.secondary, required this.footer, required this.icon, required this.iconTone, this.progress, this.progressLabel});
  final String label, value, secondary, footer;
  final IconData icon;
  final Color iconTone;
  final double? progress;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: .5, color: AdminColors.muted))),
          Container(width: 31, height: 31, decoration: BoxDecoration(color: iconTone, borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 16, color: AdminColors.ink)),
        ]),
        const SizedBox(height: 11),
        Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, height: 1)),
        const SizedBox(height: 7),
        Text(secondary, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AdminColors.green)),
        if (progress != null) ...[
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: AdminColors.canvas, color: AdminColors.yellow)),
          const SizedBox(height: 4),
          Text(progressLabel ?? '', style: const TextStyle(fontSize: 8.5, color: AdminColors.muted)),
        ],
        const Spacer(),
        Text(footer, style: const TextStyle(fontSize: 8.5, color: AdminColors.muted, height: 1.25)),
      ]),
    ),
  );
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _StatusDot(color: AdminColors.red),
          const SizedBox(width: 8),
          const Expanded(child: Text('Immediate Attention Required', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: AdminColors.redSoft, borderRadius: BorderRadius.circular(8)), child: const Text('3 Priorities', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AdminColors.red))),
        ]),
        const SizedBox(height: 13),
        LayoutBuilder(builder: (context, c) {
          final count = c.maxWidth >= 900 ? 3 : c.maxWidth >= 600 ? 2 : 1;
          return GridView.count(
            crossAxisCount: count, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: count == 1 ? 3.8 : 2.6,
            children: const [
              _AttentionItem(title: '3 Orders Need Courier...', detail: 'DriverIdle > 8 mins HR...', action: 'Reassign', danger: true),
              _AttentionItem(title: '4 Pending Partner KYC Ap...', detail: 'Aadhaar & RC uploads verificat...', action: 'Verify'),
              _AttentionItem(title: '2 Low Stock Menu Items', detail: 'Dum Biryani (Truffle Feast), Pa...', action: 'Adjust'),
            ],
          );
        }),
      ]),
    ),
  );
}

class _AttentionItem extends StatelessWidget {
  const _AttentionItem({required this.title, required this.detail, required this.action, this.danger = false});
  final String title, detail, action;
  final bool danger;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: danger ? AdminColors.redSoft : AdminColors.canvas, borderRadius: BorderRadius.circular(10), border: Border.all(color: danger ? const Color(0xFFF0C8BE) : AdminColors.line)),
    child: Row(children: [
      Container(width: 30, height: 30, decoration: BoxDecoration(color: danger ? Colors.white : AdminColors.amberSoft, borderRadius: BorderRadius.circular(8)), child: Icon(danger ? Icons.priority_high_rounded : Icons.assignment_late_outlined, size: 15, color: danger ? AdminColors.red : AdminColors.yellowDark)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, color: AdminColors.muted)),
      ])),
      const SizedBox(width: 6),
      TextButton(
        onPressed: () => _notice(context, '$action flow will connect to the existing admin service.'),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: Text(action, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: danger ? AdminColors.red : AdminColors.yellowDark)),
      ),
    ]),
  );
}

class _WeeklySalesCard extends StatelessWidget {
  const _WeeklySalesCard();
  static const values = <double>[112000, 128000, 119000, 143000, 154000, 172000, 158000];
  static const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Weekly Sales & Dispatch Volume', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('Monday through Sunday aggregate revenue with peak order milestones', style: TextStyle(fontSize: 9.5, color: AdminColors.muted)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: AdminColors.greenSoft, borderRadius: BorderRadius.circular(8)), child: const Text('Live Cluster', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AdminColors.green))),
        ]),
        const SizedBox(height: 14),
        const Row(children: [
          _MetricLabel(label: 'Peak Target', value: '₹1,80,000 / day'),
          SizedBox(width: 18),
          _MetricLabel(label: 'Week-to-Date', value: '₹9,84,320'),
          Spacer(),
          _ChartToggle(label: 'Gross (₹)', active: true),
          SizedBox(width: 5),
          _ChartToggle(label: 'Order Count'),
        ]),
        const SizedBox(height: 12),
        SizedBox(height: 225, child: CustomPaint(painter: _SalesChartPainter(values: values, labels: labels), child: const SizedBox.expand())),
        const SizedBox(height: 7),
        const Wrap(alignment: WrapAlignment.end, spacing: 12, runSpacing: 5, children: [
          _LegendDot(color: AdminColors.yellow, label: 'Regular Weekday'),
          _LegendDot(color: AdminColors.red, label: 'Current Date'),
          _LegendDot(color: AdminColors.yellowDark, label: 'Peak Dinner Rush'),
          Text('Detailed Analytics →', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AdminColors.yellowDark)),
        ]),
      ]),
    ),
  );
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 8.5, color: AdminColors.muted)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
  ]);
}

class _ChartToggle extends StatelessWidget {
  const _ChartToggle({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: active ? AdminColors.ink : AdminColors.canvas, borderRadius: BorderRadius.circular(7)),
    child: Text(label, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: active ? Colors.white : AdminColors.muted)),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 8, color: AdminColors.muted)),
  ]);
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter({required this.values, required this.labels});
  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0, right = 10.0, top = 18.0, bottom = 31.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    const maxValue = 190000.0;
    final gridPaint = Paint()..color = AdminColors.line..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const gridLabels = ['180k', '120k', '60k', '0'];
    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      textPainter.text = TextSpan(text: gridLabels[i], style: const TextStyle(fontSize: 8, color: AdminColors.muted));
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 5));
    }
    final slot = chartWidth / values.length;
    for (var i = 0; i < values.length; i++) {
      final barHeight = chartHeight * values[i] / maxValue;
      final x = left + slot * i + slot * .22;
      final w = slot * .56;
      final y = top + chartHeight - barHeight;
      final color = i == 3 ? AdminColors.red : i == 5 ? AdminColors.yellowDark : AdminColors.yellow;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, barHeight), const Radius.circular(5)), Paint()..color = color);
      textPainter.text = TextSpan(text: '₹${(values[i] / 1000).round()}k', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: i == 3 ? AdminColors.red : AdminColors.ink));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (w - textPainter.width) / 2, y - 14));
      textPainter.text = TextSpan(text: labels[i], style: TextStyle(fontSize: 8.5, fontWeight: i == 3 ? FontWeight.w900 : FontWeight.w700, color: i == 3 ? AdminColors.red : AdminColors.muted));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (w - textPainter.width) / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) => oldDelegate.values != values;
}

class _KitchenPulseCard extends StatelessWidget {
  const _KitchenPulseCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Kitchen Hubs Pulse', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(7)), child: const Text('12 Cloud Kitchens', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 12),
        const _KitchenItem(name: 'Biryani Central HQ', tickets: '24 live tickets', prep: '9 min avg prep', capacity: .98, icon: Icons.rice_bowl_rounded),
        const SizedBox(height: 9),
        const _KitchenItem(name: 'Burger Shack 5th Blo...', tickets: '16 live tickets', prep: '6 min avg prep', capacity: .72, icon: Icons.lunch_dining_rounded),
        const SizedBox(height: 9),
        const _KitchenItem(name: 'Crust & Co Pizzeria', tickets: '11 live tickets', prep: '14 min avg prep', capacity: .64, icon: Icons.local_pizza_rounded),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.flash_on_rounded, size: 17, color: AdminColors.yellowDark),
            const SizedBox(width: 8),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Express Auto-Dispatch', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900)),
              SizedBox(height: 2),
              Text('Batching window: 90 secs', style: TextStyle(fontSize: 8.5, color: AdminColors.muted)),
            ])),
            const Switch(value: true, onChanged: null, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ]),
        ),
      ]),
    ),
  );
}

class _KitchenItem extends StatelessWidget {
  const _KitchenItem({required this.name, required this.tickets, required this.prep, required this.capacity, required this.icon});
  final String name, tickets, prep;
  final double capacity;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 18, color: AdminColors.yellowDark)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('$tickets • $prep', style: const TextStyle(fontSize: 8, color: AdminColors.muted)),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: capacity, minHeight: 4, backgroundColor: AdminColors.canvas, color: capacity > .9 ? AdminColors.red : AdminColors.yellowDark)),
      ])),
      const SizedBox(width: 8),
      Text('${(capacity * 100).round()}% cap', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AdminColors.muted)),
    ]),
  );
}

class _LiveOrdersCard extends StatelessWidget {
  const _LiveOrdersCard();

  static const orders = [
    ['#SFD-4091', 'Aditi Sharma', '+9198451••••', '2× Paneer Butter Masala, 4× Butter Naan', 'Spice: Medium • Extra cutleries', '₹640.00', 'NEW', 'SnapPay UPI', 'Just now', '12:44 PM'],
    ['#SFD-4092', 'Vikram Malhotra', '', '1× Special Chicken Dum Biryani, 1× Raita', 'Truffle Feast • Cook time: 11 mins left', '₹429.00', 'PREPARING', 'SnapPay UPI', '4 mins ago', '12:40 PM'],
    ['#SFD-4093', 'Rohan Nair', '', '2× Classic Cheese Smash Burgers, 1× Peri Peri Fries', 'Rider: Rajesh K. (ID #RID-8821)', '₹519.00', 'OUT FOR DELIVERY', 'Cash on Del.', '14 mins ago', '12:30 PM'],
    ['#SFD-4090', 'Pooja Venkatesh', '', '1× Margherita Sourdough, 1× Choco Lava Cake', 'Delivered in 21.4 mins • 5-Star Rating', '₹485.00', 'DELIVERED', 'SnapPay UPI', '28 mins ago', '12:16 PM'],
  ];

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _StatusDot(color: AdminColors.red),
          const SizedBox(width: 8),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recent Live Order Stream', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('Real-time telemetry updated via websocket /api/v1/orders/stream', style: TextStyle(fontSize: 9, color: AdminColors.muted)),
          ])),
          IconButton(tooltip: 'Export', onPressed: () => _notice(context, 'Export will use the existing orders service when connected.'), icon: const Icon(Icons.download_outlined, size: 19)),
        ]),
        const SizedBox(height: 13),
        const SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _OrderTab(text: 'All Orders (64)', active: true), SizedBox(width: 6), _OrderTab(text: 'New (18)'), SizedBox(width: 6), _OrderTab(text: 'In Kitchen (26)'), SizedBox(width: 6), _OrderTab(text: 'Dispatched (20)'),
        ])),
        const SizedBox(height: 13),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AdminColors.muted),
            dataTextStyle: const TextStyle(fontSize: 9.5, color: AdminColors.ink),
            columnSpacing: 22, horizontalMargin: 4,
            columns: const [
              DataColumn(label: Text('ORDER ID')), DataColumn(label: Text('CUSTOMER')), DataColumn(label: Text('ITEMS SUMMARY')),
              DataColumn(label: Text('TOTAL AMOUNT')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('PAYMENT')),
              DataColumn(label: Text('TIMESTAMP')), DataColumn(label: Text('ACTIONS')),
            ],
            rows: orders.map((o) => DataRow(cells: [
              DataCell(Text(o[0], style: const TextStyle(fontWeight: FontWeight.w900))),
              DataCell(SizedBox(width: 125, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o[1], style: const TextStyle(fontWeight: FontWeight.w800)),
                if (o[2].isNotEmpty) Text(o[2], style: const TextStyle(fontSize: 8, color: AdminColors.muted)),
              ]))),
              DataCell(SizedBox(width: 260, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o[3], maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(o[4], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: AdminColors.muted)),
              ]))),
              DataCell(Text(o[5], style: const TextStyle(fontWeight: FontWeight.w900))),
              DataCell(_OrderStatus(o[6])),
              DataCell(Text(o[7])),
              DataCell(SizedBox(width: 80, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o[8], style: const TextStyle(fontWeight: FontWeight.w800)), Text(o[9], style: const TextStyle(fontSize: 8, color: AdminColors.muted)),
              ]))),
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                TextButton(onPressed: () => _notice(context, 'Action will connect to the existing order workflow.'), child: Text(o[6] == 'NEW' ? 'Accept' : o[6] == 'PREPARING' ? 'KDS View' : o[6] == 'OUT FOR DELIVERY' ? 'Track GPS' : 'Invoice', style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900))),
                TextButton(onPressed: () => _notice(context, 'Order detail route will use the existing navigation flow.'), child: const Text('View', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900))),
              ])),
            ])).toList(),
          ),
        ),
        const SizedBox(height: 7),
        const Row(children: [
          Expanded(child: Text('Showing 1 to 4 of 64 active telemetry records', style: TextStyle(fontSize: 8.5, color: AdminColors.muted))),
          _PageButton(label: 'Previous'), SizedBox(width: 4), _PageButton(label: '1', active: true), SizedBox(width: 4), _PageButton(label: '2'), SizedBox(width: 4), _PageButton(label: '3'), SizedBox(width: 4), _PageButton(label: 'Next'),
        ]),
      ]),
    ),
  );
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({required this.text, this.active = false});
  final String text;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: active ? AdminColors.ink : AdminColors.canvas, borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? AdminColors.ink : AdminColors.line)),
    child: Text(text, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: active ? Colors.white : AdminColors.muted)),
  );
}

class _OrderStatus extends StatelessWidget {
  const _OrderStatus(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final Color bg = switch (status) {
      'NEW' => AdminColors.redSoft,
      'PREPARING' => AdminColors.amberSoft,
      'OUT FOR DELIVERY' => AdminColors.yellow,
      _ => AdminColors.greenSoft,
    };
    final Color fg = status == 'NEW' ? AdminColors.red : status == 'OUT FOR DELIVERY' ? AdminColors.ink : status == 'DELIVERED' ? AdminColors.green : AdminColors.yellowDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: fg)),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: active ? AdminColors.yellow : Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: active ? AdminColors.yellow : AdminColors.line)),
    child: Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
  );
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.title, required this.value, required this.delta, required this.icon, required this.tone});
  final String title, value, delta;
  final IconData icon;
  final Color tone;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
    Container(width: 43, height: 43, decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 20, color: AdminColors.ink)),
    const SizedBox(width: 13),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(title, style: const TextStyle(fontSize: 11, color: AdminColors.muted, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
    ])),
    Text(delta, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AdminColors.green)),
  ])));
}

class _SalesCard extends StatelessWidget {
  const _SalesCard();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(21), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Sales overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        SizedBox(height: 3),
        Text('Weekly order volume · preview data', style: TextStyle(fontSize: 10.5, color: AdminColors.muted)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(9)), child: const Text('This week', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
    ]),
    const SizedBox(height: 25),
    SizedBox(height: 182, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: const [
      _ChartBar(day: 'MON', h: .42), _ChartBar(day: 'TUE', h: .60), _ChartBar(day: 'WED', h: .51), _ChartBar(day: 'THU', h: .78), _ChartBar(day: 'FRI', h: .65), _ChartBar(day: 'SAT', h: .92, active: true), _ChartBar(day: 'SUN', h: .73),
    ])),
  ])));
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.day, required this.h, this.active = false});
  final String day; final double h; final bool active;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
    Expanded(child: Align(alignment: Alignment.bottomCenter, child: FractionallySizedBox(heightFactor: h, child: Container(width: 24, decoration: BoxDecoration(color: active ? AdminColors.red : AdminColors.yellow, borderRadius: BorderRadius.circular(7)))))),
    const SizedBox(height: 9),
    Text(day, style: TextStyle(fontSize: 8.5, fontWeight: active ? FontWeight.w900 : FontWeight.w600, color: active ? AdminColors.red : AdminColors.muted)),
  ]));
}

class _OpsCard extends StatelessWidget {
  const _OpsCard();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(21), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Live operations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    const Text('Current order queue', style: TextStyle(fontSize: 10.5, color: AdminColors.muted)),
    const SizedBox(height: 20),
    const _Progress(label: 'New orders', value: '12', fraction: .78, color: AdminColors.red),
    const SizedBox(height: 17),
    const _Progress(label: 'Preparing', value: '24', fraction: .62, color: AdminColors.yellowDark),
    const SizedBox(height: 17),
    const _Progress(label: 'Ready for pickup', value: '09', fraction: .38, color: AdminColors.green),
    const SizedBox(height: 17),
    const _Progress(label: 'Out for delivery', value: '18', fraction: .52, color: AdminColors.blue),
  ])));
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.value, required this.fraction, required this.color});
  final String label, value; final double fraction; final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))), Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900))]),
    const SizedBox(height: 7),
    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: fraction, minHeight: 6, backgroundColor: AdminColors.canvas, color: color)),
  ]);
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, this.action});
  final String title; final String? action;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), if (action != null) TextButton(onPressed: () => _notice(context, 'Use the Orders page for the complete queue.'), child: Text(action!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.yellowDark)))]);
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable();

  static const rows = [
    ['#SF-1048', 'Aarav Mehta', '₹840', '12:42 PM', 'Preparing'],
    ['#SF-1045', 'Ananya Rao', '₹980', '12:36 PM', 'Ready'],
    ['#SF-1041', 'Meera Shah', '₹1,560', '12:19 PM', 'Out for delivery'],
  ];

  @override
  Widget build(BuildContext context) => Card(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AdminColors.muted),
        dataTextStyle: const TextStyle(fontSize: 11.5, color: AdminColors.ink),
        columnSpacing: 30,
        columns: const [
          DataColumn(label: Text('ORDER')),
          DataColumn(label: Text('CUSTOMER')),
          DataColumn(label: Text('TOTAL')),
          DataColumn(label: Text('TIME')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('ACTION')),
        ],
        rows: rows.map((r) => DataRow(cells: [
          DataCell(Text(r[0], style: const TextStyle(fontWeight: FontWeight.w900))),
          DataCell(Text(r[1])),
          DataCell(Text(r[2], style: const TextStyle(fontWeight: FontWeight.w800))),
          DataCell(Text(r[3])),
          DataCell(_Pill(r[4])),
          DataCell(IconButton(onPressed: () => _notice(context, 'Order details will be connected to the Laravel API.'), icon: const Icon(Icons.chevron_right_rounded, size: 19))),
        ])).toList(),
      ),
    ),
  );
}


class _AdminOrder {
  const _AdminOrder({required this.id,required this.customer,required this.phone,required this.address,required this.total,required this.items,required this.payment,required this.time,required this.status,required this.lines,this.partner,this.vehicle});
  final String id,customer,phone,address,payment,time,status;
  final double total;
  final int items;
  final List<_OrderLine> lines;
  final String? partner,vehicle;
  _AdminOrder withStatus(String value)=>_AdminOrder(id:id,customer:customer,phone:phone,address:address,total:total,items:items,payment:payment,time:time,status:value,lines:lines,partner:partner,vehicle:vehicle);
}
class _OrderLine{const _OrderLine(this.qty,this.name,this.modifier,this.price);final int qty;final String name,modifier;final double price;}

class _AdminOrderApi{
  const _AdminOrderApi();
  String get base{final v=apiBaseUrl.trim();return (v.isEmpty?'https://api.snapfoodd.in/api/v1':v).replaceFirst(RegExp(r'/$'),'');}
  String get token=>const String.fromEnvironment('API_TOKEN');
  bool get configured=>token.isNotEmpty;
  Map<String,String> get headers=>{'Accept':'application/json','Content-Type':'application/json',if(configured)'Authorization':'Bearer '+token};
  Future<void> status(String id,String next)async{
    if(!configured)throw StateError('API_TOKEN is not configured for this preview build.');
    final r=await http.patch(Uri.parse(base+'/admin/orders/'+Uri.encodeComponent(id)+'/status'),headers:headers,body:jsonEncode({'status':next}));
    if(r.statusCode<200||r.statusCode>=300)throw StateError('Order status update failed ('+r.statusCode.toString()+').');
  }
  Future<String?> invoice(String id)async{
    if(!configured)return null;
    final r=await http.get(Uri.parse(base+'/admin/orders/'+Uri.encodeComponent(id)+'/invoice'),headers:headers);
    if(r.statusCode<200||r.statusCode>=300)throw StateError('Invoice request failed ('+r.statusCode.toString()+').');
    final body=jsonDecode(r.body);
    return body is Map&&body['data'] is Map?body['data']['file_reference']?.toString():null;
  }
}


class _OrdersPageState extends State<OrdersPage>{
  final api=const _AdminOrderApi(),search=TextEditingController();
  final orders=List<_AdminOrder>.from(_previewOrders);
  String filter='ALL';String? selectedId;int page=1;bool busy=false;
  @override void initState(){super.initState();selectedId=orders.first.id;search.addListener(()=>setState(()=>page=1));}
  @override void dispose(){search.dispose();super.dispose();}
  List<_AdminOrder> get filtered=>orders.where((o){final q=search.text.trim().toLowerCase();final qok=q.isEmpty||o.id.toLowerCase().contains(q)||o.customer.toLowerCase().contains(q)||o.phone.contains(q);return qok&&(filter=='ALL'||_orderFilter(o.status)==filter);}).toList();
  _AdminOrder? get selected{for(final o in orders){if(o.id==selectedId)return o;}return filtered.isEmpty?null:filtered.first;}
  int count(String f)=>orders.where((o)=>f=='ALL'||_orderFilter(o.status)==f).length;

  @override Widget build(BuildContext context){
    final list=filtered,order=selected,desktop=MediaQuery.sizeOf(context).width>=1120;
    final pages=list.isEmpty?1:((list.length-1)~/10)+1;if(page>pages)page=pages;
    final queue=_OrderQueue(orders:list,selectedId:order?.id,page:page,onPage:(v)=>setState(()=>page=v),onSelect:(v)=>setState(()=>selectedId=v));
    final details=_OrderDetails(order:order,busy:busy,apiConfigured:api.configured,onAdvance:order==null?null:()=>advance(order),onInvoice:order==null?null:()=>invoice(order),onCancel:order==null?null:()=>cancel(order));
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _OrdersHeader(apiConfigured:api.configured,onExport:()=>exportCsv(list),onPos:()=>_notice(context,'Manual POS flow is not present in the existing admin application.')),
      const SizedBox(height:18),
      _OrderFilters(controller:search,active:filter,count:count,onChange:(v)=>setState((){filter=v;page=1;if(filtered.isNotEmpty)selectedId=filtered.first.id;})),
      const SizedBox(height:16),
      if(list.isEmpty)_EmptyOrders(onClear:()=>setState((){search.clear();filter='ALL';page=1;}))
      else if(desktop)Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(flex:62,child:queue),const SizedBox(width:16),Expanded(flex:38,child:details)])
      else Column(children:[queue,const SizedBox(height:16),details]),
    ]);
  }

  Future<void> advance(_AdminOrder order)async{
    final next=_nextStatus(order.status);if(next==null){_notice(context,'No valid next transition for '+order.status);return;}
    setState(()=>busy=true);try{await api.status(order.id,next);final i=orders.indexWhere((o)=>o.id==order.id);if(i>=0)orders[i]=order.withStatus(next);if(mounted)setState(()=>busy=false);if(mounted)_notice(context,order.id+' advanced to '+next);}catch(e){if(mounted){setState(()=>busy=false);_notice(context,api.configured?e.toString():'Preview Data Mode: configure API_TOKEN for real status transitions.');}}
  }
  Future<void> invoice(_AdminOrder order)async{
    setState(()=>busy=true);try{final ref=await api.invoice(order.id);if(mounted)setState(()=>busy=false);if(mounted)_notice(context,ref==null?'Invoice endpoint exists; configure API_TOKEN for a real request.':'Invoice reference: '+ref);}catch(e){if(mounted){setState(()=>busy=false);_notice(context,e.toString());}}
  }
  Future<void> cancel(_AdminOrder order)async{
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Cancel order?'),content:Text('Confirm cancellation for '+order.id+'.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Keep order')),FilledButton(style:FilledButton.styleFrom(backgroundColor:AdminColors.red),onPressed:()=>Navigator.pop(c,true),child:const Text('Confirm cancel'))]));if(ok!=true)return;
    setState(()=>busy=true);try{await api.status(order.id,'CANCELLED');final i=orders.indexWhere((o)=>o.id==order.id);if(i>=0)orders[i]=order.withStatus('CANCELLED');if(mounted)setState(()=>busy=false);if(mounted)_notice(context,order.id+' cancelled.');}catch(e){if(mounted){setState(()=>busy=false);_notice(context,api.configured?e.toString():'Preview Data Mode: configure API_TOKEN for cancellation requests.');}}
  }
  void exportCsv(List<_AdminOrder> list){
    final rows=<List<String>>[['Order ID','Customer','Phone','Address','Items','Total','Payment','Time','Status'],...list.map((o)=>[o.id,o.customer,o.phone,o.address,o.items.toString(),o.total.toStringAsFixed(2),o.payment,o.time,o.status])];
    String cell(String s)=>'"'+s.replaceAll('"','""')+'"';final csv=rows.map((r)=>r.map(cell).join(',')).join('\n');
    final blob=html.Blob([utf8.encode(csv)],'text/csv;charset=utf-8');final url=html.Url.createObjectUrlFromBlob(blob);final a=html.AnchorElement(href:url)..download='snap-foodd-orders.csv'..style.display='none';html.document.body?.children.add(a);a.click();a.remove();html.Url.revokeObjectUrl(url);
  }
}

class _OrdersHeader extends StatelessWidget{
  const _OrdersHeader({required this.apiConfigured,required this.onExport,required this.onPos});
  final bool apiConfigured;final VoidCallback onExport,onPos;
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(c,box){
    final title=const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('LIVE ORDERS',style:TextStyle(fontSize:31,height:1,fontWeight:FontWeight.w900,letterSpacing:-1)),
      Text('MANAGEMENT',style:TextStyle(fontSize:31,height:1.05,fontWeight:FontWeight.w900,letterSpacing:-1)),
      SizedBox(height:8),Text('Dual-channel Flutter engine view for real-time dispatch, kitchen KOT, and fleet tracking.',style:TextStyle(fontSize:11.5,color:AdminColors.muted)),
    ]);
    final actions=Wrap(spacing:8,runSpacing:8,children:[
      Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:10),decoration:BoxDecoration(color:apiConfigured?AdminColors.greenSoft:AdminColors.redSoft,borderRadius:BorderRadius.circular(10),border:Border.all(color:AdminColors.line)),child:Row(mainAxisSize:MainAxisSize.min,children:[_StatusDot(color:apiConfigured?AdminColors.green:AdminColors.red),const SizedBox(width:7),const Text('NODE IN-BLR-01',style:TextStyle(fontSize:9.5,fontWeight:FontWeight.w900))])),
      Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:10),decoration:BoxDecoration(color:AdminColors.amberSoft,borderRadius:BorderRadius.circular(10),border:Border.all(color:AdminColors.line)),child:const Row(mainAxisSize:MainAxisSize.min,children:[_StatusDot(color:AdminColors.yellowDark),SizedBox(width:7),Text('Auto Sync 5s Active',style:TextStyle(fontSize:9.5,fontWeight:FontWeight.w900))])),
      OutlinedButton.icon(onPressed:onExport,icon:const Icon(Icons.download_rounded,size:16),label:const Text('Export CSV'),style:OutlinedButton.styleFrom(foregroundColor:AdminColors.ink,side:const BorderSide(color:AdminColors.line),shape:RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(10))))),
      FilledButton.icon(onPressed:onPos,icon:const Icon(Icons.point_of_sale_rounded,size:17),label:const Text('Manual POS Order'),style:FilledButton.styleFrom(backgroundColor:AdminColors.yellowDark,foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)))),
    ]);
    return box.maxWidth<760?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[title,const SizedBox(height:14),actions]):Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Expanded(child:title),const SizedBox(width:16),Flexible(child:actions)]);
  });
}

class _OrderFilters extends StatelessWidget{
  const _OrderFilters({required this.controller,required this.active,required this.count,required this.onChange});
  final TextEditingController controller;final String active;final int Function(String) count;final ValueChanged<String> onChange;
  static const data=[('ALL','All Orders'),('PLACED','Pending'),('PREP','Kitchen Prep'),('OUT','Out for Delivery'),('DELIVERED','Delivered'),('DISPUTED','Disputed')];
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[
    SizedBox(width:225,height:40,child:TextField(controller:controller,style:const TextStyle(fontSize:10.5),decoration:InputDecoration(hintText:'Search by Order ID',prefixIcon:const Icon(Icons.search_rounded,size:18),filled:true,fillColor:AdminColors.canvas,border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(9)),borderSide:BorderSide(color:AdminColors.line)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(9)),borderSide:BorderSide(color:AdminColors.line))))),
    const SizedBox(width:10),...data.map((d)=>Padding(padding:const EdgeInsets.only(right:7),child:_FilterChip(label:d.$2,value:d.$1,active:active==d.$1,count:count(d.$1),onTap:()=>onChange(d.$1)))),
  ])));
}

class _FilterChip extends StatelessWidget{
  const _FilterChip({required this.label,required this.value,required this.active,required this.count,required this.onTap});
  final String label,value;final bool active;final int count;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(10),child:Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:8),decoration:BoxDecoration(color:active?AdminColors.amberSoft:Colors.white,borderRadius:BorderRadius.circular(10),border:Border.all(color:active?AdminColors.yellow:AdminColors.line)),child:Row(mainAxisSize:MainAxisSize.min,children:[Text(label,style:TextStyle(fontSize:9.5,fontWeight:FontWeight.w900,color:active?AdminColors.ink:AdminColors.muted)),const SizedBox(width:7),Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:3),decoration:BoxDecoration(color:active?AdminColors.yellow:AdminColors.canvas,borderRadius:BorderRadius.circular(6)),child:Text(count.toString(),style:const TextStyle(fontSize:8,fontWeight:FontWeight.w900)))])));
}

class _OrderQueue extends StatelessWidget{
  const _OrderQueue({required this.orders,required this.selectedId,required this.page,required this.onPage,required this.onSelect});
  final List<_AdminOrder> orders;final String? selectedId;final int page;final ValueChanged<int> onPage;final ValueChanged<String> onSelect;
  @override Widget build(BuildContext context){
    final start=(page-1)*10,visible=orders.skip(start).take(10).toList(),pages=orders.isEmpty?1:((orders.length-1)~/10)+1;
    return Card(child:Padding(padding:const EdgeInsets.fromLTRB(14,14,14,10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('ORDER QUEUE',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900)),SizedBox(height:3)])),Text('Showing '+visible.length.toString()+' of '+orders.length.toString()+' active tickets',style:const TextStyle(fontSize:9.5,color:AdminColors.muted)),const SizedBox(width:10),Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:7),decoration:BoxDecoration(color:AdminColors.canvas,borderRadius:BorderRadius.circular(8),border:Border.all(color:AdminColors.line)),child:const Row(children:[Icon(Icons.swap_vert_rounded,size:15,color:AdminColors.muted),SizedBox(width:4),Text('Live Recency',style:TextStyle(fontSize:9,fontWeight:FontWeight.w800))]))]),
      const SizedBox(height:12),const _OrderTableHeader(),const Divider(height:1,color:AdminColors.line),...visible.map((o)=>_OrderRow(order:o,selected:o.id==selectedId,onTap:()=>onSelect(o.id))),const Divider(height:1,color:AdminColors.line),
      Row(children:[const Text('Rows per page: 10',style:TextStyle(fontSize:9,color:AdminColors.muted,fontWeight:FontWeight.w700)),const Spacer(),Text((start+1).toString()+'–'+(start+visible.length).toString()+' of '+orders.length.toString(),style:const TextStyle(fontSize:9,color:AdminColors.muted,fontWeight:FontWeight.w800)),IconButton(tooltip:'Previous page',onPressed:page>1?()=>onPage(page-1):null,icon:const Icon(Icons.chevron_left_rounded,size:18),visualDensity:VisualDensity.compact),IconButton(tooltip:'Next page',onPressed:page<pages?()=>onPage(page+1):null,icon:const Icon(Icons.chevron_right_rounded,size:18),visualDensity:VisualDensity.compact)]),
    ])));
  }
}
class _OrderTableHeader extends StatelessWidget{const _OrderTableHeader();@override Widget build(BuildContext context)=>const Padding(padding:EdgeInsets.fromLTRB(10,8,10,8),child:Row(children:[SizedBox(width:30),Expanded(flex:13,child:Text('ORDER ID & TIME',style:TextStyle(fontSize:7.5,fontWeight:FontWeight.w900,color:AdminColors.muted))),Expanded(flex:17,child:Text('CUSTOMER & PHONE',style:TextStyle(fontSize:7.5,fontWeight:FontWeight.w900,color:AdminColors.muted))),Expanded(flex:20,child:Text('ADDRESS',style:TextStyle(fontSize:7.5,fontWeight:FontWeight.w900,color:AdminColors.muted))),Expanded(flex:12,child:Text('ITEMS / TOTAL',style:TextStyle(fontSize:7.5,fontWeight:FontWeight.w900,color:AdminColors.muted))),Expanded(flex:12,child:Text('STATUS',style:TextStyle(fontSize:7.5,fontWeight:FontWeight.w900,color:AdminColors.muted)))]));}
class _OrderRow extends StatelessWidget{
  const _OrderRow({required this.order,required this.selected,required this.onTap});final _AdminOrder order;final bool selected;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>Material(color:selected?AdminColors.amberSoft:Colors.transparent,child:InkWell(onTap:onTap,child:Padding(padding:const EdgeInsets.symmetric(horizontal:10,vertical:10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    SizedBox(width:30,child:Checkbox(value:selected,onChanged:(_)=>onTap(),activeColor:AdminColors.red,visualDensity:VisualDensity.compact,materialTapTargetSize:MaterialTapTargetSize.shrinkWrap,semanticLabel:'Select '+order.id)),
    Expanded(flex:13,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(order.id,style:const TextStyle(fontSize:9.5,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(order.time,style:const TextStyle(fontSize:8.5,color:AdminColors.muted))])),
    Expanded(flex:17,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(order.customer,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9.5,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(order.phone,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:8,color:AdminColors.muted))])),
    Expanded(flex:20,child:Text(order.address,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:8.5,color:AdminColors.muted,height:1.35))),
    Expanded(flex:12,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('₹'+order.total.toStringAsFixed(2),style:const TextStyle(fontSize:9.5,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(order.items.toString()+' items • '+order.payment,style:const TextStyle(fontSize:7.5,color:AdminColors.muted))])),
    Expanded(flex:12,child:Align(alignment:Alignment.topLeft,child:_OrderStatusBadge(order.status))),
  ])));
}
class _OrderStatusBadge extends StatelessWidget{
  const _OrderStatusBadge(this.status);final String status;
  @override Widget build(BuildContext context){final s=_statusStyle(status);return Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:6),decoration:BoxDecoration(color:s.$1,borderRadius:BorderRadius.circular(7)),child:Row(mainAxisSize:MainAxisSize.min,children:[_StatusDot(color:s.$2),const SizedBox(width:5),Text(_prettyStatus(status),style:TextStyle(fontSize:7.2,fontWeight:FontWeight.w900,color:s.$2))]));}
}

class _OrderDetails extends StatelessWidget{
  const _OrderDetails({required this.order,required this.busy,required this.apiConfigured,required this.onAdvance,required this.onInvoice,required this.onCancel});
  final _AdminOrder? order;final bool busy,apiConfigured;final VoidCallback? onAdvance,onInvoice,onCancel;
  @override Widget build(BuildContext context){
    final o=order;if(o==null)return const Card(child:Padding(padding:EdgeInsets.all(30),child:Center(child:Text('No selected order',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900)))));
    final next=_nextStatus(o.status);
    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(o.id,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:5),Row(children:[_OrderStatusBadge(o.status),const SizedBox(width:7),if(apiConfigured)const Text('LIVE ACTIVE',style:TextStyle(fontSize:8,fontWeight:FontWeight.w900,color:AdminColors.green))])])),IconButton(tooltip:'Print',onPressed:()=>_notice(context,'Print is not wired in the existing admin app.'),icon:const Icon(Icons.print_outlined,size:18)),IconButton(tooltip:'Share',onPressed:()=>_notice(context,'Share is not wired in the existing admin app.'),icon:const Icon(Icons.ios_share_rounded,size:18))]),
      const SizedBox(height:5),Text('Placed at '+o.time+' IST • Estimated Dispatch: 8 min',style:const TextStyle(fontSize:8.5,color:AdminColors.muted)),const SizedBox(height:15),
      _Panel(title:'Order Dispatch Progression',trailing:'Step '+_progressStep(o.status).toString()+' of 5',child:_Progression(o.status)),const SizedBox(height:12),
      LayoutBuilder(builder:(context,c)=>c.maxWidth>=500?Row(children:[Expanded(child:_PersonCard('CUSTOMER',o.customer,[o.phone,o.address],Icons.person_outline_rounded)),const SizedBox(width:10),Expanded(child:_PersonCard('DELIVERY PARTNER',o.partner??'Unassigned',[o.vehicle??'Awaiting partner assignment'],Icons.delivery_dining_rounded,badge:o.partner==null?'UNASSIGNED':'ON DUTY'))]):Column(children:[_PersonCard('CUSTOMER',o.customer,[o.phone,o.address],Icons.person_outline_rounded),const SizedBox(height:10),_PersonCard('DELIVERY PARTNER',o.partner??'Unassigned',[o.vehicle??'Awaiting partner assignment'],Icons.delivery_dining_rounded,badge:o.partner==null?'UNASSIGNED':'ON DUTY')])),
      const SizedBox(height:12),
      _Panel(title:'ITEMIZED KITCHEN MANIFEST',trailing:'KOT Ticket: #08',child:Column(children:o.lines.map((l)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Container(width:24,height:24,alignment:Alignment.center,decoration:BoxDecoration(color:AdminColors.amberSoft,borderRadius:BorderRadius.circular(6)),child:Text(l.qty.toString()+'x',style:const TextStyle(fontSize:7.5,fontWeight:FontWeight.w900))),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(l.name,style:const TextStyle(fontSize:9.5,fontWeight:FontWeight.w800)),if(l.modifier.isNotEmpty)Text(l.modifier,style:const TextStyle(fontSize:7.5,color:AdminColors.muted))])),Text('₹'+l.price.toStringAsFixed(2),style:const TextStyle(fontSize:9,fontWeight:FontWeight.w900))]))).toList())),const SizedBox(height:12),
      _Bill(o),const SizedBox(height:12),
      SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:busy||next==null?null:onAdvance,icon:const Icon(Icons.electric_bike_rounded,size:18),label:Text(busy?'Updating…':'Advance to '+_prettyStatus(next??o.status)),style:FilledButton.styleFrom(backgroundColor:AdminColors.yellow,foregroundColor:AdminColors.ink,disabledBackgroundColor:AdminColors.line,padding:const EdgeInsets.symmetric(vertical:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))))),
      const SizedBox(height:8),Wrap(spacing:7,runSpacing:7,children:[OutlinedButton.icon(onPressed:onInvoice,icon:const Icon(Icons.receipt_long_outlined,size:15),label:const Text('Tax Invoice')),OutlinedButton.icon(onPressed:()=>_notice(context,'KOT printing is not wired in the existing admin app.'),icon:const Icon(Icons.print_outlined,size:15),label:const Text('Print KOT')),TextButton.icon(onPressed:onCancel,icon:const Icon(Icons.close_rounded,size:15,color:AdminColors.red),label:const Text('Reject / Cancel',style:TextStyle(color:AdminColors.red)))])
    ])));
  }
}
class _Panel extends StatelessWidget{
  const _Panel({required this.title,required this.child,required this.trailing});final String title,trailing;final Widget child;
  @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AdminColors.canvas,borderRadius:BorderRadius.circular(11),border:Border.all(color:AdminColors.line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:8.5,fontWeight:FontWeight.w900,letterSpacing:.5))),Text(trailing,style:const TextStyle(fontSize:8.5,fontWeight:FontWeight.w900,color:AdminColors.muted))]),const SizedBox(height:9),child]));
}
class _Progression extends StatelessWidget{
  const _Progression(this.status);final String status;
  @override Widget build(BuildContext context){const s=['PLACED','ACCEPTED','PREPARING','OUT_FOR_DELIVERY','DELIVERED'];final current=_progressStep(status)-1;return Row(children:[for(var i=0;i<s.length;i++)...[
    Expanded(child:Column(children:[Container(width:25,height:25,decoration:BoxDecoration(color:i<current?AdminColors.yellow:i==current?AdminColors.red:Colors.white,shape:BoxShape.circle,border:Border.all(color:i<=current?Colors.transparent:AdminColors.line)),alignment:Alignment.center,child:i<current?const Icon(Icons.check_rounded,size:14,color:AdminColors.ink):Text((i+1).toString(),style:TextStyle(fontSize:8,fontWeight:FontWeight.w900,color:i==current?Colors.white:AdminColors.muted))),const SizedBox(height:5),Text(_prettyStatus(s[i]),textAlign:TextAlign.center,style:TextStyle(fontSize:6.5,fontWeight:FontWeight.w800,color:i==current?AdminColors.red:AdminColors.muted))])),
    if(i<s.length-1)Expanded(child:Container(height:2,margin:const EdgeInsets.only(bottom:22),color:i<current?AdminColors.yellow:AdminColors.line))
  ]]));}
}
class _PersonCard extends StatelessWidget{
  const _PersonCard(this.title,this.name,this.lines,this.icon,{this.badge});final String title,name;final List<String> lines;final IconData icon;final String? badge;
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(11),border:Border.all(color:AdminColors.line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Icon(icon,size:16,color:AdminColors.yellowDark),const SizedBox(width:6),Text(title,style:const TextStyle(fontSize:7.5,fontWeight:FontWeight.w900,color:AdminColors.muted)),const Spacer(),if(badge!=null)Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:4),decoration:BoxDecoration(color:badge=='ON DUTY'?AdminColors.greenSoft:AdminColors.redSoft,borderRadius:BorderRadius.circular(6)),child:Text(badge!,style:TextStyle(fontSize:6.5,fontWeight:FontWeight.w900,color:badge=='ON DUTY'?AdminColors.green:AdminColors.red)))]),
    const SizedBox(height:8),Text(name,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w900)),const SizedBox(height:4),...lines.map((l)=>Padding(padding:const EdgeInsets.only(top:2),child:Text(l,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:7.8,color:AdminColors.muted,height:1.3)))),
  ]));
}
class _Bill extends StatelessWidget{
  const _Bill(this.o);final _AdminOrder o;
  @override Widget build(BuildContext context){final sub=o.total-69;Widget line(String a,String b,{bool strong=false})=>Row(children:[Expanded(child:Text(a,style:TextStyle(fontSize:strong?10:8.5,fontWeight:strong?FontWeight.w900:FontWeight.w600,color:strong?AdminColors.ink:AdminColors.muted))),Text(b,style:TextStyle(fontSize:strong?12.5:8.5,fontWeight:FontWeight.w900))]);return Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(11),border:Border.all(color:AdminColors.line)),child:Column(children:[line('Item Subtotal','₹'+sub.toStringAsFixed(2)),line('GST & Packaging Charges','₹69.00'),const Divider(height:17),line('Grand Total','₹'+o.total.toStringAsFixed(2),strong:true),const SizedBox(height:9),Row(children:[const Text('PAYMENT',style:TextStyle(fontSize:7.5,fontWeight:FontWeight.w900,color:AdminColors.muted)),const Spacer(),Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:4),decoration:BoxDecoration(color:AdminColors.greenSoft,borderRadius:BorderRadius.circular(6)),child:const Text('PAID',style:TextStyle(fontSize:7,fontWeight:FontWeight.w900,color:AdminColors.green))),const SizedBox(width:6),Text(o.payment,style:const TextStyle(fontSize:7.5,color:AdminColors.muted))])]));}
}
class _EmptyOrders extends StatelessWidget{const _EmptyOrders({required this.onClear});final VoidCallback onClear;@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(34),child:Center(child:Column(children:[const Icon(Icons.inbox_outlined,size:34,color:AdminColors.muted),const SizedBox(height:9),const Text('No orders match this view',style:TextStyle(fontSize:13,fontWeight:FontWeight.w900)),const SizedBox(height:5),const Text('Try another status filter or clear the order search.',style:TextStyle(fontSize:9.5,color:AdminColors.muted)),const SizedBox(height:12),OutlinedButton(onPressed:onClear,child:const Text('Clear filters'))]))));}

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
(Color,Color) _statusStyle(String s){if(['CANCELLED','DISPUTED','PREPARING'].contains(s))return(AdminColors.redSoft,AdminColors.red);if(['OUT_FOR_DELIVERY','DELIVERED'].contains(s))return(AdminColors.greenSoft,AdminColors.green);return(AdminColors.amberSoft,AdminColors.yellowDark);}



class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final List<Object> product;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(14)), child: Icon(product[4] as IconData, size: 42, color: AdminColors.yellowDark))),
    const SizedBox(height: 13),
    Row(children: [Expanded(child: Text(product[0] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900))), _Pill(product[3] as String)]),
    const SizedBox(height: 5),
    Text(product[1] as String, style: const TextStyle(fontSize: 10, color: AdminColors.muted)),
    const SizedBox(height: 8),
    Text(product[2] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
  ])));
}





class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final Color bg = lower.contains('pending') || lower.contains('preparing') ? AdminColors.amberSoft : lower.contains('delivery') || lower.contains('approved') || lower.contains('available') || lower.contains('delivered') || lower.contains('ready') ? AdminColors.greenSoft : lower.contains('offline') ? AdminColors.canvas : AdminColors.blueSoft;
    final Color fg = lower.contains('pending') || lower.contains('preparing') ? AdminColors.yellowDark : lower.contains('delivery') || lower.contains('approved') || lower.contains('available') || lower.contains('delivered') || lower.contains('ready') ? AdminColors.green : lower.contains('offline') ? AdminColors.muted : AdminColors.blue;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg)));
  }
}
