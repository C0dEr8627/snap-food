import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class DeliveryEarningsHistoryScreen extends StatefulWidget {
  const DeliveryEarningsHistoryScreen({super.key});

  @override
  State<DeliveryEarningsHistoryScreen> createState() =>
      _DeliveryEarningsHistoryScreenState();
}

class _DeliveryEarningsHistoryScreenState
    extends State<DeliveryEarningsHistoryScreen> {
  String filter = 'All trips';

  final trips = const [
    _Trip(
      'TRP-1842',
      'Mumbai Spice Kitchen',
      'Andheri East → Powai',
      'Today · 7:42 PM',
      '₹128',
      'Completed',
    ),
    _Trip(
      'TRP-1841',
      'The Bombay Bowl',
      'Marol → Vikhroli',
      'Today · 6:51 PM',
      '₹156',
      'Completed',
    ),
    _Trip(
      'TRP-1840',
      'Green Leaf Cafe',
      'Powai → Ghatkopar',
      'Today · 5:38 PM',
      '₹142',
      'Completed',
    ),
    _Trip(
      'TRP-1839',
      'Curry House',
      'Sakinaka → Kurla West',
      'Today · 4:44 PM',
      '₹116',
      'Completed',
    ),
    _Trip(
      'TRP-1838',
      'Mumbai Spice Kitchen',
      'Andheri East → Powai',
      'Yesterday · 9:12 PM',
      '₹142',
      'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final desktop = c.maxWidth >= 900;
            return Row(
              children: [
                if (desktop) const _Sidebar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 32 : 16,
                      vertical: 22,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!desktop) const _MobileHeader(),
                            if (!desktop) const SizedBox(height: 18),
                            const Text(
                              'Earnings & trip history',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Track completed trips, payouts and delivery activity.',
                              style: TextStyle(
                                fontSize: 12,
                                color: SnapFoodColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const _EarningsHero(),
                            const SizedBox(height: 18),
                            const _SummaryRow(),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Trip history',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                _FilterChip(
                                  label: 'All trips',
                                  selected: filter == 'All trips',
                                  onTap: () =>
                                      setState(() => filter = 'All trips'),
                                ),
                                const SizedBox(width: 7),
                                _FilterChip(
                                  label: 'Today',
                                  selected: filter == 'Today',
                                  onTap: () => setState(() => filter = 'Today'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _TripList(
                              trips: filter == 'Today'
                                  ? trips.take(4).toList()
                                  : trips,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Trip {
  const _Trip(
    this.id,
    this.restaurant,
    this.route,
    this.time,
    this.earning,
    this.status,
  );
  final String id;
  final String restaurant;
  final String route;
  final String time;
  final String earning;
  final String status;
}

class _EarningsHero extends StatelessWidget {
  const _EarningsHero();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: SnapFoodColors.warmBlack,
      borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 18,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today’s earnings',
              style: TextStyle(fontSize: 11, color: SnapFoodColors.cream),
            ),
            SizedBox(height: 6),
            Text(
              '₹684',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: SnapFoodColors.primary,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '5 completed trips',
              style: TextStyle(fontSize: 10, color: SnapFoodColors.cream),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: SnapFoodColors.primary,
            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 19,
                color: SnapFoodColors.warmBlack,
              ),
              SizedBox(width: 7),
              Text(
                '₹136.80 avg / trip',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _Metric(
          label: 'Completed',
          value: '5',
          icon: Icons.check_circle_outline_rounded,
        ),
        _Metric(
          label: 'Distance',
          value: '24.7 km',
          icon: Icons.route_outlined,
        ),
        _Metric(
          label: 'Online time',
          value: '4h 18m',
          icon: Icons.schedule_outlined,
        ),
        _Metric(
          label: 'Avg. rating',
          value: '4.9',
          icon: Icons.star_outline_rounded,
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 190,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: SnapFoodColors.secondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: SnapFoodColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TripList extends StatelessWidget {
  const _TripList({required this.trips});
  final List<_Trip> trips;

  @override
  Widget build(BuildContext context) => Column(
    children: trips
        .map(
          (trip) => Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: SnapFoodColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              border: Border.all(color: SnapFoodColors.softBorder),
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                final compact = c.maxWidth < 620;
                final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.id,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: SnapFoodColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trip.restaurant,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trip.route,
                      style: const TextStyle(
                        fontSize: 10,
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trip.time,
                      style: const TextStyle(
                        fontSize: 9,
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
                final payout = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.earning,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: SnapFoodColors.primaryContainer,
                        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                      ),
                      child: Text(
                        trip.status,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      details,
                      const SizedBox(height: 10),
                      Row(children: [const Spacer(), payout]),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: details),
                    payout,
                  ],
                );
              },
            ),
          ),
        )
        .toList(),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? SnapFoodColors.primaryContainer
            : SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
      ),
    ),
  );
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Expanded(
          child: Text(
            'SNAP FOODD',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        const _StatusPill(),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: SnapFoodColors.primaryContainer,
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
    ),
    child: const Text(
      'ONLINE',
      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
    ),
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) => Container(
    width: 224,
    height: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 24, 14, 18),
    decoration: const BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      border: Border(right: BorderSide(color: SnapFoodColors.softBorder)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: SnapFoodColors.primaryContainer,
              child: Icon(
                Icons.delivery_dining_rounded,
                color: SnapFoodColors.warmBlack,
              ),
            ),
            SizedBox(width: 9),
            Text(
              'SNAP FOODD',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        SizedBox(height: 34),
        Text(
          'PARTNER',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: SnapFoodColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 10),
        _NavRow(Icons.inbox_outlined, 'Requests', false),
        _NavRow(Icons.map_outlined, 'Duty map', false),
        _NavRow(Icons.route_outlined, 'Trips', true),
        _NavRow(Icons.account_balance_wallet_outlined, 'Earnings', true),
        Spacer(),
        Text(
          'TODAY • ₹684',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: SnapFoodColors.primary,
          ),
        ),
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow(this.icon, this.label, this.selected);
  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 5),
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
    decoration: BoxDecoration(
      color: selected ? SnapFoodColors.primaryContainer : null,
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: SnapFoodColors.warmBlack),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
