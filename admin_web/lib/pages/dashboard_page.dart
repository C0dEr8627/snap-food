part of '../main.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _ConnectionBanner(),
      const SizedBox(height: 18),
      LayoutBuilder(
        builder: (context, c) {
          final count = c.maxWidth >= 1000 ? 4 : c.maxWidth >= 650 ? 2 : 1;
          return GridView.count(
            crossAxisCount: count,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: count == 4 ? 1.35 : count == 2 ? 1.8 : 3.0,
            children: const [_RevenueKpi(), _ActiveOrdersKpi(), _FleetKpi(), _SlaKpi()],
          );
        },
      ),
      const SizedBox(height: 20),
      const _AttentionSection(),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, c) => c.maxWidth >= 1050
          ? const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 7, child: _WeeklySalesCard()),
              SizedBox(width: 16),
              Expanded(flex: 4, child: _KitchenPulseCard()),
            ])
          : const Column(children: [_WeeklySalesCard(), SizedBox(height: 16), _KitchenPulseCard()]),
      ),
      const SizedBox(height: 20),
      const _LiveOrdersCard(),
    ],
  );
}
