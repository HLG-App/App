import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  static String _referralCodeForUserId(String uid) {
    final cleaned = uid.replaceAll('-', '');
    if (cleaned.isEmpty) return 'HLG';
    return cleaned.substring(0, cleaned.length >= 8 ? 8 : cleaned.length).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final uid = SupabaseConfig.auth.currentUser?.id;
    final code = uid == null ? null : _referralCodeForUserId(uid);

    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/profile',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text('Referral', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HLGColors.petal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invite a friend', style: HLGTextStyles.lessonHeading(color: HLGColors.night)),
                  const SizedBox(height: 8),
                  Text(
                    'Share your code. We’ll use it later to credit referrals.',
                    style: HLGTextStyles.body(color: HLGColors.midSage),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: HLGColors.warmCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: HLGColors.deepSage),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            code ?? 'Sign in to get a referral code',
                            style: HLGTextStyles.lessonHeading(color: HLGColors.textBody),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: code == null
                              ? null
                              : () async {
                                  try {
                                    await Clipboard.setData(ClipboardData(text: code));
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Copied to clipboard', style: HLGTextStyles.body(color: HLGColors.warmCream)),
                                        backgroundColor: HLGColors.deepSage,
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint('[ReferralPage] Clipboard copy failed: $e');
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: HLGColors.deepSage,
                            foregroundColor: HLGColors.warmCream,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: Text('Copy', style: HLGTextStyles.labelMedium(color: HLGColors.warmCream)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Tip: once sharing is live, this will also generate a link you can text.', style: HLGTextStyles.labelMedium(color: HLGColors.midSage)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
