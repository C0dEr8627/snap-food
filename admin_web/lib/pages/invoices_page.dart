part of '../main.dart';

class InvoicesPage extends flutter.StatefulWidget {
  const InvoicesPage({super.key, this.searchQuery = ''});
  final String searchQuery;
  @override State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends flutter.State<InvoicesPage> {
  final _api = const _InvoiceLedgerApi();
  final _search = TextEditingController();
  List<_LedgerInvoice> _items = [];
  int _total = 0, _page = 1, _lastPage = 1, _paidCount = 0;
  double _billed = 0, _paidTotal = 0;
  String _status = 'ALL';
  String? _error;
  DateTime? _from, _to;
  bool _loading = true, _exporting = false;

  @override void initState() { super.initState(); _search.text = widget.searchQuery; _load(); }

  @override
  void didUpdateWidget(covariant InvoicesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _search.text != widget.searchQuery) {
      _search.text = widget.searchQuery;
      _load(page: 1);
    }
  }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load({int page = 1}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _api.list(page: page, search: _search.text.trim(), status: _status, from: _from, to: _to);
      if (!mounted) return;
      setState(() { _items = result.items; _total = result.total; _page = result.page; _lastPage = result.lastPage; _billed = result.totalAmount; _paidCount = result.paidCount; _paidTotal = result.paidAmount; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString().replaceFirst('Bad state: ', ''); });
    }
  }

  Future<void> _pickDate(bool start) async {
    final now = DateTime.now();
    final selected = await showDatePicker(context: context, initialDate: (start ? _from : _to) ?? now, firstDate: DateTime(2020), lastDate: DateTime(now.year + 2));
    if (selected == null || !mounted) return;
    setState(() { if (start) { _from = selected; } else { _to = selected; } });
  }

  void _reset() {
    _search.clear();
    setState(() { _status = 'ALL'; _from = null; _to = null; });
    _load(page: 1);
  }

  Future<void> _exportPage() async {
    if (_items.isEmpty) { _notice(context, 'No invoice records on this page.', error: true); return; }
    setState(() => _exporting = true);
    try {
      String cell(String s) => '"' + s.replaceAll('"', '""') + '"';
      final rows = <List<String>>[
        ['Invoice', 'Order ID', 'Issued at', 'Customer', 'Email', 'Subtotal', 'Delivery fee', 'Total', 'Payment method', 'Payment status', 'File reference'],
        ..._items.map((i) => [i.number, i.orderId.toString(), i.issuedAt ?? '', i.customer, i.email, i.subtotal.toStringAsFixed(2), i.deliveryFee.toStringAsFixed(2), i.total.toStringAsFixed(2), i.paymentMethod, i.paymentStatus, i.fileReference ?? '']),
      ];
      final csv = rows.map((r) => r.map(cell).join(',')).join('\r\n');
      final blob = html.Blob([utf8.encode(csv)], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)..setAttribute('download', 'snap-foodd-invoices-page-' + _page.toString() + '.csv')..click();
      html.Url.revokeObjectUrl(url);
      if (mounted) _notice(context, 'Exported ' + _items.length.toString() + ' invoices from the current page.');
    } catch (e) { if (mounted) _notice(context, 'Export failed: ' + e.toString(), error: true); }
    finally { if (mounted) setState(() => _exporting = false); }
  }

  @override flutter.Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 760;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _InvoiceBreadcrumb(),
      const SizedBox(height: AdminSpacing.sm),
      SfPageHeader(
        title: 'Invoices & Billing',
        description: 'Review stored invoice snapshots, billing totals and payment status with financial precision.',
        actions: [
          SfButton(
            variant: SfButtonVariant.outline,
            icon: HugeIcons.strokeRoundedDownload01,
            loading: _exporting,
            onPressed: _exporting ? null : _exportPage,
            child: const Text('Export current page'),
          ),
        ],
      ),
      const SizedBox(height: AdminSpacing.xl),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 640 ? 2 : 1;
          final unpaid = _billed - _paidTotal;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: AdminSpacing.md,
            mainAxisSpacing: AdminSpacing.md,
            childAspectRatio: columns == 1 ? 3.8 : columns == 4 ? 1.8 : 2.5,
            children: [
              SfStat(label: 'INVOICES', value: _loading ? '—' : _total.toString(), helper: 'Matching current filters', icon: HugeIcons.strokeRoundedInvoice01),
              SfStat(label: 'TOTAL BILLED', value: _loading ? '—' : _inr(_billed), helper: 'Invoice totals in result set', icon: HugeIcons.strokeRoundedWallet01),
              SfStat(label: 'PAID', value: _loading ? '—' : _inr(_paidTotal), helper: _loading ? '—' : _paidCount.toString() + ' invoices marked PAID', icon: HugeIcons.strokeRoundedCheckmarkCircle02),
              SfStat(label: 'UNPAID', value: _loading ? '—' : _inr(unpaid), helper: 'Calculated as billed less paid', icon: HugeIcons.strokeRoundedClock01, status: const SfStatusBadge(label: 'Pending')),
            ],
          );
        },
      ),
      const SizedBox(height: AdminSpacing.lg),
      SfFilterBar(
        leading: SizedBox(
          width: mobile ? width - 42 : 320,
          child: SfSearchField(
            controller: _search,
            hintText: 'Search invoice, order, customer or email',
            onSubmitted: (_) => _load(page: 1),
          ),
        ),
        filters: [
          SfButton(variant: SfButtonVariant.outline, icon: HugeIcons.strokeRoundedCalendar03, onPressed: () => _pickDate(true), child: Text(_from == null ? 'From date' : _date(_from!))),
          SfButton(variant: SfButtonVariant.outline, icon: HugeIcons.strokeRoundedCalendar03, onPressed: () => _pickDate(false), child: Text(_to == null ? 'To date' : _date(_to!))),
          _InvoiceFilterPill('All', _status == 'ALL', () { setState(() => _status = 'ALL'); _load(page: 1); }),
          _InvoiceFilterPill('Paid', _status == 'PAID', () { setState(() => _status = 'PAID'); _load(page: 1); }),
          _InvoiceFilterPill('Pending', _status == 'PENDING', () { setState(() => _status = 'PENDING'); _load(page: 1); }),
        ],
        trailing: [
          SfButton(variant: SfButtonVariant.primary, onPressed: () => _load(page: 1), child: const Text('Apply')),
          SfButton(variant: SfButtonVariant.ghost, onPressed: _reset, child: const Text('Reset')),
        ],
      ),
      const SizedBox(height: AdminSpacing.lg),
      if (_error != null) SfErrorState(
        title: 'Unable to load invoices',
        message: _error!,
        onRetry: () => _load(page: _page),
      )
      else if (_loading) const SfLoadingState(
        title: 'Loading invoice ledger',
        message: 'Fetching the latest invoice snapshots and payment summary.',
      )
      else if (_items.isEmpty) SfEmptyState(
        icon: HugeIcons.strokeRoundedInvoice01,
        title: 'No invoices found',
        message: 'Try changing your search, date range, or payment status filter.',
        action: SfButton(
          variant: SfButtonVariant.outline,
          onPressed: _reset,
          child: const Text('Reset filters'),
        ),
      )
      else _InvoiceLedgerCard(invoices: _items, mobile: mobile, page: _page, total: _total, lastPage: _lastPage, onPage: (p) => _load(page: p), onView: _showInvoice),
      const SizedBox(height: 12),
      const Text('Stored invoice snapshots only. GST splits, gateway references, refund/reconciliation events, and rider payouts are not currently exposed by the backend.', style: TextStyle(fontSize: 11, color: AdminColors.muted, height: 1.5)),
    ]);
  }

  void _showInvoice(_LedgerInvoice i) {
    SfSideDrawer.show<void>(
      context,
      title: i.number,
      width: 460,
      child: _InvoiceDetail(invoice: i),
    );
  }
}

class _InvoiceDetail extends flutter.StatelessWidget {
  const _InvoiceDetail({required this.invoice});
  final _LedgerInvoice invoice;

  @override
  flutter.Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Text('Invoice details', style: AdminTypography.cardTitle)),
        SfStatusBadge(label: invoice.paymentStatus),
      ]),
      const SizedBox(height: AdminSpacing.lg),
      _InvoiceDetailLine('Invoice number', invoice.number),
      _InvoiceDetailLine('Order', '#' + invoice.orderId.toString()),
      _InvoiceDetailLine('Issued at', invoice.issuedAt ?? 'Not recorded'),
      _InvoiceDetailLine('Customer', invoice.customer),
      _InvoiceDetailLine('Email', invoice.email.isEmpty ? 'Not provided' : invoice.email),
      const Divider(height: 28),
      _InvoiceDetailLine('Item subtotal', _inr(invoice.subtotal)),
      _InvoiceDetailLine('Delivery fee', _inr(invoice.deliveryFee)),
      _InvoiceDetailLine('Invoice total', _inr(invoice.total), strong: true),
      _InvoiceDetailLine('Payment method', invoice.paymentMethod),
      _InvoiceDetailLine('Payment status', invoice.paymentStatus),
      if (invoice.items.isNotEmpty) ...[
        const SizedBox(height: AdminSpacing.lg),
        Text('ITEM SNAPSHOT', style: AdminTypography.caption.copyWith(fontWeight: FontWeight.w700, letterSpacing: .8)),
        const SizedBox(height: AdminSpacing.sm),
        ...invoice.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AdminSpacing.xs),
          child: Row(children: [
            Expanded(child: Text((item['product_name'] ?? 'Item').toString() + ' × ' + (item['quantity'] ?? 1).toString(), style: AdminTypography.body)),
            Text(_inr(_number(item['line_total'])), style: AdminTypography.body.copyWith(fontWeight: FontWeight.w700)),
          ]),
        )),
      ],
      const SizedBox(height: AdminSpacing.lg),
      Text('Stored invoice snapshot returned by the admin API. Tax, gateway and reconciliation data are not inferred when unavailable.',
        style: AdminTypography.caption.copyWith(color: AdminDesignColors.secondaryText)),
    ],
  );
}

class _InvoiceDetailLine extends flutter.StatelessWidget {
  const _InvoiceDetailLine(this.label, this.value, {this.strong = false});
  final String label, value;
  final bool strong;
  @override
  flutter.Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AdminSpacing.xs),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 126, child: Text(label, style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText))),
      Expanded(child: Text(value, style: AdminTypography.body.copyWith(fontWeight: strong ? FontWeight.w800 : FontWeight.w600))),
    ]),
  );
}


class _InvoiceFilterPill extends flutter.StatelessWidget {
  const _InvoiceFilterPill(this.label, this.active, this.onTap);
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

class _InvoiceLedgerCard extends flutter.StatelessWidget {
  const _InvoiceLedgerCard({
    required this.invoices,
    required this.mobile,
    required this.page,
    required this.total,
    required this.lastPage,
    required this.onPage,
    required this.onView,
  });

  final List<_LedgerInvoice> invoices;
  final bool mobile;
  final int page, total, lastPage;
  final ValueChanged<int> onPage;
  final ValueChanged<_LedgerInvoice> onView;

  @override
  flutter.Widget build(BuildContext context) => Column(
    children: [
      if (mobile)
        ...invoices.map((invoice) => _InvoiceMobileCard(
          invoice: invoice,
          onView: () => onView(invoice),
        ))
      else
        SfDataTable(
          minWidth: 980,
          columns: const [
            SfDataTableColumn(label: 'Invoice / Order', width: 190),
            SfDataTableColumn(label: 'Issued', width: 150),
            SfDataTableColumn(label: 'Customer', width: 220),
            SfDataTableColumn(label: 'Total', width: 130, alignment: Alignment.centerRight),
            SfDataTableColumn(label: 'Payment', width: 150),
            SfDataTableColumn(label: 'Status', width: 140),
          ],
          rows: invoices.map((item) => <flutter.Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(item.number, maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w700)),
              Text('Order #' + item.orderId.toString(), style: AdminTypography.caption),
            ]),
            Text(item.issuedAt ?? 'Not recorded', maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.small),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(item.customer, maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600)),
              if (item.email.isNotEmpty) Text(item.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.caption),
            ]),
            Text(_inr(item.total), style: AdminTypography.body.copyWith(fontWeight: FontWeight.w700)),
            Text(item.paymentMethod, maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.small),
            SfStatusBadge(label: item.paymentStatus),
          ]).toList(),
          onRowTap: (index) => onView(invoices[index]),
        ),
      SfTablePagination(
        page: page,
        lastPage: lastPage,
        total: total,
        onPrevious: page > 1 ? () => onPage(page - 1) : null,
        onNext: page < lastPage ? () => onPage(page + 1) : null,
      ),
    ],
  );
}

class _InvoiceMobileCard extends flutter.StatelessWidget {
  const _InvoiceMobileCard({required this.invoice, required this.onView});
  final _LedgerInvoice invoice;
  final VoidCallback onView;

  @override
  flutter.Widget build(BuildContext context) => InkWell(
    onTap: onView,
    child: Padding(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(invoice.number, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AdminSpacing.xxs),
              Text('Order #' + invoice.orderId.toString() + ' · ' + invoice.customer, style: AdminTypography.caption),
            ])),
            SfStatusBadge(label: invoice.paymentStatus),
          ]),
          const SizedBox(height: AdminSpacing.sm),
          Row(children: [
            Expanded(child: Text(invoice.email.isEmpty ? 'No email recorded' : invoice.email, style: AdminTypography.caption)),
            Text(_inr(invoice.total), style: AdminTypography.body.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: AdminSpacing.xs),
          Text('Items ' + _inr(invoice.subtotal) + ' · Delivery ' + _inr(invoice.deliveryFee), style: AdminTypography.caption),
          const SizedBox(height: AdminSpacing.sm),
          Row(children: [
            Expanded(child: Text(invoice.paymentMethod, style: AdminTypography.small)),
            SfButton(variant: SfButtonVariant.outline, onPressed: onView, child: const Text('View details')),
          ]),
        ],
      ),
    ),
  );
}

class _InvoiceLedgerApi {
  const _InvoiceLedgerApi();
  String get base { final v = apiBaseUrl.trim(); return (v.isEmpty ? 'https://api.snapfoodd.in/api/v1' : v).replaceFirst(RegExp(r'/$'), ''); }
  String get token => html.window.localStorage['snap_foodd_admin_token'] ?? '';
  Future<_InvoiceLedgerResult> list({required int page, required String search, required String status, DateTime? from, DateTime? to}) async {
    if (token.isEmpty) throw StateError('API_TOKEN is not configured. Real invoice records require an authenticated admin token.');
    final q = <String, String>{'page': page.toString(), 'per_page': '10', if (search.isNotEmpty) 'search': search, if (status != 'ALL') 'status': status, if (from != null) 'from': _isoDate(from), if (to != null) 'to': _isoDate(to)};
    final response = await http.get(Uri.parse(base + '/admin/invoices').replace(queryParameters: q), headers: {'Accept': 'application/json', 'Authorization': 'Bearer ' + token});
    if (response.statusCode < 200 || response.statusCode >= 300) throw StateError('Invoice ledger request failed (' + response.statusCode.toString() + ').');
    final body = jsonDecode(response.body);
    if (body is! Map || body['data'] is! Map) throw StateError('Unexpected invoice ledger response.');
    final p = body['data'] as Map, s = body['summary'] is Map ? body['summary'] as Map : const {};
    final raw = p['data'] is List ? p['data'] as List : const [];
    return _InvoiceLedgerResult(items: raw.whereType<Map>().map(_LedgerInvoice.fromJson).toList(), total: _int(p['total']), page: _int(p['current_page'], 1), lastPage: _int(p['last_page'], 1), totalAmount: _number(s['total']), paidCount: _int(s['paid_count']), paidAmount: _number(s['paid_total']));
  }
}

class _InvoiceLedgerResult {
  const _InvoiceLedgerResult({required this.items, required this.total, required this.page, required this.lastPage, required this.totalAmount, required this.paidCount, required this.paidAmount});
  final List<_LedgerInvoice> items;
  final int total, page, lastPage, paidCount;
  final double totalAmount, paidAmount;
}

class _LedgerInvoice {
  const _LedgerInvoice({required this.id, required this.number, required this.orderId, required this.customer, required this.email, required this.subtotal, required this.deliveryFee, required this.total, required this.paymentMethod, required this.paymentStatus, required this.issuedAt, required this.fileReference, required this.items});
  final int id, orderId;
  final String number, customer, email, paymentMethod, paymentStatus;
  final double subtotal, deliveryFee, total;
  final String? issuedAt, fileReference;
  final List<Map> items;
  factory _LedgerInvoice.fromJson(Map row) {
    final raw = row['items'] ?? row['items_snapshot'];
    return _LedgerInvoice(id: _int(row['id']), number: (row['invoice_number'] ?? 'INV-' + (row['id'] ?? '').toString()).toString(), orderId: _int(row['order_id']),
      customer: (row['customer_name'] ?? 'Customer').toString(), email: (row['customer_email'] ?? '').toString(),
      subtotal: _number(row['subtotal']), deliveryFee: _number(row['delivery_fee']), total: _number(row['total']),
      paymentMethod: (row['payment_method'] ?? 'Not recorded').toString(), paymentStatus: (row['payment_status'] ?? 'UNKNOWN').toString().toUpperCase(),
      issuedAt: row['issued_at']?.toString(), fileReference: row['file_reference']?.toString(), items: raw is List ? raw.whereType<Map>().toList() : const []);
  }
}

class _InvoiceBreadcrumb extends flutter.StatelessWidget {
  const _InvoiceBreadcrumb();
  @override flutter.Widget build(BuildContext context) => const Wrap(spacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: [
    Text('ACCOUNTING & COMPLIANCE', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w900, color: AdminColors.muted)),
    AdminIcon(HugeIcons.strokeRoundedCircle, size: 4, color: AdminColors.warning),
    Text('INVOICE LEDGER', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w900, color: AdminColors.warning)),
  ]);
}
int _int(dynamic v, [int fallback = 0]) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? fallback;
double _number(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

String _inr(double v) => '₹' + _groupIndian(v.toStringAsFixed(2));

String _groupIndian(String value) {
  final parts = value.split('.');
  final whole = parts.first;
  final negative = whole.startsWith('-');
  final digits = negative ? whole.substring(1) : whole;
  if (digits.length <= 3) return value;
  final tail = digits.substring(digits.length - 3);
  var head = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) groups.insert(0, head);
  return (negative ? '-' : '') + groups.join(',') + ',' + tail +
      (parts.length > 1 ? '.' + parts[1] : '');
}

String _isoDate(DateTime d) =>
    d.year.toString().padLeft(4, '0') + '-' +
    d.month.toString().padLeft(2, '0') + '-' +
    d.day.toString().padLeft(2, '0');

String _date(DateTime d) =>
    d.day.toString().padLeft(2, '0') + '/' +
    d.month.toString().padLeft(2, '0') + '/' +
    d.year.toString();
