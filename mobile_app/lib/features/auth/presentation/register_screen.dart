import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/tokens/app_colors.dart';
import 'auth_controller.dart';
import 'google_auth_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).registerCustomer(
      name: _name.text,
      email: _email.text.trim(),
      phone: '+91${_phone.text.trim()}',
      password: _password.text,
      passwordConfirmation: _confirmation.text,
    );
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    setState(() => _submitting = false);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_friendlyError(state.error)),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (state.value?.isAuthenticated == true) context.go('/home');
  }

  Future<void> _googleCredential(String credential) async {
    await ref.read(authControllerProvider.notifier)
        .signInWithGoogleCredential(credential);
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_friendlyError(state.error)),
        behavior: SnackBarBehavior.floating,
      ));
    } else if (state.value?.isAuthenticated == true) {
      context.go('/home');
    }
  }

  String _friendlyError(Object? error) {
    if (error is ApiException) {
      if (error.code == 'RATE_LIMITED' || error.statusCode == 429) {
        return 'Too many attempts. Please wait a moment and try again.';
      }
      if (error.code == 'NETWORK_ERROR' || error.code == 'TIMEOUT') {
        return 'Could not connect to Snap Foodd. Check your connection and try again.';
      }
      if (error.isValidationError && error.errors.isNotEmpty) {
        return error.errors.values.first.first;
      }
      if (error.statusCode == 409) {
        return 'That email may already be registered. Try signing in instead.';
      }
      if (error.message.isNotEmpty) return error.message;
    }
    return 'We could not create your account. Please check your details and try again.';
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: SnapFoodColors.softBorder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, SnapFoodColors.surface, SnapFoodColors.softYellow.withAlpha(65)]),
        ),
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 82,
                        height: 82,
                        child: SvgPicture.asset(
                          'assets/images/customer/logo-without-bg.svg',
                          fit: BoxFit.contain,
                          semanticsLabel: 'Snap Foodd',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('YOUR NEXT FAVOURITE MEAL', textAlign: TextAlign.center, style: theme.textTheme.labelSmall?.copyWith(color: SnapFoodColors.secondary, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 9),
                    Text('Create your account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                        color: SnapFoodColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text('Join Snap Foodd for meals worth coming back to.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: _decoration('Full name', Icons.person_outline_rounded, hint: 'Your name'),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.length < 2) return 'Enter your full name.';
                        if (name.length > 120) return 'Name must be 120 characters or fewer.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: _decoration('Email address', Icons.mail_outline_rounded, hint: 'you@example.com'),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Enter your email address.';
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumberNational],
                      maxLength: 10,
                      decoration: _decoration('Mobile number', Icons.phone_android_rounded, hint: '98765 43210')
                          .copyWith(prefixText: '+91 ', counterText: ''),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return 'Enter your mobile number.';
                        if (!RegExp(r'^[6-9][0-9]{9}
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: _decoration(
                        'Password', Icons.lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 8)
                          ? 'Password must be at least 8 characters.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmation,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _decoration(
                        'Confirm password', Icons.lock_reset_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscureConfirmation = !_obscureConfirmation),
                          icon: Icon(_obscureConfirmation ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirm your password.';
                        if (value != _password.text) return 'Passwords do not match.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: SnapFoodColors.secondary,
                          foregroundColor: SnapFoodColors.onSecondary,
                          elevation: 2,
                          shadowColor: SnapFoodColors.secondary.withAlpha(55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: _submitting
                            ? SizedBox(width: 24, height: 24, child: SvgPicture.asset('assets/images/customer/logo-without-bg.svg', fit: BoxFit.contain))
                            : const Text('Create account', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _RegisterDivider(),
                    const SizedBox(height: 18),
                    GoogleAuthButton(onCredential: _googleCredential),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                          style: TextStyle(color: SnapFoodColors.onSurfaceVariant)),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Your details stay protected. You can update your profile anytime.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: SnapFoodColors.outline)),
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

class _RegisterDivider extends StatelessWidget {
  const _RegisterDivider();

  @override
  Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Divider(color: SnapFoodColors.softBorder)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text('OR', style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: SnapFoodColors.outline, fontWeight: FontWeight.w800, letterSpacing: 1.2,
      )),
    ),
    const Expanded(child: Divider(color: SnapFoodColors.softBorder)),
  ]);
}
).hasMatch(phone)) {
                          return 'Enter a valid 10-digit Indian mobile number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: _decoration(
                        'Password', Icons.lock_outline_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 8)
                          ? 'Password must be at least 8 characters.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmation,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _decoration(
                        'Confirm password', Icons.lock_reset_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscureConfirmation = !_obscureConfirmation),
                          icon: Icon(_obscureConfirmation ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirm your password.';
                        if (value != _password.text) return 'Passwords do not match.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: SnapFoodColors.secondary,
                          foregroundColor: SnapFoodColors.onSecondary,
                          elevation: 2,
                          shadowColor: SnapFoodColors.secondary.withAlpha(55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: _submitting
                            ? SizedBox(width: 24, height: 24, child: SvgPicture.asset('assets/images/customer/logo-without-bg.svg', fit: BoxFit.contain))
                            : const Text('Create account', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _RegisterDivider(),
                    const SizedBox(height: 18),
                    GoogleAuthButton(onCredential: _googleCredential),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                          style: TextStyle(color: SnapFoodColors.onSurfaceVariant)),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Your details stay protected. You can update your profile anytime.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: SnapFoodColors.outline)),
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

class _RegisterDivider extends StatelessWidget {
  const _RegisterDivider();

  @override
  Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Divider(color: SnapFoodColors.softBorder)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text('OR', style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: SnapFoodColors.outline, fontWeight: FontWeight.w800, letterSpacing: 1.2,
      )),
    ),
    const Expanded(child: Divider(color: SnapFoodColors.softBorder)),
  ]);
}
