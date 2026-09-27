import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class SplashWelcomeScreen extends StatelessWidget {
  const SplashWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: _SplashDoodles(),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: SnapFoodSpacing.mobileMargin),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: const _SplashContent(),
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

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: SnapFoodSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TrustPill(),
          const SizedBox(height: 16),
          const _HeroMascot(),
          const SizedBox(height: 17),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'SNAP ',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: SnapFoodColors.onSurface,
                  ),
                ),
                TextSpan(
                  text: 'FOODD',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: SnapFoodColors.foodRed,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'Your friendly Mumbai food delivery companion',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              height: 20 / 14,
              color: SnapFoodColors.onSurface,
            ),
          ),
          const SizedBox(height: 17),
          const _ValuePropositions(),
          const SizedBox(height: 22),
          const _SplashActions(),
        ],
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: SnapFoodColors.primary),
            const SizedBox(width: 4),
            Text(
              '4.9 Rating by 1,20,000+ Mumbai foodies',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 11,
                color: SnapFoodColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMascot extends StatelessWidget {
  const _HeroMascot();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(320.0, constraints.maxWidth);
        return SizedBox(
          width: width,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: SvgPicture.asset(
                  'assets/images/customer/logo.svg',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: -16,
                right: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: SnapFoodColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x18000000), blurRadius: 7, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🛵', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'Hot & Fast!',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: SnapFoodColors.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ValuePropositions extends StatelessWidget {
  const _ValuePropositions();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ValueCard(
          icon: Icons.bolt,
          iconBackground: SnapFoodColors.primaryContainer,
          iconColor: SnapFoodColors.warmBlack,
          title: 'Lightning Fast Delivery',
          description: 'To your doorstep in under 25 minutes across Mumbai',
        ),
        SizedBox(height: 8),
        _ValueCard(
          icon: Icons.storefront,
          iconBackground: Color(0xFFFFDAD3),
          iconColor: SnapFoodColors.secondary,
          title: 'Best Neighborhood Spots',
          description: 'Curated iconic local eateries, street food & fine dining',
        ),
        SizedBox(height: 8),
        _ValueCard(
          icon: Icons.local_fire_department,
          iconBackground: Color(0xFFEDC13D),
          iconColor: SnapFoodColors.warmBlack,
          title: 'Fresh & Hot Always',
          description: 'Insulated smart thermal transport through Mumbai traffic',
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.md),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    height: 18 / 13,
                    color: SnapFoodColors.onSurface,
                  ),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 15 / 11,
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
}

class _SplashActions extends StatelessWidget {
  const _SplashActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            onPressed: () => context.go('/home'),
            style: FilledButton.styleFrom(
              backgroundColor: SnapFoodColors.secondary,
              foregroundColor: SnapFoodColors.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const StadiumBorder(),
              elevation: 4,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: SnapFoodColors.onSecondary.withAlpha(46),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.go('/home'),
          style: TextButton.styleFrom(
            foregroundColor: SnapFoodColors.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              children: [
                TextSpan(
                  text: 'Sign In with\nMobile (+91)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: SnapFoodColors.secondary,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  height: 18 / 14,
                  color: SnapFoodColors.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}

class _SplashDoodles extends StatelessWidget {
  const _SplashDoodles();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SplashDoodlesPainter());
  }
}

class _SplashDoodlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = SnapFoodColors.outlineVariant.withAlpha(140);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = SnapFoodColors.outlineVariant.withAlpha(115);

    final w = size.width;
    final h = size.height;

    canvas.drawCircle(const Offset(40, 90), 14, paint);
    canvas.drawCircle(Offset(w - 42, h * 0.67), 6, fill);
    canvas.drawCircle(Offset(w - 40, h - 34), 16, paint);

    final wave = Path()
      ..moveTo(24, h * 0.35)
      ..cubicTo(38, h * 0.33, 45, h * 0.37, 58, h * 0.35);
    canvas.drawPath(wave, paint);

    final lowerWave = Path()
      ..moveTo(24, h * 0.70)
      ..quadraticBezierTo(38, h * 0.68, 48, h * 0.71)
      ..quadraticBezierTo(60, h * 0.74, 70, h * 0.70);
    canvas.drawPath(lowerWave, paint);

    final topRight = Path()
      ..moveTo(w - 38, 70)
      ..quadraticBezierTo(w - 18, 85, w - 34, 105);
    canvas.drawPath(topRight, paint);

    final triangle = Path()
      ..moveTo(w - 30, h * 0.38)
      ..lineTo(w - 20, h * 0.405)
      ..lineTo(w - 40, h * 0.405)
      ..close();
    canvas.drawPath(triangle, paint);

    final bottomTriangle = Path()
      ..moveTo(50, h - 10)
      ..lineTo(60, h + 5)
      ..lineTo(40, h + 5)
      ..close();
    canvas.drawPath(bottomTriangle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
