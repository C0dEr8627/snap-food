import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/network/api_exception.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class DeliveryLoginOnboardingScreen extends ConsumerStatefulWidget {
  const DeliveryLoginOnboardingScreen({super.key});

  @override
  State<DeliveryLoginOnboardingScreen> createState() =>
      _DeliveryLoginOnboardingScreenState();
}

class _DeliveryLoginOnboardingScreenState
    extends ConsumerState<DeliveryLoginOnboardingScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      await _showError('Enter your delivery partner email and password.');
      return;
    }
    if (!_termsAccepted) {
      await _showError('Accept the partner terms to continue.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).loginDeliveryPartner(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        await _showError(_friendlyError(state.error));
        return;
      }
      if (state.value?.isAuthenticated == true && state.value?.isDeliveryPartner == true) {
        context.go('/delivery/requests');
      } else {
        await _showError('We could not open the delivery partner dashboard. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delivery partner sign-in'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _friendlyError(Object? error) {
    if (error is ApiException) {
      switch (error.code) {
        case 'INVALID_CREDENTIALS':
          return 'The email or password is incorrect. Please check your credentials and try again.';
        case 'DELIVERY_PARTNER_NOT_APPROVED':
          return 'Your delivery partner account is awaiting approval. Please contact the Snap Foodd team.';
        case 'DELIVERY_PARTNER_INACTIVE':
        case 'ACCOUNT_INACTIVE':
          return 'This delivery partner account is inactive. Please contact the Snap Foodd team.';
        case 'NETWORK_ERROR':
        case 'TIMEOUT':
          return 'Could not connect to Snap Foodd. Check your connection and try again.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Snap Foodd could not complete the sign-in right now. Please try again in a moment.';
      }
      if (error.message.isNotEmpty) return error.message;
    }
    return 'We could not sign you in. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final expanded = constraints.maxWidth >= 900;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: expanded ? 32 : 16,
                  vertical: expanded ? 36 : 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                  ),
                  child: expanded
                      ? _DesktopLayout(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          termsAccepted: _termsAccepted,
                          submitting: _submitting,
                          onTermsChanged: (v) =>
                              setState(() => _termsAccepted = v),
                          onContinue: _continue,
                        )
                      : _MobileLayout(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          termsAccepted: _termsAccepted,
                          submitting: _submitting,
                          onTermsChanged: (v) =>
                              setState(() => _termsAccepted = v),
                          onContinue: _continue,
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

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.phoneController,
    required this.termsAccepted,
    required this.submitting,
    required this.onTermsChanged,
    required this.onContinue,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool termsAccepted;
  final bool submitting;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandHeader(),
        const SizedBox(height: 34),
        const _OnboardingIllustration(),
        const SizedBox(height: 28),
        _LoginForm(
          phoneController: phoneController,
          termsAccepted: termsAccepted,
          submitting: submitting,
          onTermsChanged: onTermsChanged,
          onContinue: onContinue,
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.phoneController,
    required this.termsAccepted,
    required this.submitting,
    required this.onTermsChanged,
    required this.onContinue,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool termsAccepted;
  final bool submitting;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 650),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(48),
              color: SnapFoodColors.softYellow,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandHeader(),
                  Spacer(),
                  _OnboardingIllustration(),
                  SizedBox(height: 28),
                  Text(
                    'Deliver with Snap Foodd',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: SnapFoodColors.warmBlack,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Choose your trips, stay in control, and earn on your schedule.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: SnapFoodColors.onSurfaceVariant,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: _LoginForm(
                phoneController: phoneController,
                termsAccepted: termsAccepted,
                submitting: submitting,
                onTermsChanged: onTermsChanged,
                onContinue: onContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: SnapFoodColors.primaryContainer,
          child: Icon(
            Icons.delivery_dining_rounded,
            color: SnapFoodColors.warmBlack,
            size: 22,
          ),
        ),
        SizedBox(width: 10),
        Text(
          'SNAP FOODD',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 190,
        height: 150,
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 28,
              bottom: 24,
              child: Container(
                width: 132,
                height: 14,
                decoration: BoxDecoration(
                  color: SnapFoodColors.softBorder,
                  borderRadius: BorderRadius.circular(SnapFoodRadii.full),
                ),
              ),
            ),
            const Icon(
              Icons.two_wheeler_rounded,
              size: 82,
              color: SnapFoodColors.secondary,
            ),
            const Positioned(
              top: 20,
              right: 28,
              child: Icon(
                Icons.location_on_rounded,
                size: 30,
                color: SnapFoodColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.phoneController,
    required this.termsAccepted,
    required this.submitting,
    required this.onTermsChanged,
    required this.onContinue,
  });

  final TextEditingController phoneController;
  final bool termsAccepted;
  final bool submitting;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Partner login',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to manage your delivery trips.',
          style: TextStyle(
            fontSize: 14,
            color: SnapFoodColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Email address',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'partner@example.com',
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
            filled: true,
            fillColor: SnapFoodColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              borderSide: const BorderSide(color: SnapFoodColors.softBorder),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Password',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            filled: true,
            fillColor: SnapFoodColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              borderSide: const BorderSide(color: SnapFoodColors.softBorder),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: termsAccepted,
              onChanged: (value) => onTermsChanged(value ?? false),
              activeColor: SnapFoodColors.secondary,
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'I agree to the Snap Foodd delivery partner terms and privacy policy.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: SnapFoodColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: submitting ? null : onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: SnapFoodColors.secondary,
              foregroundColor: SnapFoodColors.onPrimary,
              disabledBackgroundColor: SnapFoodColors.surfaceContainerHigh,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SnapFoodRadii.full),
              ),
            ),
            child: submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Continue with OTP',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ),
        const SizedBox(height: 22),
        const Row(
          children: [
            Expanded(child: Divider(color: SnapFoodColors.softBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'PARTNER ONBOARDING',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: SnapFoodColors.onSurfaceVariant,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            Expanded(child: Divider(color: SnapFoodColors.softBorder)),
          ],
        ),
        const SizedBox(height: 18),
        const _RequirementRow(
          icon: Icons.badge_outlined,
          title: 'Government ID',
          subtitle: 'Required during verification',
        ),
        const _RequirementRow(
          icon: Icons.two_wheeler_outlined,
          title: 'Vehicle details',
          subtitle: 'Add your vehicle after verification',
        ),
        const _RequirementRow(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Payout account',
          subtitle: 'Receive your delivery earnings',
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded, size: 17),
          label: const Text('Back to Snap Foodd'),
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SnapFoodColors.softYellow,
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
            ),
            child: Icon(icon, size: 18, color: SnapFoodColors.warmBlack),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: SnapFoodColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: SnapFoodColors.primary,
          ),
        ],
      ),
    );
  }
}
