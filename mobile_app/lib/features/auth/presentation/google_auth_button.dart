import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../design_system/tokens/app_colors.dart';

/// Starts Google identity sign-in and passes only the ID token to the backend.
class GoogleAuthButton extends StatefulWidget {
  const GoogleAuthButton({super.key, required this.onCredential, this.enabled = true});

  final Future<void> Function(String credential) onCredential;
  final bool enabled;

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  bool _busy = false;

  Future<void> _signIn() async {
    if (_busy || !widget.enabled) return;
    setState(() => _busy = true);
    try {
      const clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
      final google = GoogleSignIn(
        clientId: kIsWeb && clientId.isNotEmpty ? clientId : null,
        serverClientId: !kIsWeb && clientId.isNotEmpty ? clientId : null,
        scopes: const ['email', 'profile'],
      );
      final account = await google.signIn();
      if (account == null) return;
      final authentication = await account.authentication;
      final credential = authentication.idToken;
      if (credential == null || credential.isEmpty) {
        throw Exception(
          'Google did not return an ID token. Check your Google OAuth client configuration.',
        );
      }
      await widget.onCredential(credential);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: (_busy || !widget.enabled) ? null : _signIn,
        style: OutlinedButton.styleFrom(
          foregroundColor: SnapFoodColors.warmBlack,
          side: const BorderSide(color: SnapFoodColors.softBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
        child: _busy
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/customer/google_g_logo.svg',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }
}
