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
          backgroundColor: HLGColors.deepSage,
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
          'A note from the founder',
          style: HLGTextStyles.h3SubheadItalic(color: primaryText),
        ),
        const SizedBox(height: 16),
        const _FounderNoteCallout(
          tone: _FounderNoteCalloutTone.emphasis,
          title: 'Quick clarity.',
          body:
              'I am not a financial advisor.\n\nI am not a guru.\n\nI am definitely not here to tell you to manifest wealth while journalling beside a beige candle.',
        ),
        const SizedBox(height: 20),
        Text(
          'I built Her Long Game because I worked out pretty early that enjoying life requires options.\n\nAnd options require money.\n\nThat is all money is, really.\n\nA tool that stores your time and energy so you can use it later.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        Text(
          'I am not perfect with it either. Once, after a few too many wines, I bought a large inflatable projector screen off eBay.\n\nA large one.\n\nFor what cinema empire, I cannot say.\n\nI sold it on Facebook Marketplace three years later for \$50 less than I paid.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        const _FounderNotePullQuote(
          text:
              'Honestly, not my worst investment. But still, the poor woman at checkout did not have the tools I am about to give you. The ones that help you see the true cost of the thing you absolutely do not need, but suddenly believe will transform your life after two glasses of shiraz.',
        ),
        const SizedBox(height: 20),
        Text(
          'So no, I am not perfect.\n\nBut I am money smart in a street-smart kind of way.\n\nAnd that did not happen overnight.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        Text(
          'What still breaks my heart is the shame, stress and silence around money. Especially when most people were never properly taught how any of it works.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        Text(
          'I have never once used Pythagoras’ theorem in adult life.\n\nBut compound interest?\n\nInflation?\n\nCredit card interest?\n\nThe small matter of not turning a \$5 coffee into a \$15 coffee because future-you got mugged by past-you?\n\nApparently that was all supposed to sort itself out.\n\nIt won’t.\n\nBut you can.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 24),
        const _FounderNoteCallout(
          tone: _FounderNoteCalloutTone.insight,
          title: 'The real context',
          body:
              'Women are navigating a financial system that was not built around their lives.\n\nLower lifetime earnings.\nCareer breaks.\nUnpaid labour.\nLonger life expectancy.\nLess access to financial education.\n\nAnd then somehow, women are expected to make calm, confident, informed decisions inside that system.\n\nIn every country studied, women score lower on financial literacy measures.\n\nThat is not a personal failing.\n\nThat is a structural one.',
        ),
        const SizedBox(height: 20),
        Text(
          'My first idea was to build a practical course for schools and teach people the money lessons they actually need.\n\nThen I realised something.\n\nBy the time the lesson is needed, the woman in the household is often already carrying the consequence.',
          style: HLGTextStyles.quoteItalic(color: primaryText),
        ),
        const SizedBox(height: 20),
        Text(
          'Women are shaping the next generation. Holding households together. Working. Caring. Planning. Absorbing. Stretching. Remembering the school note, the dentist appointment, the grocery budget and the invisible labour nobody seems to invoice for.\n\nAnd many are still wondering why their financial position does not reflect how hard they work.\n\nThat is the gap Her Long Game exists to close.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        const _FounderNoteCallout(
          tone: _FounderNoteCalloutTone.statement,
          title: 'What this is',
          body:
              'This app is not here to create dependency.\n\nIt is here to end one.',
        ),
        const SizedBox(height: 20),
        Text(
          'It is access to the lessons you were expected to use every day, but were never properly taught.\n\nHow money works.\nHow the system works.\nWhy inflation matters.\nWhy assets matter.\nWhy time matters.\nWhy debt is a tool, not a character flaw.\nWhy your income is not fixed.\nAnd why financial education does not stop with you.',
          style: HLGTextStyles.body(color: bodyColor).copyWith(height: 1.8),
        ),
        const SizedBox(height: 20),
        const _FounderNotePullQuote(
          text:
              'It is not your fault you were not taught this. But it is your responsibility now.',
        ),
        const SizedBox(height: 20),
        Text(
          'Not in a shamey way.\n\nIn a “you are allowed to understand the tool” way.',
          style: HLGTextStyles.quoteItalic(color: secondaryText),
        ),
        const SizedBox(height: 28),
        Container(
            height: 1, color: HLGColors.crownGold.withValues(alpha: 0.55)),
        const SizedBox(height: 28),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Start your long game.\n\nTamara\nFounder, Her Long Game',
            style: HLGTextStyles.homeMeta13(color: secondaryText).copyWith(height: 1.8),
            textAlign: TextAlign.left,
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
                isSubmitting ? 'Just a second…' : 'Start your long game →',
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
