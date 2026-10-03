part of '../main.dart';

enum AdminSection { dashboard, orders, catalogue, categories, users, partners, invoices }

extension on AdminSection {
  String get label => switch (this) {
    AdminSection.dashboard => 'Overview',
    AdminSection.orders => 'Orders',
    AdminSection.catalogue => 'Products',
    AdminSection.categories => 'Categories',
    AdminSection.users => 'Users',
    AdminSection.partners => 'Delivery partners',
    AdminSection.invoices => 'Invoices & Billing',
  };
  AdminIconData get icon => switch (this) {
    AdminSection.dashboard => HugeIcons.strokeRoundedDashboardSquare01,
    AdminSection.orders => HugeIcons.strokeRoundedInvoice01,
    AdminSection.catalogue => HugeIcons.strokeRoundedPackage01,
    AdminSection.categories => HugeIcons.strokeRoundedFolder01,
    AdminSection.users => HugeIcons.strokeRoundedUserGroup,
    AdminSection.partners => HugeIcons.strokeRoundedDeliveryTruck01,
    AdminSection.invoices => HugeIcons.strokeRoundedInvoice,
  };
  String get subtitle => switch (this) {
    AdminSection.dashboard => 'A clear view of today’s business and operations.',
    AdminSection.orders => 'Track every order from checkout to delivery.',
    AdminSection.catalogue => 'Manage products and availability.',
    AdminSection.categories => 'Organize catalogue categories and availability.',
    AdminSection.users => 'Manage customer accounts and customer access.',
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
    theme: AdminTheme.material(),
    home: shad.ShadcnApp(
      title: 'Snap Foodd Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.shadcn(),
      // ShadcnApp creates its own localization scope. Restore the Material
      // delegates inside it for Material TextField, Scaffold and Tooltip.
      home: Localizations(
        locale: const Locale('en'),
        delegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: const Material(
          color: AdminDesignColors.canvas,
          child: AdminAuthGate(),
        ),
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
  final ScrollController _contentScrollController = ScrollController();
  String _searchQuery = '';
  late final StreamSubscription<html.KeyboardEvent> _keyboardSubscription;

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    _globalSearch.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  void _openCommandPalette() {
    SfCommandPalette.show(
      context,
      sections: AdminSection.values,
      selectedSection: section,
      onSelectSection: _select,
      onSearchInSection: (value, query) {
        _globalSearch.text = query;
        _searchQuery = query;
        _select(value);
      },
      onAddProduct: section == AdminSection.catalogue
          ? () => _catalogueKey.currentState?._newProduct()
          : null,
      onManageCategories: section == AdminSection.catalogue
          ? () => _catalogueKey.currentState?._manageCategories()
          : null,
    );
  }

  void _applyGlobalSearch() {
    final value = _globalSearch.text.trim();
    setState(() => _searchQuery = value);
  }

  @override
  void initState() {
    super.initState();
    _keyboardSubscription = html.window.onKeyDown.listen((event) {
      final key = (event.key ?? '').toLowerCase();
      if ((event.ctrlKey || event.metaKey) && key == 'k') {
        event.preventDefault();
        if (mounted) _openCommandPalette();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1200;
    final rail = width >= 900 && width < 1200;
    final tablet = width >= 600;

    return Scaffold(
      backgroundColor: AdminDesignColors.canvas,
      body: Row(
        children: [
          if (desktop || rail)
            SizedBox(
              width: rail ? 76 : 248,
              height: double.infinity,
              child: _Sidebar(
                selected: section,
                onSelect: _select,
                user: widget.user,
                onLogout: widget.onLogout,
                rail: rail,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _Header(
                  desktop: desktop,
                  user: widget.user,
                  section: section,
                  onLogout: widget.onLogout,
                  searchController: _globalSearch,
                  onSearch: _applyGlobalSearch,
                  onOpenCommandPalette: _openCommandPalette,
                  onOpenNavigation: () => _openMobileNav(
                    context,
                    tablet ? 320 : width * .88,
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: desktop || rail,
                    child: SingleChildScrollView(
                      primary: true,
                      padding: EdgeInsets.fromLTRB(
                        desktop ? AdminSpacing.xl : AdminSpacing.md,
                        desktop ? AdminSpacing.xl : AdminSpacing.lg,
                        desktop ? AdminSpacing.xl : AdminSpacing.md,
                        AdminSpacing.xxxl,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 1280,
                            minWidth: math.min(
                              1280,
                              math.max(
                                0,
                                MediaQuery.sizeOf(context).width -
                                    (desktop ? AdminSpacing.xl * 2 : AdminSpacing.md * 2),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PageHeading(
                                section: section,
                                desktop: desktop,
                                onAddProduct: section == AdminSection.catalogue
                                    ? () => _catalogueKey.currentState?._newProduct()
                                    : null,
                                onManageCategories:
                                    section == AdminSection.catalogue
                                        ? () => _catalogueKey.currentState?._manageCategories()
                                        : null,
                              ),
                              const SizedBox(height: AdminSpacing.xxl),
                              switch (section) {
                                AdminSection.dashboard => const DashboardPage(),
                                AdminSection.orders =>
                                  OrdersPage(searchQuery: _searchQuery),
                                AdminSection.catalogue => CataloguePage(
                                    key: _catalogueKey,
                                    searchQuery: _searchQuery,
                                  ),
                                AdminSection.categories => CategoriesPage(
                                    searchQuery: _searchQuery,
                                  ),
                                AdminSection.users =>
                                  UsersPage(searchQuery: _searchQuery),
                                AdminSection.partners =>
                                  PartnersPage(searchQuery: _searchQuery),
                                AdminSection.invoices =>
                                  InvoicesPage(searchQuery: _searchQuery),
                              },
                              const SizedBox(height: AdminSpacing.xxxl),
                              const Center(
                                child: Text(
                                  'Snap Foodd Admin',
                                  style: AdminTypography.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _select(AdminSection value, [BuildContext? drawerContext]) {
    setState(() => section = value);
    if (drawerContext != null) {
      shad.closeDrawer(drawerContext);
    }
  }

  Future<void> _openMobileNav(BuildContext context, double width) async {
    await shad.openDrawerOverlay<void>(
      context: context,
      position: shad.OverlayPosition.left,
      constraints: BoxConstraints(maxWidth: width),
      builder: (drawerContext) => _Sidebar(
        selected: section,
        onSelect: (value) => _select(value, drawerContext),
        user: widget.user,
        onLogout: widget.onLogout,
        compact: true,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selected,
    required this.onSelect,
    this.compact = false,
    this.rail = false,
    this.user,
    this.onLogout,
  });

  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;
  final bool compact;
  final bool rail;
  final AdminUser? user;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AdminDesignColors.surface,
      border: Border(right: BorderSide(color: AdminDesignColors.border)),
    ),
    child: Material(
      color: AdminDesignColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                rail ? AdminSpacing.sm : compact ? AdminSpacing.lg : AdminSpacing.xl,
                AdminSpacing.xl,
                rail ? AdminSpacing.sm : AdminSpacing.lg,
                AdminSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: rail ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  const _BrandMark(),
                  if (!rail) ...[
                    const SizedBox(width: AdminSpacing.sm),
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Snap Foodd',
                          style: TextStyle(
                            fontFamily: AdminTypography.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AdminDesignColors.primaryText,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'ADMIN CONSOLE',
                          style: TextStyle(
                            fontFamily: AdminTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: AdminDesignColors.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: rail ? 0 : AdminSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NavGroup(
                      label: 'WORKSPACE',
                      items: const [AdminSection.dashboard],
                      selected: selected,
                      onSelect: onSelect,
                      rail: rail,
                    ),
                    const SizedBox(height: AdminSpacing.lg),
                    _NavGroup(
                      label: 'OPERATIONS',
                      items: const [AdminSection.orders, AdminSection.partners],
                      selected: selected,
                      onSelect: onSelect,
                      rail: rail,
                    ),
                    const SizedBox(height: AdminSpacing.lg),
                    _NavGroup(
                      label: 'CATALOGUE',
                      items: const [AdminSection.catalogue],
                      selected: selected,
                      onSelect: onSelect,
                      rail: rail,
                    ),
                    const SizedBox(height: AdminSpacing.lg),
                    _NavGroup(
                      label: 'CUSTOMERS',
                      items: const [AdminSection.users],
                      selected: selected,
                      onSelect: onSelect,
                      rail: rail,
                    ),
                    const SizedBox(height: AdminSpacing.lg),
                    _NavGroup(
                      label: 'FINANCE',
                      items: const [AdminSection.invoices],
                      selected: selected,
                      onSelect: onSelect,
                      rail: rail,
                    ),
                  ],
                ),
              ),
            ),
            if (user != null && onLogout != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AdminSpacing.md,
                  AdminSpacing.sm,
                  AdminSpacing.md,
                  AdminSpacing.md,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AdminSpacing.sm),
                    _SidebarProfile(user: user!, onLogout: onLogout!, compact: rail),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _NavGroup extends StatelessWidget {
  const _NavGroup({
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.rail = false,
  });

  final String label;
  final List<AdminSection> items;
  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;
  final bool rail;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.sm),
        child: rail ? const SizedBox.shrink() : Text(
          label,
          style: AdminTypography.caption.copyWith(
            fontSize: 10,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: AdminSpacing.xs),
      ...items.map(
        (item) => _NavItem(
          item: item,
          active: item == selected,
          onTap: () => onSelect(item),
          rail: rail,
        ),
      ),
    ],
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
    this.rail = false,
  });

  final AdminSection item;
  final bool active;
  final VoidCallback onTap;
  final bool rail;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: active,
    label: item.label,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AdminRadii.control),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AdminRadii.control),
          hoverColor: AdminDesignColors.subtleSurface,
          splashColor: AdminDesignColors.yellowSoft,
          child: AnimatedContainer(
            duration: AdminMotion.navigation,
            curve: AdminMotion.easeOutCubic,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.sm),
            decoration: BoxDecoration(
              color: active ? AdminDesignColors.yellowSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(AdminRadii.control),
              border: active
                  ? const Border.fromBorderSide(
                      BorderSide(color: AdminDesignColors.border),
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: rail ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                AdminIcon(
                  item.icon,
                  size: 18,
                  color: active
                      ? AdminDesignColors.primaryText
                      : AdminDesignColors.secondaryText,
                ),
                if (!rail) ...[
                  const SizedBox(width: AdminSpacing.sm),
                  Expanded(
                    child: Text(
                      item.label,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTypography.body.copyWith(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active
                          ? AdminDesignColors.primaryText
                          : AdminDesignColors.secondaryText,
                    ),
                  ),
                  ),
                ],
                if (active && !rail)
                  const AdminIcon(
                    HugeIcons.strokeRoundedArrowRight01,
                    size: 16,
                    color: AdminDesignColors.secondaryText,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SidebarProfile extends StatelessWidget {
  const _SidebarProfile({required this.user, required this.onLogout, this.compact = false});

  final AdminUser user;
  final Future<void> Function() onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AdminSpacing.sm),
    decoration: BoxDecoration(
      color: AdminDesignColors.surface,
      borderRadius: BorderRadius.circular(AdminRadii.control),
      border: Border.all(color: AdminDesignColors.border),
    ),
    child: Row(
      children: [
        SfAvatar(
          name: user.name,
          size: 34,
          backgroundColor: AdminDesignColors.ink,
          foregroundColor: AdminDesignColors.surface,
        ),
        if (!compact) ...[
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminTypography.small.copyWith(
                    color: AdminDesignColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminTypography.caption,
                ),
              ],
            ),
          ),
        ],
        SfIconButton(
          icon: HugeIcons.strokeRoundedLogout01,
          onPressed: onLogout,
          tooltip: 'Logout',
        ),
      ],
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
    required this.section,
    required this.onLogout,
    required this.searchController,
    required this.onSearch,
    required this.onOpenCommandPalette,
    required this.onOpenNavigation,
  });

  final bool desktop;
  final AdminUser user;
  final AdminSection section;
  final Future<void> Function() onLogout;
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final VoidCallback onOpenCommandPalette;
  final VoidCallback onOpenNavigation;

  @override
  Widget build(BuildContext context) => Container(
    height: desktop ? 76 : 64,
    padding: EdgeInsets.symmetric(
      horizontal: desktop ? AdminSpacing.xl : AdminSpacing.md,
    ),
    decoration: const BoxDecoration(
      color: AdminDesignColors.surface,
      border: Border(bottom: BorderSide(color: AdminDesignColors.border)),
    ),
    child: Row(
      children: [
        if (!desktop) ...[
          SfIconButton(
            icon: HugeIcons.strokeRoundedMenu01,
            onPressed: onOpenNavigation,
            tooltip: 'Open navigation',
          ),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Text(
              section.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AdminTypography.cardTitle.copyWith(fontSize: 16),
            ),
          ),
        ] else ...[
          Expanded(
            child: Row(
              children: [
                Text(
                  section.label,
                  style: AdminTypography.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(width: AdminSpacing.sm),
                Container(
                  width: 1,
                  height: 18,
                  color: AdminDesignColors.border,
                ),
                const SizedBox(width: AdminSpacing.sm),
                Flexible(
                  child: Text(
                    'Admin workspace',
                    overflow: TextOverflow.ellipsis,
                    style: AdminTypography.small,
                  ),
                ),
              ],
            ),
          ),
          _CommandSearchTrigger(
            controller: searchController,
            onOpenCommandPalette: onOpenCommandPalette,
          ),
        ],
        const SizedBox(width: AdminSpacing.sm),
        if (!desktop)
          SfIconButton(
            icon: HugeIcons.strokeRoundedSearch01,
            onPressed: onOpenCommandPalette,
            tooltip: 'Search',
          ),
        SfIconButton(
          icon: HugeIcons.strokeRoundedNotification01,
          onPressed: () => _notice(
            context,
            'No new notifications in preview mode.',
          ),
          tooltip: 'Notifications',
        ),
        if (desktop) ...[
          const SizedBox(width: AdminSpacing.xs),
          PopupMenuButton<String>(
            tooltip: 'Admin profile',
            offset: const Offset(0, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminRadii.card),
            ),
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                value: 'profile',
                child: SizedBox(
                  width: 220,
                  child: Row(
                    children: [
                      SfAvatar(
                        name: user.name,
                        size: 34,
                        backgroundColor: AdminDesignColors.ink,
                        foregroundColor: AdminDesignColors.surface,
                      ),
                      const SizedBox(width: AdminSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AdminTypography.small.copyWith(
                                color: AdminDesignColors.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AdminTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    AdminIcon(HugeIcons.strokeRoundedLogout01, size: 17),
                    SizedBox(width: AdminSpacing.sm),
                    Text('Log out'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  SfAvatar(
                    name: user.name,
                    size: 34,
                    backgroundColor: AdminDesignColors.ink,
                    foregroundColor: AdminDesignColors.surface,
                  ),
                  const SizedBox(width: AdminSpacing.xs),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.small.copyWith(
                        color: AdminDesignColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AdminSpacing.xs),
                  const AdminIcon(
                    HugeIcons.strokeRoundedArrowDown01,
                    size: 16,
                    color: AdminDesignColors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _CommandSearchTrigger extends StatelessWidget {
  const _CommandSearchTrigger({
    required this.controller,
    required this.onOpenCommandPalette,
  });

  final TextEditingController controller;
  final VoidCallback onOpenCommandPalette;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 420,
    height: 42,
    child: Material(
      color: AdminDesignColors.canvas,
      borderRadius: BorderRadius.circular(AdminRadii.input),
      child: InkWell(
        onTap: onOpenCommandPalette,
        borderRadius: BorderRadius.circular(AdminRadii.input),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AdminDesignColors.border),
            borderRadius: BorderRadius.circular(AdminRadii.input),
          ),
          child: Row(
            children: [
              const AdminIcon(
                HugeIcons.strokeRoundedSearch01,
                size: 18,
                color: AdminDesignColors.secondaryText,
              ),
              const SizedBox(width: AdminSpacing.sm),
              Expanded(
                child: Text(
                  'Search orders, users, products…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminTypography.body.copyWith(
                    color: AdminDesignColors.tertiaryText,
                  ),
                ),
              ),
              const SfBadge(
                label: '⌘ K',
                backgroundColor: AdminDesignColors.surface,
              ),
            ],
          ),
        ),
      ),
    ),
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
    final actions = <Widget>[];

    // Keep product creation available on the Catalogue page only. Other pages
    // should not display a generic "Quick action" button.
    if (section == AdminSection.catalogue && onAddProduct != null) {
      actions.add(
        shad.PrimaryButton(
          onPressed: onAddProduct,
          leading: const AdminIcon(HugeIcons.strokeRoundedAdd01, size: 17),
          child: const Text('Add product'),
        ),
      );
    }

    if (section == AdminSection.catalogue && onManageCategories != null) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: 10));
      }
      actions.add(
        shad.OutlineButton(
          onPressed: onManageCategories,
          leading: const AdminIcon(HugeIcons.strokeRoundedTag01, size: 17),
          child: const Text('Manage Categories'),
        ),
      );
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
