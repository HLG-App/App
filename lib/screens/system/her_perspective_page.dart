import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

/// Her Perspective (pillar)
///
/// A community feed of “passed on” notes from other users.
///
/// This is intentionally *separate* from Wisdom. Wisdom remains a curated content
/// area; Her Perspective is lived experience.
class HerPerspectivePage extends StatefulWidget {
  const HerPerspectivePage({super.key});

  @override
  State<HerPerspectivePage> createState() => _HerPerspectivePageState();
}

class _HerPerspectivePageState extends State<HerPerspectivePage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _rows = const [];
    });

    try {
      // Community content is de-identified; still require auth so the rest of the
      // app’s expectations remain consistent.
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _isLoading = false;
          _error = 'Please sign in to view Her Perspective.';
        });
        return;
      }

      final rows = await SupabaseConfig.client
          .from('passed_on')
          .select('lesson_code, insight_text, first_name, created_at')
          .eq('approved', true)
          .order('created_at', ascending: false)
          .limit(80);

      setState(() {
        _isLoading = false;
        // ignore: unnecessary_type_check
        _rows = (rows is List) ? rows.cast<Map<String, dynamic>>() : const [];
      });
    } catch (e) {
      debugPrint('[HerPerspectivePage] load FAILED: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load community notes right now.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/system',
        title: Text('Her Perspective', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: HLGColors.deepSage))
            : (_error != null)
                ? _PerspectiveError(message: _error!, onRetry: _load)
                : (_rows.isEmpty)
                    ? const _PerspectiveEmpty()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          const _PerspectiveIntro(),
                          const SizedBox(height: 14),
                          ..._buildCards(_rows),
                        ],
                      ),
      ),
    );
  }

  List<Widget> _buildCards(List<Map<String, dynamic>> rows) {
    final rng = Random();
    final cards = <Widget>[];
    for (final r in rows) {
      final text = (r['insight_text'] ?? '').toString().trim();
      if (text.isEmpty) continue;
      final firstName = (r['first_name'] ?? '').toString().trim();
      final lesson = (r['lesson_code'] ?? '').toString().trim();
      cards.add(_PerspectiveCard(
        text: text,
        firstName: firstName.isEmpty ? null : firstName,
        lessonCode: lesson.isEmpty ? null : lesson,
        tint: rng.nextBool() ? HLGColors.petal : HLGColors.sagePale,
      ));
      cards.add(const SizedBox(height: 12));
    }
    return cards;
  }
}

class _PerspectiveIntro extends StatelessWidget {
  const _PerspectiveIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: HLGColors.sagePale,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(color: HLGColors.warmCream, borderRadius: BorderRadius.circular(14), border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.25))),
            child: const Icon(Icons.people_outline_rounded, color: HLGColors.deepSage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notes women chose to pass on', style: HLGTextStyles.moduleTitle(color: HLGColors.night)),
                const SizedBox(height: 4),
                Text('Shared reflections, lessons, and lived experience – in their own words.', style: HLGTextStyles.homeBody14(color: HLGColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerspectiveCard extends StatelessWidget {
  const _PerspectiveCard({required this.text, required this.firstName, required this.lessonCode, required this.tint});

  final String text;
  final String? firstName;
  final String? lessonCode;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((lessonCode ?? '').trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: HLGColors.warmCream, borderRadius: BorderRadius.circular(999), border: Border.all(color: HLGColors.crownGold.withValues(alpha: 0.45))),
              child: Text('After $lessonCode', style: HLGTextStyles.labelMedium(color: HLGColors.deepSage)),
            ),
          if ((lessonCode ?? '').trim().isNotEmpty) const SizedBox(height: 10),
          Text(
            text,
            style: GoogleFonts.playfairDisplay(fontSize: 17, fontStyle: FontStyle.italic, color: HLGColors.deepSage, height: 1.6),
          ),
          if ((firstName ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text('– ${firstName!.trim()}', style: HLGTextStyles.labelMedium(color: HLGColors.midSage)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerspectiveEmpty extends StatelessWidget {
  const _PerspectiveEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(color: HLGColors.petal, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.35))),
        child: Row(
          children: [
            Container(height: 40, width: 40, decoration: BoxDecoration(color: HLGColors.sagePale, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.forum_outlined, color: HLGColors.deepSage)),
            const SizedBox(width: 12),
            Expanded(child: Text('No community notes yet. After lessons, women can choose to “pass it on”.', style: HLGTextStyles.body(color: HLGColors.textBody))),
          ],
        ),
      ),
    );
  }
}

class _PerspectiveError extends StatelessWidget {
  const _PerspectiveError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: HLGTextStyles.body(color: HLGColors.textBody), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: HLGColors.deepSage, foregroundColor: HLGColors.white),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
