part of '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.auth,
    required this.onAuthenticated,
  });

  final AdminAuthService auth;
  final ValueChanged<AdminUser> onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _google = GoogleSignIn(
    clientId: googleClientId.isEmpty ? null : googleClientId,
    scopes: const ['email', 'profile'],
  );
  StreamSubscription<GoogleSignInAccount?>? _googleSubscription;

  bool _loading = false;
  bool _obscurePassword = true;
  bool _googleLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _googleSubscription = _google.onCurrentUserChanged.listen(_handleGoogleAccount);
  }

  @override
  void dispose() {
    _googleSubscription?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AdminCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 28, 30, 26),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _LoginBrand(),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome back',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AdminColors.ink),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Sign in to access the Snap Foodd Admin Portal.',
                        style: TextStyle(fontSize: 12.5, color: AdminColors.muted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username, AutofillHints.email],
                        decoration: _fieldDecoration('Email address', HugeIcons.strokeRoundedMail01),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter your email address.';
                          if (!value.contains('@')) return 'Enter a valid email address.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: _fieldDecoration(
                          'Password',
                          HugeIcons.strokeRoundedLock,
                          suffix: IconButton(
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: AdminIcon(_obscurePassword ? HugeIcons.strokeRoundedView : HugeIcons.strokeRoundedViewOff),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 8 ? 'Enter your password.' : null,
                        onFieldSubmitted: (_) => _submitPassword(),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AdminAdminColors.redSoft,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AdminAdminColors.red.withOpacity(.22)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AdminIcon(HugeIcons.strokeRoundedAlertCircle, size: 18, color: AdminAdminColors.red),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(fontSize: 11.5, color: AdminAdminColors.red))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      shad.PrimaryButton(
                        onPressed: _loading ? null : _submitPassword,
                        child: _loading
                            ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Sign in', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      ).sized(width: double.infinity, height: 46),
                      const SizedBox(height: 18),
                      const _OrDivider(),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: IgnorePointer(
                          ignoring: _loading || _googleLoading,
                          child: google_web.renderButton(
                            configuration: google_web.GSIButtonConfiguration(
                              type: google_web.GSIButtonType.standard,
                              theme: google_web.GSIButtonTheme.outline,
                              size: google_web.GSIButtonSize.large,
                              text: google_web.GSIButtonText.continueWith,
                              shape: google_web.GSIButtonShape.rectangular,
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

  InputDecoration _fieldDecoration(String label, AdminIconData icon, {Widget? suffix}) => InputDecoration(
    labelText: label,
    prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 13), child: AdminIcon(icon, size: 18)),
    suffixIcon: suffix == null ? null : Padding(padding: const EdgeInsets.only(right: 5), child: suffix),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.line)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AdminColors.line)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AdminAdminColors.amber, width: 1.5)),
  );

  Future<void> _submitPassword() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() => widget.auth.loginWithPassword(email: _email.text, password: _password.text));
  }

  Future<void> _handleGoogleAccount(GoogleSignInAccount? account) async {
    if (account == null || _loading || _googleLoading) return;
    setState(() => _googleLoading = true);

    await _run(() async {
      final authentication = await account.authentication;
      final credential = authentication.idToken;
      if (credential == null || credential.isEmpty) {
        throw const AdminAuthException('Google did not return an ID token.');
      }

      return widget.auth.loginWithGoogle(credential);
    });
  }

  Future<void> _run(Future<AdminUser> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await action();
      if (!mounted) return;
      widget.onAuthenticated(user);
    } on AdminAuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to reach the authentication service. Please try again.');
    } finally {
      if (mounted) setState(() { _loading = false; _googleLoading = false; });
    }
  }
}

class AdminAuthGate extends StatefulWidget {
  const AdminAuthGate({super.key});

  @override
  State<AdminAuthGate> createState() => _AdminAuthGateState();
}

class _AdminAuthGateState extends State<AdminAuthGate> {
  final AdminAuthService _auth = AdminAuthService();
  AdminUser? _user;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final user = await _auth.restoreSession();
    if (!mounted) return;
    setState(() {
      _user = user;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AdminColors.canvas,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return LoginPage(auth: _auth, onAuthenticated: (user) => setState(() => _user = user));
    }

    return AdminShell(
      user: _user!,
      onLogout: () async {
        await _auth.logout();
        if (mounted) setState(() => _user = null);
      },
    );
  }
}

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SvgPicture.asset(
          'assets/brand/logo.svg',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          semanticsLabel: 'Snap Foodd',
        ),
      ),
      const SizedBox(height: 12),
      const Text('SNAP FOODD', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      const SizedBox(height: 2),
      const Text('ADMIN PORTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.7, color: AdminColors.muted)),
    ],
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(color: AdminColors.line)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('OR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AdminColors.muted)),
      ),
      const Expanded(child: Divider(color: AdminColors.line)),
    ],
  );
}
