import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/auth/supabase_auth_manager.dart';
import 'package:her_long_game/data/repositories/user_repository.dart';
import 'package:her_long_game/flow/onboarding_flow_controller.dart';
import 'package:her_long_game/flow/user_progress.dart';
import 'package:her_long_game/flow/user_state_repository.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/terms_privacy_consent_text.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthMode { signIn, signUp }

/// Combined auth screen (Sign In / Create Account) for Her Long Game.
///
/// Uses Supabase Auth (email/password) and routes based on
/// `users.onboarding_complete`:
/// - null/false -> `/lesson/L0`
/// - true -> `/home`
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final _auth = SupabaseAuthManager();
  final UserRepository _userRepo = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late AuthMode _mode;
  bool _isSubmitting = false;
  String? _error;
  String? _transientDisplayName;
  bool _showTransientGreeting = false;

  Future<void> _openResetPasswordSheet() async {
    FocusScope.of(context).unfocus();

    final controller = TextEditingController(text: _emailController.text.trim());
    final sheetFormKey = GlobalKey<FormState>();
    bool isSending = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: HLGColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: StatefulBuilder(
            builder: (context, setSheetState) => SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reset password',
                            style: HLGTextStyles.moduleTitle(color: HLGColors.textBody),
                          ),
                        ),
                        IconButton(
                          onPressed: isSending ? null : () => context.pop(),
                          icon: Icon(Icons.close, color: HLGColors.textMuted),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We’ll email you a secure link to set a new password.',
                      style: HLGTextStyles.body(color: HLGColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Form(
                      key: sheetFormKey,
                      child: TextFormField(
                        controller: controller,
                        enabled: !isSending,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Enter your email.';
                          if (!value.contains('@')) return 'Enter a valid email.';
                          return null;
                        },
                        onFieldSubmitted: (_) async {
                          if (isSending) return;
                          final valid = sheetFormKey.currentState?.validate() ?? false;
                          if (!valid) return;
                          setSheetState(() => isSending = true);
                          try {
                            await _auth.resetPassword(email: controller.text.trim(), context: context);
                            if (!context.mounted) return;
                            context.pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Check your email for a password reset link.',
                                  style: HLGTextStyles.body(color: HLGColors.white),
                                ),
                                backgroundColor: HLGColors.deepSage,
                              ),
                            );
                          } catch (e) {
                            debugPrint('Reset password failed: $e');
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Couldn\'t send reset email. Please try again.',
                                  style: HLGTextStyles.body(color: HLGColors.white),
                                ),
                                backgroundColor: HLGColors.deepSage,
                              ),
                            );
                          } finally {
                            if (context.mounted) setSheetState(() => isSending = false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final valid = sheetFormKey.currentState?.validate() ?? false;
                              if (!valid) return;
                              setSheetState(() => isSending = true);
                              try {
                                await _auth.resetPassword(email: controller.text.trim(), context: context);
                                if (!context.mounted) return;
                                context.pop();
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Check your email for a password reset link.',
                                      style: HLGTextStyles.body(color: HLGColors.white),
                                    ),
                                     backgroundColor: HLGColors.deepSage,
                                  ),
                                );
                              } catch (e) {
                                debugPrint('Reset password failed: $e');
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Couldn\'t send reset email. Please try again.',
                                      style: HLGTextStyles.body(color: HLGColors.white),
                                    ),
                                     backgroundColor: HLGColors.deepSage,
                                  ),
                                );
                              } finally {
                                if (context.mounted) setSheetState(() => isSending = false);
                              }
                            },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: isSending
                            ? const SizedBox(
                                key: ValueKey('sending'),
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: HLGColors.white),
                              )
                            : Text(
                                'Send reset link',
                                key: const ValueKey('send'),
                                style: HLGTextStyles.labelMedium(color: HLGColors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _ensureProfileRow({required String uid, String? email}) async {
    try {
      final currentEmail = email ?? SupabaseConfig.auth.currentUser?.email;
      await _userRepo.upsertProfile(userId: uid, email: currentEmail);
    } catch (e) {
      debugPrint('Auth: ensure profile row failed: $e');
    }
  }

  Future<void> _routeAfterSignIn({required String uid}) async {
    // SIGN IN: routing is determined entirely by flow controllers.
    // NOTE: this widget still performs the data load, but it does NOT branch
    // on routes itself.
    try {
      await _ensureProfileRow(uid: uid);
      final state = await const SupabaseUserStateRepository().load();
      final progress = UserProgress.fromUserState(state);
      final target = OnboardingFlowController.instance.resumeOnboarding(progress);
      if (!mounted) return;
      context.go(target);
    } catch (e) {
      debugPrint('Auth sign-in: failed to determine onboarding resume route: $e');
      if (!mounted) return;
      context.go('/welcome');
    }
  }

  Future<void> _showTransientGreetingIfPossible({required String uid}) async {
    try {
      final row = await SupabaseConfig.client.from('users').select('display_name').eq('id', uid).maybeSingle();
      final displayName = (row?['display_name'] ?? '').toString().trim();
      if (!mounted) return;
      setState(() {
        _transientDisplayName = displayName.isEmpty ? null : displayName;
        _showTransientGreeting = _transientDisplayName != null;
      });
    } catch (e) {
      debugPrint('Auth sign-in: failed to fetch display_name for greeting: $e');
    }
  }

  Future<void> _signInWithApple() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final idToken = credential.identityToken;
      if (idToken == null) throw StateError('Apple sign-in failed: missing identityToken');

      await SupabaseConfig.client.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: idToken);

      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) throw StateError('Sign-in failed: no active session returned.');

      await _showTransientGreetingIfPossible(uid: uid);
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _routeAfterSignIn(uid: uid));
    } catch (e) {
      debugPrint('Apple sign-in failed: $e');
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    try {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_mode == AuthMode.signIn) {
        await _auth.signInWithEmail(context, email, password);
      } else {
        await _auth.createAccountWithEmail(context, email, password);
      }

      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        // With Supabase email confirmation enabled, `signUp()` often returns no
        // active session, so `currentUser` is null until the user confirms.
        if (_mode == AuthMode.signUp) {
          if (!mounted) return;
          setState(() {
            _mode = AuthMode.signIn;
            _error = 'Account created. Please check your email to confirm, then sign in.';
          });
          return;
        }

        throw StateError('Sign-in failed: no active session returned.');
      }

      if (!context.mounted) return;

      // SIGN UP: always goes to Welcome (shown once-only, before L0).
      if (_mode == AuthMode.signUp) {
        await _ensureProfileRow(uid: uid, email: email);
        context.go('/welcome');
        return;
      }

      // SIGN IN greeting (UI only): show the user's name if present, then navigate.
      await _showTransientGreetingIfPossible(uid: uid);
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _routeAfterSignIn(uid: uid));
    } catch (e) {
      debugPrint('Auth submit failed: $e');
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.toLowerCase().contains('invalid login credentials')) {
      return 'That email/password combination didn\'t work.';
    }
    if (s.toLowerCase().contains('already registered')) {
      return 'That email is already registered. Try signing in instead.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final isSignIn = _mode == AuthMode.signIn;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoSize = constraints.maxHeight < 720 ? 200.0 : 260.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: AppSpacing.paddingLg,
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: Image.asset(
                                'assets/images/Her_Long_Game-01_1.png',
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              child: (!_showTransientGreeting || _transientDisplayName == null)
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: HLGColors.petal,
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: HLGColors.textBody.withValues(alpha: 0.08)),
                                          ),
                                          child: Text(
                                            'Welcome back, ${_transientDisplayName!}',
                                            style: HLGTextStyles.labelMedium(color: HLGColors.textBody),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            dartPadding(
                              padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                     color: HLGColors.sageMid,
                                    height: 1.6,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'The money lessons women were never taught. But are expected to use everyday.',
                                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: HLGColors.deepSage),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _ModeToggle(
                              mode: _mode,
                              onChanged: (m) => setState(() {
                                _mode = m;
                                _error = null;
                                _transientDisplayName = null;
                                _showTransientGreeting = false;
                              }),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Enter your email.';
                            if (!value.contains('@')) return 'Enter a valid email.';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          enabled: !_isSubmitting,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (v) {
                            final value = (v ?? '');
                            if (value.isEmpty) return 'Enter your password.';
                            if (!isSignIn && value.length < 8) {
                              return 'Use at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                        if (isSignIn) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: _isSubmitting ? null : _openResetPasswordSheet,
                              child: Text('Forgot password?', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
                            ),
                          )
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _isSubmitting
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: HLGColors.white),
                                  )
                                : Text(
                                    isSignIn ? 'Sign In' : 'Create Account',
                                    key: ValueKey(isSignIn ? 'signIn' : 'signUp'),
                                    style: HLGTextStyles.labelMedium(color: HLGColors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const TermsPrivacyConsentText(),
                        const SizedBox(height: 18),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          child: _error == null
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: HLGColors.petal,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: HLGColors.textBody.withValues(alpha: 0.08)),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: HLGTextStyles.body(color: HLGColors.textBody),
                                  ),
                                ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (isSignIn) ...[
                          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                            _SocialAuthButton(
                              onPressed: _isSubmitting ? null : _signInWithApple,
                              icon: Icons.apple,
                              label: 'Continue with Apple',
                            ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
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

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HLGColors.white,
        borderRadius: BorderRadius.circular(999),
         border: Border.all(color: HLGColors.textBody.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _Pill(
                label: 'Sign In',
                selected: mode == AuthMode.signIn,
                onTap: () => onChanged(AuthMode.signIn),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _Pill(
                label: 'Create Account',
                selected: mode == AuthMode.signUp,
                onTap: () => onChanged(AuthMode.signUp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? HLGColors.deepSage : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HLGTextStyles.labelMedium(
                color: selected ? HLGColors.white : HLGColors.textBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({required this.onPressed, required this.icon, required this.label});

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: HLGColors.white,
           side: BorderSide(color: HLGColors.sageMid, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: HLGColors.textBody, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HLGTextStyles.labelMedium(color: HLGColors.textBody).copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget dartPadding({required EdgeInsets padding, required Widget child}) => Padding(padding: padding, child: child);
