import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.84, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final brand = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: SvgPicture.asset(
            'assets/images/customer/logo-without-bg.svg',
            fit: BoxFit.contain,
            semanticsLabel: 'Snap Foodd',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Snap Foodd',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: SnapFoodColors.warmBlack,
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Good food, just a snap away.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: SnapFoodColors.onSurfaceVariant,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: SnapFoodColors.foodRed,
            backgroundColor: SnapFoodColors.foodRed.withAlpha(25),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: -95,
            right: -85,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: SnapFoodColors.softYellow.withAlpha(150),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -115,
            left: -75,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                color: SnapFoodColors.softRed.withAlpha(135),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: reduceMotion
                    ? brand
                    : FadeTransition(
                        opacity: _fade,
                        child: ScaleTransition(scale: _scale, child: brand),
                      ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: SafeArea(
              top: false,
              child: Text(
                'YOUR CRAVINGS. ONE EASY ORDER.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SnapFoodColors.outline,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
