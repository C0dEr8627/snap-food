import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../core/network/api_exception.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).loginWithPassword(
      email: _email.text,
      password: _password.text,
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
      if (error.code == 'INVALID_CREDENTIALS' || error.statusCode == 401) {
        return 'The email or password is incorrect. Please try again.';
      }
      if (error.code == 'RATE_LIMITED' || error.statusCode == 429) {
        return 'Too many attempts. Please wait a moment and try again.';
      }
      if (error.code == 'NETWORK_ERROR' || error.code == 'TIMEOUT') {
        return 'Could not connect to Snap Foodd. Check your connection and try again.';
      }
    }
    return 'We could not sign you in. Please check your details and try again.';
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
                      decoration: BoxDecoration(
                        color: SnapFoodColors.softRed,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.restaurant_rounded, size: 34, color: SnapFoodColors.foodRed),
                    ),
                    const SizedBox(height: 28),
                    Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: SnapFoodColors.warmBlack)),
                    const SizedBox(height: 8),
                    Text('Sign in to discover your next favourite meal.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: SnapFoodColors.onSurfaceVariant)),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
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
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded), border: const OutlineInputBorder(), suffixIcon: IconButton(tooltip: _obscurePassword ? 'Show password' : 'Hide password', onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter your password.' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(backgroundColor: SnapFoodColors.secondary, foregroundColor: SnapFoodColors.onSecondary),
                        child: _submitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account? ", style: TextStyle(color: SnapFoodColors.onSurfaceVariant)),
                      TextButton(onPressed: () => context.go('/register'), child: const Text('Create account')),
                    ]),
                    const SizedBox(height: 8),
                    Text('Your account is protected with secure sign-in.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SnapFoodColors.outline)),
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
