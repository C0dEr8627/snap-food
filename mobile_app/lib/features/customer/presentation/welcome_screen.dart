import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heroAnimation;
  late final Animation<double> _copyAnimation;
  late final Animation<double> _benefitsAnimation;
  late final Animation<double> _actionsAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _heroAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.42, curve: Curves.easeOutCubic),
    );
    _copyAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.58, curve: Curves.easeOutCubic),
    );
    _benefitsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.78, curve: Curves.easeOutCubic),
    );
    _actionsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 1, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxWidth >= 900;

            return SizedBox(
              width: double.infinity,
              height: constraints.maxHeight,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isExpanded
                        ? SnapFoodSpacing.desktopMargin
                        : SnapFoodSpacing.mobileMargin,
                    vertical: isExpanded ? 20 : 12,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isExpanded
                        ? _DesktopWelcome(
                            heroAnimation: _heroAnimation,
                            copyAnimation: _copyAnimation,
                            benefitsAnimation: _benefitsAnimation,
                            actionsAnimation: _actionsAnimation,
                          )
                        : _MobileWelcome(
                            height: constraints.maxHeight,
                            heroAnimation: _heroAnimation,
                            copyAnimation: _copyAnimation,
                            benefitsAnimation: _benefitsAnimation,
                            actionsAnimation: _actionsAnimation,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MobileWelcome extends StatelessWidget {
  const _MobileWelcome({
    required this.height,
    required this.heroAnimation,
    required this.copyAnimation,
    required this.benefitsAnimation,
    required this.actionsAnimation,
  });

  final double height;
  final Animation<double> heroAnimation;
  final Animation<double> copyAnimation;
  final Animation<double> benefitsAnimation;
  final Animation<double> actionsAnimation;

  @override
  Widget build(BuildContext context) {
    final compact = height < 680;
    final veryCompact = height < 600;
    final heroSize = veryCompact
        ? 188.0
        : compact
        ? 220.0
        : 252.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _BrandHeader(),
        _AnimatedSection(
          animation: heroAnimation,
          child: _FoodHero(maxSize: heroSize),
        ),
        _AnimatedSection(animation: copyAnimation, child: const _WelcomeCopy()),
        _AnimatedSection(
          animation: benefitsAnimation,
          child: const _BenefitStrip(),
        ),
        _AnimatedSection(
          animation: actionsAnimation,
          child: const _WelcomeActions(),
        ),
      ],
    );
  }
}

class _DesktopWelcome extends StatelessWidget {
  const _DesktopWelcome({
    required this.heroAnimation,
    required this.copyAnimation,
    required this.benefitsAnimation,
    required this.actionsAnimation,
  });

  final Animation<double> heroAnimation;
  final Animation<double> copyAnimation;
  final Animation<double> benefitsAnimation;
  final Animation<double> actionsAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandHeader(),
        const SizedBox(height: 52),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 11,
              child: _AnimatedSection(
                animation: heroAnimation,
                child: const _FoodHero(),
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedSection(
                    animation: copyAnimation,
                    child: const _WelcomeCopy(alignStart: true),
                  ),
                  const SizedBox(height: 34),
                  _AnimatedSection(
                    animation: benefitsAnimation,
                    child: const _BenefitStrip(alignStart: true),
                  ),
                  const SizedBox(height: 34),
                  _AnimatedSection(
                    animation: actionsAnimation,
                    child: const _WelcomeActions(alignStart: true),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const _FooterHint(),
      ],
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.045),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/customer/logo.svg',
          width: 46,
          height: 46,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'SNAP ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: SnapFoodColors.warmBlack,
                ),
              ),
              TextSpan(
                text: 'FOODD',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: SnapFoodColors.foodRed,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const _MumbaiLabel(),
      ],
    );
  }
}

class _MumbaiLabel extends StatelessWidget {
  const _MumbaiLabel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SnapFoodColors.softYellow,
        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 14,
              color: SnapFoodColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Made for Mumbai',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: SnapFoodColors.warmBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodHero extends StatelessWidget {
  const _FoodHero({this.maxSize});

  final double? maxSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (maxSize ?? 320);
        final size = (maxSize ?? (available >= 600 ? 420.0 : 320.0)).clamp(
          0.0,
          available,
        );

        return SizedBox(
          width: double.infinity,
          child: Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: size * 0.84,
                    height: size * 0.84,
                    decoration: const BoxDecoration(
                      color: SnapFoodColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Positioned(
                    top: size * 0.07,
                    right: size * 0.06,
                    child: _FoodBubble(
                      icon: Icons.local_pizza_rounded,
                      background: SnapFoodColors.softRed,
                      iconColor: SnapFoodColors.secondary,
                      rotation: -0.08,
                    ),
                  ),
                  Positioned(
                    bottom: size * 0.09,
                    left: size * 0.02,
                    child: _FoodBubble(
                      icon: Icons.ramen_dining_rounded,
                      background: SnapFoodColors.surfaceContainerLowest,
                      iconColor: SnapFoodColors.primary,
                      rotation: 0.06,
                    ),
                  ),
                  Positioned(
                    bottom: size * 0.05,
                    right: size * 0.12,
                    child: _FoodBubble(
                      icon: Icons.local_cafe_rounded,
                      background: SnapFoodColors.softYellow,
                      iconColor: SnapFoodColors.tertiary,
                      rotation: -0.05,
                    ),
                  ),
                  Container(
                    width: size * 0.56,
                    height: size * 0.56,
                    decoration: BoxDecoration(
                      color: SnapFoodColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SnapFoodColors.warmBlack.withAlpha(24),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(size * 0.106),
                    child: SvgPicture.asset(
                      'assets/images/customer/logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: size * 0.02,
                    left: size * 0.04,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: SnapFoodColors.warmBlack,
                        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 15,
                              color: SnapFoodColors.accentYellow,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Fast. Local. Fresh.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FoodBubble extends StatelessWidget {
  const _FoodBubble({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.rotation,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(
            color: SnapFoodColors.surfaceContainerLowest,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: SnapFoodColors.warmBlack.withAlpha(18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 27),
      ),
    );
  }
}

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy({this.alignStart = false});

  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment = alignStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = alignStart ? TextAlign.left : TextAlign.center;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          'GOOD FOOD.\nFAST DELIVERY.',
          textAlign: textAlign,
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: 36,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            color: SnapFoodColors.warmBlack,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Discover local favourites, neighbourhood gems, and everyday comfort food — all in one place.',
          textAlign: textAlign,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: SnapFoodColors.onSurfaceVariant,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _BenefitStrip extends StatelessWidget {
  const _BenefitStrip({this.alignStart = false});

  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final items = const [
      _Benefit(
        icon: Icons.bolt_rounded,
        title: 'Fast',
        detail: 'quick delivery',
        color: SnapFoodColors.primaryContainer,
      ),
      _Benefit(
        icon: Icons.storefront_rounded,
        title: 'Local',
        detail: 'nearby favourites',
        color: SnapFoodColors.softRed,
      ),
      _Benefit(
        icon: Icons.local_fire_department_rounded,
        title: 'Fresh',
        detail: 'hot & ready',
        color: SnapFoodColors.softYellow,
      ),
    ];

    return Wrap(
      alignment: alignStart ? WrapAlignment.start : WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: items,
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.md),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: SnapFoodColors.warmBlack),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SnapFoodColors.warmBlack,
                ),
              ),
              Text(
                detail,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({this.alignStart = false});

  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = alignStart ? 360.0 : double.infinity;

    return SizedBox(
      width: buttonWidth,
      child: Column(
        crossAxisAlignment: alignStart
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () => context.go('/register'),
              style: FilledButton.styleFrom(
                backgroundColor: SnapFoodColors.secondary,
                foregroundColor: SnapFoodColors.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/login'),
            style: TextButton.styleFrom(
              foregroundColor: SnapFoodColors.onSurface,
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Already have an account? ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SnapFoodColors.onSurfaceVariant,
                ),
                children: const [
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      color: SnapFoodColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterHint extends StatelessWidget {
  const _FooterHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Local food. Simple ordering. One happy delivery.',
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: SnapFoodColors.outline),
    );
  }
}
