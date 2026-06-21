import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/flow/onboarding_flow_controller.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;
  bool _isSubmitting = false;

  bool _founderNoteSubmitting = false;

  static const Color _warmDarkSage = HLGColors.deepSage;
  static const Color _warmLight = HLGColors.warmCream;

  static const int _founderNoteStepCount = 5;

  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isFounderNotePage => _index >= 1 && _index <= _founderNoteStepCount;

  int get _founderNoteStepIndex => (_index - 1).clamp(0, _founderNoteStepCount - 1);

  Future<void> _goToPage(int i) async {
    if (!_controller.hasClients) return;
    await _controller.animateToPage(i, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  Future<void> _nextPage() async => _goToPage((_index + 1).clamp(0, _pageCount - 1));

  Future<void> _prevPage() async => _goToPage((_index - 1).clamp(0, _pageCount - 1));

  static int get _pageCount => 1 + _founderNoteStepCount + 3; // wordmark + founder(5) + is + isNot + commitment

  Future<void> _markFounderNoteSeenAndContinue() async {
    if (_founderNoteSubmitting) return;
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      debugPrint('WelcomeScreen(FounderNote): no current user session; sending to /auth');
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    setState(() => _founderNoteSubmitting = true);
    try {
      await SupabaseConfig.client.from('users').update({'founder_note_seen': true}).eq('id', uid);
      if (!mounted) return;
      await _nextPage();
    } catch (e) {
      debugPrint('WelcomeScreen(FounderNote): failed to set founder_note_seen: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Couldn\'t continue. Please try again.', style: HLGTextStyles.body(color: HLGColors.warmCream)),
          backgroundColor: HLGColors.deepSage,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _founderNoteSubmitting = false);
    }
  }

  Future<void> _markWelcomedAndContinue() async {
    if (_isSubmitting) return;
    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      debugPrint('WelcomeScreen: no current user session; sending to /auth');
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await SupabaseConfig.client
          .from('users')
          .update({'welcomed_at': DateTime.now().toIso8601String()})
          .eq('id', SupabaseConfig.auth.currentUser!.id);
      if (!mounted) return;
      context.go(OnboardingFlowController.instance.nextOnboardingStep('/welcome'));
    } catch (e) {
      debugPrint('WelcomeScreen: failed to set welcomed_at: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Couldn\'t continue. Please try again.', style: HLGTextStyles.body(color: HLGColors.warmCream)),
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
    final scaffoldBg = _isFounderNotePage ? _warmLight : _warmDarkSage;
    final appBarBg = scaffoldBg;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: HerAppBar(
          backgroundColor: appBarBg,
          surfaceTintColor: Colors.transparent,
          titleText: '',
          showBack: _isFounderNotePage && _founderNoteStepIndex > 0,
          onBackPressed: _isFounderNotePage && _founderNoteStepIndex > 0 ? _prevPage : null,
          useBrandBand: _isFounderNotePage,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _WordmarkPage(pulse: _pulse),
                  for (int i = 0; i < _founderNoteStepCount; i++)
                    _FounderNoteStepPage(
                      stepIndex: i,
                      totalSteps: _founderNoteStepCount,
                      onContinue: i == _founderNoteStepCount - 1
                          ? (_founderNoteSubmitting ? null : _markFounderNoteSeenAndContinue)
                          : (_nextPage),
                      isSubmitting: i == _founderNoteStepCount - 1 ? _founderNoteSubmitting : false,
                    ),
                  const _IsPage(),
                  const _IsNotPage(),
                  _CommitmentPage(onReady: _isSubmitting ? null : _markWelcomedAndContinue, isLoading: _isSubmitting),
                ],
              ),
              if (!_isFounderNotePage)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: _DotIndicator(index: _index, onTapDot: (i) {
                    // The Welcome section is now a larger PageView. We only expose
                    // dot navigation for the original 4 "welcome" pages.
                    const map = <int, int>{0: 0, 1: 1 + _founderNoteStepCount, 2: 2 + _founderNoteStepCount, 3: 3 + _founderNoteStepCount};
                    final target = map[i];
                    if (target != null) _goToPage(target);
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.index, required this.onTapDot});

  final int index;
  final ValueChanged<int> onTapDot;

  @override
  Widget build(BuildContext context) {
    // We only show dot navigation for the original 4 welcome pages. Map the
    // extended PageView indexes to the 0..3 dot positions.
    const founderSteps = _WelcomeScreenState._founderNoteStepCount;
    final mapped = switch (index) {
      0 => 0,
      const (1 + founderSteps) => 1,
      const (2 + founderSteps) => 2,
      const (3 + founderSteps) => 3,
      _ => 0,
    };
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final active = i == mapped;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapDot(i),
            child: Container(
              width: 20,
              height: 20,
              margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? HLGColors.crownGold : HLGColors.sageMid,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FounderNoteStepPage extends StatelessWidget {
  const _FounderNoteStepPage({required this.stepIndex, required this.totalSteps, required this.onContinue, required this.isSubmitting});

  final int stepIndex;
  final int totalSteps;
  final VoidCallback? onContinue;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final pad = maxWidth >= 520 ? const EdgeInsets.symmetric(horizontal: 32, vertical: 24) : const EdgeInsets.fromLTRB(24, 20, 24, 24);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A NOTE FROM THE FOUNDER', style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.deepSage).copyWith(letterSpacing: 4.0)),
                const SizedBox(height: 10),
                _FounderDots(count: totalSteps, index: stepIndex),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: pad,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: _FounderNoteStepBody(stepIndex: stepIndex),
              ),
            ),
          ),
          _FounderNoteActions(stepIndex: stepIndex, totalSteps: totalSteps, onContinue: onContinue, isSubmitting: isSubmitting),
        ],
      ),
    );
  }
}

class _FounderDots extends StatelessWidget {
  const _FounderDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 8),
            height: 7,
            width: i == index ? 18 : 7,
            decoration: BoxDecoration(
              color: i == index ? cs.primary : cs.outlineVariant.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _FounderNoteActions extends StatelessWidget {
  const _FounderNoteActions({required this.stepIndex, required this.totalSteps, required this.onContinue, required this.isSubmitting});

  final int stepIndex;
  final int totalSteps;
  final VoidCallback? onContinue;
  final bool isSubmitting;

  bool get _isFinal => stepIndex == totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = 16 + MediaQuery.of(context).viewPadding.bottom;
    final label = _isFinal ? 'Start your long game →' : 'Continue';

    // Per spec: screen 2 gets even more breathing room above the CTA.
    final topGap = stepIndex == 1 ? 26.0 : (_isFinal ? 34.0 : 18.0);

    return Container(
      padding: EdgeInsets.fromLTRB(16, topGap, 16, bottomPad),
      decoration: BoxDecoration(color: cs.surface, border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)))),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: isSubmitting ? null : onContinue,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSubmitting
                ? Text('Just a second…', key: const ValueKey('loading'))
                : Text(label, key: const ValueKey('label')),
          ),
        ),
      ),
    );
  }
}

class _FounderNoteStepBody extends StatelessWidget {
  const _FounderNoteStepBody({required this.stepIndex});

  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    return switch (stepIndex) {
      0 => const _FounderNoteStep1(),
      1 => const _FounderNoteStep2(),
      2 => const _FounderNoteStep3(),
      3 => const _FounderNoteStep4(),
      4 => const _FounderNoteStep5(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _StaggeredFadeIn extends StatefulWidget {
  const _StaggeredFadeIn({required this.children, this.initialDelay = Duration.zero});

  final List<Widget> children;
  final Duration initialDelay;

  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn> {
  late List<bool> _visible;

  @override
  void initState() {
    super.initState();
    _visible = List<bool>.filled(widget.children.length, false);
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _StaggeredFadeIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _visible = List<bool>.filled(widget.children.length, false);
      _schedule();
    }
  }

  void _schedule() {
    Future<void>.delayed(widget.initialDelay, () {
      if (!mounted) return;
      for (int i = 0; i < _visible.length; i++) {
        Future<void>.delayed(const Duration(milliseconds: 200) * i, () {
          if (!mounted) return;
          setState(() => _visible[i] = true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            opacity: _visible[i] ? 1 : 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              offset: _visible[i] ? Offset.zero : const Offset(0, 0.02),
              child: widget.children[i],
            ),
          ),
      ],
    );
  }
}

class _FounderNoteStep1 extends StatelessWidget {
  const _FounderNoteStep1();

  @override
  Widget build(BuildContext context) {
    final base = HLGTextStyles.body(color: HLGColors.textBody.withValues(alpha: 0.82)).copyWith(height: 1.75);
    final thesis = base.copyWith(fontSize: (base.fontSize ?? 14) + 2, fontWeight: FontWeight.w500, color: HLGColors.textBody.withValues(alpha: 0.92));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaggeredFadeIn(
          children: [
            Text('I am not a financial advisor.', style: base),
            const SizedBox(height: 12),
            Text('I am not a guru.', style: base),
            const SizedBox(height: 12),
            Text('I am definitely not here to tell you to manifest wealth while journalling beside a beige candle.', style: base),
          ],
        ),
        const SizedBox(height: 28),
        _StaggeredFadeIn(
          initialDelay: const Duration(milliseconds: 800), // 3 lines @200ms + buffer
          children: [
            Text('I built Her Long Game because I worked out pretty early that enjoying life requires options.', style: base),
            const SizedBox(height: 12),
            Text('And options require money.', style: base),
            const SizedBox(height: 12),
            Text('That is all money is, really.', style: base),
            const SizedBox(height: 14),
            Text('A tool that stores your time and energy so you can use it later.', style: thesis),
          ],
        ),
      ],
    );
  }
}

class _FounderNoteStep2 extends StatelessWidget {
  const _FounderNoteStep2();

  @override
  Widget build(BuildContext context) {
    final base = HLGTextStyles.body(color: HLGColors.textBody.withValues(alpha: 0.82)).copyWith(height: 1.75);

    return _StaggeredFadeIn(
      children: [
        Text('I am not perfect with it either. Once, after a few too many wines, I bought a large inflatable projector screen off eBay.', style: base),
        const SizedBox(height: 18),
        Text('A large one.', style: base.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 18),
        Text('For what cinema empire, I cannot say.', style: base.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 18),
        Text('I sold it on Facebook Marketplace three years later for \$50 less than I paid.', style: base),
        const SizedBox(height: 16),
        Text(
          'Honestly, not my worst investment. But still, the poor guy on Facebook Marketplace did not have the tools I am about to give you. The ones that help you see the true cost of the thing you absolutely do not need, but suddenly believe will transform your life after two glasses of shiraz.',
          style: base,
        ),
        const SizedBox(height: 16),
        Text('So no, I am not perfect.', style: base),
        const SizedBox(height: 12),
        Text('But I am money smart in a street-smart kind of way.', style: base),
        const SizedBox(height: 12),
        Text('And that did not happen overnight.', style: base),
      ],
    );
  }
}

class _FounderNoteStep3 extends StatelessWidget {
  const _FounderNoteStep3();

  @override
  Widget build(BuildContext context) {
    final base = HLGTextStyles.body(color: HLGColors.textBody.withValues(alpha: 0.82)).copyWith(height: 1.75);
    final section = HLGTextStyles.eyebrowAllCaps(color: HLGColors.deepSage).copyWith(letterSpacing: 4.0);
    final cs = Theme.of(context).colorScheme;

    Widget listItem(String s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(s, style: base)),
            ],
          ),
        );

    return _StaggeredFadeIn(
      children: [
        Text('What still breaks my heart is the shame, stress and silence around money. Especially when most people were never properly taught how any of it works.', style: base),
        const SizedBox(height: 16),
        Text('I have never once used Pythagoras\' theorem in adult life.', style: base),
        const SizedBox(height: 16),
        Text(
          'But compound interest? Inflation? Credit card interest? The small matter of not turning a \$5 coffee into a \$15 coffee because future-you got mugged by past-you?',
          style: base,
        ),
        const SizedBox(height: 16),
        Text('Apparently that was all supposed to sort itself out.', style: base),
        const SizedBox(height: 12),
        Text('It won\'t.', style: base.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text('But you can.', style: base.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 26),
        Text('The real context', style: section),
        const SizedBox(height: 12),
        Text('Women are navigating a financial system that was not built around their lives.', style: base),
        const SizedBox(height: 18),
        listItem('Lower lifetime earnings'),
        listItem('Career breaks'),
        listItem('Unpaid labour'),
        listItem('Longer life expectancy'),
        listItem('Less access to financial education'),
        const SizedBox(height: 18),
        Text('And then somehow, women are expected to make calm, confident, informed decisions inside that system.', style: base),
        const SizedBox(height: 14),
        Text('In every country studied, women score lower on financial literacy measures.', style: base),
        const SizedBox(height: 18),
        Container(height: 1, color: cs.outlineVariant.withValues(alpha: 0.75)),
        const SizedBox(height: 18),
        Text('That is not a personal failing.', style: base.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text('That is a structural one.', style: base.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _FounderNoteStep4 extends StatelessWidget {
  const _FounderNoteStep4();

  @override
  Widget build(BuildContext context) {
    final base = HLGTextStyles.body(color: HLGColors.textBody.withValues(alpha: 0.82)).copyWith(height: 1.75);
    final section = HLGTextStyles.eyebrowAllCaps(color: HLGColors.deepSage).copyWith(letterSpacing: 4.0);
    final mission = HLGTextStyles.h3SubheadItalic(color: HLGColors.textBody).copyWith(fontSize: 22, height: 1.4);
    final cs = Theme.of(context).colorScheme;

    Widget listItem(String s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(s, style: base)),
            ],
          ),
        );

    return _StaggeredFadeIn(
      children: [
        Text('What this is', style: section),
        const SizedBox(height: 14),
        Text('This app is not here to create dependency.', style: mission),
        const SizedBox(height: 10),
        Text('It is here to end one.', style: mission),
        const SizedBox(height: 24),
        Text('It is access to the lessons you were expected to use every day, but were never properly taught.', style: base),
        const SizedBox(height: 16),
        listItem('How money works'),
        listItem('How the system works'),
        listItem('Why inflation matters'),
        listItem('Why assets matter'),
        listItem('Why time matters'),
        listItem('Why debt is a tool, not a character flaw'),
        listItem('Why your income is not fixed'),
        listItem('And why financial education does not stop with you'),
      ],
    );
  }
}

class _FounderNoteStep5 extends StatelessWidget {
  const _FounderNoteStep5();

  @override
  Widget build(BuildContext context) {
    final base = HLGTextStyles.body(color: HLGColors.textBody.withValues(alpha: 0.82)).copyWith(height: 1.75);
    final signOff = base.copyWith(fontStyle: FontStyle.italic, color: HLGColors.deepSage.withValues(alpha: 0.95));

    return _StaggeredFadeIn(
      children: [
        Text('It is not your fault you were not taught this.', style: base),
        const SizedBox(height: 14),
        Text('But it is your responsibility now.', style: base.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Text('Not in a shamey way.', style: base),
        const SizedBox(height: 12),
        Text('In a "you are allowed to understand the tool" way.', style: base),
        const SizedBox(height: 18),
        Text('Start your long game.', style: base.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 26),
        Text('Tamara', style: signOff),
        const SizedBox(height: 6),
        Text('Founder, Her Long Game', style: signOff),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _WordmarkPage extends StatelessWidget {
  const _WordmarkPage({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Her_Long_Game-02.png',
              width: 240,
            ),
            const SizedBox(height: 40),
            Text(
              'The money lessons women were never taught. But are expected to use everyday.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.h3SubheadItalic(color: HLGColors.warmCream).copyWith(fontSize: 22),
            ),
            const SizedBox(height: 48),
            ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.03).animate(pulse),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.55, end: 0.95).animate(pulse),
                child: Column(
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: HLGColors.crownGold),
                    const SizedBox(height: 8),
                    Text(
                      'Swipe to continue',
                      textAlign: TextAlign.center,
                      style: HLGTextStyles.uiElement(color: HLGColors.sageMid).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IsPage extends StatelessWidget {
  const _IsPage();

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      eyebrow: 'DESIGNED FOR HER.',
      eyebrowColor: HLGColors.crownGoldOnDark,
      heading: 'Here\'s what you\'re getting.',
      items: [
        _InfoCardData(
          stripeColor: HLGColors.crownGoldSoft,
          title: 'Simple.',
          titleColor: HLGColors.crownGoldSoft,
          bodyLines: [
            'Financial concepts explained the way they should have been explained years ago.',
            'Plain language.',
            'When we have to use a financial term, Her Cheat Sheet makes it simple and relatable.',
          ],
        ),
        _InfoCardData(
          stripeColor: HLGColors.crownGoldSoft,
          title: 'Grounded in reality.',
          titleColor: HLGColors.crownGoldSoft,
          bodyLines: [
            'We give you Her Tools: interactive calculators that use numbers you select, so the picture makes sense for your life.',
            'You will leave every lesson with clear takeaways so you can choose what you do next.',
          ],
        ),
        _InfoCardData(
          stripeColor: HLGColors.crownGoldSoft,
          title: 'Long game.',
          titleColor: HLGColors.crownGoldSoft,
          bodyLines: [
            'Not quick wins.',
            'Not 30-day transformations.',
            'The foundations that build wealth over time, taught in the order that makes them land.',
          ],
        ),
      ],
    );
  }
}

class _IsNotPage extends StatelessWidget {
  const _IsNotPage();

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      eyebrow: 'LET\'S BE CLEAR.',
      // Use brand gold variants for readability and consistency on the sage background.
      eyebrowColor: HLGColors.crownGoldOnDark,
      heading: 'What this isn\'t.',
      items: [
        _InfoCardData(
          stripeColor: HLGColors.crownGoldSoft,
          title: 'Not financial advice.',
          titleColor: HLGColors.crownGoldSoft,
          bodyLines: [
            'Advice tells you what to do today.',
            'Principles tell you how to think for the rest of your life.',
            'These ones are old enough to have been tested, and simple enough to explain to your daughter.',
            'That\'s why this is for the long game.',
          ],
          accentLineIndexes: {3},
        ),
        _InfoCardData(
          stripeColor: HLGColors.crownGoldSoft,
          title: 'Not a firehose.',
          titleColor: HLGColors.crownGoldSoft,
          bodyLines: [
            'If we thought you needed another degree, on top of your career, your relationships, your life, we wouldn\'t be here.',
            'We\'re stripping back to what matters.',
            'The app is based on ten specific principles we see as timeless.',
            'The right foundations, in the right order, at a pace that fits in your real life.',
          ],
        ),
        _InfoCardData(
          stripeColor: HLGColors.crownGoldSoft,
          title: 'Not political.',
          titleColor: HLGColors.crownGoldSoft,
          bodyLines: [
            'Facts. Numbers.',
            'How the system works and how it impacts women specifically.',
            'No political opinion. No agenda beyond this: you deserve to understand the system you\'ve been operating inside.',
          ],
        ),
      ],
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({required this.eyebrow, required this.eyebrowColor, required this.heading, required this.items});

  final String eyebrow;
  final Color eyebrowColor;
  final String heading;
  final List<_InfoCardData> items;

  static const _cardFill = Color(0x14FFFFFF);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = HLGTextStyles.body(color: HLGColors.warmCream.withValues(alpha: 0.85)).copyWith(fontSize: 14, height: 1.6);
    final signatureStyle = bodyStyle.copyWith(color: HLGColors.warmCream.withValues(alpha: 0.98), fontWeight: FontWeight.w700, fontStyle: FontStyle.italic);
    final signatureAccentStyle = bodyStyle.copyWith(color: HLGColors.crownGoldSoft.withValues(alpha: 0.98), fontWeight: FontWeight.w700, fontStyle: FontStyle.italic);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.only(top: 26, bottom: 52),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      eyebrow,
                      style: HLGTextStyles.eyebrowAllCaps(color: eyebrowColor).copyWith(letterSpacing: 4.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      heading,
                      style: HLGTextStyles.h2Section(color: HLGColors.warmCream).copyWith(fontSize: 32, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 32),
                  for (final item in items) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cardFill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: item.stripeColor, width: 4)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: HLGTextStyles.h3SubheadItalic(color: item.titleColor).copyWith(fontSize: 22),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < item.bodyLines.length; i++) ...[
                                      _InfoLine(
                                        text: item.bodyLines[i],
                                        style: item.accentLineIndexes.contains(i)
                                            ? bodyStyle.copyWith(color: HLGColors.crownGold, fontStyle: FontStyle.italic)
                                            : bodyStyle,
                                        signatureStyle: signatureStyle,
                                        signatureAccentStyle: signatureAccentStyle,
                                      ),
                                      if (i != item.bodyLines.length - 1) const SizedBox(height: 8),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.text, required this.style, required this.signatureStyle, required this.signatureAccentStyle});

  final String text;
  final TextStyle style;
  final TextStyle signatureStyle;
  final TextStyle signatureAccentStyle;

  @override
  Widget build(BuildContext context) {
    const cheatSheet = 'Her Cheat Sheet';
    const tools = 'Her Tools';

    if (text.contains(cheatSheet)) {
      final parts = text.split(cheatSheet);
      return RichText(
        text: TextSpan(
          style: style,
          children: [
            TextSpan(text: parts[0]),
            TextSpan(text: cheatSheet, style: signatureAccentStyle),
            TextSpan(text: parts.length > 1 ? parts[1] : ''),
          ],
        ),
      );
    }

    if (text.contains(tools)) {
      final parts = text.split(tools);
      return RichText(
        text: TextSpan(
          style: style,
          children: [
            TextSpan(text: parts[0]),
            TextSpan(text: tools, style: signatureAccentStyle),
            TextSpan(text: parts.length > 1 ? parts[1] : ''),
          ],
        ),
      );
    }

    return Text(text, style: style);
  }
}

class _InfoCardData {
  const _InfoCardData({required this.stripeColor, required this.title, required this.titleColor, required this.bodyLines, this.accentLineIndexes = const {}});

  final Color stripeColor;
  final String title;
  final Color titleColor;
  final List<String> bodyLines;
  final Set<int> accentLineIndexes;
}

class _CommitmentPage extends StatelessWidget {
  const _CommitmentPage({required this.onReady, required this.isLoading});

  final VoidCallback? onReady;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BEFORE WE BEGIN.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.crownGold).copyWith(letterSpacing: 4.0),
            ),
            const SizedBox(height: 48),
            Text(
              'You were never taught this.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.h2Section(color: HLGColors.warmCream).copyWith(fontSize: 28, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 32),
            Text(
              'Not in school. Not at home.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.h2Section(color: HLGColors.warmCream).copyWith(fontSize: 28, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 32),
            Text(
              'Not by the system that expected you to use it every day.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.h2Section(color: HLGColors.warmCream).copyWith(fontSize: 28, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 48),
            Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 60), color: HLGColors.crownGold.withValues(alpha: 0.95)),
            const SizedBox(height: 48),
            Text(
              'The gap was never in you.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.h3SubheadItalic(color: HLGColors.crownGold).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'The gap was in what you were given.',
              textAlign: TextAlign.center,
              style: HLGTextStyles.h3SubheadItalic(color: HLGColors.crownGold).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(HLGColors.horizonOrange),
                  foregroundColor: const WidgetStatePropertyAll(HLGColors.warmCream),
                  iconColor: const WidgetStatePropertyAll(HLGColors.warmCream),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
                  overlayColor: WidgetStatePropertyAll(HLGColors.warmCream.withValues(alpha: 0.10)),
                ),
                onPressed: onReady,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? const SizedBox(key: ValueKey('loading'), height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: HLGColors.warmCream))
                      : Text(
                          'Start my long game →',
                          key: const ValueKey('ready'),
                          style: HLGTextStyles.labelMedium(color: HLGColors.warmCream).copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
