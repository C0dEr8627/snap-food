import 'package:flutter/material.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

void main() => runApp(const SnapFooddAdminApp());

abstract final class AdminColors {
  static const canvas = Color(0xFFFFF8F5);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF201B17);
  static const muted = Color(0xFF7F7662);
  static const border = Color(0xFFE9E4D8);
  static const primary = Color(0xFF755B00);
  static const yellow = Color(0xFFE4B935);
  static const red = Color(0xFFD54126);
  static const softYellow = Color(0xFFFFF3C4);
  static const softRed = Color(0xFFFBE3DC);
  static const softGreen = Color(0xFFE5F4E8);
  static const green = Color(0xFF267447);
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: AdminColors.primary,
        surface: AdminColors.surface,
        primary: AdminColors.primary,
        secondary: AdminColors.red,
      ),
      fontFamily: 'Plus Jakarta Sans',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AdminColors.ink),
        headlineSmall: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AdminColors.ink),
        titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AdminColors.ink),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminColors.ink),
        bodyMedium: TextStyle(fontSize: 13, color: AdminColors.ink, height: 1.45),
        bodySmall: TextStyle(fontSize: 12, color: AdminColors.muted),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AdminColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AdminColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.yellow, width: 1.5)),
      ),
    ),
    home: const AdminShell(),
  );
}

enum AdminSection { dashboard, orders, catalogue, partners, invoices }

extension SectionDetails on AdminSection {
  String get label => switch (this) {
    AdminSection.dashboard => 'Dashboard',
    AdminSection.orders => 'Orders',
    AdminSection.catalogue => 'Catalogue',
    AdminSection.partners => 'Delivery partners',
    AdminSection.invoices => 'Invoices',
  };
  IconData get icon => switch (this) {
    AdminSection.dashboard => Icons.grid_view_rounded,
    AdminSection.orders => Icons.receipt_long_rounded,
    AdminSection.catalogue => Icons.restaurant_menu_rounded,
    AdminSection.partners => Icons.delivery_dining_rounded,
    AdminSection.invoices => Icons.request_quote_rounded,
  };
  String get subtitle => switch (this) {
    AdminSection.dashboard => 'Here’s what’s happening with your store today.',
    AdminSection.orders => 'Review, search and manage incoming orders.',
    AdminSection.catalogue => 'Manage the products and categories customers see.',
    AdminSection.partners => 'Review delivery partner status and availability.',
    AdminSection.invoices => 'Browse order invoices and payment summaries.',
  };
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminSection section = AdminSection.dashboard;
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      drawer: wide ? null : Drawer(child: _Sidebar(selected: section, onSelect: _select)),
      body: Row(children: [
        if (wide) SizedBox(width: 248, child: _Sidebar(selected: section, onSelect: _select)),
        Expanded(child: Column(children: [
          _TopBar(wide: wide, apiConfigured: apiBaseUrl.trim().isNotEmpty),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: wide ? 34 : 18, vertical: 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (!wide) Builder(builder: (context) => Padding(
                      padding: const EdgeInsets.only(right: 10, top: 3),
                      child: IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.menu_rounded)),
                    )),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(section.label, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 5),
                      Text(section.subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminColors.muted)),
                    ])),
                    if (wide) FilledButton.icon(
                      onPressed: () => _showNotice(context, section == AdminSection.catalogue ? 'Catalogue editor will be connected to the Laravel API in the next integration step.' : 'This action will be connected to the Laravel API in the next integration step.'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(section == AdminSection.catalogue ? 'Add product' : 'Quick action'),
                      style: FilledButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16)),
                    ),
                  ]),
                  const SizedBox(height: 26),
                  if (section == AdminSection.dashboard) const DashboardPage()
                  else if (section == AdminSection.orders) const OrdersPage()
                  else if (section == AdminSection.catalogue) const CataloguePage()
                  else if (section == AdminSection.partners) const PartnersPage()
                  else const InvoicesPage(),
                  const SizedBox(height: 26),
                  const Center(child: Text('Snap Foodd Admin • Preview data only • API integration pending', style: TextStyle(color: AdminColors.muted, fontSize: 11))),
                ]),
              ),
            ),
          )),
        ])),
      ]),
    );
  }

  void _select(AdminSection value) {
    setState(() => section = value);
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}

void _showNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect});
  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;

  @override
  Widget build(BuildContext context) => Container(
    color: AdminColors.surface,
    decoration: const BoxDecoration(border: Border(right: BorderSide(color: AdminColors.border))),
    child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 25, 18, 28), child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: AdminColors.yellow, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.restaurant_rounded, color: AdminColors.ink, size: 23)),
        const SizedBox(width: 11),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Snap Foodd', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AdminColors.ink)),
          SizedBox(height: 2),
          Text('ADMIN CONSOLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AdminColors.muted)),
        ])),
      ])),
      const Padding(padding: EdgeInsets.fromLTRB(22, 0, 12, 12), child: Text('WORKSPACE', style: TextStyle(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800, color: AdminColors.muted))),
      ...AdminSection.values.map((item) {
        final active = selected == item;
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelect(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(color: active ? AdminColors.softYellow : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(item.icon, size: 19, color: active ? AdminColors.primary : AdminColors.muted),
              const SizedBox(width: 12),
              Expanded(child: Text(item.label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? AdminColors.primary : AdminColors.ink))),
              if (active) Container(width: 5, height: 5, decoration: const BoxDecoration(color: AdminColors.red, shape: BoxShape.circle)),
            ]),
          ),
        ));
      }),
      const Spacer(),
      Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(14), border: Border.all(color: AdminColors.border)), child: const Row(children: [
        Icon(Icons.shield_outlined, color: AdminColors.primary, size: 20),
        SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin workspace', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AdminColors.ink)),
          SizedBox(height: 3),
          Text('Secure API access required', style: TextStyle(fontSize: 10, color: AdminColors.muted)),
        ])),
      ])),
    ])),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.wide, required this.apiConfigured});
  final bool wide;
  final bool apiConfigured;
  @override
  Widget build(BuildContext context) => Container(
    height: 78,
    padding: EdgeInsets.symmetric(horizontal: wide ? 34 : 18),
    decoration: const BoxDecoration(color: AdminColors.surface, border: Border(bottom: BorderSide(color: AdminColors.border))),
    child: Row(children: [
      if (wide) const Icon(Icons.wb_sunny_outlined, color: AdminColors.primary, size: 19),
      if (wide) const SizedBox(width: 10),
      Expanded(child: Text(wide ? 'Good morning, Admin' : 'Snap Foodd Admin', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AdminColors.ink))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: apiConfigured ? AdminColors.softGreen : AdminColors.softYellow, borderRadius: BorderRadius.circular(20)), child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: apiConfigured ? AdminColors.green : AdminColors.primary, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(apiConfigured ? 'API configured' : 'Preview mode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: apiConfigured ? AdminColors.green : AdminColors.primary)),
      ])),
      const SizedBox(width: 14),
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AdminColors.softRed, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.person_outline_rounded, color: AdminColors.red)),
    ]),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Wrap(spacing: 16, runSpacing: 16, children: const [
      _MetricCard(title: 'Orders today', value: '128', change: '+12.8%', icon: Icons.receipt_long_rounded, tone: AdminColors.softYellow, detail: 'vs. previous day'),
      _MetricCard(title: 'Gross sales', value: '₹48,290', change: '+8.2%', icon: Icons.payments_outlined, tone: AdminColors.softGreen, detail: 'COD orders'),
      _MetricCard(title: 'Active delivery', value: '18', change: 'Live', icon: Icons.delivery_dining_rounded, tone: AdminColors.softRed, detail: 'partners on trips'),
      _MetricCard(title: 'Needs attention', value: '07', change: 'Review', icon: Icons.notifications_active_outlined, tone: Color(0xFFF1E6DF), detail: 'orders to review'),
    ]),
    const SizedBox(height: 24),
    LayoutBuilder(builder: (context, constraints) {
      final stacked = constraints.maxWidth < 780;
      final sales = const _SalesPanel();
      final activity = const _ActivityPanel();
      return stacked ? Column(children: [sales, const SizedBox(height: 18), activity]) : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: sales), const SizedBox(width: 18), Expanded(flex: 2, child: activity)]);
    }),
    const SizedBox(height: 24),
    const _SectionHeader(title: 'Recent orders', action: 'View all orders'),
    const SizedBox(height: 12),
    const _OrdersTable(compact: true),
  ]);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.change, required this.icon, required this.tone, required this.detail});
  final String title, value, change, detail;
  final IconData icon;
  final Color tone;
  @override
  Widget build(BuildContext context) => SizedBox(width: 250, child: Card(child: Padding(padding: const EdgeInsets.all(19), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AdminColors.ink, size: 20)), const Spacer(), Text(change, style: const TextStyle(color: AdminColors.green, fontSize: 11, fontWeight: FontWeight.w800))]),
    const SizedBox(height: 18),
    Text(value, style: const TextStyle(fontSize: 27, height: 1.1, fontWeight: FontWeight.w900, color: AdminColors.ink)),
    const SizedBox(height: 7),
    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminColors.ink)),
    const SizedBox(height: 3),
    Text(detail, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
  ]))));
}

class _SalesPanel extends StatelessWidget {
  const _SalesPanel();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Sales overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AdminColors.ink)),
    const SizedBox(height: 4),
    const Text('Weekly order volume • preview data', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
    const SizedBox(height: 24),
    SizedBox(height: 155, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
      _Bar(day: 'MON', height: 64), _Bar(day: 'TUE', height: 92), _Bar(day: 'WED', height: 76), _Bar(day: 'THU', height: 118), _Bar(day: 'FRI', height: 98), _Bar(day: 'SAT', height: 137, selected: true), _Bar(day: 'SUN', height: 110),
    ])),
  ])));
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day, required this.height, this.selected = false});
  final String day;
  final double height;
  final bool selected;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
    Container(width: 23, height: height, decoration: BoxDecoration(color: selected ? AdminColors.red : AdminColors.yellow.withValues(alpha: .72), borderRadius: BorderRadius.circular(7))),
    const SizedBox(height: 10),
    Text(day, style: TextStyle(fontSize: 9, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? AdminColors.red : AdminColors.muted)),
  ]));
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Live operations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AdminColors.ink)),
    const SizedBox(height: 4),
    const Text('A quick look at the order queue', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
    const SizedBox(height: 18),
    const _ProgressRow(label: 'New orders', value: '12', fraction: .78, color: AdminColors.red),
    const SizedBox(height: 17),
    const _ProgressRow(label: 'Preparing', value: '24', fraction: .62, color: AdminColors.primary),
    const SizedBox(height: 17),
    const _ProgressRow(label: 'Ready for pickup', value: '09', fraction: .38, color: AdminColors.green),
    const SizedBox(height: 17),
    const _ProgressRow(label: 'Out for delivery', value: '18', fraction: .52, color: Color(0xFFB88720)),
  ])));
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value, required this.fraction, required this.color});
  final String label, value;
  final double fraction;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.ink))), Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AdminColors.ink))]),
    const SizedBox(height: 8),
    ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: fraction, minHeight: 6, backgroundColor: AdminColors.canvas, color: color)),
  ]);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AdminColors.ink))), if (action != null) TextButton(onPressed: () => _showNotice(context, 'Use the left navigation to open the relevant section.'), child: Text(action!, style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.w800, fontSize: 12)))]);
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}
class _OrdersPageState extends State<OrdersPage> {
  String filter = 'All orders';
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Wrap(spacing: 10, runSpacing: 10, children: ['All orders', 'New', 'Preparing', 'Ready for pickup', 'Delivered'].map((item) => ChoiceChip(label: Text(item), selected: filter == item, onSelected: (_) => setState(() => filter = item), selectedColor: AdminColors.softYellow, side: BorderSide(color: filter == item ? AdminColors.yellow : AdminColors.border))).toList()),
    const SizedBox(height: 16),
    const _OrdersTable(),
  ]);
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({this.compact = false});
  final bool compact;
  static const rows = [
    ['#SF-1048', 'Aarav Mehta', '₹840', 'Preparing', 'Today, 12:42 PM'],
    ['#SF-1047', 'Isha Patel', '₹1,240', 'Ready for pickup', 'Today, 12:38 PM'],
    ['#SF-1046', 'Rohan Shah', '₹560', 'Out for delivery', 'Today, 12:31 PM'],
    ['#SF-1045', 'Ananya Rao', '₹980', 'Delivered', 'Today, 12:19 PM'],
    ['#SF-1044', 'Kabir Singh', '₹420', 'New', 'Today, 12:12 PM'],
  ];
  @override
  Widget build(BuildContext context) => Card(child: Column(children: [
    if (!compact) const Padding(padding: EdgeInsets.all(18), child: Row(children: [Expanded(child: Text('Orders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))), Icon(Icons.download_outlined, color: AdminColors.muted), SizedBox(width: 8), Text('Export', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.primary))])),
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      headingRowHeight: 46, dataRowMinHeight: 62, dataRowMaxHeight: 68,
      columns: const [DataColumn(label: Text('ORDER ID')), DataColumn(label: Text('CUSTOMER')), DataColumn(label: Text('TOTAL')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('CREATED'))],
      rows: rows.map((row) => DataRow(cells: [
        DataCell(Text(row[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
        DataCell(Text(row[1], style: const TextStyle(fontSize: 12))),
        DataCell(Text(row[2], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        DataCell(_StatusPill(row[3])),
        DataCell(Text(row[4], style: const TextStyle(fontSize: 11, color: AdminColors.muted))),
      ])).toList(),
    )),
  ]));
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = status == 'Delivered' || status == 'Approved' ? AdminColors.green : status == 'New' || status == 'Preparing' ? AdminColors.primary : status == 'Suspended' ? AdminColors.red : const Color(0xFF8A6414);
    final background = color == AdminColors.green ? AdminColors.softGreen : color == AdminColors.red ? AdminColors.softRed : AdminColors.softYellow;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)));
  }
}

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});
  @override
  State<CataloguePage> createState() => _CataloguePageState();
}
class _CataloguePageState extends State<CataloguePage> {
  String category = 'All items';
  final items = <List<String>>[
    ['Classic Veg Burger', 'Burgers', '₹189', 'Active'],
    ['Paneer Tikka Wrap', 'Wraps', '₹229', 'Active'],
    ['Masala Fries', 'Sides', '₹119', 'Active'],
    ['Crispy Chicken Bowl', 'Bowls', '₹299', 'Inactive'],
    ['Chocolate Brownie', 'Desserts', '₹149', 'Active'],
  ];
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
      SizedBox(width: 250, child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search products'))),
      DropdownButton<String>(value: category, items: ['All items', 'Burgers', 'Wraps', 'Sides', 'Bowls', 'Desserts'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v ?? 'All items')),
      OutlinedButton.icon(onPressed: () => _showNotice(context, 'Category management will be connected to the Laravel API.'), icon: const Icon(Icons.category_outlined), label: const Text('Categories')),
    ]),
    const SizedBox(height: 16),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns: const [DataColumn(label: Text('PRODUCT')), DataColumn(label: Text('CATEGORY')), DataColumn(label: Text('PRICE')), DataColumn(label: Text('STATUS')), DataColumn(label: Text('ACTIONS'))],
      rows: items.where((item) => category == 'All items' || item[1] == category).map((item) => DataRow(cells: [
        DataCell(Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: AdminColors.softYellow, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.fastfood_rounded, color: AdminColors.primary, size: 17)), const SizedBox(width: 10), Text(item[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))])),
        DataCell(Text(item[1], style: const TextStyle(fontSize: 12))),
        DataCell(Text(item[2], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
        DataCell(_StatusPill(item[3])),
        DataCell(IconButton(onPressed: () => _showNotice(context, 'Product editing will be enabled when API integration is complete.'), icon: const Icon(Icons.edit_outlined, size: 18))),
      ])).toList(),
    ))),
  ]);
}

class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key});
  static const partners = [
    ['Vikram Joshi', 'DP-0084', 'Mumbai Central', 'Approved', 'Available'],
    ['Neha Kulkarni', 'DP-0083', 'Andheri West', 'Approved', 'On delivery'],
    ['Sameer Khan', 'DP-0082', 'Bandra', 'Pending review', 'Offline'],
    ['Priya Nair', 'DP-0081', 'Powai', 'Approved', 'Available'],
  ];
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Wrap(spacing: 14, runSpacing: 14, children: const [
      _MetricCard(title: 'Total partners', value: '84', change: '+6 this week', icon: Icons.groups_2_outlined, tone: AdminColors.softYellow, detail: 'registered partners'),
      _MetricCard(title: 'Available now', value: '21', change: 'Online', icon: Icons.electric_bike_outlined, tone: AdminColors.softGreen, detail: 'ready for assignment'),
      _MetricCard(title: 'Pending review', value: '03', change: 'Action needed', icon: Icons.pending_actions_rounded, tone: AdminColors.softRed, detail: 'approval requests'),
    ]),
    const SizedBox(height: 20),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns: const [DataColumn(label: Text('PARTNER')), DataColumn(label: Text('PARTNER ID')), DataColumn(label: Text('SERVICE AREA')), DataColumn(label: Text('APPROVAL')), DataColumn(label: Text('AVAILABILITY')), DataColumn(label: Text('ACTION'))],
      rows: partners.map((p) => DataRow(cells: [
        DataCell(Text(p[0], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        DataCell(Text(p[1], style: const TextStyle(fontSize: 11))),
        DataCell(Text(p[2], style: const TextStyle(fontSize: 12))),
        DataCell(_StatusPill(p[3])),
        DataCell(Text(p[4], style: const TextStyle(fontSize: 12))),
        DataCell(TextButton(onPressed: () => _showNotice(context, 'Partner actions will be connected to protected admin API endpoints.'), child: const Text('Review'))),
      ])).toList(),
    ))),
  ]);
}

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});
  static const invoices = [
    ['INV-2026-1048', '#SF-1048', 'Aarav Mehta', '₹840', 'Pending delivery'],
    ['INV-2026-1045', '#SF-1045', 'Ananya Rao', '₹980', 'Available'],
    ['INV-2026-1041', '#SF-1041', 'Meera Shah', '₹1,560', 'Available'],
    ['INV-2026-1038', '#SF-1038', 'Kabir Singh', '₹620', 'Available'],
  ];
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Card(child: Padding(padding: EdgeInsets.all(18), child: Row(children: [
      Icon(Icons.info_outline_rounded, color: AdminColors.primary),
      SizedBox(width: 10),
      Expanded(child: Text('Invoice access follows delivered-order availability. Preview rows below are illustrative, not live records.', style: TextStyle(fontSize: 12, color: AdminColors.muted))),
    ]))),
    const SizedBox(height: 16),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns: const [DataColumn(label: Text('INVOICE')), DataColumn(label: Text('ORDER')), DataColumn(label: Text('CUSTOMER')), DataColumn(label: Text('AMOUNT')), DataColumn(label: Text('ACCESS')), DataColumn(label: Text('ACTION'))],
      rows: invoices.map((i) => DataRow(cells: [
        DataCell(Text(i[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
        DataCell(Text(i[1], style: const TextStyle(fontSize: 12))),
        DataCell(Text(i[2], style: const TextStyle(fontSize: 12))),
        DataCell(Text(i[3], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
        DataCell(_StatusPill(i[4])),
        DataCell(IconButton(onPressed: () => _showNotice(context, 'Invoice download/view will be wired to the Laravel API.'), icon: const Icon(Icons.open_in_new_rounded, size: 18))),
      ])).toList(),
    ))),
  ]);
}
