import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class DeliveryDutyMapScreen extends StatefulWidget {
  const DeliveryDutyMapScreen({super.key});

  @override
  State<DeliveryDutyMapScreen> createState() => _DeliveryDutyMapScreenState();
}

class _DeliveryDutyMapScreenState extends State<DeliveryDutyMapScreen> {
  bool online = true;

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
                if (desktop) _Sidebar(online: online),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 32 : 16,
                      vertical: desktop ? 28 : 18,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!desktop)
                              _MobileHeader(
                                online: online,
                                onToggle: () =>
                                    setState(() => online = !online),
                              ),
                            if (!desktop) const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Duty map',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'See your active area and nearby demand.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              SnapFoodColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (desktop)
                                  _OnlineToggle(
                                    online: online,
                                    onToggle: () =>
                                        setState(() => online = !online),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _MapPanel(online: online),
                            const SizedBox(height: 18),
                            LayoutBuilder(
                              builder: (context, inner) {
                                final columns = inner.maxWidth >= 850 ? 3 : 1;
                                final width =
                                    (inner.maxWidth - (columns - 1) * 14) /
                                    columns;
                                return Wrap(
                                  spacing: 14,
                                  runSpacing: 14,
                                  children: [
                                    SizedBox(
                                      width: width,
                                      child: const _StatCard(
                                        icon: Icons.radar_rounded,
                                        label: 'Nearby demand',
                                        value: '12',
                                        detail: 'requests in your area',
                                      ),
                                    ),
                                    SizedBox(
                                      width: width,
                                      child: const _StatCard(
                                        icon: Icons.route_rounded,
                                        label: 'Active trips',
                                        value: '1',
                                        detail: 'in progress right now',
                                      ),
                                    ),
                                    SizedBox(
                                      width: width,
                                      child: const _StatCard(
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        label: 'Today',
                                        value: '₹684',
                                        detail: 'from 5 completed trips',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 18),
                            _DemandPanel(online: online),
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

class _MapPanel extends StatelessWidget {
  const _MapPanel({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainer,
        borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _MapPainter()),
          Positioned(
            top: 16,
            left: 16,
            child: _MapLabel(
              icon: Icons.my_location_rounded,
              text: online ? 'You are here' : 'You are offline',
            ),
          ),
          const Positioned(top: 16, right: 16, child: _MapLegend()),
          const Positioned(
            left: 31,
            top: 112,
            child: _MapPin(label: 'Andheri', demand: 'High'),
          ),
          const Positioned(
            right: 72,
            top: 92,
            child: _MapPin(label: 'Powai', demand: 'Medium'),
          ),
          const Positioned(
            right: 104,
            bottom: 76,
            child: _MapPin(label: 'Ghatkopar', demand: 'High'),
          ),
          const Positioned(
            left: 43,
            bottom: 62,
            child: _MapPin(label: 'Kurla', demand: 'Medium'),
          ),
          Positioned(
            left: MediaQuery.sizeOf(context).width * 0.34,
            top: 185,
            child: _CurrentLocation(online: online),
          ),
          const Positioned(
            left: 18,
            bottom: 16,
            child: Text(
              'Mumbai · Andheri East',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: SnapFoodColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = SnapFoodColors.surfaceContainerLowest
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadFine = Paint()
      ..color = SnapFoodColors.softBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paths = [
      Path()
        ..moveTo(-20, size.height * .28)
        ..quadraticBezierTo(
          size.width * .35,
          size.height * .08,
          size.width + 20,
          size.height * .32,
        ),
      Path()
        ..moveTo(size.width * .18, size.height + 20)
        ..quadraticBezierTo(
          size.width * .40,
          size.height * .52,
          size.width * .60,
          -20,
        ),
      Path()
        ..moveTo(-20, size.height * .70)
        ..quadraticBezierTo(
          size.width * .45,
          size.height * .45,
          size.width + 20,
          size.height * .74,
        ),
    ];

    for (final path in paths) {
      canvas.drawPath(path, road);
      canvas.drawPath(path, roadFine);
    }

    final blocks = Paint()..color = SnapFoodColors.surfaceContainerHigh;
    for (var x = 20.0; x < size.width; x += 58) {
      for (var y = 72.0; y < size.height; y += 64) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 38, 25),
            const Radius.circular(5),
          ),
          blocks,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.label, required this.demand});
  final String label;
  final String demand;

  @override
  Widget build(BuildContext context) {
    final high = demand == 'High';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: high ? SnapFoodColors.softRed : SnapFoodColors.softYellow,
            borderRadius: BorderRadius.circular(SnapFoodRadii.full),
            border: Border.all(color: SnapFoodColors.softBorder),
          ),
          child: Text(
            '$label · $demand',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
          ),
        ),
        Icon(
          Icons.location_on_rounded,
          size: 22,
          color: high ? SnapFoodColors.foodRed : SnapFoodColors.secondary,
        ),
      ],
    );
  }
}

class _CurrentLocation extends StatelessWidget {
  const _CurrentLocation({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: online
                ? SnapFoodColors.primary
                : SnapFoodColors.onSurfaceVariant,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 3),
            ],
          ),
          child: const Icon(
            Icons.delivery_dining_rounded,
            size: 24,
            color: SnapFoodColors.warmBlack,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: SnapFoodColors.warmBlack,
            borderRadius: BorderRadius.circular(SnapFoodRadii.full),
          ),
          child: const Text(
            'You',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: SnapFoodColors.cream,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: SnapFoodColors.secondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: const Row(
      children: [
        Icon(Icons.circle, size: 8, color: SnapFoodColors.foodRed),
        SizedBox(width: 5),
        Text(
          'High demand',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
        ),
        SizedBox(width: 10),
        Icon(Icons.circle, size: 8, color: SnapFoodColors.secondary),
        SizedBox(width: 5),
        Text(
          'Medium',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: SnapFoodColors.primaryContainer,
            borderRadius: BorderRadius.circular(SnapFoodRadii.md),
          ),
          child: Icon(icon, color: SnapFoodColors.warmBlack, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 9,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DemandPanel extends StatelessWidget {
  const _DemandPanel({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Row(
      children: [
        Icon(
          online ? Icons.bolt_rounded : Icons.pause_circle_outline_rounded,
          size: 25,
          color: online
              ? SnapFoodColors.secondary
              : SnapFoodColors.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                online
                    ? 'Demand is active around you'
                    : 'You are currently offline',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                online
                    ? 'Andheri East and Ghatkopar currently have more requests than nearby zones.'
                    : 'Go online when you are ready to receive delivery requests.',
                style: const TextStyle(
                  fontSize: 11,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({required this.online, required this.onToggle});
  final bool online;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onToggle,
    icon: Icon(
      online
          ? Icons.pause_circle_outline_rounded
          : Icons.play_circle_outline_rounded,
      size: 18,
    ),
    label: Text(online ? 'Go offline' : 'Go online'),
    style: OutlinedButton.styleFrom(
      foregroundColor: SnapFoodColors.warmBlack,
      side: const BorderSide(color: SnapFoodColors.softBorder),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.online, required this.onToggle});
  final bool online;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const CircleAvatar(
        radius: 19,
        backgroundColor: SnapFoodColors.primaryContainer,
        child: Icon(
          Icons.delivery_dining_rounded,
          color: SnapFoodColors.warmBlack,
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Text(
          'SNAP FOODD',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      TextButton(
        onPressed: onToggle,
        child: Text(
          online ? 'ONLINE' : 'OFFLINE',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) => Container(
    width: 224,
    height: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 24, 14, 18),
    decoration: const BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      border: Border(right: BorderSide(color: SnapFoodColors.softBorder)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
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
        const SizedBox(height: 34),
        const Text(
          'PARTNER',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: SnapFoodColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        const _NavRow(Icons.inbox_outlined, 'Requests', false),
        const _NavRow(Icons.map_outlined, 'Duty map', true),
        const _NavRow(Icons.route_outlined, 'Trips', false),
        const _NavRow(Icons.account_balance_wallet_outlined, 'Earnings', false),
        const Spacer(),
        Text(
          online ? 'ONLINE • ACCEPTING REQUESTS' : 'OFFLINE • PAUSED',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: online
                ? SnapFoodColors.primary
                : SnapFoodColors.onSurfaceVariant,
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
