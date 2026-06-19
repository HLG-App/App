import 'package:flutter/material.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/profile',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text('Payment', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HLGColors.petal,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Billing & plan', style: HLGTextStyles.lessonHeading(color: HLGColors.textBody)),
                const SizedBox(height: 8),
                Text(
                  'This area is where you’ll manage your subscription, billing, and payment method.',
                  style: HLGTextStyles.body(color: HLGColors.sageMid),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HLGColors.warmCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: HLGColors.deepSage),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Not connected yet. If you’d like, tell me your plan model (free / paid / trial) and I’ll wire the UI + Supabase hooks.',
                          style: HLGTextStyles.body(color: HLGColors.textBody),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
