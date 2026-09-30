part of '../main.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});
  static const rows = [
    ['INV-2026-1048', '#SF-1048', 'Aarav Mehta', '₹840', 'Pending delivery'],
    ['INV-2026-1045', '#SF-1045', 'Ananya Rao', '₹980', 'Available'],
    ['INV-2026-1041', '#SF-1041', 'Meera Shah', '₹1,560', 'Available'],
    ['INV-2026-1038', '#SF-1038', 'Kabir Singh', '₹620', 'Available'],
  ];
  @override
  Widget build(BuildContext context) => Column(children: [
    Card(child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AdminColors.amberSoft, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.receipt_long_rounded, color: AdminColors.yellowDark)),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Invoice centre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        SizedBox(height: 3),
        Text('Invoice access follows delivered-order availability. Preview rows are illustrative.', style: TextStyle(fontSize: 10.5, color: AdminColors.muted)),
      ])),
    ]))),
    const SizedBox(height: 15),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      headingTextStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AdminColors.muted),
      columnSpacing: 28,
      columns: const [DataColumn(label: Text('INVOICE')), DataColumn(label: Text('ORDER')), DataColumn(label: Text('CUSTOMER')), DataColumn(label: Text('AMOUNT')), DataColumn(label: Text('ACCESS')), DataColumn(label: Text('ACTION'))],
      rows: rows.map((r) => DataRow(cells: [
        DataCell(Text(r[0], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5))),
        DataCell(Text(r[1])),
        DataCell(Text(r[2])),
        DataCell(Text(r[3], style: const TextStyle(fontWeight: FontWeight.w800))),
        DataCell(_Pill(r[4])),
        DataCell(IconButton(onPressed: () => _notice(context, 'Invoice viewing will be connected to the Laravel API.'), icon: const Icon(Icons.open_in_new_rounded, size: 18))),
      ])).toList(),
    ))),
  ]);
}
