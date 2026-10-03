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

  Future<void> _showDetails(_DeliveryPartnerRecord partner) async {
    await SfSideDrawer.show<void>(
      context,
      title: partner.name.isEmpty ? 'Partner details' : partner.name,
      width: 460,
      child: _PartnerDetailDrawer(
        partner: partner,
        busy: _busy,
        onApproval: _setApproval,
      ),
    );
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
    final userId = await shad.showOverlay<int>(context, shad.DialogConfiguration(), builder: (dialogContext) => shad.AlertDialog(
        title: const Text('Manual partner onboarding'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The existing backend provisions an existing active user by ID. '
                'It does not create a user account; it links an existing active user to a delivery-partner record.',
                style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText, height: 1.5),
              ),
              const SizedBox(height: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Existing user ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                shad.TextField(controller: controller, keyboardType: TextInputType.number, autofocus: true, placeholder: const Text('Enter a user ID')),
              ]),
            ],
          ),
        ),
        actions: [
          shad.OutlineButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          shad.PrimaryButton(onPressed: () { final value = int.tryParse(controller.text.trim()); if (value == null || value < 1) { _partnersNotice(dialogContext, 'Enter a valid positive user ID.', error: true); return; } Navigator.pop(dialogContext, value); }, child: const Text('Create partner')),
        ],
      )).future;
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
            onView: _showDetails,
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
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Partners', style: AdminTypography.pageTitle),
                const SizedBox(height: AdminSpacing.xs),
                Text(
                  apiConfigured
                      ? 'Monitor approval and availability states from the admin API.'
                      : 'Connect the admin API to load the delivery partner roster.',
                  style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: AdminSpacing.sm,
            children: [
              SfButton(
                variant: SfButtonVariant.outline,
                onPressed: onExport,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminIcon(HugeIcons.strokeRoundedDownload01, size: 18),
                    SizedBox(width: AdminSpacing.xs),
                    Text('Export'),
                  ],
                ),
              ),
              SfButton(
                onPressed: apiConfigured ? onManualOnboard : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminIcon(HugeIcons.strokeRoundedUserAdd01, size: 18),
                    SizedBox(width: AdminSpacing.xs),
                    Text('Add partner'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    final online = partners.where((p) => p.available).length;
    final active = partners.where((p) => p.active).length;
    final pending = partners.where((p) => !p.approved).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 2 : 1;
        final width = (constraints.maxWidth - AdminSpacing.md * (count - 1)) / count;
        final items = [
          ('Total partners', total.toString(), 'All records', HugeIcons.strokeRoundedUserGroup, AdminDesignColors.yellowSoft),
          ('Available', online.toString(), 'Current API page', HugeIcons.strokeRoundedDeliveryTruck01, AdminDesignColors.successSoft),
          ('Active', active.toString(), 'Current API page', HugeIcons.strokeRoundedCheckmarkCircle02, AdminDesignColors.infoSoft),
          ('Awaiting approval', pending.toString(), 'Current API page', HugeIcons.strokeRoundedClock02, AdminDesignColors.warningSoft),
        ];
        return Wrap(
          spacing: AdminSpacing.md,
          runSpacing: AdminSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: SfStat(
                  label: item.$1,
                  value: loading ? '—' : item.$2,
                  helper: apiConfigured ? item.$3 : 'API unavailable',
                  icon: item.$4,
                  tone: item.$5,
                ),
              ),
          ],
        );
      },
    );
  }
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
    ('ALL', 'All'),
    ('ACTIVE', 'Active'),
    ('PENDING', 'Pending approval'),
    ('INACTIVE', 'Inactive'),
  ];

  @override
  Widget build(BuildContext context) => SfFilterBar(
        leading: SizedBox(
          width: 320,
          child: SfSearchField(
            controller: controller,
            hintText: 'Search name, email or partner ID',
          ),
        ),
        filters: [
          for (final option in options)
            SfBadge(
              label: '${option.$2} · ${counts[option.$1] ?? 0}',
              backgroundColor: AdminDesignColors.subtleSurface,
              foregroundColor: AdminDesignColors.secondaryText,
            ),
        ],
        trailing: [
          SfIconButton(
            icon: HugeIcons.strokeRoundedRefresh,
            tooltip: 'Refresh delivery partners',
            onPressed: loading ? null : onRefresh,
          ),
        ],
      );
}

class _PartnerRoster extends StatelessWidget {
  const _PartnerRoster({
    required this.partners,
    required this.busy,
    required this.onApproval,
    required this.onView,
  });

  final List<_DeliveryPartnerRecord> partners;
  final bool busy;
  final Future<void> Function(_DeliveryPartnerRecord, bool) onApproval;
  final ValueChanged<_DeliveryPartnerRecord> onView;

  @override
  Widget build(BuildContext context) => SfDataTable(
        minWidth: 920,
        columns: const [
          SfDataTableColumn(label: 'Partner', width: 260),
          SfDataTableColumn(label: 'Contact', width: 250),
          SfDataTableColumn(label: 'Availability', width: 150),
          SfDataTableColumn(label: 'Approval', width: 150),
          SfDataTableColumn(label: 'Status', width: 130),
          SfDataTableColumn(label: 'Action', width: 110, alignment: Alignment.centerRight),
        ],
        rows: [
          for (final partner in partners)
            [
              Row(
                children: [
                  SfAvatar(name: partner.name, size: 38),
                  const SizedBox(width: AdminSpacing.sm),
                  Expanded(
                    child: Text(
                      partner.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminTypography.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              Text(
                partner.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText),
              ),
              SfStatusBadge(
                label: partner.available ? 'Available' : 'Unavailable',
                status: partner.available ? 'active' : 'inactive',
              ),
              SfStatusBadge(
                label: partner.approved ? 'Approved' : 'Pending',
                status: partner.approved ? 'approved' : 'pending',
              ),
              SfStatusBadge(
                label: partner.active ? 'Active' : 'Inactive',
                status: partner.active ? 'active' : 'inactive',
              ),
              SfIconButton(
                icon: HugeIcons.strokeRoundedArrowRight01,
                tooltip: 'View partner',
                onPressed: () => onView(partner),
              ),
            ],
        ],
        onRowTap: (index) => onView(partners[index]),
      );
}

class _PartnerPagination extends StatelessWidget {
  const _PartnerPagination({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.onPage,
  });

  final int currentPage;
  final int lastPage;
  final int total;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => SfTablePagination(
        page: currentPage,
        lastPage: lastPage,
        total: total,
        onPrevious: currentPage > 1 ? () => onPage(currentPage - 1) : null,
        onNext: currentPage < lastPage ? () => onPage(currentPage + 1) : null,
      );
}

class _PartnerLoadingState extends StatelessWidget {
  const _PartnerLoadingState();

  @override
  Widget build(BuildContext context) => SfCard(
        padding: const EdgeInsets.all(AdminSpacing.xl),
        child: Column(
          children: [
            for (var i = 0; i < 5; i++) ...[
              Row(
                children: const [
                  SfSkeleton(width: 42, height: 42),
                  SizedBox(width: AdminSpacing.md),
                  SfSkeleton(width: 220, height: 14),
                  Spacer(),
                  SfSkeleton(width: 120, height: 14),
                ],
              ),
              if (i < 4) const SizedBox(height: AdminSpacing.lg),
            ],
          ],
        ),
      );
}

class _PartnerErrorBanner extends StatelessWidget {
  const _PartnerErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SfErrorState(
        title: 'Could not load delivery partners',
        message: message,
        onRetry: onRetry,
      );
}

class _PartnerEmptyState extends StatelessWidget {
  const _PartnerEmptyState({required this.hasQuery, required this.onClear});
  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => SfEmptyState(
        icon: HugeIcons.strokeRoundedDeliveryTruck01,
        title: hasQuery ? 'No partners match these filters' : 'No delivery partners found',
        message: hasQuery
            ? 'Try another search or clear the current filters.'
            : 'Delivery partner records will appear here when they are available.',
        action: hasQuery
            ? SfButton(
                variant: SfButtonVariant.outline,
                onPressed: onClear,
                child: const Text('Clear filters'),
              )
            : null,
      );
}

class _PartnerDetailDrawer extends StatelessWidget {
  const _PartnerDetailDrawer({
    required this.partner,
    required this.busy,
    required this.onApproval,
  });

  final _DeliveryPartnerRecord partner;
  final bool busy;
  final Future<void> Function(_DeliveryPartnerRecord, bool) onApproval;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SfAvatar(name: partner.name, size: 56),
              const SizedBox(width: AdminSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(partner.name, style: AdminTypography.sectionTitle),
                    const SizedBox(height: AdminSpacing.xxs),
                    Text(partner.email, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
                    const SizedBox(height: AdminSpacing.sm),
                    Wrap(
                      spacing: AdminSpacing.xs,
                      runSpacing: AdminSpacing.xs,
                      children: [
                        SfStatusBadge(label: partner.approved ? 'Approved' : 'Pending', status: partner.approved ? 'approved' : 'pending'),
                        SfStatusBadge(label: partner.active ? 'Active' : 'Inactive', status: partner.active ? 'active' : 'inactive'),
                        SfStatusBadge(label: partner.available ? 'Available' : 'Unavailable', status: partner.available ? 'active' : 'inactive'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.xl),
          _PartnerDetailSection(
            title: 'Partner record',
            children: [
              _PartnerDetailLine('Partner ID', '#${partner.id}'),
              _PartnerDetailLine('Joined', _formatPartnerDate(partner.createdAt)),
            ],
          ),
          const SizedBox(height: AdminSpacing.lg),
          _PartnerDetailSection(
            title: 'Supported actions',
            children: [
              SfButton(
                variant: partner.approved ? SfButtonVariant.outline : SfButtonVariant.primary,
                onPressed: busy ? null : () => onApproval(partner, !partner.approved),
                child: Text(partner.approved ? 'Remove approval' : 'Approve partner'),
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.lg),
          Text(
            'Availability reflects the value returned by the admin API. No live location or telemetry is shown here.',
            style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText, height: 1.5),
          ),
        ],
      );
}

class _PartnerDetailSection extends StatelessWidget {
  const _PartnerDetailSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AdminTypography.cardTitle),
          const SizedBox(height: AdminSpacing.sm),
          SfCard(
            padding: const EdgeInsets.all(AdminSpacing.md),
            child: Column(children: children),
          ),
        ],
      );
}

class _PartnerDetailLine extends StatelessWidget {
  const _PartnerDetailLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AdminSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label, style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText)),
            ),
            Expanded(child: Text(value, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

String _formatPartnerDate(String? value) {
  if (value == null || value.trim().isEmpty) return 'Not provided';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
}

void _partnersNotice(BuildContext context, String message, {bool error = false}) {
  if (error) {
    SfFeedback.showError(context, message);
  } else {
    SfFeedback.showSuccess(context, message);
  }
}
