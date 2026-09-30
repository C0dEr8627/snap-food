part of '../main.dart';

/// Delivery partner operations view. This page intentionally uses the existing
/// AdminShell section and the authenticated Laravel admin API.
class PartnersPage extends StatefulWidget {
  const PartnersPage({super.key, this.searchQuery = ''});
  final String searchQuery;

  @override
  State<PartnersPage> createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage> {
  final _api = const _DeliveryPartnerApi();
  final _search = TextEditingController();
  List<_DeliveryPartnerRecord> _partners = [];
  int _total = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _busy = false;
  String _filter = 'ALL';
  String? _error;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refreshView);
    _loadPartners();
  }

  @override
  void dispose() {
    _search.removeListener(_refreshView);
    _search.dispose();
    super.dispose();
  }

  void _refreshView() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant PartnersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _search.text != widget.searchQuery) {
      _search.text = widget.searchQuery;
      _refreshView();
    }
  }

  Future<void> _loadPartners({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.list(page: page);
      if (!mounted) return;
      setState(() {
        _partners = result.items;
        _total = result.total;
        _currentPage = result.currentPage;
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

  List<_DeliveryPartnerRecord> get _filtered {
    final query = _search.text.trim().toLowerCase();
    return _partners.where((partner) {
      final statusMatches = switch (_filter) {
        'PENDING' => !partner.approved,
        'ACTIVE' => partner.approved && partner.active,
        'INACTIVE' => !partner.active,
        _ => true,
      };
      final queryMatches = query.isEmpty ||
          partner.name.toLowerCase().contains(query) ||
          partner.email.toLowerCase().contains(query) ||
          partner.id.toString().contains(query);
      return statusMatches && queryMatches;
    }).toList();
  }

  int _count(String filter) => _partners.where((partner) {
        return switch (filter) {
          'PENDING' => !partner.approved,
          'ACTIVE' => partner.approved && partner.active,
          'INACTIVE' => !partner.active,
          _ => true,
        };
      }).length;

  Future<void> _setApproval(_DeliveryPartnerRecord partner, bool approved) async {
    if (!_api.configured) {
      _partnersNotice(context, 'Configure API_TOKEN to change partner approval.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final updated = await _api.setApproval(partner.id, approved);
      if (!mounted) return;
      setState(() {
        final index = _partners.indexWhere((item) => item.id == updated.id);
        if (index >= 0) _partners[index] = updated;
        _busy = false;
      });
      _partnersNotice(context, approved
          ? 'Partner approval saved.'
          : 'Partner approval removed. Availability was disabled by the server.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _partnersNotice(context, e.toString().replaceFirst('Bad state: ', ''), error: true);
    }
  }

  Future<void> _manualOnboard() async {
    if (!_api.configured) {
      _partnersNotice(context, 'Configure API_TOKEN to onboard a delivery partner.', error: true);
      return;
    }
    final controller = TextEditingController();
    final userId = await shad.showOverlay<int>(context, shad.DialogConfiguration<int>(builder: (dialogContext) => shad.AlertDialog(
        title: const Text('Manual partner onboarding'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The existing backend provisions an existing active user by ID. '
                'It does not create a user account or accept KYC documents here.',
                style: TextStyle(fontSize: 12, color: AdminColors.muted, height: 1.5),
              ),
              const SizedBox(height: 14),
              shad.TextField(controller: controller, keyboardType: TextInputType.number, autofocus: true, label: const Text('Existing user ID'), placeholder: const Text('Enter a user ID')),
            ],
          ),
        ),
        actions: [
          shad.OutlineButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          shad.PrimaryButton(onPressed: () { final value = int.tryParse(controller.text.trim()); if (value == null || value < 1) { _partnersNotice(dialogContext, 'Enter a valid positive user ID.', error: true); return; } Navigator.pop(dialogContext, value); }, child: const Text('Create partner')),
        ],
      ))).future;
    controller.dispose();
    if (userId == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await _api.create(userId: userId);
      if (!mounted) return;
      setState(() => _busy = false);
      await _loadPartners(page: 1);
      if (mounted) _partnersNotice(context, 'Partner record created. Admin approval is still required.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _partnersNotice(context, e.toString().replaceFirst('Bad state: ', ''), error: true);
    }
  }

  void _exportRoster() {
    final rows = <List<String>>[
      ['Partner ID', 'Name', 'Email', 'Approved', 'Active', 'Available'],
      ..._filtered.map((p) => [
            p.id.toString(),
            p.name,
            p.email,
            p.approved ? 'Yes' : 'No',
            p.active ? 'Yes' : 'No',
            p.available ? 'Yes' : 'No',
          ]),
    ];
    String cell(String value) => '"${value.replaceAll('"', '""')}"';
    final csv = rows.map((row) => row.map(cell).join(',')).join('\n');
    final blob = html.Blob([utf8.encode(csv)], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = 'snap-foodd-delivery-partners.csv'
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PartnerCommandHeader(
          apiConfigured: _api.configured,
          onExport: _exportRoster,
          onManualOnboard: _manualOnboard,
        ),
        const SizedBox(height: 18),
        if (_error != null)
          _PartnerErrorBanner(message: _error!, onRetry: () => _loadPartners(page: _currentPage)),
        if (_error != null) const SizedBox(height: 14),
        _FleetSummary(
          partners: _partners,
          total: _total,
          loading: _loading,
          apiConfigured: _api.configured,
        ),
        const SizedBox(height: 18),
        _PartnerFilterBar(
          controller: _search,
          filter: _filter,
          counts: {
            'ALL': _partners.length,
            'ACTIVE': _count('ACTIVE'),
            'PENDING': _count('PENDING'),
            'INACTIVE': _count('INACTIVE'),
          },
          onFilter: (value) => setState(() => _filter = value),
          onRefresh: () => _loadPartners(page: _currentPage),
          loading: _loading,
        ),
        const SizedBox(height: 14),
        if (_loading)
          const _PartnerLoadingState()
        else if (_error == null && _filtered.isEmpty)
          _PartnerEmptyState(
            hasQuery: _search.text.trim().isNotEmpty || _filter != 'ALL',
            onClear: () => setState(() {
              _search.clear();
              _filter = 'ALL';
            }),
          )
        else
          _PartnerRoster(
            partners: _filtered,
            busy: _busy,
            onApproval: _setApproval,
          ),
        if (!_loading && _error == null && _total > 0) ...[
          const SizedBox(height: 12),
          _PartnerPagination(
            currentPage: _currentPage,
            lastPage: _lastPage,
            total: _total,
            onPage: (page) => _loadPartners(page: page),
          ),
        ],
        const SizedBox(height: 22),
        _KycQueueNotice(
          pendingPartners: _partners.where((partner) => !partner.approved).toList(),
          onReview: () => setState(() => _filter = 'PENDING'),
          onApprove: (partner) => _setApproval(partner, true),
          busy: _busy,
        ),
        const SizedBox(height: 14),
        const _KycDataBoundary(),
      ],
    );
  }
}

class _DeliveryPartnerApi {
  const _DeliveryPartnerApi();

  String get base {
    final value = apiBaseUrl.trim();
    return (value.isEmpty ? 'https://api.snapfoodd.in/api/v1' : value)
        .replaceFirst(RegExp(r'/$'), '');
  }

  String get token => html.window.localStorage['snap_foodd_admin_token'] ?? '';
  bool get configured => token.isNotEmpty;
  Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (configured) 'Authorization': 'Bearer $token',
      };

  Future<_DeliveryPartnerPage> list({required int page}) async {
    if (!configured) {
      throw StateError('API_TOKEN is not configured. Partner data cannot be loaded in preview mode.');
    }
    final response = await http.get(
      Uri.parse('$base/admin/delivery-partners?page=$page'),
      headers: headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Delivery partner request failed (${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['data'] is! Map) {
      throw StateError('The delivery partner API returned an unexpected response.');
    }
    final pageData = decoded['data'] as Map;
    final itemsData = pageData['data'];
    final items = itemsData is List
        ? itemsData.whereType<Map>().map(_DeliveryPartnerRecord.fromJson).toList()
        : <_DeliveryPartnerRecord>[];
    return _DeliveryPartnerPage(
      items: items,
      total: _partnersAsInt(pageData['total'], items.length),
      currentPage: _partnersAsInt(pageData['current_page'], page),
      lastPage: _partnersAsInt(pageData['last_page'], 1),
    );
  }

  Future<_DeliveryPartnerRecord> setApproval(int id, bool approved) async {
    final response = await http.patch(
      Uri.parse('$base/admin/delivery-partners/$id/approval'),
      headers: headers,
      body: jsonEncode({'approved': approved}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Approval update failed (${response.statusCode}): ${_responseMessage(response.body)}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['data'] is! Map) {
      throw StateError('The approval API returned an unexpected response.');
    }
    return _DeliveryPartnerRecord.fromJson(decoded['data'] as Map);
  }

  Future<void> create({required int userId}) async {
    final response = await http.post(
      Uri.parse('$base/admin/delivery-partners'),
      headers: headers,
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Onboarding failed (${response.statusCode}): ${_responseMessage(response.body)}');
    }
  }

  static String _responseMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
    } catch (_) {
      // Keep the response generic if the server did not return JSON.
    }
    return 'Please retry or contact the backend administrator.';
  }
}

class _DeliveryPartnerPage {
  const _DeliveryPartnerPage({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });
  final List<_DeliveryPartnerRecord> items;
  final int total;
  final int currentPage;
  final int lastPage;
}

class _DeliveryPartnerRecord {
  const _DeliveryPartnerRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.approved,
    required this.active,
    required this.available,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final bool approved;
  final bool active;
  final bool available;
  final String? createdAt;

  factory _DeliveryPartnerRecord.fromJson(Map json) {
    final user = json['user'] is Map ? json['user'] as Map : const {};
    return _DeliveryPartnerRecord(
      id: _partnersAsInt(json['id'], 0),
      name: (user['name'] ?? 'Unnamed partner').toString(),
      email: (user['email'] ?? 'No email on file').toString(),
      approved: json['is_approved'] == true,
      active: json['is_active'] == true && user['is_active'] != false,
      available: json['is_available'] == true,
      createdAt: json['created_at']?.toString(),
    );
  }

  _DeliveryPartnerRecord withApprovalFrom(_DeliveryPartnerRecord other) => other;
}

int _partnersAsInt(dynamic value, int fallback) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;

class _PartnerCommandHeader extends StatelessWidget {
  const _PartnerCommandHeader({
    required this.apiConfigured,
    required this.onExport,
    required this.onManualOnboard,
  });

  final bool apiConfigured;
  final VoidCallback onExport;
  final VoidCallback onManualOnboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final actions = Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          shad.OutlineButton(
            onPressed: onExport,
            leading: const AdminIcon(HugeIcons.strokeRoundedDownload01, size: 17),
            child: const Text('Export roster'),
          ),
          shad.PrimaryButton(
            onPressed: onManualOnboard,
            leading: const AdminIcon(HugeIcons.strokeRoundedUserAdd01, size: 17),
            child: const Text('Manual onboard'),
          ),
        ],
      );
      final title = const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Partner Command', style: TextStyle(fontSize: 30, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: AdminColors.ink)),
          SizedBox(height: 7),
          Text('Fleet roster, partner approvals, and operational readiness.', style: TextStyle(fontSize: 12, color: AdminColors.muted)),
          SizedBox(height: 10),
          Text('FLEET LOGISTICS  /  MUMBAI CLUSTER  /  RIDER OPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: AdminColors.muted)),
        ],
      );
      if (constraints.maxWidth < 760) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 15),
            actions,
            const SizedBox(height: 12),
            _ApiStatusPill(configured: apiConfigured),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: title),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [actions, const SizedBox(height: 9), _ApiStatusPill(configured: apiConfigured)],
          ),
        ],
      );
    });
  }
}

class _ApiStatusPill extends StatelessWidget {
  const _ApiStatusPill({required this.configured});
  final bool configured;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: configured ? AdminColors.greenSoft : AdminColors.redSoft,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AdminColors.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _StatusDot(color: configured ? AdminColors.green : AdminColors.red),
          const SizedBox(width: 7),
          Text(
            configured ? 'API configured • Authenticated requests enabled' : 'API token missing • Data unavailable',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: configured ? AdminColors.green : AdminColors.red),
          ),
        ]),
      );
}

class _FleetSummary extends StatelessWidget {
  const _FleetSummary({
    required this.partners,
    required this.total,
    required this.loading,
    required this.apiConfigured,
  });

  final List<_DeliveryPartnerRecord> partners;
  final int total;
  final bool loading;
  final bool apiConfigured;

  @override
  Widget build(BuildContext context) {
    final approved = partners.where((p) => p.approved && p.active).length;
    final pending = partners.where((p) => !p.approved).length;
    final available = partners.where((p) => p.approved && p.active && p.available).length;
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 560 ? 2 : 1;
      final cards = [
        _FleetKpiCard(title: 'TOTAL FLEET STRENGTH', value: loading ? '—' : total.toString(), caption: 'Partners registered in backend', icon: HugeIcons.strokeRoundedScooterElectric, tone: AdminColors.amberSoft),
        _FleetKpiCard(title: 'APPROVED & ACTIVE', value: loading ? '—' : approved.toString(), caption: 'On the current result page', icon: HugeIcons.strokeRoundedFlash, tone: AdminColors.greenSoft),
        _FleetKpiCard(title: 'AVAILABLE NOW', value: loading ? '—' : available.toString(), caption: 'Availability reported by API', icon: HugeIcons.strokeRoundedRoute01, tone: AdminColors.blueSoft),
        _FleetKpiCard(title: 'PENDING APPROVAL', value: loading ? '—' : pending.toString(), caption: 'Needs admin decision on this page', icon: HugeIcons.strokeRoundedTask01, tone: AdminColors.redSoft),
      ];
      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 4 ? 1.8 : columns == 2 ? 2.15 : 4.2,
        children: cards,
      );
    });
  }
}

class _FleetKpiCard extends StatelessWidget {
  const _FleetKpiCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.tone,
  });
  final String title;
  final String value;
  final String caption;
  final AdminIconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) => AdminCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .6, color: AdminColors.muted))),
              Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(10)),
                child: AdminIcon(icon, size: 17, color: AdminColors.ink),
              ),
            ]),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.7, color: AdminColors.ink)),
            const SizedBox(height: 3),
            Text(caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
          ]),
        ),
      );
}

class _PartnerFilterBar extends StatelessWidget {
  const _PartnerFilterBar({
    required this.controller,
    required this.filter,
    required this.counts,
    required this.onFilter,
    required this.onRefresh,
    required this.loading,
  });

  final TextEditingController controller;
  final String filter;
  final Map<String, int> counts;
  final ValueChanged<String> onFilter;
  final VoidCallback onRefresh;
  final bool loading;

  static const options = [
    ('ALL', 'All partners'),
    ('ACTIVE', 'Active'),
    ('PENDING', 'Pending approval / KYC'),
    ('INACTIVE', 'Inactive'),
  ];

  @override
  Widget build(BuildContext context) => AdminCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(builder: (context, constraints) {
            final search = SizedBox(
              width: constraints.maxWidth < 700 ? double.infinity : 250,
              child: shad.TextField(
                controller: controller,
                hintText: 'Search name, email or partner ID',
                style: const TextStyle(fontSize: 11),
                filled: true,
                border: const Border.fromBorderSide(BorderSide(color: AdminColors.line)),
                borderRadius: BorderRadius.circular(9),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                features: const [shad.InputClearFeature()],
              ),
            );
            final chips = Wrap(
              spacing: 7,
              runSpacing: 7,
              children: options.map((option) {
                final active = filter == option.$1;
                return (active ? shad.Button.secondary : shad.Button.ghost)(
                  onPressed: () => onFilter(option.$1),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(option.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: active ? AdminColors.ink : AdminColors.muted)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: active ? AdminColors.yellow : AdminColors.canvas, borderRadius: BorderRadius.circular(6)),
                      child: Text((counts[option.$1] ?? 0).toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                  ]),
                );
              }).toList(),
            );
            if (constraints.maxWidth < 700) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                search,
                const SizedBox(height: 10),
                chips,
                Align(alignment: Alignment.centerRight, child: shad.IconButton.ghost(onPressed: loading ? null : onRefresh, tooltip: 'Refresh roster', icon: const AdminIcon(HugeIcons.strokeRoundedRefresh))),
              ]);
            }
            return Row(children: [
              search,
              const SizedBox(width: 10),
              Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: chips)),
              const SizedBox(width: 4),
              shad.IconButton.ghost(onPressed: loading ? null : onRefresh, tooltip: 'Refresh roster', icon: const AdminIcon(HugeIcons.strokeRoundedRefresh)),
            ]);
          }),
        ),
      );
}

class _PartnerRoster extends StatelessWidget {
  const _PartnerRoster({required this.partners, required this.busy, required this.onApproval});
  final List<_DeliveryPartnerRecord> partners;
  final bool busy;
  final Future<void> Function(_DeliveryPartnerRecord, bool) onApproval;

  @override
  Widget build(BuildContext context) => AdminCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 12),
            child: Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('DELIVERY PARTNER ROSTER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .3)),
                SizedBox(height: 3),
                Text('Partner identity and operational flags returned by the admin API.', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
              ])),
              const _TelemetryBoundaryPill(),
            ]),
          ),
          const Divider(height: 1, color: AdminColors.line),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return Column(
                children: partners.map((partner) => _PartnerMobileCard(
                  partner: partner,
                  busy: busy,
                  onApproval: onApproval,
                )).toList(),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 780),
                child: shad.Table(
                  rows: [
                    shad.TableHeader(cells: const [
                      shad.TableCell(child: Text('PARTNER / IDENTITY')),
                      shad.TableCell(child: Text('CONTACT')),
                      shad.TableCell(child: Text('DUTY STATUS')),
                      shad.TableCell(child: Text('APPROVAL')),
                      shad.TableCell(child: Text('QUICK ACTIONS')),
                    ]),
                    ...partners.map((partner) => shad.TableRow(cells: [
                      shad.TableCell(child: SizedBox(width: 175, child: _PartnerIdentity(partner: partner))),
                      shad.TableCell(child: SizedBox(width: 185, child: Text(partner.email, style: const TextStyle(fontSize: 11)))),
                      shad.TableCell(child: _PartnerDutyStatus(partner: partner)),
                      shad.TableCell(child: _ApprovalPill(approved: partner.approved)),
                      shad.TableCell(child: _PartnerActions(partner: partner, busy: busy, onApproval: onApproval)),
                    ])),
                  ],
                  columnWidths: const {
                    0: shad.FlexTableSize(flex: 2),
                    1: shad.FlexTableSize(flex: 2),
                    2: shad.FlexTableSize(flex: 1),
                    3: shad.FixedTableSize(120),
                    4: shad.FixedTableSize(150),
                  },
                ),
              ),
            );
          }),
        ]),
      );
}

class _PartnerIdentity extends StatelessWidget {
  const _PartnerIdentity({required this.partner});
  final _DeliveryPartnerRecord partner;

  @override
  Widget build(BuildContext context) {
    final initials = partner.name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2).map((part) => part[0]).join().toUpperCase();
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(11)),
        child: Text(initials.isEmpty ? 'DP' : initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.yellowDark)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(partner.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('Partner #${partner.id}', style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
      ])),
    ]);
  }
}

class _PartnerDutyStatus extends StatelessWidget {
  const _PartnerDutyStatus({required this.partner});
  final _DeliveryPartnerRecord partner;

  @override
  Widget build(BuildContext context) {
    final text = !partner.active ? 'Inactive' : !partner.approved ? 'Awaiting approval' : partner.available ? 'Available' : 'Not available';
    final color = !partner.active || !partner.approved ? AdminColors.red : partner.available ? AdminColors.green : AdminColors.muted;
    final background = !partner.active || !partner.approved ? AdminColors.redSoft : partner.available ? AdminColors.greenSoft : AdminColors.canvas;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _StatusDot(color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}

class _ApprovalPill extends StatelessWidget {
  const _ApprovalPill({required this.approved});
  final bool approved;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: approved ? AdminColors.greenSoft : AdminColors.amberSoft, borderRadius: BorderRadius.circular(18)),
        child: Text(approved ? 'APPROVED' : 'PENDING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: approved ? AdminColors.green : AdminColors.yellowDark)),
      );
}

class _PartnerActions extends StatelessWidget {
  const _PartnerActions({required this.partner, required this.busy, required this.onApproval});
  final _DeliveryPartnerRecord partner;
  final bool busy;
  final Future<void> Function(_DeliveryPartnerRecord, bool) onApproval;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 2, children: [
        shad.IconButton.ghost(
          onPressed: () => shad.showOverlay<void>(context, shad.DialogConfiguration<void>(builder: (dialogContext) => shad.AlertDialog(
              title: Text(partner.name),
              content: SizedBox(
                width: 360,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _DetailLine(label: 'Partner ID', value: partner.id.toString()),
                  _DetailLine(label: 'Email', value: partner.email),
                  _DetailLine(label: 'Approval', value: partner.approved ? 'Approved' : 'Pending approval'),
                  _DetailLine(label: 'Account active', value: partner.active ? 'Yes' : 'No'),
                  _DetailLine(label: 'Available', value: partner.available ? 'Yes' : 'No'),
                  const SizedBox(height: 8),
                  const Text('Vehicle, trip history, live GPS, phone, and rating are not supplied by the current API.', style: TextStyle(fontSize: 11, color: AdminColors.muted, height: 1.5)),
                ]),
              ),
              actions: [shad.OutlineButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
            ))),
          icon: const AdminIcon(HugeIcons.strokeRoundedLinkSquare01, size: 17),
        ),
        shad.IconButton.ghost(
          onPressed: busy ? null : () => onApproval(partner, !partner.approved),
          icon: AdminIcon(partner.approved ? HugeIcons.strokeRoundedSecurityCheck : HugeIcons.strokeRoundedCheckmarkCircle01, size: 18, color: partner.approved ? AdminColors.muted : AdminColors.green),
        ),
      ]);
}

class _PartnerMobileCard extends StatelessWidget {
  const _PartnerMobileCard({required this.partner, required this.busy, required this.onApproval});
  final _DeliveryPartnerRecord partner;
  final bool busy;
  final Future<void> Function(_DeliveryPartnerRecord, bool) onApproval;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _PartnerIdentity(partner: partner)),
            _ApprovalPill(approved: partner.approved),
          ]),
          const SizedBox(height: 10),
          Text(partner.email, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _PartnerDutyStatus(partner: partner)),
            shad.OutlineButton(onPressed: busy ? null : () => onApproval(partner, !partner.approved), leading: AdminIcon(partner.approved ? HugeIcons.strokeRoundedSecurityBlock : HugeIcons.strokeRoundedCheckmarkCircle01, size: 16), child: Text(partner.approved ? 'Remove approval' : 'Approve')),
          ]),
          const Divider(height: 16, color: AdminColors.line),
        ]),
      );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 105, child: Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.muted))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
        ]),
      );
}

class _TelemetryBoundaryPill extends StatelessWidget {
  const _TelemetryBoundaryPill();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(9), border: Border.all(color: AdminColors.line)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          _StatusDot(color: AdminColors.muted),
          SizedBox(width: 6),
          Text('Telemetry unavailable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.muted)),
        ]),
      );
}

class _PartnerPagination extends StatelessWidget {
  const _PartnerPagination({required this.currentPage, required this.lastPage, required this.total, required this.onPage});
  final int currentPage;
  final int lastPage;
  final int total;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Row(children: [
        Text('Page $currentPage of $lastPage • $total partners', style: const TextStyle(fontSize: 11, color: AdminColors.muted, fontWeight: FontWeight.w700)),
        const Spacer(),
        shad.IconButton.ghost(onPressed: currentPage > 1 ? () => onPage(currentPage - 1) : null, icon: const AdminIcon(HugeIcons.strokeRoundedArrowLeft01)),
        shad.IconButton.ghost(onPressed: currentPage < lastPage ? () => onPage(currentPage + 1) : null, icon: const AdminIcon(HugeIcons.strokeRoundedArrowRight01)),
      ]);
}

class _PartnerLoadingState extends StatelessWidget {
  const _PartnerLoadingState();

  @override
  Widget build(BuildContext context) => AdminCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Row(children: [
              shad.CircularProgressIndicator(size: 18, strokeWidth: 2),
              SizedBox(width: 11),
              Text('Loading delivery partners…', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 18),
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Container(height: 48, decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(9)),
                child: const SizedBox.expand()),
            )),
          ]),
        ),
      );
}

class _PartnerErrorBanner extends StatelessWidget {
  const _PartnerErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AdminColors.redSoft, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.redSoft)),
        child: Row(children: [
          const AdminIcon(HugeIcons.strokeRoundedCloud, color: AdminColors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Delivery partner data could not be loaded', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.red)),
            const SizedBox(height: 3),
            Text(message, style: const TextStyle(fontSize: 11, color: AdminColors.ink, height: 1.4)),
          ])),
          shad.OutlineButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}

class _PartnerEmptyState extends StatelessWidget {
  const _PartnerEmptyState({required this.hasQuery, required this.onClear});
  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => AdminCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
          child: Center(child: Column(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(15)), child: const AdminIcon(HugeIcons.strokeRoundedDeliveryTruck01, color: AdminColors.yellowDark, size: 24)),
            const SizedBox(height: 12),
            Text(hasQuery ? 'No partners match these filters' : 'No delivery partners found', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('Try another search or refresh the roster from the admin API.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AdminColors.muted)),
            if (hasQuery) ...[
              const SizedBox(height: 10),
              shad.OutlineButton(onPressed: onClear, child: const Text('Clear filters')),
            ],
          ])),
        ),
      );
}

class _KycQueueNotice extends StatelessWidget {
  const _KycQueueNotice({
    required this.pendingPartners,
    required this.onReview,
    required this.onApprove,
    required this.busy,
  });
  final List<_DeliveryPartnerRecord> pendingPartners;
  final VoidCallback onReview;
  final Future<void> Function(_DeliveryPartnerRecord) onApprove;
  final bool busy;

  @override
  Widget build(BuildContext context) => AdminCard(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(12)), child: const AdminIcon(HugeIcons.strokeRoundedTaskDone01, color: AdminColors.yellowDark, size: 21)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sarathi & UIDAI Automated KYC Queue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Pending partner records from the admin API. Government document verification metadata is not currently exposed.', style: TextStyle(fontSize: 11, color: AdminColors.muted, height: 1.5)),
              ])),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(18)), child: Text('${pendingPartners.length} pending on page', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.yellowDark))),
                const SizedBox(height: 8),
                shad.OutlineButton(onPressed: onReview, child: const Text('Filter pending')),
              ]),
            ]),
            if (pendingPartners.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AdminColors.line),
              const SizedBox(height: 8),
              ...pendingPartners.map((partner) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: LayoutBuilder(builder: (context, constraints) {
                  final identity = Row(children: [
                    Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: AdminColors.peach, borderRadius: BorderRadius.circular(10)), child: Text(partner.name.trim().isEmpty ? 'DP' : partner.name.trim().split(RegExp(r'\\s+')).take(2).map((part) => part.isEmpty ? '' : part[0]).join().toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(partner.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text('Partner #${partner.id} • ${partner.email}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
                    ])),
                  ]);
                  final action = shad.PrimaryButton(
                    onPressed: busy ? null : () => onApprove(partner),
                    child: const Text('Approve & activate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  );
                  if (constraints.maxWidth < 540) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      identity,
                      const SizedBox(height: 8),
                      const Text('KYC documents / OCR score unavailable from current API', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
                      const SizedBox(height: 6),
                      Align(alignment: Alignment.centerRight, child: action),
                    ]);
                  }
                  return Row(children: [
                    Expanded(child: identity),
                    const SizedBox(width: 12),
                    const Text('KYC metadata unavailable', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
                    const SizedBox(width: 12),
                    action,
                  ]);
                }),
              )),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text('No pending partner approvals on this page. KYC document queue requires a dedicated backend endpoint.', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
              ),
          ]),
        ),
      );
}

class _KycDataBoundary extends StatelessWidget {
  const _KycDataBoundary();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.line)),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AdminIcon(HugeIcons.strokeRoundedInformationCircle, color: AdminColors.muted, size: 18),
          SizedBox(width: 10),
          Expanded(child: Text(
            'KYC integration boundary: no document URLs, UIDAI/Sarathi verification metadata, trust scores, rejection endpoint, or re-upload endpoint were found in the existing API. These controls are intentionally not simulated. The existing approval endpoint is used only for its supported approve/unapprove action.',
            style: TextStyle(fontSize: 11, color: AdminColors.muted, height: 1.5),
          )),
        ]),
      );
}

void _partnersNotice(BuildContext context, String message, {bool error = false}) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AdminColors.red : null,
      behavior: SnackBarBehavior.floating,
    ));
