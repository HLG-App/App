import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/data/lesson_names.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

/// HerBookmarks (pillar)
///
/// A lightweight placeholder module introduced by “Her System”.
///
/// IMPORTANT: This does not remove or change any existing features. It is a
/// navigation + classification surface only.
class HerBookmarksPage extends StatelessWidget {
  const HerBookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HerBookmarksBody();
  }
}

class _HerBookmarksBody extends StatefulWidget {
  const _HerBookmarksBody();

  @override
  State<_HerBookmarksBody> createState() => _HerBookmarksBodyState();
}

class _HerBookmarksBodyState extends State<_HerBookmarksBody> {
  static const String _takeawayPrompt = 'TAKEAWAY';

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _items = const [];
          _error = 'Please sign in to view your saved takeaways.';
        });
        return;
      }

      final rows = await SupabaseConfig.client
          .from('her_notes')
          .select('id, lesson_code, response, created_at')
          .eq('user_id', uid)
          .eq('prompt', _takeawayPrompt)
          .order('created_at', ascending: false);

      setState(() => _items = (rows as List).cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('[HerBookmarksPage] Failed to load takeaways: $e');
      setState(() => _error = 'Could not load your saved takeaways.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;
    try {
      await SupabaseConfig.client.from('her_notes').delete().eq('id', id);
      if (!mounted) return;
      setState(() => _items = _items.where((e) => e['id'] != id).toList(growable: false));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Removed'),
        backgroundColor: HLGColors.deepSage,
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      debugPrint('[HerBookmarksPage] Delete FAILED: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not remove. Please try again.'),
        backgroundColor: HLGColors.horizonOrange,
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/system',
        title: Text('Her Bookmarks', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? _BookmarksError(message: _error!, onRetry: _load)
                : (_items.isEmpty)
                    ? const _BookmarksEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _TakeawayCard(item: _items[index], onRemove: () => _delete(_items[index])),
                      ),
      ),
    );
  }
}

class _TakeawayCard extends StatelessWidget {
  const _TakeawayCard({required this.item, required this.onRemove});

  final Map<String, dynamic> item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final lessonCode = (item['lesson_code'] ?? '').toString();
    final response = (item['response'] ?? '').toString().trim();
    final micro = lessonMicroLabels[lessonCode] ?? lessonCode;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: HLGColors.sagePale, borderRadius: BorderRadius.circular(999)),
                child: Text(micro, style: HLGTextStyles.labelMedium(color: HLGColors.deepSage)),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: HLGColors.textMuted),
                tooltip: 'Remove',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(response, style: HLGTextStyles.body(color: HLGColors.textBody).copyWith(height: 1.55)),
        ],
      ),
    );
  }
}

class _BookmarksEmptyState extends StatelessWidget {
  const _BookmarksEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: HLGColors.petal,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: HLGColors.sageMid.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: HLGColors.sagePale,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bookmark_border, color: HLGColors.deepSage),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('A place to keep what you want to return to.', style: HLGTextStyles.body(color: HLGColors.textBody))),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'When something lands, tap “Save” on the Carry This screen and it will appear here.',
              style: HLGTextStyles.homeBody14(color: HLGColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarksError extends StatelessWidget {
  const _BookmarksError({required this.message, required this.onRetry});

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
            style: FilledButton.styleFrom(
              backgroundColor: HLGColors.deepSage,
              foregroundColor: HLGColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Try again', style: HLGTextStyles.labelMedium(color: HLGColors.white)),
          ),
        ],
      ),
    );
  }
}
