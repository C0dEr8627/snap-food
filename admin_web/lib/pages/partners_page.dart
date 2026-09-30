part of '../main.dart';

class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key});
  static const rows = [
    ['Vikram Joshi', 'DP-0084', 'Mumbai Central', 'Approved', 'Available'],
    ['Neha Kulkarni', 'DP-0083', 'Andheri West', 'Approved', 'On delivery'],
    ['Sameer Khan', 'DP-0082', 'Bandra', 'Pending review', 'Offline'],
    ['Priya Nair', 'DP-0081', 'Powai', 'Approved', 'Available'],
  ];
  @override
  Widget build(BuildContext context) => Column(children: [
    LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 850 ? 3 : c.maxWidth >= 500 ? 2 : 1;
      return GridView.count(crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 13, mainAxisSpacing: 13, childAspectRatio: cols == 1 ? 3.2 : 2.1, children: const [
        _Kpi(title: 'Total partners', value: '84', delta: '+6 this week', icon: Icons.groups_2_outlined, tone: AdminColors.amberSoft),
        _Kpi(title: 'Available now', value: '21', delta: 'Online', icon: Icons.electric_bike_outlined, tone: AdminColors.greenSoft),
        _Kpi(title: 'Pending review', value: '03', delta: 'Action needed', icon: Icons.pending_actions_rounded, tone: AdminColors.redSoft),
      ]);
    }),
    const SizedBox(height: 17),
    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      headingTextStyle: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AdminColors.muted),
      columnSpacing: 28,
      columns: const [DataColumn(label: Text('PARTNER')), DataColumn(label: Text('ID')), DataColumn(label: Text('AREA')), DataColumn(label: Text('KYC')), DataColumn(label: Text('AVAILABILITY')), DataColumn(label: Text('ACTION'))],
      rows: rows.map((r) => DataRow(cells: [
        DataCell(Text(r[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
        DataCell(Text(r[1])),
        DataCell(Text(r[2])),
        DataCell(_Pill(r[3])),
        DataCell(Text(r[4])),
        DataCell(TextButton(onPressed: () => _notice(context, 'Partner review will use protected Laravel admin endpoints.'), child: const Text('Review'))),
      ])).toList(),
    ))),
  ]);
}
