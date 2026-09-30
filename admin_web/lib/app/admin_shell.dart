part of '../main.dart';

enum AdminSection { dashboard, orders, catalogue, partners, invoices }

extension on AdminSection {
  String get label => switch (this) {
    AdminSection.dashboard => 'Dashboard',
    AdminSection.orders => 'Orders',
    AdminSection.catalogue => 'Catalogue',
    AdminSection.partners => 'Delivery partners',
    AdminSection.invoices => 'Invoices & Tax Billing Ledger',
  };
  AdminIconData get icon => switch (this) {
    AdminSection.dashboard => HugeIcons.strokeRoundedDashboardSquare01,
    AdminSection.orders => HugeIcons.strokeRoundedInvoice01,
    AdminSection.catalogue => HugeIcons.strokeRoundedPackage01,
    AdminSection.partners => HugeIcons.strokeRoundedDeliveryTruck01,
    AdminSection.invoices => HugeIcons.strokeRoundedInvoice,
  };
  String get subtitle => switch (this) {
    AdminSection.dashboard => 'A clear view of today’s business and operations.',
    AdminSection.orders => 'Track every order from checkout to delivery.',
    AdminSection.catalogue => 'Manage menu items, categories and availability.',
    AdminSection.partners => 'Review delivery partners and KYC status.',
    AdminSection.invoices => 'Reconcile invoice snapshots and review billing records.',
  };
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
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AdminColors.ink,
        onPrimary: Colors.white,
        primaryContainer: AdminColors.amberSoft,
        onPrimaryContainer: AdminColors.ink,
        secondary: AdminColors.yellowDark,
        onSecondary: Colors.white,
        secondaryContainer: AdminColors.amberSoft,
        onSecondaryContainer: AdminColors.ink,
        tertiary: AdminColors.red,
        onTertiary: Colors.white,
        tertiaryContainer: AdminColors.redSoft,
        onTertiaryContainer: AdminColors.ink,
        error: AdminColors.red,
        onError: Colors.white,
        errorContainer: AdminColors.redSoft,
        onErrorContainer: AdminColors.ink,
        surface: AdminColors.surface,
        onSurface: AdminColors.ink,
        surfaceContainerHighest: Color(0xFFF2F2F2),
        onSurfaceVariant: Color(0xFF454545),
        outline: Color(0xFF6B6B6B),
        outlineVariant: Color(0xFFD0D0D0),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AdminColors.ink,
        onInverseSurface: Colors.white,
        inversePrimary: AdminColors.yellow,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 36, height: 1.15, fontWeight: FontWeight.w800, color: AdminColors.ink),
        displayMedium: TextStyle(fontSize: 32, height: 1.2, fontWeight: FontWeight.w800, color: AdminColors.ink),
        headlineLarge: TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w800, color: AdminColors.ink),
        headlineSmall: TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w800, color: AdminColors.ink),
        titleLarge: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w800, color: AdminColors.ink),
        titleMedium: TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w700, color: AdminColors.ink),
        titleSmall: TextStyle(fontSize: 14, height: 1.35, fontWeight: FontWeight.w700, color: AdminColors.ink),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: AdminColors.ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: AdminColors.ink),
        bodySmall: TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF454545)),
        labelLarge: TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: 11, height: 1.2, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AdminColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AdminColors.line)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          side: const BorderSide(color: Color(0xFF6B6B6B)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          iconSize: 22,
          padding: const EdgeInsets.all(10),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF454545)),
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF5C5C5C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6B6B6B))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6B6B6B))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.ink, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.red, width: 2)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFD0D0D0), thickness: 1, space: 1),
    ),
    home: const AdminAuthGate(),
  );
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.user, required this.onLogout});

  final AdminUser user;
  final Future<void> Function() onLogout;
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
          _Header(desktop: desktop, user: widget.user, onLogout: widget.onLogout),
          Expanded(child: LayoutBuilder(builder: (context, constraints) => Scrollbar(thumbVisibility: desktop, child: SingleChildScrollView(
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
                        icon: const AdminIcon(HugeIcons.strokeRoundedMenu01),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: Text(section.label, style: Theme.of(context).textTheme.headlineSmall)),
                    ]),
                  ),
                  if (section != AdminSection.partners && section != AdminSection.invoices)
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
                  const Center(child: Text('Snap Foodd Admin  •  Preview data • Laravel API v1', style: TextStyle(fontSize: 11, color: AdminColors.muted))),
                ]),
              ),
            ),
          )))),
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
      child: SingleChildScrollView(
      padding: EdgeInsets.zero,
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
                  Text('ADMIN PORTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AdminColors.muted)),
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
                Text('IN-BLR-01', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.ink)),
                SizedBox(height: 2),
                Text('Preview Data Mode', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
              ])),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 18, 9),
            child: Align(alignment: Alignment.centerLeft, child: Text('NAVIGATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AdminColors.muted))),
          ),
          ...AdminSection.values.map((item) {
            final active = item == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Semantics(
                button: true,
                selected: active,
                label: item.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onSelect(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                  decoration: BoxDecoration(color: active ? AdminColors.amberSoft : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                  child: Row(children: [
                    AdminIcon(item.icon, size: 18, color: active ? AdminColors.yellowDark : AdminColors.muted),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item.label, style: TextStyle(fontSize: 12.5, fontWeight: active ? FontWeight.w900 : FontWeight.w700, color: AdminColors.ink))),
                    if (active) const AdminIcon(HugeIcons.strokeRoundedArrowRight01, size: 16, color: AdminColors.yellowDark),
                  ]),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Flutter Engine', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.muted)),
              const SizedBox(height: 4),
              const Text('api.snapfoodd.in/v1', style: TextStyle(fontSize: 11, color: AdminColors.ink, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(7), border: Border.all(color: AdminColors.line)),
                child: const Text('v3.22 Web', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.muted)),
              ),
            ]),
          ),
        ],
      ),
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SvgPicture.asset(
      'assets/brand/logo.svg',
      width: 42,
      height: 42,
      fit: BoxFit.cover,
      semanticsLabel: 'Snap Foodd',
    ),
  );
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _Header extends StatelessWidget {
  const _Header({required this.desktop, required this.user, required this.onLogout});
  final bool desktop;
  final AdminUser user;
  final Future<void> Function() onLogout;

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
              AdminIcon(HugeIcons.strokeRoundedSearch01, size: 19, color: AdminColors.muted),
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
          decoration: BoxDecoration(color: AdminColors.greenSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: AdminColors.greenSoft)),
          child: const Row(children: [
            _StatusDot(color: AdminColors.green),
            SizedBox(width: 7),
            Text('api.snapfoodd.in/v1', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AdminColors.ink)),
            SizedBox(width: 7),
            Text('• Live Connected', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AdminColors.green)),
          ]),
        ),
      const SizedBox(width: 10),
      IconButton(tooltip: 'Notifications', onPressed: () => _notice(context, 'No new notifications in preview mode.'), icon: const AdminIcon(HugeIcons.strokeRoundedNotification01, size: 21, color: AdminColors.ink)),
      const SizedBox(width: 2),
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AdminColors.ink, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text(_initials(user.name), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
      if (desktop) ...[
        const SizedBox(width: 9),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(user.email, style: const TextStyle(fontSize: 9, color: AdminColors.muted)),
        ]),
        const SizedBox(width: 8),
        IconButton(tooltip: 'Logout', onPressed: onLogout, icon: const AdminIcon(HugeIcons.strokeRoundedLogout01, size: 18, color: AdminColors.muted)),
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
      icon: const AdminIcon(HugeIcons.strokeRoundedAdd01, size: 17),
      label: Text(section == AdminSection.catalogue ? 'Add product' : 'Quick action'),
      style: FilledButton.styleFrom(backgroundColor: AdminColors.ink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ),
  ]);
}


String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return 'AD';
  if (parts.length == 1) return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
