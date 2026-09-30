import 'package:flutter/material.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

void main() => runApp(const SnapFooddAdminApp());

abstract final class AdminColors {
  static const ink = Color(0xFF191512);
  static const muted = Color(0xFF756E67);
  static const canvas = Color(0xFFF7F4EF);
  static const surface = Colors.white;
  static const line = Color(0xFFE8E1D9);
  static const yellow = Color(0xFFF2C94C);
  static const yellowDark = Color(0xFF9A7200);
  static const red = Color(0xFFCF3D27);
  static const redSoft = Color(0xFFFCE9E4);
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
        headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AdminColors.ink, letterSpacing: -.7),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AdminColors.ink),
        titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AdminColors.ink),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AdminColors.ink),
        bodyMedium: TextStyle(fontSize: 13, color: AdminColors.ink, height: 1.45),
        bodySmall: TextStyle(fontSize: 11, color: AdminColors.muted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AdminColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AdminColors.line)),
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
        if (desktop) SizedBox(width: 264, child: _Sidebar(selected: section, onSelect: _select)),
        Expanded(child: Column(children: [
          _Header(desktop: desktop),
          Expanded(child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(desktop ? 38 : 18, 28, desktop ? 38 : 18, 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1420),
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
    color: AdminColors.ink,
    child: SafeArea(child: Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(compact ? 22 : 24, 26, 22, 34),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: AdminColors.yellow, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.restaurant_rounded, color: AdminColors.ink, size: 25),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Snap Foodd', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('ADMIN CONSOLE', style: TextStyle(color: Color(0xFFB9B2AA), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.6)),
          ])),
        ]),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(22, 0, 18, 12),
        child: Align(alignment: Alignment.centerLeft, child: Text('MAIN MENU', style: TextStyle(color: Color(0xFF8D867F), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
      ),
      ...AdminSection.values.map((item) {
        final active = item == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: active ? AdminColors.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(children: [
                Icon(item.icon, size: 19, color: active ? AdminColors.ink : const Color(0xFFB8B0A7)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? AdminColors.ink : Colors.white))),
                if (active) const Icon(Icons.chevron_right_rounded, size: 17, color: AdminColors.ink),
              ]),
            ),
          ),
        );
      }),
      const Spacer(),
      Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: const Color(0xFF292522), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF39332F))),
        child: const Row(children: [
          Icon(Icons.shield_outlined, color: AdminColors.yellow, size: 20),
          SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Protected workspace', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
            SizedBox(height: 3),
            Text('API access only', style: TextStyle(color: Color(0xFF9C958D), fontSize: 10)),
          ])),
        ]),
      ),
    ])),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.desktop});
  final bool desktop;
  @override
  Widget build(BuildContext context) => Container(
    height: 74,
    padding: EdgeInsets.symmetric(horizontal: desktop ? 38 : 18),
    decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AdminColors.line))),
    child: Row(children: [
      if (desktop) ...[
        const Icon(Icons.wb_sunny_outlined, size: 18, color: AdminColors.yellowDark),
        const SizedBox(width: 9),
        const Text('Good morning, Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      ] else const Expanded(child: Text('Snap Foodd Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
      const Spacer(),
      if (desktop) Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(color: apiBaseUrl.isEmpty ? AdminColors.amberSoft : AdminColors.greenSoft, borderRadius: BorderRadius.circular(30)),
        child: Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: apiBaseUrl.isEmpty ? AdminColors.yellowDark : AdminColors.green, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(apiBaseUrl.isEmpty ? 'Preview mode' : 'API configured', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: apiBaseUrl.isEmpty ? AdminColors.yellowDark : AdminColors.green)),
        ]),
      ),
      const SizedBox(width: 12),
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AdminColors.redSoft, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person_outline_rounded, color: AdminColors.red, size: 19)),
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
  Widget build(BuildContext context) => Column(children: [
    LayoutBuilder(builder: (context, c) {
      final n = c.maxWidth >= 1000 ? 4 : c.maxWidth >= 650 ? 2 : 1;
      return GridView.count(
        crossAxisCount: n, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: n == 1 ? 3.2 : n == 2 ? 1.8 : 1.55,
        children: const [
          _Kpi(title: 'Orders today', value: '128', delta: '+12.8%', icon: Icons.receipt_long_rounded, tone: AdminColors.amberSoft),
          _Kpi(title: 'Gross sales', value: '₹48,290', delta: '+8.2%', icon: Icons.payments_outlined, tone: AdminColors.greenSoft),
          _Kpi(title: 'Active deliveries', value: '18', delta: 'Live', icon: Icons.delivery_dining_rounded, tone: AdminColors.redSoft),
          _Kpi(title: 'Needs attention', value: '07', delta: 'Review', icon: Icons.notifications_active_outlined, tone: AdminColors.blueSoft),
        ],
      );
    }),
    const SizedBox(height: 18),
    LayoutBuilder(builder: (context, c) {
      final stacked = c.maxWidth < 850;
      final sales = const _SalesCard();
      final ops = const _OpsCard();
      return stacked ? Column(children: [sales, const SizedBox(height: 18), ops]) : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: sales), const SizedBox(width: 18), Expanded(flex: 2, child: ops)]);
    }),
    const SizedBox(height: 18),
    const _CardTitle(title: 'Recent orders', action: 'View all'),
    const SizedBox(height: 11),
    const _OrdersTable(),
  ]);
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
    SizedBox(height: 170, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: const [
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
