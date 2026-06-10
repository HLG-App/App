import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/utils/lesson_flow.dart';
import 'package:her_long_game/widgets/passed_on_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonClosePage extends StatefulWidget {
  const LessonClosePage({super.key, required this.lessonCode});

  final String lessonCode;

  @override
  State<LessonClosePage> createState() => _LessonClosePageState();
}

class _LessonClosePageState extends State<LessonClosePage> {
  bool _loading = true;
  String? _bullet1, _bullet2, _bullet3, _quote;
  String? _herNotesPrompt;
  String? _laResponse;
  String _noteText = '';
  String _passItOnText = '';
  bool _nameToggle = false;
  String? _firstName;
  String? _randomPrompt;

  static const String _takeawayPrompt = 'TAKEAWAY';
  final Set<String> _savedTakeaways = <String>{};
  bool _savingTakeaway = false;

  static const List<String> _passItOnPrompts = [
    'What do you wish you\'d known sooner?',
    'What would you tell her?',
    'What shifted for you in this lesson?',
    'What would you write on a note and leave somewhere?',
    'What do you wish was said more?',
  ];

  @override
  void initState() {
    super.initState();
    _randomPrompt = _passItOnPrompts[DateTime.now().millisecondsSinceEpoch % _passItOnPrompts.length];
    _loadCloseData();
  }

  Future<void> _loadCloseData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final screen = await Supabase.instance.client
          .from('lesson_screens')
          .select('carry_bullet_1, carry_bullet_2, carry_bullet_3, carry_quote, her_notes_prompt, display_name')
          .eq('lesson_code', widget.lessonCode)
          .eq('screen_type', 'complete')
          .maybeSingle();

      String? laResponse;
      if (widget.lessonCode == 'LA') {
        final progress = await Supabase.instance.client
            .from('lesson_progress')
            .select('s7_response')
            .eq('user_id', userId)
            .eq('lesson_code', 'LA')
            .maybeSingle();
        final raw = progress?['s7_response'];
        if (raw is String && raw.isNotEmpty) laResponse = raw;
        else if (raw is Map && raw.isNotEmpty) laResponse = raw.values.first?.toString();
      }

      if (!mounted) return;
      setState(() {
        _bullet1 = screen?['carry_bullet_1'];
        _bullet2 = screen?['carry_bullet_2'];
        _bullet3 = screen?['carry_bullet_3'];
        _quote = screen?['carry_quote'];
        _herNotesPrompt = screen?['her_notes_prompt'];
        _laResponse = laResponse;
        _loading = false;
      });

      await _loadSavedTakeaways(userId: userId);
    } catch (e) {
      debugPrint('[LessonClosePage] load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSavedTakeaways({required String userId}) async {
    try {
      final bullets = [_bullet1, _bullet2, _bullet3].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (bullets.isEmpty) return;
      final rows = await Supabase.instance.client
          .from('her_notes')
          .select('response')
          .eq('user_id', userId)
          .eq('lesson_code', widget.lessonCode)
          .eq('prompt', _takeawayPrompt);

      final saved = <String>{};
      for (final r in (rows as List)) {
        final v = r['response'];
        if (v is String && v.trim().isNotEmpty) saved.add(v.trim());
      }
      if (!mounted) return;
      setState(() {
        _savedTakeaways
          ..clear()
          ..addAll(saved);
      });
    } catch (e) {
      debugPrint('[LessonClosePage] Failed to load saved takeaways: $e');
    }
  }

  Future<void> _toggleTakeaway(String takeaway) async {
    final text = takeaway.trim();
    if (text.isEmpty) return;
    if (_savingTakeaway) return;

    setState(() => _savingTakeaway = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      if (_savedTakeaways.contains(text)) {
        await Supabase.instance.client
            .from('her_notes')
            .delete()
            .eq('user_id', userId)
            .eq('lesson_code', widget.lessonCode)
            .eq('prompt', _takeawayPrompt)
            .eq('response', text);
        if (!mounted) return;
        setState(() => _savedTakeaways.remove(text));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Removed from Her System'),
          backgroundColor: Color(0xFF5C7A62),
          duration: Duration(seconds: 2),
        ));
      } else {
        // Avoid duplicates in case of multi-tap or prior saves.
        final existing = await Supabase.instance.client
            .from('her_notes')
            .select('id')
            .eq('user_id', userId)
            .eq('lesson_code', widget.lessonCode)
            .eq('prompt', _takeawayPrompt)
            .eq('response', text)
            .maybeSingle();
        if (existing == null) {
          await Supabase.instance.client.from('her_notes').insert({
            'user_id': userId,
            'lesson_code': widget.lessonCode,
            'prompt': _takeawayPrompt,
            'response': text,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
        if (!mounted) return;
        setState(() => _savedTakeaways.add(text));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Saved to Her System'),
          backgroundColor: Color(0xFF5C7A62),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      debugPrint('[LessonClosePage] Toggle takeaway FAILED: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Save failed: $e'),
        backgroundColor: const Color(0xFFD4621A),
        duration: const Duration(seconds: 3),
      ));
    } finally {
      if (mounted) setState(() => _savingTakeaway = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F5F0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF5C7A62), strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLAResponse(),
                  _buildThreeThingsToCarry(),
                  _buildPassedOnWidget(),
                  _buildHerNotes(),
                  _buildPassItOn(),
                ],
              ),
            ),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildContinueButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildLAResponse() {
    if (widget.lessonCode != 'LA' || _laResponse == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You said that ${_laResponse!.toLowerCase().replaceAll(RegExp(r'\.$'), '')}. We\'ll come back to that.',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: const Color(0xFF5C7A62), height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(height: 1, color: const Color(0xFFB8923A)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildThreeThingsToCarry() {
    final bullets = [_bullet1, _bullet2, _bullet3].whereType<String>().toList();
    if (bullets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THREE THINGS TO CARRY',
          style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF8A9E8D), letterSpacing: 2.0),
        ),
        const SizedBox(height: 16),
        ...bullets.map((b) {
          final t = b.trim();
          final isSaved = _savedTakeaways.contains(t);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _savingTakeaway ? null : () => _toggleTakeaway(t),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        decoration: const BoxDecoration(color: Color(0xFFB8923A), shape: BoxShape.circle),
                      ),
                      Expanded(child: Text(b, style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF2A3A2C), height: 1.6))),
                      const SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                        child: Container(
                          key: ValueKey(isSaved),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: (isSaved ? const Color(0xFF5C7A62) : const Color(0xFFEDE0D4)).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF5C7A62).withValues(alpha: isSaved ? 0.0 : 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 16, color: isSaved ? const Color(0xFFF7F5F0) : const Color(0xFF5C7A62)),
                              const SizedBox(width: 6),
                              Text(
                                isSaved ? 'Saved' : 'Save',
                                style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: isSaved ? const Color(0xFFF7F5F0) : const Color(0xFF5C7A62)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_quote != null) ...[
          const SizedBox(height: 8),
          Text(_quote!, style: GoogleFonts.playfairDisplay(fontSize: 17, fontStyle: FontStyle.italic, color: const Color(0xFF5C7A62))),
        ],
        const SizedBox(height: 24),
        Container(height: 1, color: const Color(0xFFB8923A).withValues(alpha: 0.3)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPassedOnWidget() => PassedOnWidget(lessonCode: widget.lessonCode);

  Widget _buildHerNotes() {
    if (_herNotesPrompt == null) return const SizedBox.shrink();
    if (widget.lessonCode == 'L0') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text('HER NOTES', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: HLGColors.antiqueRose, letterSpacing: 2.0)),
        const SizedBox(height: 8),
        Text(_herNotesPrompt!, style: GoogleFonts.playfairDisplay(fontSize: 18, fontStyle: FontStyle.italic, color: const Color(0xFF5C7A62))),
        const SizedBox(height: 12),
        TextField(
          minLines: 3,
          maxLines: 6,
          onChanged: (v) => setState(() => _noteText = v),
          style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF2A3A2C)),
          decoration: InputDecoration(
            hintText: 'Write here...',
            hintStyle: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF8A9E8D), fontStyle: FontStyle.italic),
            filled: true,
            fillColor: const Color(0xFFEDE0D4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _noteText.trim().isEmpty ? null : _saveHerNote,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5C7A62), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
                child: Text('Save to Her Notes', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _saveHerNoteLater,
              child: Text('Write later', style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF8A9E8D))),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(height: 1, color: const Color(0xFFB8923A).withValues(alpha: 0.3)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPassItOn() {
    // "Pass it on" is a later-stage/community-style reflection. Keep it off the
    // early intro/toolkit completion experience.
    if (widget.lessonCode == 'L0' || widget.lessonCode == 'L0b' || widget.lessonCode == 'LA') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HER LONG GAME', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFFB8923A), letterSpacing: 2.0)),
        const SizedBox(height: 8),
        Text('Pass it on to her.', style: GoogleFonts.playfairDisplay(fontSize: 22, fontStyle: FontStyle.italic, color: const Color(0xFF161E17))),
        const SizedBox(height: 8),
        Text(
          _randomPrompt ?? _passItOnPrompts[0],
          style: GoogleFonts.dmSans(fontSize: 15, fontStyle: FontStyle.italic, color: const Color(0xFF8A9E8D)),
        ),
        const SizedBox(height: 12),
        TextField(
          minLines: 4,
          maxLines: null,
          onChanged: (v) => setState(() => _passItOnText = v),
          style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF2A3A2C)),
          decoration: InputDecoration(
            hintText: 'Write it here. In your own words.',
            hintStyle: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF8A9E8D), fontStyle: FontStyle.italic),
            filled: true,
            fillColor: const Color(0xFFEDE0D4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Switch(value: _nameToggle, onChanged: (v) => setState(() => _nameToggle = v), activeColor: const Color(0xFF5C7A62)),
            const SizedBox(width: 8),
            Text('Add your first name', style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF2A3A2C))),
            const Spacer(),
            FilledButton(
              onPressed: _passItOnText.trim().isEmpty ? null : _savePassItOn,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4621A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
              child: Text('Pass it on to her →', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (_nameToggle) ...[
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => setState(() => _firstName = v),
            style: GoogleFonts.dmSans(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Your first name',
              filled: true,
              fillColor: const Color(0xFFEDE0D4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      color: const Color(0xFFF7F5F0),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: _onContinue,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5C7A62), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
          child: Text('Continue →', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Future<void> _saveHerNote() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client.from('her_notes').insert({
        'user_id': userId,
        'lesson_code': widget.lessonCode,
        'prompt': _herNotesPrompt,
        'response': _noteText.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Note saved'),
        backgroundColor: Color(0xFF5C7A62),
        duration: Duration(seconds: 2),
      ));
      setState(() => _noteText = '');
    } catch (e) {
      debugPrint('[HerNotes] FAILED: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Save failed: $e'),
        backgroundColor: const Color(0xFFD4621A),
        duration: const Duration(seconds: 4),
      ));
    }
  }

  Future<void> _saveHerNoteLater() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client.from('her_notes').insert({
        'user_id': userId,
        'lesson_code': widget.lessonCode,
        'prompt': _herNotesPrompt,
        'response': null,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[HerNotes] write later FAILED: $e');
    }
  }

  Future<void> _savePassItOn() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final userRow = await Supabase.instance.client.from('users').select('emotional_baseline').eq('id', userId).maybeSingle();
      await Supabase.instance.client.from('passed_on').insert({
        'lesson_code': widget.lessonCode,
        'insight_text': _passItOnText.trim(),
        'first_name': _nameToggle ? (_firstName?.trim()) : null,
        'emotional_baseline': userRow?['emotional_baseline'],
        'approved': true,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Passed on.'),
        backgroundColor: Color(0xFF5C7A62),
        duration: Duration(seconds: 2),
      ));
      setState(() {
        _passItOnText = '';
        _nameToggle = false;
        _firstName = null;
      });
    } catch (e) {
      debugPrint('[PassItOn] FAILED: $e');
    }
  }

  void _onContinue() {
    final nextRoute = LessonFlow.nextRouteAfterClose(widget.lessonCode);
    context.go(nextRoute);
  }
}
