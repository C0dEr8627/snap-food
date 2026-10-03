import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

/// First-run welcome surface for Snap Foodd's product-first food commerce flow.
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? SnapFoodSpacing.desktopMargin : SnapFoodSpacing.mobileMargin,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: wide
                    ? _WideWelcome()
                    : _CompactWelcome(minHeight: constraints.maxHeight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactWelcome extends StatelessWidget {
  const _CompactWelcome({required this.minHeight});
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final compact = minHeight < 660;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight - 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _BrandMark(),
          SizedBox(height: compact ? 18 : 30),
          _FoodIllustration(size: compact ? 190 : 236),
          SizedBox(height: compact ? 18 : 28),
          const _WelcomeMessage(centered: true),
          SizedBox(height: compact ? 22 : 30),
          const _WelcomeActions(),
          const SizedBox(height: 18),
          const _TrustNote(),
        ],
      ),
    );
  }
}

class _WideWelcome extends StatelessWidget {
  const _WideWelcome();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const _BrandMark(),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(child: _FoodIllustration(size: 400)),
              const SizedBox(width: 64),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeMessage(),
                    SizedBox(height: 28),
                    _WelcomeActions(),
                    SizedBox(height: 18),
                    _TrustNote(),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/customer/logo-without-bg.svg',
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            semanticsLabel: 'Snap Foodd logo',
          ),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'SNAP ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SnapFoodColors.warmBlack,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
              ),
              TextSpan(
                text: 'FOODD',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SnapFoodColors.foodRed,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
              ),
            ]),
          ),
        ],
      );
}

class _FoodIllustration extends StatelessWidget {
  const _FoodIllustration({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Illustration of a freshly prepared meal',
        image: true,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * .92,
                height: size * .92,
                decoration: const BoxDecoration(
                  color: SnapFoodColors.softYellow,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: size * .72,
                height: size * .72,
                decoration: BoxDecoration(
                  color: SnapFoodColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: SnapFoodColors.softBorder, width: 2),
                ),
              ),
              Container(
                width: size * .55,
                height: size * .55,
                decoration: const BoxDecoration(
                  color: SnapFoodColors.softRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.ramen_dining_rounded,
                  size: size * .29,
                  color: SnapFoodColors.foodRed,
                ),
              ),
              Positioned(
                top: size * .09,
                right: size * .03,
                child: _FoodAccent(
                  icon: Icons.local_pizza_rounded,
                  color: SnapFoodColors.foodRed,
                  background: SnapFoodColors.surface,
                  size: size * .19,
                ),
              ),
              Positioned(
                bottom: size * .09,
                left: size * .02,
                child: _FoodAccent(
                  icon: Icons.local_cafe_rounded,
                  color: SnapFoodColors.warmBlack,
                  background: SnapFoodColors.surface,
                  size: size * .18,
                ),
              ),
              Positioned(
                bottom: size * .15,
                right: size * .05,
                child: _FoodAccent(
                  icon: Icons.bolt_rounded,
                  color: SnapFoodColors.warmBlack,
                  background: SnapFoodColors.goldenYellow,
                  size: size * .15,
                ),
              ),
            ],
          ),
        ),
      );
}

class _FoodAccent extends StatelessWidget {
  const _FoodAccent({
    required this.icon,
    required this.color,
    required this.background,
    required this.size,
  });
  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: SnapFoodColors.surface, width: 3),
        ),
        child: Icon(icon, color: color, size: size * .52),
      );
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage({this.centered = false});
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR CRAVINGS.\nONE EASY ORDER.',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: SnapFoodColors.warmBlack,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                height: 1.03,
              ),
        ),
        const SizedBox(height: 14),
        Text(
          'Find something delicious, choose your dishes, and get your order moving in just a few taps.',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SnapFoodColors.onSurfaceVariant,
                height: 1.55,
              ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: const [
            _BenefitPill(icon: Icons.search_rounded, label: 'Easy discovery'),
            _BenefitPill(icon: Icons.favorite_rounded, label: 'Save favourites'),
            _BenefitPill(icon: Icons.shopping_bag_rounded, label: 'Simple checkout'),
          ],
        ),
      ],
    );
  }
}

class _BenefitPill extends StatelessWidget {
  const _BenefitPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: SnapFoodColors.foodRed),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: SnapFoodColors.warmBlack,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SnapPrimaryButton(
            label: 'Create your account',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go('/register'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SnapFoodColors.warmBlack,
                side: const BorderSide(color: SnapFoodColors.softBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                ),
              ),
              child: const Text('I already have an account'),
            ),
          ),
        ],
      );
}

class _TrustNote extends StatelessWidget {
  const _TrustNote();

  @override
  Widget build(BuildContext context) => Text(
        'Browse the menu, manage your cart, and track orders from one place.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SnapFoodColors.outline,
              height: 1.4,
            ),
      );
}
