import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/app.dart';
import 'package:her_long_game/flow/onboarding_flow_controller.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';

class FounderNoteScreen extends StatefulWidget {
  const FounderNoteScreen({super.key});

  @override
  State<FounderNoteScreen> createState() => _FounderNoteScreenState();
}

class _FounderNoteScreenState extends State<FounderNoteScreen> {
  bool _isSubmitting = false;

  Future<void> _markSeenAndContinue() async {
    if (_isSubmitting) return;
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      debugPrint('FounderNote: no current user; routing to /auth');
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await SupabaseConfig.client.from('users').update({
        'founder_note_seen': true,
        'welcomed_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);

      if (!mounted) return;
      context.go(OnboardingFlowController.instance
          .nextOnboardingStep(AppRoutes.founderNote));
    } catch (e) {
      debugPrint('FounderNote: failed to set founder_note_seen: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Couldn\'t continue. Please try again.',
              style: HLGTextStyles.body(color: HLGColors.warmCream)),
          backgroundColor: HLGColors.night,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        // Match Home page background for consistency/readability.
        backgroundColor: HLGColors.warmCream,
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.only(left: 32, right: 32, top: 48, bottom: 80),
            child: FounderNoteContent(
              showPrimaryButton: true,
              isSubmitting: _isSubmitting,
              onPrimaryTap: _markSeenAndContinue,
            ),
          ),
        ),
      ),
    );
  }
}

class FounderNoteContent extends StatelessWidget {
  const FounderNoteContent(
      {super.key,
      required this.showPrimaryButton,
      this.isSubmitting = false,
      this.onPrimaryTap,
      this.isDarkSurface = false});

  final bool showPrimaryButton;
  final bool isSubmitting;
  final VoidCallback? onPrimaryTap;
  final bool isDarkSurface;

  @override
  Widget build(BuildContext context) {
    final bodyColor = isDarkSurface
        ? HLGColors.warmCream.withValues(alpha: 0.84)
        : HLGColors.night.withValues(alpha: 0.78);
    final primaryText = isDarkSurface ? HLGColors.warmCream : HLGColors.night;
    final secondaryText = isDarkSurface
        ? HLGColors.warmCream.withValues(alpha: 0.68)
        : HLGColors.deepSage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A NOTE FROM THE FOUNDER',
          style: HLGTextStyles.eyebrowAllCaps(
            color: isDarkSurface ? HLGColors.crownGold : HLGColors.deepSage,
          ),
        ),
        const SizedBox(height: 12),
        Center(
            child:
                Image.asset('assets/images/Her_Long_Game-02.png', width: 200)),
        Text(
          'A note from the founder.',
          style: HLGTextStyles.h3SubheadItalic(color: primaryText),
        ),
        const SizedBox(height: 16),
        const _FounderNoteCallout(
          tone: _FounderNoteCalloutTone.emphasis,
          title: 'Quick clarity',
          body:
              'I am not a financial advisor. I am not a guru. I am definitely not here to tell you to manifest wealth.',
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        Text(
          'I\'m an average woman who figured out early that enjoying life requires options — and options require money. That\'s all money is. A tool that stores your time and energy so you can use it later.\n\nI\'m not perfect with it either. Once, after a few too many wines, I bought a large inflatable projector screen off eBay. Sold it on Facebook Marketplace three years later for \$50 less than I paid. Poor guy on the other end didn\'t have the tools I\'m about to give you — the ones that show you the true cost of the thing you don\'t need.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        const _FounderNotePullQuote(
          text:
              'So although I am not perfect, I would say I am money smart — in a street smart kind of way. But this does not happen overnight.',
        ),
        const SizedBox(height: 20),
        Text(
          'Yet still, what breaks my heart is the shame, stress and silence that surrounds the topic of money. Especially when most people were never properly taught how any of it works.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        Text(
          'I have never once used Pythagoras\' theorem in adult life. But compound interest? Inflation? Not putting a coffee on a credit card and turning a \$5 latte into a \$15 one? Apparently that was all supposed to sort itself out. It won\'t. But you can.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 24),
        const _FounderNoteCallout(
          tone: _FounderNoteCalloutTone.insight,
          title: 'The real context',
          body:
              'The data is confronting. Women are navigating a financial system built around unpaid labour, lower lifetime earnings and less financial education. In every country studied — every single one — women score lower on financial literacy measures. Not a personal failing. A structural one.',
        ),
        const SizedBox(height: 20),
        Text(
          'My initial idea was to build a practical course to go into schools and teach people the things they actually need to know about money. Then I realised — schools don\'t raise kids or set the environment for what they do. Women do.',
          style: HLGTextStyles.quoteItalic(color: primaryText),
        ),
        const SizedBox(height: 20),
        Text(
          'The people shaping the next generation most closely are often women. Many of those same women are working full time, carrying the majority of unpaid domestic labour, holding households together — and wondering why their financial position doesn\'t reflect how hard they work.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        const _FounderNoteCallout(
          tone: _FounderNoteCalloutTone.statement,
          title: 'What this is',
          body:
              'This app is not about creating dependency. It\'s about ending one.',
        ),
        const SizedBox(height: 20),
        Text(
          'I have never once used Pythagoras\' theorem in adult life, sooo wait… why don\'t they teach this in school?',
          style: HLGTextStyles.quoteItalic(color: secondaryText),
        ),
        const SizedBox(height: 20),
        Text(
          'You still live your life like everyone else. This is simply access to the lessons you were expected to use every day — but were never properly taught.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 28),
        Container(
            height: 1, color: HLGColors.crownGold.withValues(alpha: 0.55)),
        const SizedBox(height: 28),
        Center(
          child: Text(
            'It is not your fault you don\'t know this stuff.',
            textAlign: TextAlign.center,
            style: HLGTextStyles.quoteItalic(color: primaryText),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'But it is your responsibility.',
            textAlign: TextAlign.center,
            style: HLGTextStyles.quoteItalic(color: secondaryText),
          ),
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '— Tamara, Founder',
            style: HLGTextStyles.homeMeta13(color: secondaryText),
            textAlign: TextAlign.right,
          ),
        ),
        if (showPrimaryButton) ...[
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onPrimaryTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: HLGColors.horizonOrange,
                foregroundColor: HLGColors.warmCream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                isSubmitting ? 'Just a second…' : 'Start my long game →',
                style: HLGTextStyles.homeCta15(
                  color: HLGColors.warmCream,
                ).copyWith(fontSize: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

enum _FounderNoteCalloutTone { emphasis, insight, statement }

class _FounderNotePullQuote extends StatelessWidget {
  const _FounderNotePullQuote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HLGColors.crownGold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: HLGColors.deepSage,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: HLGTextStyles.quoteItalic(color: HLGColors.night))),
        ],
      ),
    );
  }
}

class _FounderNoteCallout extends StatelessWidget {
  const _FounderNoteCallout(
      {required this.tone, required this.title, required this.body});

  final _FounderNoteCalloutTone tone;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final (Color tint, Color accent) = switch (tone) {
      _FounderNoteCalloutTone.emphasis => (
          HLGColors.sagePale,
          HLGColors.horizonOrange
        ),
      _FounderNoteCalloutTone.insight => (HLGColors.petal, HLGColors.crownGold),
      _FounderNoteCalloutTone.statement => (
          HLGColors.sagePale,
          HLGColors.deepSage
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: accent, borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(title,
                      style:
                          HLGTextStyles.labelMedium(color: HLGColors.night))),
            ],
          ),
          const SizedBox(height: 10),
          Text(body,
              style: HLGTextStyles.body(
                      color: HLGColors.night.withValues(alpha: 0.78))
                  .copyWith(height: 1.75)),
        ],
      ),
    );
  }
}
