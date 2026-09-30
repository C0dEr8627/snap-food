import 'package:flutter/material.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _ConnectionBanner(),
      const SizedBox(height: 18),
      LayoutBuilder(
        builder: (context, c) {
          final count = c.maxWidth >= 1000 ? 4 : c.maxWidth >= 650 ? 2 : 1;
          return GridView.count(
            crossAxisCount: count,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: count == 4 ? 1.35 : count == 2 ? 1.8 : 3.0,
            children: const [_RevenueKpi(), _ActiveOrdersKpi(), _FleetKpi(), _SlaKpi()],
          );
        },
      ),
      const SizedBox(height: 20),
      const _AttentionSection(),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, c) => c.maxWidth >= 1050
          ? const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 7, child: _WeeklySalesCard()),
              SizedBox(width: 16),
              Expanded(flex: 4, child: _KitchenPulseCard()),
            ])
          : const Column(children: [_WeeklySalesCard(), SizedBox(height: 16), _KitchenPulseCard()]),
      ),
      const SizedBox(height: 20),
      const _LiveOrdersCard(),
    ],
  );
}

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

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  static const rows = [
    ['#SF-1048', 'Aarav Mehta', '₹840', '12:42 PM', 'Preparing'],
    ['#SF-1045', 'Ananya Rao', '₹980', '12:36 PM', 'Ready'],
    ['#SF-1041', 'Meera Shah', '₹1,560', '12:19 PM', 'Out for delivery'],
    ['#SF-1038', 'Kabir Singh', '₹620', '11:58 AM', 'Delivered'],
  ];
  @override
  Widget build(BuildContext context) => Column(children: [
    Wrap(spacing: 9, runSpacing: 9, children: const ['All orders', 'New', 'Preparing', 'Ready', 'Out for delivery'].map((e) => _Filter(text: e)).toList()),
    const SizedBox(height: 15),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      headingTextStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AdminColors.muted),
      dataTextStyle: const TextStyle(fontSize: 11.5, color: AdminColors.ink),
      columnSpacing: 30,
      columns: const [DataColumn(label: Text('ORDER')), DataColumn(label: Text('CUSTOMER')), DataColumn(label: Text('TOTAL')), DataColumn(label: Text('TIME')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('ACTION'))],
      rows: rows.map((r) => DataRow(cells: [
        DataCell(Text(r[0], style: const TextStyle(fontWeight: FontWeight.w900))),
        DataCell(Text(r[1])),
        DataCell(Text(r[2], style: const TextStyle(fontWeight: FontWeight.w800))),
        DataCell(Text(r[3])),
        DataCell(_Pill(r[4])),
        DataCell(IconButton(onPressed: () => _notice(context, 'Order details will be connected to the Laravel API.'), icon: const Icon(Icons.chevron_right_rounded, size: 19))),
      ])).toList(),
    ))),
  ]);
}

class _Filter extends StatelessWidget {
  const _Filter({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9), decoration: BoxDecoration(color: text == 'All orders' ? AdminColors.ink : Colors.white, border: Border.all(color: text == 'All orders' ? AdminColors.ink : AdminColors.line), borderRadius: BorderRadius.circular(10)), child: Text(text, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: text == 'All orders' ? Colors.white : AdminColors.muted)));
}

class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});
  static const products = [
    ['Classic Veg Burger', 'Burgers', '₹180', 'In stock', Icons.lunch_dining_rounded],
    ['Paneer Tikka Wrap', 'Wraps', '₹220', 'In stock', Icons.breakfast_dining_rounded],
    ['Masala Fries', 'Sides', '₹120', 'Low stock', Icons.fastfood_rounded],
    ['Chocolate Brownie', 'Desserts', '₹140', 'In stock', Icons.cake_rounded],
  ];
  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      Expanded(child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 13), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(11)), child: const Row(children: [Icon(Icons.search_rounded, size: 18, color: AdminColors.muted), SizedBox(width: 9), Text('Search products...', style: TextStyle(fontSize: 11, color: AdminColors.muted))]))),
      const SizedBox(width: 10),
      Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(11)), child: const Row(children: [Text('All categories', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)), SizedBox(width: 5), Icon(Icons.keyboard_arrow_down_rounded, size: 17)])),
    ]),
    const SizedBox(height: 16),
    LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 720 ? 2 : 1;
      return GridView.builder(
        itemCount: products.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.38),
        itemBuilder: (context, i) => _ProductCard(product: products[i]),
      );
    }),
  ]);
}

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

class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key});
  static const rows = [
    ['Vikram Joshi', 'DP-0084', 'Mumbai Central', 'Approved', 'Available'],
    ['Neha Kulkarni', 'DP-0083', 'Andheri West', 'Approved', 'On delivery'],
    ['Sameer Khan', 'DP-0082', 'Bandra', 'Pending review', 'Offline'],
    ['Priya Nair', 'DP-0081', 'Powai', 'Approved', 'Available'],
  ];
  @override
  Widget build(BuildContext context) => Column(children: [
    LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 850 ? 3 : c.maxWidth >= 500 ? 2 : 1;
      return GridView.count(crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 13, mainAxisSpacing: 13, childAspectRatio: cols == 1 ? 3.2 : 2.1, children: const [
        _Kpi(title: 'Total partners', value: '84', delta: '+6 this week', icon: Icons.groups_2_outlined, tone: AdminColors.amberSoft),
        _Kpi(title: 'Available now', value: '21', delta: 'Online', icon: Icons.electric_bike_outlined, tone: AdminColors.greenSoft),
        _Kpi(title: 'Pending review', value: '03', delta: 'Action needed', icon: Icons.pending_actions_rounded, tone: AdminColors.redSoft),
      ]);
    }),
    const SizedBox(height: 17),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      headingTextStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AdminColors.muted),
      columnSpacing: 28,
      columns: const [DataColumn(label: Text('PARTNER')), DataColumn(label: Text('ID')), DataColumn(label: Text('AREA')), DataColumn(label: Text('KYC')), DataColumn(label: Text('AVAILABILITY')), DataColumn(label: Text('ACTION'))],
      rows: rows.map((r) => DataRow(cells: [
        DataCell(Text(r[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
        DataCell(Text(r[1])),
        DataCell(Text(r[2])),
        DataCell(_Pill(r[3])),
        DataCell(Text(r[4])),
        DataCell(TextButton(onPressed: () => _notice(context, 'Partner review will use protected Laravel admin endpoints.'), child: const Text('Review'))),
      ])).toList(),
    ))),
  ]);
}

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});
  static const rows = [
    ['INV-2026-1048', '#SF-1048', 'Aarav Mehta', '₹840', 'Pending delivery'],
    ['INV-2026-1045', '#SF-1045', 'Ananya Rao', '₹980', 'Available'],
    ['INV-2026-1041', '#SF-1041', 'Meera Shah', '₹1,560', 'Available'],
    ['INV-2026-1038', '#SF-1038', 'Kabir Singh', '₹620', 'Available'],
  ];
  @override
  Widget build(BuildContext context) => Column(children: [
    Card(child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.receipt_long_rounded, color: AdminColors.yellowDark)),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Invoice centre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        SizedBox(height: 3),
        Text('Invoice access follows delivered-order availability. Preview rows are illustrative.', style: TextStyle(fontSize: 10.5, color: AdminColors.muted)),
      ])),
    ]))),
    const SizedBox(height: 15),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      headingTextStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AdminColors.muted),
      columnSpacing: 28,
      columns: const [DataColumn(label: Text('INVOICE')), DataColumn(label: Text('ORDER')), DataColumn(label: Text('CUSTOMER')), DataColumn(label: Text('AMOUNT')), DataColumn(label: Text('ACCESS')), DataColumn(label: Text('ACTION'))],
      rows: rows.map((r) => DataRow(cells: [
        DataCell(Text(r[0], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5))),
        DataCell(Text(r[1])),
        DataCell(Text(r[2])),
        DataCell(Text(r[3], style: const TextStyle(fontWeight: FontWeight.w800))),
        DataCell(_Pill(r[4])),
        DataCell(IconButton(onPressed: () => _notice(context, 'Invoice viewing will be connected to the Laravel API.'), icon: const Icon(Icons.open_in_new_rounded, size: 18))),
      ])).toList(),
    ))),
  ]);
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
