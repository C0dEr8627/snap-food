part of '../main.dart';

enum AdminSection { dashboard, orders, catalogue, users, partners, invoices }

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
    AdminSection.users => HugeIcons.strokeRoundedUserGroup,
    AdminSection.partners => HugeIcons.strokeRoundedDeliveryTruck01,
    AdminSection.invoices => HugeIcons.strokeRoundedInvoice,
  };
  String get subtitle => switch (this) {
    AdminSection.dashboard => 'A clear view of today’s business and operations.',
    AdminSection.orders => 'Track every order from checkout to delivery.',
    AdminSection.catalogue => 'Manage categories and menu items.',
    AdminSection.users => 'View customer accounts, activity and saved addresses.',
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
      colorScheme: ColorScheme.fromSeed(seedColor: AdminColors.amber),
      scaffoldBackgroundColor: AdminColors.canvas,
      useMaterial3: true,
    ),
    home: shad.ShadcnApp(
      title: 'Snap Foodd Admin',
      debugShowCheckedModeBanner: false,
      theme: shad.ThemeData(
        colorScheme: shad.LegacyColorSchemes.lightZinc(),
        radius: 0.65,
      ),
      // ShadcnApp creates its own localization scope. Restore the Material
      // delegates inside it for Material TextField, Scaffold and Tooltip.
      home: Localizations(
        locale: const Locale('en'),
        delegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: const AdminAuthGate(),
      ),
    ),
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
  final GlobalKey<_CataloguePageState> _catalogueKey = GlobalKey<_CataloguePageState>();
  final TextEditingController _globalSearch = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _globalSearch.dispose();
    super.dispose();
  }

  void _applyGlobalSearch() {
    final value = _globalSearch.text.trim();
    setState(() => _searchQuery = value);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1050;
    final tablet = width >= 720;
    return Scaffold(
      drawer: null,
      body: Row(children: [
        if (desktop) SizedBox(width: 248, height: double.infinity, child: _Sidebar(selected: section, onSelect: _select)),
        Expanded(child: Column(children: [
          _Header(
            desktop: desktop,
            user: widget.user,
            onLogout: widget.onLogout,
            searchController: _globalSearch,
            searchQuery: _searchQuery,
            onSearch: _applyGlobalSearch,
          ),
          Expanded(child: LayoutBuilder(builder: (context, constraints) => Scrollbar(thumbVisibility: desktop, child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(desktop ? 24 : 16, 24, desktop ? 24 : 16, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (!desktop) Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(children: [
                      shad.IconButton.secondary(
                        onPressed: () => _openMobileNav(context, tablet ? 300 : width * .84),
                        icon: const AdminIcon(HugeIcons.strokeRoundedMenu01),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(section.label, style: Theme.of(context).textTheme.headlineSmall)),
                    ]),
                  ),
                  if (section != AdminSection.partners && section != AdminSection.invoices)
                    _PageHeading(
                      section: section,
                      desktop: desktop,
                      onAddProduct: section == AdminSection.catalogue
                          ? () => _catalogueKey.currentState?._newProduct()
                          : null,
                      onManageCategories: section == AdminSection.catalogue
                          ? () => _catalogueKey.currentState?._manageCategories()
                          : null,
                    ),
                  const SizedBox(height: 24),
                  switch (section) {
                    AdminSection.dashboard => const DashboardPage(),
                    AdminSection.orders => OrdersPage(searchQuery: _searchQuery),
                    AdminSection.catalogue => CataloguePage(key: _catalogueKey, searchQuery: _searchQuery),
                    AdminSection.users => UsersPage(searchQuery: _searchQuery),
                    AdminSection.partners => PartnersPage(searchQuery: _searchQuery),
                    AdminSection.invoices => InvoicesPage(searchQuery: _searchQuery),
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
    shad.closeDrawer(context);
  }

  Future<void> _openMobileNav(BuildContext context, double width) async {
    await shad.openDrawerOverlay<void>(
      context: context,
      position: shad.OverlayPosition.left,
      constraints: BoxConstraints(maxWidth: width),
      builder: (drawerContext) => _Sidebar(
        selected: section,
        onSelect: _select,
        compact: true,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect, this.compact = false});
  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: AdminColors.line, width: 1)),
    ),
    child: Material(
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
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 18, 9),
            child: Align(alignment: Alignment.centerLeft, child: Text('NAVIGATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AdminColors.muted))),
          ),
          ...AdminSection.values.map((item) {
            final active = item == selected;
            final button = active
                ? shad.Button.secondary(
                    onPressed: () => onSelect(item),
                    leading: AdminIcon(item.icon, size: 18),
                    trailing: const AdminIcon(HugeIcons.strokeRoundedArrowRight01, size: 16),
                    child: Text(item.label),
                  )
                : shad.Button.ghost(
                    onPressed: () => onSelect(item),
                    leading: AdminIcon(item.icon, size: 18),
                    child: Text(item.label),
                  );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Semantics(
                button: true,
                selected: active,
                label: item.label,
                child: button.sized(width: double.infinity, height: 44),
              ),
            );
          }),
        ],
      ),
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
  const _Header({
    required this.desktop,
    required this.user,
    required this.onLogout,
    required this.searchController,
    required this.searchQuery,
    required this.onSearch,
  });
  final bool desktop;
  final AdminUser user;
  final Future<void> Function() onLogout;
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) => Container(
    height: desktop ? 78 : 64,
    padding: EdgeInsets.symmetric(horizontal: desktop ? 24 : 16),
    decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AdminColors.line))),
    child: Row(children: [
      if (desktop)
        Expanded(
          flex: 3,
          child: shad.TextField(
            controller: searchController,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            hintText: 'Search this section...',
            style: const TextStyle(fontSize: 11, color: AdminColors.ink),
            filled: true,
            border: const Border.fromBorderSide(BorderSide(color: AdminColors.line)),
            borderRadius: BorderRadius.circular(11),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            features: const [shad.InputClearFeature()],
          ).constrained(maxWidth: 560, height: 42),
        )
      else
        const Expanded(child: Text('Snap Foodd Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
      if (desktop) const SizedBox(width: 16),
      const SizedBox(width: 10),
      Tooltip(
        message: 'Notifications',
        child: shad.IconButton.ghost(
          onPressed: () => _notice(context, 'No new notifications in preview mode.'),
          icon: const AdminIcon(HugeIcons.strokeRoundedNotification01, size: 20),
        ),
      ),
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
        Tooltip(
          message: 'Logout',
          child: shad.IconButton.ghost(
            onPressed: onLogout,
            icon: const AdminIcon(HugeIcons.strokeRoundedLogout01, size: 18),
          ),
        ),
      ],
    ]),
  );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.section,
    required this.desktop,
    this.onAddProduct,
    this.onManageCategories,
  });

  final AdminSection section;
  final bool desktop;
  final VoidCallback? onAddProduct;
  final VoidCallback? onManageCategories;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      shad.PrimaryButton(
        onPressed: onAddProduct ??
            () => _notice(
                  context,
                  section == AdminSection.catalogue
                      ? 'Product creation will connect to the Laravel API.'
                      : 'This action will connect to the Laravel API.',
                ),
        leading: const AdminIcon(HugeIcons.strokeRoundedAdd01, size: 17),
        child: Text(section == AdminSection.catalogue ? 'Add product' : 'Quick action'),
      ),
    ];

    if (section == AdminSection.catalogue && onManageCategories != null) {
      actions.addAll([
        const SizedBox(width: 10),
        shad.OutlineButton(
          onPressed: onManageCategories,
          leading: const AdminIcon(HugeIcons.strokeRoundedTag01, size: 17),
          child: const Text('Manage Categories'),
        ),
      ]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (desktop)
                Text(
                  section.label,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              if (desktop) const SizedBox(height: 5),
              Text(
                section.subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AdminColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (desktop) ...actions,
      ],
    );
  }
}


String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return 'AD';
  if (parts.length == 1) return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
