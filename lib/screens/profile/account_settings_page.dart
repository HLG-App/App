import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _isLoading = true;
  String? _error;
  String? _email;
  bool _isSavingName = false;
  bool _isSendingReset = false;
  bool _isSavingEmail = false;
  bool _isSavingPassword = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _passwordConfirmCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _passwordConfirmCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = SupabaseConfig.auth.currentUser;
      if (user == null) {
        setState(() {
          _email = null;
          _nameCtrl.text = '';
        });
        return;
      }

      final email = user.email;
      String? name;
      try {
        final row = await SupabaseService.selectSingle(
          'users',
          select: 'name, display_name',
          filters: {'id': user.id},
        );
        final v1 = row?['name'];
        final v2 = row?['display_name'];
        final asName = (v1 is String && v1.trim().isNotEmpty) ? v1.trim() : null;
        final asDisplayName = (v2 is String && v2.trim().isNotEmpty) ? v2.trim() : null;
        name = asDisplayName ?? asName;
      } catch (e) {
        // Column might not exist in some environments. Keep it optional.
        debugPrint('[AccountSettingsPage] Could not load users.name: $e');
      }

      setState(() {
        _email = email;
        _nameCtrl.text = name ?? '';
        _emailCtrl.text = email ?? '';
      });
    } catch (e) {
      debugPrint('[AccountSettingsPage] Load failed: $e');
      setState(() => _error = 'Could not load account settings.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ensureUsersRow({required String userId, required String? email}) async {
    // Best-effort: keep a public.users row in sync with auth user.
    // Some environments may have different columns/RLS; failures should not block the UI.
    try {
      await SupabaseConfig.client.from('users').upsert({
        'id': userId,
        if (email != null) 'email': email,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[AccountSettingsPage] users upsert best-effort failed: $e');
    }
  }

  Future<void> _saveDisplayName() async {
    if (_isSavingName) return;
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return;

    final next = _nameCtrl.text.trim();
    setState(() => _isSavingName = true);
    try {
      await _ensureUsersRow(userId: user.id, email: user.email);
      // Try to update both common column names to stay compatible with older/newer schemas.
      try {
        await SupabaseConfig.client.from('users').update({'display_name': next.isEmpty ? null : next}).eq('id', user.id);
      } catch (e) {
        debugPrint('[AccountSettingsPage] display_name update failed (optional): $e');
      }
      try {
        await SupabaseConfig.client.from('users').update({'name': next.isEmpty ? null : next}).eq('id', user.id);
      } catch (e) {
        debugPrint('[AccountSettingsPage] name update failed (optional): $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved.')),
      );
    } catch (e) {
      debugPrint('[AccountSettingsPage] Save display name failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not save. Please try again.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _saveEmail() async {
    if (_isSavingEmail) return;
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return;

    final next = _emailCtrl.text.trim();
    if (next.isEmpty || !next.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
      return;
    }

    setState(() => _isSavingEmail = true);
    try {
      await SupabaseConfig.auth.updateUser(UserAttributes(email: next));
      await _ensureUsersRow(userId: user.id, email: next);
      if (!mounted) return;
      setState(() => _email = next);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email update requested. Check your inbox to confirm.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
    } catch (e) {
      debugPrint('[AccountSettingsPage] Save email failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not update email.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingEmail = false);
    }
  }

  Future<void> _savePassword() async {
    if (_isSavingPassword) return;
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return;

    final pw = _passwordCtrl.text;
    final confirm = _passwordConfirmCtrl.text;
    if (pw.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password must be at least 8 characters.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
      return;
    }
    if (pw != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
      return;
    }

    setState(() => _isSavingPassword = true);
    try {
      await SupabaseConfig.auth.updateUser(UserAttributes(password: pw));
      if (!mounted) return;
      _passwordCtrl.clear();
      _passwordConfirmCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated.')),
      );
    } catch (e) {
      debugPrint('[AccountSettingsPage] Save password failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not update password.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_isSendingReset) return;
    final email = _email;
    if (email == null || email.trim().isEmpty) return;

    setState(() => _isSendingReset = true);
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset email sent.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
    } catch (e) {
      debugPrint('[AccountSettingsPage] resetPasswordForEmail failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not send reset email.'),
          backgroundColor: HLGColors.deepSage,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/profile',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text('Account', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            if (_isLoading)
              Text('Loading…', style: HLGTextStyles.body(color: HLGColors.midSage))
            else if (_error != null)
              Text(_error!, style: HLGTextStyles.body(color: HLGColors.horizonOrange))
            else ...[
              _SettingCard(
                icon: Icons.alternate_email,
                title: 'Email',
                subtitle: _email ?? '-',
              ),
              const SizedBox(height: 12),
              _EditableSettingCard(
                icon: Icons.alternate_email,
                title: 'Update email',
                hintText: 'you@example.com',
                controller: _emailCtrl,
                trailing: FilledButton(
                  onPressed: _isSavingEmail ? null : _saveEmail,
                  style: FilledButton.styleFrom(
                    backgroundColor: HLGColors.deepSage,
                    foregroundColor: HLGColors.warmCream,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(_isSavingEmail ? 'Saving…' : 'Save', style: HLGTextStyles.labelMedium(color: HLGColors.warmCream)),
                ),
              ),
              const SizedBox(height: 12),
              _EditableSettingCard(
                icon: Icons.badge_outlined,
                title: 'Username',
                hintText: 'Your name (optional)',
                controller: _nameCtrl,
                trailing: FilledButton(
                  onPressed: _isSavingName ? null : _saveDisplayName,
                  style: FilledButton.styleFrom(
                    backgroundColor: HLGColors.deepSage,
                    foregroundColor: HLGColors.warmCream,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(_isSavingName ? 'Saving…' : 'Save', style: HLGTextStyles.labelMedium(color: HLGColors.warmCream)),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                decoration: BoxDecoration(
                  color: HLGColors.petal,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, color: HLGColors.deepSage),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Password', style: HLGTextStyles.labelMedium(color: HLGColors.textBody))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      style: HLGTextStyles.body(color: HLGColors.textBody),
                      decoration: InputDecoration(
                        hintText: 'New password (min 8 characters)',
                        hintStyle: HLGTextStyles.body(color: HLGColors.midSage),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: HLGColors.warmCream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.35))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.35))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: HLGColors.deepSage)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordConfirmCtrl,
                      obscureText: true,
                      style: HLGTextStyles.body(color: HLGColors.textBody),
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        hintStyle: HLGTextStyles.body(color: HLGColors.midSage),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: HLGColors.warmCream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.35))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.35))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: HLGColors.deepSage)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSavingPassword ? null : _savePassword,
                            style: FilledButton.styleFrom(
                              backgroundColor: HLGColors.deepSage,
                              foregroundColor: HLGColors.warmCream,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _isSavingPassword ? 'Saving…' : 'Update password',
                              style: HLGTextStyles.labelMedium(color: HLGColors.warmCream),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _isSendingReset ? null : _sendPasswordReset,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.55)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          ),
                          child: Text('Email reset link', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tip: some email/password changes require confirmation in your inbox.',
                      style: HLGTextStyles.homeMeta13(color: HLGColors.midSage),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.check, color: HLGColors.deepSage),
                label: Text('Done', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: HLGColors.deepSage),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                const SizedBox(height: 4),
                Text(subtitle, style: HLGTextStyles.body(color: HLGColors.midSage)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableSettingCard extends StatelessWidget {
  const _EditableSettingCard({
    required this.icon,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String hintText;
  final TextEditingController controller;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: HLGColors.deepSage),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  style: HLGTextStyles.body(color: HLGColors.textBody),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: HLGTextStyles.body(color: HLGColors.midSage),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: HLGColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.35))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.35))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: HLGColors.deepSage)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
