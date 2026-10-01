import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../core/network/api_exception.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).registerCustomer(
      name: _name.text,
      email: _email.text,
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
    }
    return 'We could not create your account. Please check your details and try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      appBar: AppBar(backgroundColor: SnapFoodColors.surface, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(color: SnapFoodColors.softYellow, borderRadius: BorderRadius.circular(22)),
                      child: const Icon(Icons.person_add_alt_1_rounded, size: 34, color: SnapFoodColors.primary),
                    ),
                    const SizedBox(height: 28),
                    Text('Create your account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: SnapFoodColors.warmBlack)),
                    const SizedBox(height: 8),
                    Text('Join Snap Foodd and get your favourites delivered.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: SnapFoodColors.onSurfaceVariant)),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(labelText: 'Full name', hintText: 'Your name', prefixIcon: Icon(Icons.person_outline_rounded), border: OutlineInputBorder()),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.length < 2) return 'Enter your full name.';
                        if (name.length > 120) return 'Name must be 120 characters or fewer.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email address', hintText: 'you@example.com', prefixIcon: Icon(Icons.mail_outline_rounded), border: OutlineInputBorder()),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Enter your email address.';
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) return 'Enter a valid email address.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(labelText: 'Password', helperText: 'Use at least 8 characters.', prefixIcon: const Icon(Icons.lock_outline_rounded), border: const OutlineInputBorder(), suffixIcon: IconButton(tooltip: _obscurePassword ? 'Show password' : 'Hide password', onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
                      validator: (value) => (value == null || value.length < 8) ? 'Password must be at least 8 characters.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmation,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(labelText: 'Confirm password', prefixIcon: const Icon(Icons.lock_reset_rounded), border: const OutlineInputBorder(), suffixIcon: IconButton(tooltip: _obscureConfirmation ? 'Show password' : 'Hide password', onPressed: () => setState(() => _obscureConfirmation = !_obscureConfirmation), icon: Icon(_obscureConfirmation ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirm your password.';
                        if (value != _password.text) return 'Passwords do not match.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(backgroundColor: SnapFoodColors.secondary, foregroundColor: SnapFoodColors.onSecondary),
                        child: _submitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create account', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Already have an account? ', style: TextStyle(color: SnapFoodColors.onSurfaceVariant)),
                      TextButton(onPressed: () => context.go('/login'), child: const Text('Sign in')),
                    ]),
                    const SizedBox(height: 8),
                    Text('By creating an account, you agree to use Snap Foodd responsibly.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SnapFoodColors.outline)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
