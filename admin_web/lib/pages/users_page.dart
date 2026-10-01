part of '../main.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, this.searchQuery = ''});
  final String searchQuery;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
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

  List<_PlatformUser> get _filtered {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _users;
    return _users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.id.toString().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final users = _filtered;
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
          const _UsersEmpty()
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
    await shad.showOverlay<void>(
      context,
      shad.DialogConfiguration(),
      builder: (dialogContext) => shad.AlertDialog(
        title: Text(user.name),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserDetailSection(
                  title: 'Account',
                  children: [
                    _UserDetailLine('User ID', '#${user.id}'),
                    _UserDetailLine('Name', user.name),
                    _UserDetailLine('Email', user.email.isEmpty ? 'Not provided' : user.email),
                    _UserDetailLine('Role', user.role),
                    _UserDetailLine('Status', user.active ? 'Active' : 'Inactive'),
                    _UserDetailLine('Joined', _formatTimestamp(user.createdAt)),
                  ],
                ),
                const SizedBox(height: 16),
                _UserDetailSection(
                  title: 'Activity',
                  children: [
                    _UserDetailLine('Orders', user.ordersCount.toString()),
                    _UserDetailLine('Saved addresses', user.addresses.length.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                _UserDetailSection(
                  title: 'Addresses',
                  children: user.addresses.isEmpty
                      ? [const Text('No address has been saved for this account.', style: TextStyle(fontSize: 12, color: AdminColors.muted))]
                      : user.addresses.map((address) => _AddressCard(address: address)).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          shad.OutlineButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _UsersApi {
  const _UsersApi();

  String get base {
    final value = apiBaseUrl.trim();
    return (value.isEmpty ? 'https://api.snapfoodd.in/api/v1' : value).replaceFirst(RegExp(r'/$'), '');
  }

  String get token => html.window.localStorage['snap_foodd_admin_token'] ?? '';

  Map<String, String> get headers => {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<_UsersPage> list({required int page, required String search, required String role}) async {
    if (token.isEmpty) {
      throw StateError('Admin session is not available. Please sign in again.');
    }
    final params = <String, String>{
      'page': page.toString(),
      'per_page': '20',
      if (search.isNotEmpty) 'search': search,
      if (role != 'ALL') 'role': role,
    };
    final uri = Uri.parse('$base/admin/users').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Users request failed (${response.statusCode}).');
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

class _UsersToolbar extends StatelessWidget {
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AdminColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 330,
              child: shad.TextField(
                controller: controller,
                onSubmitted: (_) => onSearch(),
                hintText: 'Search name, email or user ID...',
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            _UsersFilter('ALL', filter == 'ALL', () => onFilter('ALL')),
            _UsersFilter('CUSTOMER', filter == 'CUSTOMER', () => onFilter('CUSTOMER')),
            _UsersFilter('DELIVERY_PARTNER', filter == 'DELIVERY_PARTNER', () => onFilter('DELIVERY_PARTNER')),
            _UsersFilter('ADMIN', filter == 'ADMIN', () => onFilter('ADMIN')),
            shad.IconButton.ghost(
              onPressed: loading ? null : onRefresh,
              icon: const AdminIcon(HugeIcons.strokeRoundedRefresh, size: 18),
            ),
          ],
        ),
      );
}

class _UsersFilter extends StatelessWidget {
  const _UsersFilter(this.label, this.active, this.onTap);
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => (active ? shad.Button.secondary : shad.Button.ghost)(
        onPressed: onTap,
        child: Text(label == 'DELIVERY_PARTNER' ? 'DELIVERY' : label),
      );
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({required this.users, required this.onView});
  final List<_PlatformUser> users;
  final ValueChanged<_PlatformUser> onView;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AdminColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 930),
            child: shad.Table(
              rows: [
                shad.TableHeader(cells: const [
                  shad.TableCell(child: Text('USER')),
                  shad.TableCell(child: Text('ROLE')),
                  shad.TableCell(child: Text('STATUS')),
                  shad.TableCell(child: Text('ORDERS')),
                  shad.TableCell(child: Text('ADDRESSES')),
                  shad.TableCell(child: Text('JOINED')),
                  shad.TableCell(child: Text('ACTIONS')),
                ]),
                ...users.map((user) => shad.TableRow(cells: [
                      shad.TableCell(
                        child: SizedBox(
                          width: 190,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text(user.email.isEmpty ? 'No email recorded' : user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: AdminColors.muted)),
                              Text('#${user.id}', style: const TextStyle(fontSize: 10, color: AdminColors.muted)),
                            ],
                          ),
                        ),
                      ),
                      shad.TableCell(child: _UserRolePill(user.role)),
                      shad.TableCell(child: _UserStatusPill(user.active)),
                      shad.TableCell(child: Text(user.ordersCount.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                      shad.TableCell(child: Text(user.addresses.length.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                      shad.TableCell(child: Text(_formatTimestamp(user.createdAt), style: const TextStyle(fontSize: 10.5, color: AdminColors.muted))),
                      shad.TableCell(child: shad.OutlineButton(onPressed: () => onView(user), child: const Text('View'))),
                    ])),
              ],
              columnWidths: const {
                0: shad.FlexTableSize(flex: 3),
                1: shad.FixedTableSize(140),
                2: shad.FixedTableSize(100),
                3: shad.FixedTableSize(80),
                4: shad.FixedTableSize(95),
                5: shad.FixedTableSize(150),
                6: shad.FixedTableSize(90),
              },
            ),
          ),
        ),
      );
}

class _UserRolePill extends StatelessWidget {
  const _UserRolePill(this.role);
  final String role;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(20)),
        child: Text(role == 'DELIVERY_PARTNER' ? 'DELIVERY' : role, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AdminColors.ink)),
      );
}

class _UserStatusPill extends StatelessWidget {
  const _UserStatusPill(this.active);
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AdminColors.greenSoft : AdminColors.redSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(active ? 'ACTIVE' : 'INACTIVE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: active ? AdminColors.green : AdminColors.red)),
      );
}

class _UserDetailSection extends StatelessWidget {
  const _UserDetailSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .7, color: AdminColors.muted)),
          const SizedBox(height: 8),
          ...children,
        ]),
      );
}

class _UserDetailLine extends StatelessWidget {
  const _UserDetailLine(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 125, child: Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.muted))),
          Expanded(child: Text(value.isEmpty ? 'Not recorded' : value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
        ]),
      );
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final _UserAddress address;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if (address.recipientName.isNotEmpty) address.recipientName,
      if (address.line1.isNotEmpty) address.line1,
      if (address.line2.isNotEmpty) address.line2,
      [address.city, address.state, address.postalCode].where((v) => v.isNotEmpty).join(', '),
      if (address.country.isNotEmpty) address.country,
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AdminColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(address.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(lines.where((v) => v.isNotEmpty).join('\n'), style: const TextStyle(fontSize: 11, color: AdminColors.muted, height: 1.45)),
      ]),
    );
  }
}

class _UsersPagination extends StatelessWidget {
  const _UsersPagination({required this.page, required this.lastPage, required this.total, required this.visible, required this.onPage});
  final int page, lastPage, total, visible;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text('Showing ${visible} on this page · ${total} total users', style: const TextStyle(fontSize: 11, color: AdminColors.muted))),
          shad.OutlineButton(onPressed: page > 1 ? () => onPage(page - 1) : null, child: const Text('Previous')),
          const SizedBox(width: 6),
          Text('$page / $lastPage'.replaceFirst('$', ''), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(width: 6),
          shad.OutlineButton(onPressed: page < lastPage ? () => onPage(page + 1) : null, child: const Text('Next')),
        ],
      );
}

class _UsersLoading extends StatelessWidget {
  const _UsersLoading();
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(40), child: shad.CircularProgressIndicator()));
}

class _UsersEmpty extends StatelessWidget {
  const _UsersEmpty();
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('No users found.', style: TextStyle(fontSize: 12, color: AdminColors.muted))));
}

class _UsersError extends StatelessWidget {
  const _UsersError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AdminColors.redSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: AdminColors.line)), child: Column(children: [
    const Text('Could not load users', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6),
    Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, color: AdminColors.muted)),
    const SizedBox(height: 12),
    shad.OutlineButton(onPressed: onRetry, child: const Text('Retry')),
  ]));
}

int _usersInt(dynamic value, [int fallback = 0]) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? fallback;

String _formatTimestamp(String value) {
  if (value.isEmpty) return 'Not recorded';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final d = parsed.toLocal();
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · $hour:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
}
