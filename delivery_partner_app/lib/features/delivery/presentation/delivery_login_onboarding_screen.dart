import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';

class DeliveryLoginOnboardingScreen extends ConsumerStatefulWidget {
  const DeliveryLoginOnboardingScreen({super.key});

  @override
  ConsumerState<DeliveryLoginOnboardingScreen> createState() =>
      _DeliveryLoginOnboardingScreenState();
}

class _DeliveryLoginOnboardingScreenState
    extends ConsumerState<DeliveryLoginOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).loginDeliveryPartner(
            email: _email.text.trim(),
            password: _password.text,
          );

      if (!mounted) return;

      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        _showError(_friendlyError(state.error));
        return;
      }

      if (state.value?.isAuthenticated == true &&
          state.value?.isDeliveryPartner == true) {
        context.go('/delivery/requests');
      } else {
        _showError(
          'We could not sign you in as a delivery partner. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _friendlyError(Object? error) {
    if (error is ApiException) {
      if (error.code == 'INVALID_CREDENTIALS' || error.statusCode == 401) {
        return 'The email or password is incorrect. Please try again.';
      }
      if (error.code == 'DELIVERY_PARTNER_NOT_APPROVED') {
        return 'Your delivery partner account is awaiting approval. Please contact the Snap Foodd team.';
      }
      if (error.code == 'DELIVERY_PARTNER_INACTIVE' ||
          error.code == 'ACCOUNT_INACTIVE') {
        return 'This delivery partner account is inactive. Please contact the Snap Foodd team.';
      }
      if (error.code == 'NETWORK_ERROR' || error.code == 'TIMEOUT') {
        return 'Could not connect to Snap Foodd. Check your connection and try again.';
      }
      if (error.message.isNotEmpty) return error.message;
    }
    return 'We could not sign you in. Please check your details and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              SnapFoodColors.surface,
              SnapFoodColors.softYellow.withAlpha(65),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 94,
                          height: 94,
                          child: SvgPicture.asset(
                            'assets/images/customer/logo-without-bg.svg',
                            fit: BoxFit.contain,
                            semanticsLabel: 'Snap Foodd',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: SnapFoodColors.secondary.withAlpha(20),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: SnapFoodColors.secondary.withAlpha(45)),
                        ),
                        child: Text(
                          'DELIVERY PARTNER',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: SnapFoodColors.secondary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Welcome back',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: SnapFoodColors.warmBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your deliveries.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: SnapFoodColors.softYellow.withAlpha(75),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: SnapFoodColors.softBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delivery_dining_rounded, color: SnapFoodColors.secondary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your delivery dashboard starts here.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: SnapFoodColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: SnapFoodColors.softBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: SnapFoodColors.softBorder,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Enter your email address.';
                          }
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(email)) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: SnapFoodColors.softBorder,
                            ),
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter your password.'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 58,
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: SnapFoodColors.secondary,
                            foregroundColor: SnapFoodColors.onSecondary,
                            elevation: 2,
                            shadowColor:
                                SnapFoodColors.secondary.withAlpha(55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
