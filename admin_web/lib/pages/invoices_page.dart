part of '../main.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key, this.searchQuery = ''});
  final String searchQuery;
  @override State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
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

  @override Widget build(BuildContext context) {
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
      const SizedBox(height: AdminSpacing.xl),Page extends StatefulWidget {
  const InvoicesPage({super.key, this.searchQuery = ''});
  final String searchQuery;
  @override State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
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

  @override Widget build(BuildContext context) {
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
      LayoutBuilder(builder: (context, c) {
        final columns = c.maxWidth >= 900 ? 4 : c.maxWidth >= 540 ? 2 : 1;
        return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: columns == 1 ? 3.2 : columns == 4 ? 1.65 : 2.2, children: [
          _InvoiceKpi(title: 'TAX INVOICES ISSUED', value: _loading ? '—' : _total.toString(), caption: 'Stored invoices matching filters', icon: HugeIcons.strokeRoundedInvoice01, accent: AdminColors.amber),
          _InvoiceKpi(title: 'TOTAL NET BILLED', value: _loading ? '—' : _inr(_billed), caption: 'Invoice totals in current result set', icon: HugeIcons.strokeRoundedWallet01, accent: AdminColors.ink),
          _InvoiceKpi(title: 'PAID INVOICES', value: _loading ? '—' : _inr(_paidTotal), caption: _paidCount.toString() + ' marked PAID', icon: HugeIcons.strokeRoundedStoreVerified01, accent: AdminColors.green),
          const _InvoiceKpi(title: 'RIDER PAYOUTS', value: 'Not available', caption: 'Payout ledger is not exposed by API', icon: HugeIcons.strokeRoundedDeliveryTruck01, accent: AdminColors.muted),
        ]);
      }),
      const SizedBox(height: 18),
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
      if (_error != null) _InvoiceStateCard(icon: HugeIcons.strokeRoundedCloud, title: 'Unable to load invoices', message: _error!, action: 'Retry', onAction: () => _load(page: _page))
      else if (_loading) const _InvoiceLoadingCard()
      else if (_items.isEmpty) _InvoiceStateCard(icon: HugeIcons.strokeRoundedInvoice01, title: 'No invoices found', message: 'Try changing your search, date range, or payment status filter.', action: 'Reset filters', onAction: _reset)
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

class _InvoiceDetail extends StatelessWidget {
  const _InvoiceDetail({required this.invoice});
  final _LedgerInvoice invoice;

  @override
  Widget build(BuildContext context) => Column(
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

class _InvoiceDetailLine extends StatelessWidget {
  const _InvoiceDetailLine(this.label, this.value, {this.strong = false});
  final String label, value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AdminSpacing.xs),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 126, child: Text(label, style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText))),
      Expanded(child: Text(value, style: AdminTypography.body.copyWith(fontWeight: strong ? FontWeight.w800 : FontWeight.w600))),
    ]),
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

class _InvoiceBreadcrumb extends StatelessWidget {
  const _InvoiceBreadcrumb();
  @override Widget build(BuildContext context) => const Wrap(spacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: [
    Text('ACCOUNTING & COMPLIANCE', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w900, color: AdminColors.muted)),
    AdminIcon(HugeIcons.strokeRoundedCircle, size: 4, color: AdminColors.warning),
    Text('INVOICE LEDGER', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w900, color: AdminColors.warning)),
  ]);
}

class _InvoiceKpi extends StatelessWidget {
  const _InvoiceKpi({required this.title, required this.value, required this.caption, required this.icon, required this.accent});
  final String title, value, caption; final AdminIconData icon; final Color accent;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminColors.line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 11, letterSpacing: .7, fontWeight: FontWeight.w900, color: AdminColors.muted))), AdminIcon(icon, size: 18, color: accent)]),
      const SizedBox(height: 12), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: value == 'Not available' ? 16 : 22, fontWeight: FontWeight.w900, color: AdminColors.ink, letterSpacing: -.5)),
      const SizedBox(height: 5), Text(caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AdminColors.muted, height: 1.4)),
    ]));
}

class _InvoiceFilterPill extends StatelessWidget {
  const _InvoiceFilterPill(this.label, this.active, this.onTap);
  final String label; final bool active; final VoidCallback onTap;
  @override Widget build(BuildContext context) => (active ? shad.Button.secondary : shad.Button.ghost)(
    onPressed: onTap,
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: active ? AdminColors.ink : AdminColors.muted)),
  );
}

class _InvoiceLedgerCard extends StatelessWidget {
  const _InvoiceLedgerCard({required this.invoices, required this.mobile, required this.page, required this.total, required this.lastPage, required this.onPage, required this.onView});
  final List<_LedgerInvoice> invoices; final bool mobile; final int page, total, lastPage; final ValueChanged<int> onPage; final ValueChanged<_LedgerInvoice> onView;
  @override Widget build(BuildContext context) => Column(children: [
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
      rows: invoices.map((item) => [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(item.number, maxLines: 1, overflow: TextOverflow.ellipsis, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w700)),
          Text('Order #\${item.orderId}', style: AdminTypography.caption),
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
    SfTablePagination(page: page, lastPage: lastPage, total: total, onPrevious: page > 1 ? () => onPage(page - 1) : null, onNext: page < lastPage ? () => onPage(page + 1) : null),
  ]);
}
class _InvoiceMobileCard extends StatelessWidget {
  const _InvoiceMobileCard({required this.invoice, required this.onView});
  final _LedgerInvoice invoice; final VoidCallback onView;
  @override Widget build(BuildContext context) => InkWell(onTap: onView, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(invoice.number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text('#ORDER-' + invoice.orderId.toString() + ' · ' + invoice.customer, style: const TextStyle(fontSize: 11, color: AdminColors.muted))])), _InvoiceStatus(invoice.paymentStatus)]),
    const SizedBox(height: 12), Row(children: [Expanded(child: Text(invoice.email.isEmpty ? 'No email recorded' : invoice.email, style: const TextStyle(fontSize: 11, color: AdminColors.muted))), Text(_inr(invoice.total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))]),
    const SizedBox(height: 7), Text('Items ' + _inr(invoice.subtotal) + ' · Delivery ' + _inr(invoice.deliveryFee), style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
    const SizedBox(height: 7), Row(children: [Expanded(child: Text(invoice.paymentMethod, style: const TextStyle(fontSize: 11))), shad.OutlineButton(onPressed: onView, child: const Text('View details'))]), const Divider(height: 1, color: AdminColors.line),
  ])));
}

class _InvoiceStatus extends StatelessWidget {
  const _InvoiceStatus(this.status); final String status;
  @override Widget build(BuildContext context) {
    final paid = status == 'PAID', pending = status == 'PENDING';
    final bg = paid ? AdminColors.greenSoft : pending ? AdminColors.amberSoft : AdminColors.redSoft;
    final fg = paid ? AdminColors.green : pending ? AdminColors.amber : AdminColors.red;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: fg)));
  }
}

class _InvoiceStateCard extends StatelessWidget {
  const _InvoiceStateCard({required this.icon, required this.title, required this.message, required this.action, required this.onAction});
  final AdminIconData icon; final String title, message, action; final VoidCallback onAction;
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(16)),
    child: Column(children: [AdminIcon(icon, size: 32, color: AdminColors.amber), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, color: AdminColors.muted, height: 1.5)), const SizedBox(height: 14), shad.PrimaryButton(onPressed: onAction, child: Text(action))]));
}

class _InvoiceLoadingCard extends StatelessWidget {
  const _InvoiceLoadingCard();
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(16)), child: const Column(children: [shad.CircularProgressIndicator(), SizedBox(height: 14), Text('Loading invoice ledger…', style: TextStyle(fontSize: 12, color: AdminColors.muted))]));
}

class _InvoiceDetailLine extends StatelessWidget {
  const _InvoiceDetailLine(this.label, this.value, {this.strong = false});
  final String label, value; final bool strong;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 125, child: Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.muted))), Expanded(child: Text(value, style: TextStyle(fontSize: 11.5, fontWeight: strong ? FontWeight.w900 : FontWeight.w700, color: AdminColors.ink)))]));
}

int _int(dynamic v, [int fallback = 0]) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? fallback;
double _number(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
String _inr(double v) => '₹' + _groupIndian(v.toStringAsFixed(2));
String _groupIndian(String value) {
  final p = value.split('.'), whole = p.first;
  if (whole.length <= 3) return value;
  final last = whole.substring(whole.length - 3);
  var prefix = whole.substring(0, whole.length - 3);
  final groups = <String>[];
  while (prefix.length > 2) { groups.insert(0, prefix.substring(prefix.length - 2)); prefix = prefix.substring(0, prefix.length - 2); }
  if (prefix.isNotEmpty) groups.insert(0, prefix);
  return groups.join(',') + ',' + last + '.' + (p.length > 1 ? p[1] : '00');
}
String _isoDate(DateTime d) => d.year.toString().padLeft(4, '0') + '-' + d.month.toString().padLeft(2, '0') + '-' + d.day.toString().padLeft(2, '0');
String _date(DateTime d) => d.day.toString().padLeft(2, '0') + '/' + d.month.toString().padLeft(2, '0') + '/' + d.year.toString();
String _formatTimestamp(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final d = parsed.toLocal(), hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return _date(d) + ' · ' + hour.toString() + ':' + d.minute.toString().padLeft(2, '0') + ' ' + (d.hour >= 12 ? 'PM' : 'AM');
}
