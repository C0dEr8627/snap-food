import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class DeliveryLoginOnboardingScreen extends StatefulWidget {
  const DeliveryLoginOnboardingScreen({super.key});

  @override
  State<DeliveryLoginOnboardingScreen> createState() =>
      _DeliveryLoginOnboardingScreenState();
}

class _DeliveryLoginOnboardingScreenState
    extends State<DeliveryLoginOnboardingScreen> {
  final _phoneController = TextEditingController();
  bool _termsAccepted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_phoneController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number.')),
      );
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept the partner terms to continue.')),
      );
      return;
    }

    setState(() => _submitting = true);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP flow is ready for backend integration.')),
      );
    });
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
                          phoneController: _phoneController,
                          termsAccepted: _termsAccepted,
                          submitting: _submitting,
                          onTermsChanged: (v) =>
                              setState(() => _termsAccepted = v),
                          onContinue: _continue,
                        )
                      : _MobileLayout(
                          phoneController: _phoneController,
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

  final TextEditingController phoneController;
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

  final TextEditingController phoneController;
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
                    'Deliver with Snap Food',
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
          'SNAP FOOD',
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
          'Mobile number',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            counterText: '',
            prefixText: '+91  ',
            hintText: '98765 43210',
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            filled: true,
            fillColor: SnapFoodColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              borderSide: const BorderSide(color: SnapFoodColors.softBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              borderSide: const BorderSide(color: SnapFoodColors.softBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              borderSide: const BorderSide(
                color: SnapFoodColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
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
                  'I agree to the Snap Food delivery partner terms and privacy policy.',
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
          label: const Text('Back to Snap Food'),
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
