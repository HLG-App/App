import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';

class PassedOnWidget extends StatefulWidget {
  const PassedOnWidget({super.key, required this.lessonCode});

  final String lessonCode;

  @override
  State<PassedOnWidget> createState() => _PassedOnWidgetState();
}

class _PassedOnWidgetState extends State<PassedOnWidget> {
  bool _isLoading = true;
  String? _error;
  List<_PassedOnInsight> _insights = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PassedOnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonCode != widget.lessonCode) _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _insights = const [];
    });

    try {
      final rows = await SupabaseConfig.client
          .from('passed_on')
          .select('insight_text, first_name, created_at')
          .eq('lesson_code', widget.lessonCode)
          .eq('approved', true)
          .order('created_at', ascending: false)
          .limit(20);

      final list = (rows as List)
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .map(_PassedOnInsight.fromJson)
          .where((e) => e.insightText.trim().isNotEmpty)
          .toList();

      final selected = _pickRandom3(list);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _insights = selected;
      });
    } catch (e) {
      debugPrint('[PassedOnWidget] Failed to load insights: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load.';
      });
    }
  }

  static List<_PassedOnInsight> _pickRandom3(List<_PassedOnInsight> all) {
    if (all.isEmpty) return const [];
    final rng = Random();
    final pool = List<_PassedOnInsight>.from(all);
    pool.shuffle(rng);
    return pool.take(min(3, pool.length)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if ((_error ?? '').trim().isNotEmpty) return const SizedBox.shrink();
    if (_insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT OTHER WOMEN SAID AFTER THIS LESSON',
          style: HLGTextStyles.eyebrowAllCaps(color: HLGColors.sageMid).copyWith(letterSpacing: 2.0),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final insight in _insights) ...[
          _PassedOnCard(insight: insight),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _PassedOnCard extends StatelessWidget {
  const _PassedOnCard({required this.insight});

  final _PassedOnInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.35)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, decoration: const BoxDecoration(color: HLGColors.antiqueRose, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.insightText,
                      style: HLGTextStyles.quoteItalic(color: HLGColors.deepSage).copyWith(fontSize: 17),
                    ),
                    if ((insight.firstName ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '– ${insight.firstName!.trim()}',
                          style: HLGTextStyles.labelMedium(color: HLGColors.sageMid).copyWith(fontSize: 12),
                        ),
                      ),
                    ],
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

class _PassedOnInsight {
  const _PassedOnInsight({required this.insightText, this.firstName});

  final String insightText;
  final String? firstName;

  factory _PassedOnInsight.fromJson(Map<String, dynamic> json) => _PassedOnInsight(
        insightText: (json['insight_text'] ?? '').toString(),
        firstName: (json['first_name'] as Object?)?.toString(),
      );
}
