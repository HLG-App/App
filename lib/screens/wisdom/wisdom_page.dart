import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/founder_note_card.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/principles_card.dart';
import 'package:url_launcher/url_launcher.dart';

class WisdomPage extends StatefulWidget {
  const WisdomPage({super.key});

  @override
  State<WisdomPage> createState() => _WisdomPageState();
}

class _WisdomPageState extends State<WisdomPage> {
  bool _isLoading = true;
  String? _myBaseline;
  List<Map<String, dynamic>> _allInsights = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _myBaseline = null;
      _allInsights = const [];
    });

    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final userRow = await SupabaseConfig.client
          .from('users')
          .select('emotional_baseline')
          .eq('id', uid)
          .maybeSingle();
      final String? myBaseline = userRow?['emotional_baseline'];

      final allInsights = await SupabaseConfig.client
          .from('passed_on')
          .select('lesson_code, insight_text, first_name, emotional_baseline')
          .eq('approved', true)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _myBaseline = (myBaseline ?? '').trim().isEmpty ? null : myBaseline;
        // ignore: unnecessary_type_check
        _allInsights = (allInsights is List)
            ? allInsights.cast<Map<String, dynamic>>()
            : const <Map<String, dynamic>>[];
      });
    } catch (e) {
      debugPrint('[WisdomPage] Failed to load wisdom: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _myBaseline = null;
        _allInsights = const [];
      });
    }
  }

  String _baselineFirstWord(String baseline) {
    final cleaned = baseline.trim();
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(RegExp(r'[\s–-]+'));
    return (parts.isEmpty ? cleaned : parts.first).toLowerCase();
  }

  List<Map<String, dynamic>> _matchingBaselineInsights({required String baseline}) {
    return _allInsights
        .where((m) => (m['emotional_baseline'] ?? '').toString().trim() == baseline.trim())
        .toList(growable: false);
  }

  static const Map<String, List<String>> _moduleLessonCodes = {
    'Pre-Course': ['L0', 'LA'],
    'Module 1': ['L1', 'L1b', 'LB', 'L2', 'CK1'],
    'Module 2': ['L3', 'L4', 'LD', 'LE', 'CK2'],
    'Module 3': ['L5', 'L6', 'L7', 'L7b', 'LC', 'LF', 'CK3'],
    'Module 4': ['L8', 'L8a', 'L9', 'L10', 'CK4'],
  };

  List<Map<String, dynamic>> _insightsForModule(List<String> lessonCodes) {
    final set = lessonCodes.toSet();
    final filtered = _allInsights.where((m) => set.contains((m['lesson_code'] ?? '').toString())).toList(growable: false);
    if (filtered.isEmpty) return const [];
    return filtered.take(2).toList(growable: false);
  }

  Future<void> _openUrl(String url) async {
    try {
      final trimmed = url.trim();
      final uri = Uri.parse(trimmed);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[WisdomPage] Failed to launch url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseline = _myBaseline;
    final matching = (baseline == null) ? const <Map<String, dynamic>>[] : _matchingBaselineInsights(baseline: baseline);
    final List<Map<String, dynamic>> section1 = () {
      if (baseline == null || matching.isEmpty) return const <Map<String, dynamic>>[];
      final shuffled = [...matching];
      shuffled.shuffle(Random());
      return shuffled.take(3).toList(growable: false);
    }();

    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(title: Text('Wisdom', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)), actions: const [HerLogoutIconButton()]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          'Her ',
                          style: GoogleFonts.playfairDisplay(fontSize: 22, fontStyle: FontStyle.italic, color: HLGColors.horizonOrange),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            'Long Game',
                            style: GoogleFonts.dmSans(fontSize: 11, color: HLGColors.night, letterSpacing: 6.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Wisdom',
                      style: GoogleFonts.playfairDisplay(fontSize: 32, fontStyle: FontStyle.italic, color: HLGColors.night),
                    ),
                    Container(
                      height: 4,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      color: HLGColors.crownGold,
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator(color: HLGColors.deepSage)),
                ),

              if (!_isLoading) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const FounderNoteCard(),
                        const SizedBox(height: 24),
                        const PrinciplesCard(),
                        const SizedBox(height: 16),
                    ],
                  ),
                ),
                // SECTION 1
                if (section1.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FROM WOMEN WHO STARTED WHERE YOU DID',
                          style: GoogleFonts.dmSans(fontSize: 9, letterSpacing: 6.0, color: HLGColors.crownGold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Women who felt ${_baselineFirstWord(baseline!)} – and kept going.',
                          style: GoogleFonts.dmSans(fontSize: 14, fontStyle: FontStyle.italic, color: HLGColors.midSage),
                        ),
                        const SizedBox(height: 16),
                        for (final insight in section1) ...[
                          _BaselineInsightCard(
                            text: (insight['insight_text'] ?? '').toString(),
                            firstName: (insight['first_name'] ?? '').toString().trim().isEmpty ? null : (insight['first_name'] ?? '').toString().trim(),
                          ),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],

                // SECTION 2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHAT WOMEN ARE SAYING',
                        style: GoogleFonts.dmSans(fontSize: 9, letterSpacing: 6.0, color: HLGColors.midSage),
                      ),
                      const SizedBox(height: 8),
                      for (final entry in _moduleLessonCodes.entries) ...[
                        ...() {
                          final insights = _insightsForModule(entry.value);
                          if (insights.isEmpty) return const <Widget>[];
                          return <Widget>[
                            Text(
                              entry.key,
                              style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: HLGColors.night),
                            ),
                            const SizedBox(height: 8),
                            for (final insight in insights) ...[
                              _ModuleInsightCard(
                                text: (insight['insight_text'] ?? '').toString(),
                                firstName: (insight['first_name'] ?? '').toString().trim().isEmpty ? null : (insight['first_name'] ?? '').toString().trim(),
                              ),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 16),
                          ];
                        }(),
                      ],
                    ],
                  ),
                ),

                // SECTION 3
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WORTH READING',
                        style: GoogleFonts.dmSans(fontSize: 9, letterSpacing: 6.0, color: HLGColors.midSage),
                      ),
                      const SizedBox(height: 8),
                      _ReadingCard(
                        title: 'The Psychology of Money',
                        author: 'Morgan Housel',
                        description: 'The best book on how humans actually behave with money. Warm, readable, no jargon.',
                        url: 'https://www.morganhousel.com/the-psychology-of-money',
                        onTap: _openUrl,
                      ),
                      const SizedBox(height: 8),
                      _ReadingCard(
                        title: 'wtfhappenedin1971.com',
                        author: 'Anonymous',
                        description: 'Every chart that broke in 1971, documented. Read after L1b.',
                        url: 'https://wtfhappenedin1971.com',
                        onTap: _openUrl,
                      ),
                      const SizedBox(height: 8),
                      _ReadingCard(
                        title: 'SPIVA Australia Scorecard',
                        author: 'S&P Dow Jones Indices',
                        description: 'The data behind why index funds beat active managers. Read after L9.',
                        url: 'https://spglobal.com/spdji/en/spiva/article/spiva-australia',
                        onTap: _openUrl,
                      ),
                      const SizedBox(height: 8),
                      _ReadingCard(
                        title: 'WGEA Gender Pay Gap Data',
                        author: 'Workplace Gender Equality Agency',
                        description: "Your industry's pay gap, by occupation. Read after L4.",
                        url: 'https://wgea.gov.au/data-statistics/gender-pay-gap-data ',
                        onTap: _openUrl,
                      ),
                      const SizedBox(height: 8),
                      _ReadingCard(
                        title: 'RBA Inflation Calculator',
                        author: 'Reserve Bank of Australia',
                        description: 'See exactly what \$100 from any year is worth today. Read after L3.',
                        url: 'https://rba.gov.au/calculator ',
                        onTap: _openUrl,
                      ),
                      const SizedBox(height: 8),
                      _ReadingCard(
                        title: 'Bitcoin Whitepaper',
                        author: 'Satoshi Nakamoto',
                        description: 'The original 9-page document. Shorter than you think. Read after L10.',
                        url: 'https://bitcoin.org/bitcoin.pdf ',
                        onTap: _openUrl,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BaselineInsightCard extends StatelessWidget {
  const _BaselineInsightCard({required this.text, required this.firstName});

  final String text;
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: HLGColors.crownGold, width: 4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.playfairDisplay(fontSize: 16, fontStyle: FontStyle.italic, color: HLGColors.deepSage, height: 1.6),
          ),
          if ((firstName ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '– ${firstName!.trim()}',
                style: GoogleFonts.dmSans(fontSize: 12, color: HLGColors.midSage),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModuleInsightCard extends StatelessWidget {
  const _ModuleInsightCard({required this.text, required this.firstName});

  final String text;
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HLGColors.warmCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.6), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.dmSans(fontSize: 14, color: HLGColors.textBody, height: 1.6),
          ),
          if ((firstName ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '– ${firstName!.trim()}',
                style: GoogleFonts.dmSans(fontSize: 11, color: HLGColors.midSage),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.title, required this.author, required this.description, required this.url, required this.onTap});

  final String title;
  final String author;
  final String description;
  final String url;
  final Future<void> Function(String url) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: HLGColors.warmCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HLGColors.crownGold.withValues(alpha: 0.65), width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: HLGColors.night),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: GoogleFonts.dmSans(fontSize: 11, color: HLGColors.midSage),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.dmSans(fontSize: 13, fontStyle: FontStyle.italic, color: HLGColors.textBody, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: HLGColors.midSage.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}
