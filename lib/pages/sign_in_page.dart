import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/auth/supabase_auth_manager.dart';
import 'package:her_long_game/nav.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/terms_privacy_consent_text.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = SupabaseAuthManager();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _auth.signInWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      debugPrint('Sign in failed: $e');
      if (!mounted) return;
      setState(() => _error = 'Sign in failed. Check credentials and email confirmation settings.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - MediaQuery.paddingOf(context).vertical),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/Her_Long_Game-01_1.png',
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Welcome back', style: context.textStyles.titleLarge?.copyWith(color: cs.onSurface).semiBold),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Sign in to continue.', style: context.textStyles.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _isLoading ? null : _signIn(),
                        decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: context.textStyles.bodySmall?.copyWith(color: cs.error)),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _signIn,
                        icon: Icon(Icons.arrow_forward, color: cs.onPrimary),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(_isLoading ? 'Signing in…' : 'Sign in', style: TextStyle(color: cs.onPrimary)),
                        ),
                      ),
                      const TermsPrivacyConsentText(),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _isLoading ? null : () => context.go(AppRoutes.auth),
                        child: Text("Go to auth", style: TextStyle(color: cs.primary)),
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
