import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/flow/onboarding_flow_controller.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;
  bool _isSubmitting = false;

  static const Color _warmDarkSage = Color(0xFF1E2E20);

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
          backgroundColor: HLGColors.night,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _goToPage(int i) async {
    if (!_controller.hasClients) return;
    await _controller.animateToPage(i, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _warmDarkSage,
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _WordmarkPage(pulse: _pulse),
                  const _IsPage(),
                  const _IsNotPage(),
                  _CommitmentPage(onReady: _isSubmitting ? null : _markWelcomedAndContinue, isLoading: _isSubmitting),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,
                child: _DotIndicator(index: _index, onTapDot: _goToPage),
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
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final active = i == index;
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
                  color: active ? HLGColors.crownGold : HLGColors.midSage,
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
                      style: HLGTextStyles.uiElement(color: HLGColors.midSage).copyWith(fontSize: 11),
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
      eyebrowColor: HLGColors.crownGold,
      heading: 'Here\'s what you\'re getting.',
      items: const [
        _InfoCardData(
          stripeColor: HLGColors.crownGold,
          title: 'Simple.',
          titleColor: HLGColors.crownGold,
          bodyLines: [
            'Financial concepts explained the way they should have been explained years ago.',
            'Plain language.',
            'When we have to use a financial term, Her Cheat Sheet makes it simple and relatable.',
          ],
        ),
        _InfoCardData(
          stripeColor: HLGColors.crownGold,
          title: 'Grounded in reality.',
          titleColor: HLGColors.crownGold,
          bodyLines: [
            'We give you Her Tools: interactive calculators that use numbers you select, so the picture makes sense for your life.',
            'You will leave every lesson with clear takeaways so you can choose what you do next.',
          ],
        ),
        _InfoCardData(
          stripeColor: HLGColors.crownGold,
          title: 'Long game.',
          titleColor: HLGColors.crownGold,
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
      eyebrowColor: HLGColors.horizonOrange,
      heading: 'What this isn\'t.',
      items: const [
        _InfoCardData(
          stripeColor: HLGColors.horizonOrange,
          title: 'Not financial advice.',
          titleColor: HLGColors.horizonOrange,
          bodyLines: [
            'Advice tells you what to do today.',
            'Principles tell you how to think for the rest of your life.',
            'These ones are old enough to have been tested, and simple enough to explain to your daughter.',
            'That\'s why this is for the long game.',
          ],
          accentLineIndexes: {3},
        ),
        _InfoCardData(
          stripeColor: HLGColors.horizonOrange,
          title: 'Not a firehose.',
          titleColor: HLGColors.horizonOrange,
          bodyLines: [
            'If we thought you needed another degree, on top of your career, your relationships, your life, we wouldn\'t be here.',
            'We are cutting through the noise.',
            'The right foundations, in the right order, at a pace that fits in your real life.',
          ],
        ),
        _InfoCardData(
          stripeColor: HLGColors.horizonOrange,
          title: 'Not political.',
          titleColor: HLGColors.horizonOrange,
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
    final signatureAccentStyle = bodyStyle.copyWith(color: HLGColors.crownGold.withValues(alpha: 0.98), fontWeight: FontWeight.w700, fontStyle: FontStyle.italic);
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
                                            ? bodyStyle.copyWith(color: const Color(0xFFB8923A), fontStyle: FontStyle.italic)
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
            TextSpan(text: tools, style: signatureStyle),
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
