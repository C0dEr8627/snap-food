part of '../main.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _ConnectionBanner(),
      const SizedBox(height: AdminSpacing.xxl),
      LayoutBuilder(
        builder: (context, c) {
          final count = c.maxWidth >= 1000 ? 4 : c.maxWidth >= 650 ? 2 : 1;
          return GridView.count(
            crossAxisCount: count,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AdminSpacing.md,
            mainAxisSpacing: AdminSpacing.md,
            childAspectRatio: count == 4 ? 1.35 : count == 2 ? 1.8 : 3.0,
            children: const [_RevenueKpi(), _ActiveOrdersKpi(), _FleetKpi(), _SlaKpi()],
          );
        },
      ),
      const SizedBox(height: AdminSpacing.xxl),
      const _AttentionSection(),
      const SizedBox(height: AdminSpacing.xxl),
      LayoutBuilder(
        builder: (context, c) => c.maxWidth >= 1050
          ? const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 7, child: _WeeklySalesCard()),
              SizedBox(width: 16),
              Expanded(flex: 4, child: _OperationsPulseCard()),
            ])
          : const Column(children: [_WeeklySalesCard(), SizedBox(height: 16), _OperationsPulseCard()]),
      ),
      const SizedBox(height: AdminSpacing.xxl),
      const _LiveOrdersCard(),
    ],
  );
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner();

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AdminColors.greenSoft, borderRadius: BorderRadius.circular(9)), child: const AdminIcon(HugeIcons.strokeRoundedCloudSavingDone01, size: 18, color: AdminColors.green)),
        const SizedBox(width: 11),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Laravel API v1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          SizedBox(height: 2),
          Text('Preview environment', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
          SizedBox(height: 2),
          Text('Preview data mode is active; live dashboard aggregates are not fabricated.', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
        ])),
        if (MediaQuery.sizeOf(context).width >= 650) ...[
          const Text('Preview', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.muted)),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _notice(context, 'Sync state is ready for the live API connection.'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), side: const BorderSide(color: AdminColors.line)),
            child: const Text('API status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ],
      ]),
    ),
  );
}

class _RevenueKpi extends StatelessWidget {
  const _RevenueKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: "TODAY'S REVENUE", value: '₹1,42,850', secondary: '+14.8% vs last week',
    footer: 'Settled Orders: 382    •    AOV: ₹374', icon: HugeIcons.strokeRoundedWallet01, iconTone: AdminColors.amberSoft,
  );
}

class _ActiveOrdersKpi extends StatelessWidget {
  const _ActiveOrdersKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: 'ACTIVE ORDERS', value: '64', secondary: 'In-flight',
    footer: '18 New   •   26 Preparation   •   20 Out', icon: HugeIcons.strokeRoundedShoppingBag01, iconTone: AdminColors.redSoft, progress: .72,
  );
}

class _FleetKpi extends StatelessWidget {
  const _FleetKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: 'FLEET STATUS', value: '42', secondary: 'Partners Online',
    footer: 'Zone: Koramangala – HSR   •   36 on Trip', icon: HugeIcons.strokeRoundedMotorbike02, iconTone: AdminColors.greenSoft,
    progress: .85, progressLabel: '85% Utilized    •    6 Available',
  );
}

class _SlaKpi extends StatelessWidget {
  const _SlaKpi();
  @override
  Widget build(BuildContext context) => const _DashboardKpi(
    label: 'AVG SLA DELIVERY', value: '24.2 mins', secondary: 'Target: < 30 mins (Optimal)',
    footer: 'Prep SLA: 12.4m    •    Transit: 11.8m', icon: HugeIcons.strokeRoundedTimer02, iconTone: AdminColors.blueSoft,
  );
}

class _DashboardKpi extends StatelessWidget {
  const _DashboardKpi({required this.label, required this.value, required this.secondary, required this.footer, required this.icon, required this.iconTone, this.progress, this.progressLabel});
  final String label, value, secondary, footer;
  final AdminIconData icon;
  final Color iconTone;
  final double? progress;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .5, color: AdminColors.muted))),
          Container(width: 31, height: 31, decoration: BoxDecoration(color: iconTone, borderRadius: BorderRadius.circular(9)), child: AdminIcon(icon, size: 16, color: AdminColors.ink)),
        ]),
        const SizedBox(height: 11),
        Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, height: 1)),
        const SizedBox(height: 7),
        Text(secondary, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.green)),
        if (progress != null) ...[
          const SizedBox(height: 10),
          _DashboardProgress(value: progress ?? 0),
          const SizedBox(height: 4),
          Text(progressLabel ?? '', style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
        ],
        const Spacer(),
        Text(footer, style: const TextStyle(fontSize: 11, color: AdminColors.muted, height: 1.25)),
      ]),
    ),
  );
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection();

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _StatusDot(color: AdminColors.red),
          const SizedBox(width: 8),
          const Expanded(child: Text('Immediate Attention Required', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: AdminColors.redSoft, borderRadius: BorderRadius.circular(8)), child: const Text('3 Priorities', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.red))),
        ]),
        const SizedBox(height: 13),
        LayoutBuilder(builder: (context, c) {
          final count = c.maxWidth >= 900 ? 3 : c.maxWidth >= 600 ? 2 : 1;
          return GridView.count(
            crossAxisCount: count, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: count == 1 ? 3.8 : 2.6,
            children: const [
              _AttentionItem(title: '3 Orders Need Courier...', detail: 'DriverIdle > 8 mins HR...', action: 'Reassign', danger: true),
              _AttentionItem(title: '4 Pending Partner KYC Ap...', detail: 'Aadhaar & RC uploads verificat...', action: 'Verify'),
              _AttentionItem(title: '2 Catalogue Items Need Review', detail: 'Existing catalogue records require review...', action: 'Adjust'),
            ],
          );
        }),
      ]),
    ),
  );
}

class _AttentionItem extends StatelessWidget {
  const _AttentionItem({required this.title, required this.detail, required this.action, this.danger = false});
  final String title, detail, action;
  final bool danger;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: danger ? AdminColors.redSoft : AdminColors.canvas, borderRadius: BorderRadius.circular(10), border: Border.all(color: danger ? AdminColors.redSoft : AdminColors.line)),
    child: Row(children: [
      Container(width: 30, height: 30, decoration: BoxDecoration(color: danger ? Colors.white : AdminColors.amberSoft, borderRadius: BorderRadius.circular(8)), child: AdminIcon(danger ? HugeIcons.strokeRoundedAlert02 : HugeIcons.strokeRoundedTask01, size: 15, color: danger ? AdminColors.red : AdminColors.amber)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
      ])),
      const SizedBox(width: 6),
      shad.OutlineButton(
        onPressed: () => _notice(context, '$action flow will connect to the existing admin service.'),
        child: Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
      ),
    ]),
  );
}

class _WeeklySalesCard extends StatelessWidget {
  const _WeeklySalesCard();
  static const values = <double>[112000, 128000, 119000, 143000, 154000, 172000, 158000];
  static const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Weekly Sales & Dispatch Volume', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('Monday through Sunday aggregate revenue with peak order milestones', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: AdminColors.greenSoft, borderRadius: BorderRadius.circular(8)), child: const Text('Preview data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.green))),
        ]),
        const SizedBox(height: 14),
        const Row(children: [
          _MetricLabel(label: 'Peak Target', value: '₹1,80,000 / day'),
          SizedBox(width: 18),
          _MetricLabel(label: 'Week-to-Date', value: '₹9,84,320'),
          Spacer(),
          _ChartToggle(label: 'Gross (₹)', active: true),
          SizedBox(width: 5),
          _ChartToggle(label: 'Order Count'),
        ]),
        const SizedBox(height: 12),
        SizedBox(height: 225, child: CustomPaint(painter: _SalesChartPainter(values: values, labels: labels), child: const SizedBox.expand())),
        const SizedBox(height: 7),
        const Wrap(alignment: WrapAlignment.end, spacing: 12, runSpacing: 5, children: [
          _LegendDot(color: AdminColors.yellow, label: 'Regular Weekday'),
          _LegendDot(color: AdminColors.red, label: 'Current Date'),
          _LegendDot(color: AdminColors.amber, label: 'Peak Dinner Rush'),
          Text('Detailed Analytics →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.amber)),
        ]),
      ]),
    ),
  );
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
  ]);
}

class _ChartToggle extends StatelessWidget {
  const _ChartToggle({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: active ? AdminColors.ink : AdminColors.canvas, borderRadius: BorderRadius.circular(7)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: active ? Colors.white : AdminColors.muted)),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
  ]);
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter({required this.values, required this.labels});
  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0, right = 10.0, top = 18.0, bottom = 31.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    const maxValue = 190000.0;
    final gridPaint = Paint()..color = AdminColors.line..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const gridLabels = ['180k', '120k', '60k', '0'];
    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      textPainter.text = TextSpan(text: gridLabels[i], style: const TextStyle(fontSize: 11, color: AdminColors.muted));
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 5));
    }
    final slot = chartWidth / values.length;
    for (var i = 0; i < values.length; i++) {
      final barHeight = chartHeight * values[i] / maxValue;
      final x = left + slot * i + slot * .22;
      final w = slot * .56;
      final y = top + chartHeight - barHeight;
      final color = i == 3 ? AdminColors.red : i == 5 ? AdminColors.amber : AdminColors.yellow;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, barHeight), const Radius.circular(5)), Paint()..color = color);
      textPainter.text = TextSpan(text: '₹${(values[i] / 1000).round()}k', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: i == 3 ? AdminColors.red : AdminColors.ink));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (w - textPainter.width) / 2, y - 14));
      textPainter.text = TextSpan(text: labels[i], style: TextStyle(fontSize: 11, fontWeight: i == 3 ? FontWeight.w900 : FontWeight.w700, color: i == 3 ? AdminColors.red : AdminColors.muted));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (w - textPainter.width) / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) => oldDelegate.values != values;
}

class _OperationsPulseCard extends StatelessWidget {
  const _OperationsPulseCard();

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Operations Pulse', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(7)), child: const Text('Current order flow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 12),
        const _OperationsItem(name: 'New orders', tickets: '18 active orders', prep: 'Awaiting processing', capacity: .98, icon: HugeIcons.strokeRoundedShoppingBag01),
        const SizedBox(height: 9),
        const _OperationsItem(name: 'Preparing orders', tickets: '26 active orders', prep: 'In preparation', capacity: .72, icon: HugeIcons.strokeRoundedTask01),
        const SizedBox(height: 9),
        const _OperationsItem(name: 'Dispatched orders', tickets: '20 active orders', prep: 'With delivery partners', capacity: .64, icon: HugeIcons.strokeRoundedDeliveryTruck01),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const AdminIcon(HugeIcons.strokeRoundedFlash, size: 17, color: AdminColors.amber),
            const SizedBox(width: 8),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Delivery operations', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              SizedBox(height: 2),
              Text('42 partners online', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
            ])),
            const shad.Switch(value: true, onChanged: null),
          ]),
        ),
      ]),
    ),
  );
}

class _DashboardProgress extends StatelessWidget {
  const _DashboardProgress({required this.value, this.color = AdminColors.yellow});
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Container(
      height: 5,
      color: AdminColors.canvas,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(color: color),
      ),
    ),
  );
}

class _OperationsItem extends StatelessWidget {
  const _OperationsItem({required this.name, required this.tickets, required this.prep, required this.capacity, required this.icon});
  final String name, tickets, prep;
  final double capacity;
  final AdminIconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(9)), child: AdminIcon(icon, size: 18, color: AdminColors.amber)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('$tickets • $prep', style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
        const SizedBox(height: 6),
        _DashboardProgress(value: capacity, color: capacity > .9 ? AdminColors.red : AdminColors.amber),
      ])),
      const SizedBox(width: 8),
      Text('${(capacity * 100).round()}% cap', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.muted)),
    ]),
  );
}

class _LiveOrdersCard extends StatelessWidget {
  const _LiveOrdersCard();

  static const orders = [
    ['#SFD-4091', 'Aditi Sharma', '+9198451••••', '2× Paneer Butter Masala, 4× Butter Naan', 'Spice: Medium • Extra cutleries', '₹640.00', 'NEW', 'SnapPay UPI', 'Just now', '12:44 PM'],
    ['#SFD-4092', 'Vikram Malhotra', '', '1× Special Chicken Dum Biryani, 1× Raita', 'Truffle Feast • Cook time: 11 mins left', '₹429.00', 'PREPARING', 'SnapPay UPI', '4 mins ago', '12:40 PM'],
    ['#SFD-4093', 'Rohan Nair', '', '2× Classic Cheese Smash Burgers, 1× Peri Peri Fries', 'Rider: Rajesh K. (ID #RID-8821)', '₹519.00', 'OUT FOR DELIVERY', 'Cash on Del.', '14 mins ago', '12:30 PM'],
    ['#SFD-4090', 'Pooja Venkatesh', '', '1× Margherita Sourdough, 1× Choco Lava Cake', 'Delivered in 21.4 mins • 5-Star Rating', '₹485.00', 'DELIVERED', 'SnapPay UPI', '28 mins ago', '12:16 PM'],
  ];

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _StatusDot(color: AdminColors.red),
          const SizedBox(width: 8),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recent Live Order Stream', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('Real-time telemetry updated via websocket /api/v1/orders/stream', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
          ])),
          shad.IconButton.ghost(onPressed: () => _notice(context, 'Export will use the existing orders service when connected.'), icon: const AdminIcon(HugeIcons.strokeRoundedDownload01, size: 19)),
        ]),
        const SizedBox(height: 13),
        const SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _OrderTab(text: 'All Orders (64)', active: true), SizedBox(width: 6), _OrderTab(text: 'New (18)'), SizedBox(width: 6), _OrderTab(text: 'Preparing (26)'), SizedBox(width: 6), _OrderTab(text: 'Dispatched (20)'),
        ])),
        const SizedBox(height: 13),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: shad.Table(
            rows: [
              shad.TableHeader(cells: const [
                shad.TableCell(child: Text('ORDER ID')),
                shad.TableCell(child: Text('CUSTOMER')),
                shad.TableCell(child: Text('ITEMS SUMMARY')),
                shad.TableCell(child: Text('TOTAL AMOUNT')),
                shad.TableCell(child: Text('STATUS')),
                shad.TableCell(child: Text('PAYMENT')),
                shad.TableCell(child: Text('TIMESTAMP')),
                shad.TableCell(child: Text('ACTIONS')),
              ]),
              ...orders.map((o) => shad.TableRow(cells: [
                shad.TableCell(child: Text(o[0], style: const TextStyle(fontWeight: FontWeight.w900))),
                shad.TableCell(child: SizedBox(width: 125, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o[1], style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (o[2].isNotEmpty) Text(o[2], style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
                ]))),
                shad.TableCell(child: SizedBox(width: 260, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o[3], maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(o[4], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
                ]))),
                shad.TableCell(child: Text(o[5], style: const TextStyle(fontWeight: FontWeight.w900))),
                shad.TableCell(child: _OrderStatus(o[6])),
                shad.TableCell(child: Text(o[7])),
                shad.TableCell(child: SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o[8], style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(o[9], style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
                ]))),
                shad.TableCell(child: Wrap(spacing: 4, children: [
                  shad.OutlineButton(onPressed: () => _notice(context, 'Action will connect to the existing order workflow.'), child: Text(o[6] == 'NEW' ? 'Accept' : o[6] == 'PREPARING' ? 'KDS View' : o[6] == 'OUT FOR DELIVERY' ? 'Track GPS' : 'Invoice', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                  shad.OutlineButton(onPressed: () => _notice(context, 'Order detail route will use the existing navigation flow.'), child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                ])),
              ])),
            ],
            columnWidths: const {
              0: shad.FixedTableSize(110),
              1: shad.FlexTableSize(flex: 1),
              2: shad.FlexTableSize(flex: 2),
              3: shad.FixedTableSize(110),
              4: shad.FixedTableSize(125),
              5: shad.FixedTableSize(100),
              6: shad.FixedTableSize(115),
              7: shad.FixedTableSize(230),
            },
          ),
        ),
        const SizedBox(height: 7),
        const Row(children: [
          Expanded(child: Text('Showing 1 to 4 of 64 active telemetry records', style: TextStyle(fontSize: 11, color: AdminColors.muted))),
          _PageButton(label: 'Previous'), SizedBox(width: 4), _PageButton(label: '1', active: true), SizedBox(width: 4), _PageButton(label: '2'), SizedBox(width: 4), _PageButton(label: '3'), SizedBox(width: 4), _PageButton(label: 'Next'),
        ]),
      ]),
    ),
  );
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({required this.text, this.active = false});
  final String text;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: active ? AdminColors.ink : AdminColors.canvas, borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? AdminColors.ink : AdminColors.line)),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: active ? Colors.white : AdminColors.muted)),
  );
}

class _OrderStatus extends StatelessWidget {
  const _OrderStatus(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final Color bg = switch (status) {
      'NEW' => AdminColors.redSoft,
      'PREPARING' => AdminColors.amberSoft,
      'OUT FOR DELIVERY' => AdminColors.yellow,
      _ => AdminColors.greenSoft,
    };
    final Color fg = status == 'NEW' ? AdminColors.red : status == 'OUT FOR DELIVERY' ? AdminColors.ink : status == 'DELIVERED' ? AdminColors.green : AdminColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: fg)),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: active ? AdminColors.yellow : Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: active ? AdminColors.yellow : AdminColors.line)),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
  );
}

class _SalesCard extends StatelessWidget {
  const _SalesCard();
  @override
  Widget build(BuildContext context) => AdminCard(child: Padding(padding: const EdgeInsets.all(21), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Sales overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        SizedBox(height: 3),
        Text('Weekly order volume · preview data', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(9)), child: const Text('This week', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
    ]),
    const SizedBox(height: 25),
    SizedBox(height: 182, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: const [
      _ChartBar(day: 'MON', h: .42), _ChartBar(day: 'TUE', h: .60), _ChartBar(day: 'WED', h: .51), _ChartBar(day: 'THU', h: .78), _ChartBar(day: 'FRI', h: .65), _ChartBar(day: 'SAT', h: .92, active: true), _ChartBar(day: 'SUN', h: .73),
    ])),
  ])));
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.day, required this.h, this.active = false});
  final String day; final double h; final bool active;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
    Expanded(child: Align(alignment: Alignment.bottomCenter, child: FractionallySizedBox(heightFactor: h, child: Container(width: 24, decoration: BoxDecoration(color: active ? AdminColors.red : AdminColors.yellow, borderRadius: BorderRadius.circular(7)))))),
    const SizedBox(height: 9),
    Text(day, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w900 : FontWeight.w600, color: active ? AdminColors.red : AdminColors.muted)),
  ]));
}

class _OpsCard extends StatelessWidget {
  const _OpsCard();
  @override
  Widget build(BuildContext context) => AdminCard(child: Padding(padding: const EdgeInsets.all(21), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Live operations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    const Text('Current order queue', style: TextStyle(fontSize: 11, color: AdminColors.muted)),
    const SizedBox(height: AdminSpacing.xxl),
    const _Progress(label: 'New orders', value: '12', fraction: .78, color: AdminColors.red),
    const SizedBox(height: 17),
    const _Progress(label: 'Preparing', value: '24', fraction: .62, color: AdminColors.amber),
    const SizedBox(height: 17),
    const _Progress(label: 'Ready for pickup', value: '09', fraction: .38, color: AdminColors.green),
    const SizedBox(height: 17),
    const _Progress(label: 'Out for delivery', value: '18', fraction: .52, color: AdminColors.blue),
  ])));
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.value, required this.fraction, required this.color});
  final String label, value; final double fraction; final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))), Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))]),
    const SizedBox(height: 7),
    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: fraction, minHeight: 6, backgroundColor: AdminColors.canvas, color: color)),
  ]);
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, this.action});
  final String title; final String? action;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), if (action != null) shad.Button.ghost(onPressed: () => _notice(context, 'Use the Orders page for the complete queue.'), child: Text(action!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.amber)))]);
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable();

  static const rows = [
    ['#SF-1048', 'Aarav Mehta', '₹840', '12:42 PM', 'Preparing'],
    ['#SF-1045', 'Ananya Rao', '₹980', '12:36 PM', 'Ready'],
    ['#SF-1041', 'Meera Shah', '₹1,560', '12:19 PM', 'Out for delivery'],
  ];

  @override
  Widget build(BuildContext context) => AdminCard(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: shad.Table(
        rows: [
          shad.TableHeader(cells: const [
            shad.TableCell(child: Text('ORDER')),
            shad.TableCell(child: Text('CUSTOMER')),
            shad.TableCell(child: Text('TOTAL')),
            shad.TableCell(child: Text('TIME')),
            shad.TableCell(child: Text('STATUS')),
            shad.TableCell(child: Text('ACTION')),
          ]),
          ...rows.map((r) => shad.TableRow(cells: [
            shad.TableCell(child: Text(r[0], style: const TextStyle(fontWeight: FontWeight.w900))),
            shad.TableCell(child: Text(r[1])),
            shad.TableCell(child: Text(r[2], style: const TextStyle(fontWeight: FontWeight.w800))),
            shad.TableCell(child: Text(r[3])),
            shad.TableCell(child: SfStatusBadge(label: r[4], status: r[4])),
            shad.TableCell(child: shad.IconButton.ghost(onPressed: () => _notice(context, 'Order details will be connected to the Laravel API.'), icon: const AdminIcon(HugeIcons.strokeRoundedArrowRight01, size: 19))),
          ])),
        ],
        columnWidths: const {
          0: shad.FixedTableSize(120),
          1: shad.FlexTableSize(flex: 2),
          2: shad.FixedTableSize(90),
          3: shad.FixedTableSize(90),
          4: shad.FixedTableSize(120),
          5: shad.FixedTableSize(90),
        },
      ),
    ),
  );
}
