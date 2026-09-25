import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class DeliveryNavigateRestaurantScreen extends StatefulWidget {
  const DeliveryNavigateRestaurantScreen({super.key});

  @override
  State<DeliveryNavigateRestaurantScreen> createState() => _DeliveryNavigateRestaurantScreenState();
}

class _DeliveryNavigateRestaurantScreenState extends State<DeliveryNavigateRestaurantScreen> {
  bool arrived = false;

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
                            if (!desktop) const _MobileHeader(),
                            if (!desktop) const SizedBox(height: 18),
                            _TripHeader(arrived: arrived),
                            const SizedBox(height: 18),
                            LayoutBuilder(
                              builder: (context, inner) {
                                final wide = inner.maxWidth >= 850;
                                if (wide) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 7, child: _NavigationMap(arrived: arrived)),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        flex: 4,
                                        child: _TripPanel(
                                          arrived: arrived,
                                          onArrived: () => setState(() => arrived = true),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _NavigationMap(arrived: arrived),
                                    const SizedBox(height: 18),
                                    _TripPanel(
                                      arrived: arrived,
                                      onArrived: () => setState(() => arrived = true),
                                    ),
                                  ],
                                );
                              },
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

class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.arrived});
  final bool arrived;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Navigate to restaurant', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text(
                  'TRP-1842 · Mumbai Spice Kitchen',
                  style: TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          _StatusPill(label: arrived ? 'ARRIVED' : 'EN ROUTE'),
        ],
      );
}

class _NavigationMap extends StatelessWidget {
  const _NavigationMap({required this.arrived});
  final bool arrived;

  @override
  Widget build(BuildContext context) => Container(
        height: 520,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainer,
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Stack(
          children: [
            CustomPaint(size: Size.infinite, painter: _RouteMapPainter()),
            Positioned(
              top: 16,
              left: 16,
              child: _MapBadge(
                icon: Icons.navigation_rounded,
                text: arrived ? 'At destination' : 'Following route',
              ),
            ),
            const Positioned(
              top: 16,
              right: 16,
              child: _MapBadge(icon: Icons.gps_fixed_rounded, text: 'GPS'),
            ),
            Positioned(
              left: 42,
              bottom: 48,
              child: _MapPoint(
                icon: Icons.delivery_dining_rounded,
                label: 'You',
                primary: true,
              ),
            ),
            Positioned(
              right: 48,
              top: 118,
              child: _MapPoint(
                icon: Icons.storefront_rounded,
                label: 'Mumbai Spice Kitchen',
                primary: false,
              ),
            ),
            Positioned(
              left: 18,
              bottom: 16,
              child: Text(
                arrived ? 'Andheri East · Destination reached' : 'Andheri East → Powai · Pickup route',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: SnapFoodColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = SnapFoodColors.surfaceContainerHigh;
    for (var x = 18.0; x < size.width; x += 64) {
      for (var y = 70.0; y < size.height; y += 62) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 42, 27), const Radius.circular(5)),
          blockPaint,
        );
      }
    }

    final road = Paint()
      ..color = SnapFoodColors.surfaceContainerLowest
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final edge = Paint()
      ..color = SnapFoodColors.softBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final route = Path()
      ..moveTo(size.width * .14, size.height * .82)
      ..cubicTo(
        size.width * .22,
        size.height * .62,
        size.width * .38,
        size.height * .70,
        size.width * .48,
        size.height * .48,
      )
      ..cubicTo(
        size.width * .60,
        size.height * .25,
        size.width * .72,
        size.height * .42,
        size.width * .87,
        size.height * .25,
      );

    canvas.drawPath(route, road);
    canvas.drawPath(route, edge);

    final routePaint = Paint()
      ..color = SnapFoodColors.secondary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(route, routePaint);

    final destination = Offset(size.width * .87, size.height * .25);
    final current = Offset(size.width * .14, size.height * .82);

    canvas.drawCircle(destination, 9, Paint()..color = SnapFoodColors.foodRed);
    canvas.drawCircle(current, 10, Paint()..color = SnapFoodColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.icon, required this.text});
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
            Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

class _MapPoint extends StatelessWidget {
  const _MapPoint({required this.icon, required this.label, required this.primary});
  final IconData icon;
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: primary ? SnapFoodColors.primary : SnapFoodColors.foodRed,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 9, spreadRadius: 2)],
            ),
            child: Icon(icon, size: 22, color: SnapFoodColors.warmBlack),
          ),
          const SizedBox(height: 5),
          Container(
            constraints: const BoxConstraints(maxWidth: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: SnapFoodColors.warmBlack,
              borderRadius: BorderRadius.circular(SnapFoodRadii.full),
            ),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: SnapFoodColors.cream),
            ),
          ),
        ],
      );
}

class _TripPanel extends StatelessWidget {
  const _TripPanel({required this.arrived, required this.onArrived});
  final bool arrived;
  final VoidCallback onArrived;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SnapFoodColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
              border: Border.all(color: SnapFoodColors.softBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Pickup trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                    _StatusPill(label: arrived ? 'ARRIVED' : 'ACTIVE'),
                  ],
                ),
                const SizedBox(height: 18),
                const _InfoRow(icon: Icons.storefront_outlined, label: 'Restaurant', value: 'Mumbai Spice Kitchen'),
                const SizedBox(height: 13),
                const _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: 'Andheri East, Mumbai'),
                const SizedBox(height: 13),
                const _InfoRow(icon: Icons.route_outlined, label: 'Distance', value: '4.8 km'),
                const SizedBox(height: 13),
                const _InfoRow(icon: Icons.schedule_outlined, label: 'ETA', value: '18 min'),
                const SizedBox(height: 18),
                const Divider(color: SnapFoodColors.softBorder),
                const SizedBox(height: 16),
                const Text('Pickup instructions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text(
                  'Enter through the main entrance and ask for the Snap Food pickup counter.',
                  style: TextStyle(fontSize: 11, height: 1.45, color: SnapFoodColors.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling Mumbai Spice Kitchen…')),
                        ),
                        icon: const Icon(Icons.call_outlined, size: 17),
                        label: const Text('Call restaurant'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SnapFoodColors.warmBlack,
                          side: const BorderSide(color: SnapFoodColors.softBorder),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: arrived ? null : onArrived,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SnapFoodColors.secondary,
                          foregroundColor: SnapFoodColors.onPrimary,
                          disabledBackgroundColor: SnapFoodColors.primaryContainer,
                          disabledForegroundColor: SnapFoodColors.warmBlack,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(arrived ? 'Arrived' : 'Arrived at restaurant'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: SnapFoodColors.softYellow,
              borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
              border: Border.all(color: SnapFoodColors.softBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 21, color: SnapFoodColors.secondary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keep location services enabled while navigating to the pickup point.',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: SnapFoodColors.secondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: SnapFoodColors.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
        ],
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: label == 'ARRIVED' ? SnapFoodColors.primaryContainer : SnapFoodColors.softYellow,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        ),
        child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
      );
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Text('SNAP FOOD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const _StatusPill(label: 'EN ROUTE'),
        ],
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
                  child: Icon(Icons.delivery_dining_rounded, color: SnapFoodColors.warmBlack),
                ),
                SizedBox(width: 9),
                Text('SNAP FOOD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
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
            _NavRow(Icons.account_balance_wallet_outlined, 'Earnings', false),
            Spacer(),
            Text(
              'TRP-1842 • EN ROUTE',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: SnapFoodColors.primary),
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
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
