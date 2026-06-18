import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/data/lesson_names.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

class HerNotesPage extends StatefulWidget {
  const HerNotesPage({super.key});

  @override
  State<HerNotesPage> createState() => _HerNotesPageState();
}

class _HerNotesPageState extends State<HerNotesPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _notes = const [];

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
          _notes = const [];
          _error = 'Please sign in to view your notes.';
        });
        return;
      }

      final rows = await SupabaseConfig.client
          .from('her_notes')
          .select('id, lesson_code, prompt, response, created_at')
          .eq('user_id', uid)
          // Takeaways saved from “Carry this” live in Her System (Bookmarks), not Her Notes.
          .neq('prompt', 'TAKEAWAY')
          // Goal summaries are rendered in Her Direction.
          .neq('prompt', 'GOAL_SUMMARY')
          .order('created_at', ascending: false);

      setState(() => _notes = (rows as List).cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('[HerNotesPage] Failed to load her_notes: $e');
      setState(() => _error = 'Failed to load your notes. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveResponse({required Map<String, dynamic> note, required String newValue}) async {
    final id = note['id'];
    if (id == null) {
      debugPrint('[HerNotesPage] Cannot update note without id column. note=$note');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit this note (missing id).')),
      );
      return;
    }

    try {
      await SupabaseConfig.client.from('her_notes').update({'response': newValue.trim()}).eq('id', id);
      final idx = _notes.indexOf(note);
      if (idx >= 0) {
        final updated = Map<String, dynamic>.from(note);
        updated['response'] = newValue.trim();
        setState(() {
          final copy = [..._notes];
          copy[idx] = updated;
          _notes = copy;
        });
      }
    } catch (e) {
      debugPrint('[HerNotesPage] Failed to update her_note response: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HLGColors.warmCream,
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/profile',
        backgroundColor: HLGColors.warmCream,
        surfaceTintColor: Colors.transparent,
        title: Text('Her Notes', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? _NotesErrorState(message: _error!, onRetry: _load)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: _notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => HerNoteCard(
                      note: _notes[index],
                      onSave: (v) => _saveResponse(note: _notes[index], newValue: v),
                    ),
                  ),
      ),
    );
  }
}

class HerNoteCard extends StatefulWidget {
  const HerNoteCard({super.key, required this.note, required this.onSave});

  final Map<String, dynamic> note;
  final ValueChanged<String> onSave;

  @override
  State<HerNoteCard> createState() => _HerNoteCardState();
}

class _HerNoteCardState extends State<HerNoteCard> {
  bool _isEditing = false;
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: (widget.note['response'] as String?)?.trim() ?? '');
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus && _isEditing) {
        _finishEditing(save: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    Future.microtask(() => _focus.requestFocus());
  }

  void _finishEditing({required bool save}) {
    final text = _controller.text;
    setState(() => _isEditing = false);
    if (save) widget.onSave(text);
  }

  @override
  Widget build(BuildContext context) {
    final lessonCode = (widget.note['lesson_code'] ?? '').toString();
    final microLabel = lessonMicroLabels[lessonCode];
    final prompt = (widget.note['prompt'] ?? '').toString();
    final response = (widget.note['response'] as String?)?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HLGColors.midSage.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (microLabel != null && microLabel.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: HLGColors.horizonOrange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(microLabel, style: HLGTextStyles.labelMedium(color: HLGColors.white)),
                ),
              const Spacer(),
              if (!_isEditing)
                TextButton(
                  onPressed: _startEditing,
                  style: TextButton.styleFrom(
                    foregroundColor: HLGColors.deepSage,
                    textStyle: HLGTextStyles.labelMedium(color: HLGColors.deepSage),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Edit'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(prompt, style: HLGTextStyles.quoteItalic(color: HLGColors.deepSage)),
          const SizedBox(height: 10),
          if (_isEditing)
            TextField(
              controller: _controller,
              focusNode: _focus,
              minLines: 2,
              maxLines: 6,
              style: HLGTextStyles.body(color: HLGColors.textBody),
              decoration: InputDecoration(
                filled: true,
                fillColor: HLGColors.warmCream,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: HLGColors.midSage.withValues(alpha: 0.55)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: HLGColors.deepSage, width: 1.2),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _finishEditing(save: true),
            )
          else
            GestureDetector(
              onTap: _startEditing,
              behavior: HitTestBehavior.opaque,
              child: Text(
                (response == null || response.isEmpty) ? 'Not written yet' : response,
                style: (response == null || response.isEmpty)
                    ? HLGTextStyles.body(color: HLGColors.midSage).copyWith(fontStyle: FontStyle.italic)
                    : HLGTextStyles.body(color: HLGColors.textBody),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesErrorState extends StatelessWidget {
  const _NotesErrorState({required this.message, required this.onRetry});

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
