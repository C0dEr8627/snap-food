part of '../main.dart';

class UsersPage extends flutter.StatefulWidget {
  const UsersPage({super.key, this.searchQuery = ''});
  final String searchQuery;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends flutter.State<UsersPage> {
  final _api = const _UsersApi();
  final _search = TextEditingController();
  List<_PlatformUser> _users = [];
  int _total = 0;
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  String _filter = 'ALL';
  String? _error;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
    _load();
  }

  @override
  void dispose() {
    _search.removeListener(_refresh);
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UsersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _search.text != widget.searchQuery) {
      _search.text = widget.searchQuery;
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.list(page: page, search: _search.text.trim(), role: _filter);
      if (!mounted) return;
      setState(() {
        _users = result.items;
        _total = result.total;
        _page = result.currentPage;
        _lastPage = result.lastPage;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Bad state: ', '');
      });
    }
  }

  @override
  flutter.Widget build(BuildContext context) {
    final users = _users;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UsersToolbar(
          controller: _search,
          filter: _filter,
          onFilter: (value) {
            setState(() => _filter = value);
            _load(page: 1);
          },
          onSearch: () => _load(page: 1),
          onRefresh: () => _load(page: _page),
          loading: _loading,
        ),
        const SizedBox(height: 14),
        if (_error != null)
          _UsersError(message: _error!, onRetry: () => _load(page: _page))
        else if (_loading)
          const _UsersLoading()
        else if (users.isEmpty)
          _UsersEmpty()
        else
          _UsersTable(users: users, onView: (user) => _showDetails(user)),
        if (!_loading && _error == null && _total > 0) ...[
          const SizedBox(height: 12),
          _UsersPagination(
            page: _page,
            lastPage: _lastPage,
            total: _total,
            visible: users.length,
            onPage: (page) => _load(page: page),
          ),
        ],
      ],
    );
  }

  Future<void> _showDetails(_PlatformUser user) async {
    await SfSideDrawer.show<void>(
      context,
      title: user.name.isEmpty ? 'User details' : user.name,
      width: 460,
      child: _UserDetails(user: user),
    );
  }
}

class _UsersApi {
  const _UsersApi();

  String get base {
    final value = apiBaseUrl.trim();
    return (value.isEmpty ? 'http://localhost:8000/api/v1' : value)
        .replaceFirst(RegExp(r'/+$'), '');
  }
  String get token => html.window.localStorage['snap_foodd_admin_token'] ?? '';

  Map<String, String> get headers => {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<_UsersPage> list({required int page, required String search, String? role}) async {
    if (token.isEmpty) {
      throw StateError('Admin session is not available. Please sign in again.');
    }
    final params = <String, String>{
      'page': page.toString(),
      'per_page': '20',
      if (search.isNotEmpty) 'search': search,
      if (role != null && role.isNotEmpty && role != 'ALL') 'role': role,
    };
    final uri = Uri.parse('$base/admin/users').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'Users request failed (${response.statusCode}).';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] is String && (body['message'] as String).isNotEmpty) {
          message = body['message'] as String;
        }
      } catch (_) {
        // Keep the status-based fallback for non-JSON error responses.
      }
      throw StateError('$message (HTTP ${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['data'] is! Map) {
      throw StateError('The users API returned an unexpected response.');
    }
    final data = decoded['data'] as Map;
    final raw = data['data'];
    final items = raw is List
        ? raw.whereType<Map>().map(_PlatformUser.fromJson).toList()
        : <_PlatformUser>[];
    return _UsersPage(
      items: items,
      total: _usersInt(data['total'], items.length),
      currentPage: _usersInt(data['current_page'], page),
      lastPage: _usersInt(data['last_page'], 1),
    );
  }
}

class _UsersPage {
  const _UsersPage({required this.items, required this.total, required this.currentPage, required this.lastPage});
  final List<_PlatformUser> items;
  final int total;
  final int currentPage;
  final int lastPage;
}

class _PlatformUser {
  const _PlatformUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.ordersCount,
    required this.addresses,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final bool active;
  final String createdAt;
  final int ordersCount;
  final List<_UserAddress> addresses;

  factory _PlatformUser.fromJson(Map json) {
    final rawAddresses = json['addresses'];
    return _PlatformUser(
      id: _usersInt(json['id'], 0),
      name: (json['name'] ?? 'Unnamed user').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'UNKNOWN').toString(),
      active: json['is_active'] == true,
      createdAt: (json['created_at'] ?? '').toString(),
      ordersCount: _usersInt(json['orders_count'], 0),
      addresses: rawAddresses is List
          ? rawAddresses.whereType<Map>().map(_UserAddress.fromJson).toList()
          : const [],
    );
  }
}

class _UserAddress {
  const _UserAddress({
    required this.label,
    required this.recipientName,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  final String label, recipientName, line1, line2, city, state, postalCode, country;

  factory _UserAddress.fromJson(Map json) => _UserAddress(
        label: (json['label'] ?? 'Address').toString(),
        recipientName: (json['recipient_name'] ?? '').toString(),
        line1: (json['address_line1'] ?? '').toString(),
        line2: (json['address_line2'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        state: (json['state'] ?? '').toString(),
        postalCode: (json['postal_code'] ?? '').toString(),
        country: (json['country'] ?? '').toString(),
      );
}


class _UsersToolbar extends flutter.StatelessWidget {
  const _UsersToolbar({
    required this.controller,
    required this.filter,
    required this.onFilter,
    required this.onSearch,
    required this.onRefresh,
    required this.loading,
  });
  final TextEditingController controller;
  final String filter;
  final ValueChanged<String> onFilter;
  final VoidCallback onSearch;
  final VoidCallback onRefresh;
  final bool loading;

  @override
  flutter.Widget build(BuildContext context) => SfCard(
    padding: const EdgeInsets.all(AdminSpacing.md),
    child: Wrap(
      spacing: AdminSpacing.sm,
      runSpacing: AdminSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: SfSearchField(
            controller: controller,
            hintText: 'Search name, email or user ID',
            onSubmitted: (_) => onSearch(),
          ),
        ),
        _UsersFilterPill('All', filter == 'ALL', () => onFilter('ALL')),
        _UsersFilterPill('Admin', filter == 'ADMIN', () => onFilter('ADMIN')),
        _UsersFilterPill('Customers', filter == 'CUSTOMER', () => onFilter('CUSTOMER')),
        _UsersFilterPill('Delivery Partners', filter == 'DELIVERY_PARTNER', () => onFilter('DELIVERY_PARTNER')),
        SfButton(
          variant: SfButtonVariant.outline,
          onPressed: loading ? null : onRefresh,
          child: const Text('Refresh'),
        ),
      ],
    ),
  );
}

class _UsersFilterPill extends flutter.StatelessWidget {
  const _UsersFilterPill(this.label, this.active, this.onTap);
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  flutter.Widget build(BuildContext context) => SfButton(
    variant: active ? SfButtonVariant.secondary : SfButtonVariant.ghost,
    onPressed: onTap,
    child: Text(label),
  );
}

class _UsersError extends flutter.StatelessWidget {
  const _UsersError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  flutter.Widget build(BuildContext context) => SfErrorState(
    title: 'Unable to load users',
    message: message,
    onRetry: onRetry,
  );
}

class _UsersPagination extends flutter.StatelessWidget {
  const _UsersPagination({
    required this.page,
    required this.lastPage,
    required this.total,
    required this.visible,
    required this.onPage,
  });
  final int page;
  final int lastPage;
  final int total;
  final int visible;
  final ValueChanged<int> onPage;

  @override
  flutter.Widget build(BuildContext context) => SfTablePagination(
    page: page,
    lastPage: lastPage,
    total: total,
    onPrevious: page > 1 ? () => onPage(page - 1) : null,
    onNext: page < lastPage ? () => onPage(page + 1) : null,
  );
}

class _UsersTable extends flutter.StatelessWidget {
  const _UsersTable({required this.users, required this.onView});
  final List<_PlatformUser> users;
  final ValueChanged<_PlatformUser> onView;

  @override
  flutter.Widget build(BuildContext context) => SfDataTable(
    minWidth: 1180,
    columns: const [
      SfDataTableColumn(label: 'ID', width: 80),
      SfDataTableColumn(label: 'User', width: 240),
      SfDataTableColumn(label: 'Email', width: 250),
      SfDataTableColumn(label: 'Role', width: 150),
      SfDataTableColumn(label: 'Status', width: 120),
      SfDataTableColumn(label: 'Orders', width: 90, alignment: Alignment.centerRight),
      SfDataTableColumn(label: 'Addresses', width: 110, alignment: Alignment.centerRight),
      SfDataTableColumn(label: 'Joined', width: 140),
      SfDataTableColumn(label: '', width: 80, alignment: Alignment.centerRight),
    ],
    rows: users.map((user) => [
      Text('#\${user.id}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.small.copyWith(fontWeight: FontWeight.w700)),
      Row(children: [
        SfAvatar(name: user.name, size: 36),
        const SizedBox(width: AdminSpacing.sm),
        Expanded(child: Text(user.name.isEmpty ? 'Unnamed user' : user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600))),
      ]),
      Text(user.email.isEmpty ? 'Not provided' : user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
      SfStatusBadge(label: user.role),
      SfStatusBadge(label: user.active ? 'Active' : 'Inactive', status: user.active ? 'active' : 'inactive'),
      Text(user.ordersCount.toString(), style: AdminTypography.body),
      Text(user.addresses.length.toString(), style: AdminTypography.body),
      Text(_formatUserTimestamp(user.createdAt), maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.small),
      SfIconButton(icon: HugeIcons.strokeRoundedArrowRight01, onPressed: () => onView(user), tooltip: 'View user details'),
    ]).toList(),
    onRowTap: (index) => onView(users[index]),
  );
}
class _UsersEmpty extends flutter.StatelessWidget {
  const _UsersEmpty();

  @override
  flutter.Widget build(BuildContext context) => SfCard(
        padding: const EdgeInsets.all(AdminSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AdminIcon(HugeIcons.strokeRoundedUser, size: 32, color: AdminDesignColors.secondaryText),
            const SizedBox(height: AdminSpacing.md),
            Text('No users found', style: AdminTypography.sectionTitle),
            const SizedBox(height: AdminSpacing.xs),
            Text(
              'Try a different search or role filter.',
              textAlign: TextAlign.center,
              style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText),
            ),
          ],
        ),
      );
}

class _UsersLoading extends flutter.StatelessWidget {
  const _UsersLoading();

  @override
  flutter.Widget build(BuildContext context) => SfCard(
        padding: const EdgeInsets.all(AdminSpacing.xl),
        child: Column(
          children: [
            for (var i = 0; i < 5; i++) ...[
              Row(
                children: [
                  const SfSkeleton(width: 52, height: 14),
                  const SizedBox(width: AdminSpacing.md),
                  const SfSkeleton(width: 180, height: 14),
                  const Spacer(),
                  const SfSkeleton(width: 120, height: 14),
                ],
              ),
              if (i < 4) const SizedBox(height: AdminSpacing.lg),
            ],
          ],
        ),
      );
}

class _UserDetails extends flutter.StatelessWidget {
  const _UserDetails({required this.user});
  final _PlatformUser user;

  @override
  flutter.Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SfAvatar(name: user.name, size: 52),
              const SizedBox(width: AdminSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name.isEmpty ? 'Unnamed user' : user.name, style: AdminTypography.sectionTitle),
                    const SizedBox(height: AdminSpacing.xxs),
                    Text(user.email.isEmpty ? 'Not provided' : user.email, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
                    const SizedBox(height: AdminSpacing.sm),
                    Wrap(
                      spacing: AdminSpacing.xs,
                      runSpacing: AdminSpacing.xs,
                      children: [
                        SfStatusBadge(label: user.role),
                        SfStatusBadge(label: user.active ? 'Active' : 'Inactive', status: user.active ? 'active' : 'inactive'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.xl),
          _UserDetailSection(title: 'Account', children: [
            _UserDetailLine('User ID', '#${user.id}'),
            _UserDetailLine('Joined', _formatUserTimestamp(user.createdAt)),
          ]),
          const SizedBox(height: AdminSpacing.lg),
          _UserDetailSection(title: 'Activity', children: [
            _UserDetailLine('Orders', user.ordersCount.toString()),
            _UserDetailLine('Saved addresses', user.addresses.length.toString()),
          ]),
          const SizedBox(height: AdminSpacing.lg),
          _UserDetailSection(
            title: 'Addresses',
            children: user.addresses.isEmpty
                ? [Text('No address has been saved for this account.', style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText))]
                : user.addresses.map((address) => _AddressCard(address: address)).toList(),
          ),
        ],
      );
}

class _UserDetailSection extends flutter.StatelessWidget {
  const _UserDetailSection({required this.title, required this.children});
  final String title;
  final List<flutter.Widget> children;

  @override
  flutter.Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AdminTypography.cardTitle),
          const SizedBox(height: AdminSpacing.sm),
          SfCard(padding: const EdgeInsets.all(AdminSpacing.md), child: Column(children: children)),
        ],
      );
}

class _UserDetailLine extends flutter.StatelessWidget {
  const _UserDetailLine(this.label, this.value);
  final String label;
  final String value;

  @override
  flutter.Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AdminSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 118, child: Text(label, style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText))),
            Expanded(child: Text(value.isEmpty ? 'Not provided' : value, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}

class _AddressCard extends flutter.StatelessWidget {
  const _AddressCard({required this.address});
  final _UserAddress address;

  @override
  flutter.Widget build(BuildContext context) {
    final lines = [
      if (address.recipientName.isNotEmpty) address.recipientName,
      if (address.line1.isNotEmpty) address.line1,
      if (address.line2.isNotEmpty) address.line2,
      [
        if (address.city.isNotEmpty) address.city,
        if (address.state.isNotEmpty) address.state,
        if (address.postalCode.isNotEmpty) address.postalCode,
      ].where((part) => part.isNotEmpty).join(', '),
      if (address.country.isNotEmpty) address.country,
    ].where((line) => line.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AdminSpacing.sm),
      padding: const EdgeInsets.all(AdminSpacing.md),
      decoration: BoxDecoration(
        color: AdminDesignColors.subtleSurface,
        borderRadius: BorderRadius.circular(AdminRadii.control),
        border: Border.all(color: AdminDesignColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(address.label, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w700))),
              const AdminIcon(HugeIcons.strokeRoundedLocation01, size: 16, color: AdminDesignColors.secondaryText),
            ],
          ),
          const SizedBox(height: AdminSpacing.xs),
          Text(lines.isEmpty ? 'Address details are not available.' : lines.join('\n'), style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText, height: 1.45)),
        ],
      ),
    );
  }
}

int _usersInt(dynamic value, [int fallback = 0]) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? fallback;

String _formatUserTimestamp(String value) {
  if (value.isEmpty) return 'Not recorded';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final d = parsed.toLocal();
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · $hour:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
}