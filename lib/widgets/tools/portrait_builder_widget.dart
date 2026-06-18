import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:her_long_game/supabase/supabase_config.dart';

class PortraitBuilderWidget extends StatefulWidget {
  final Function(Map<String, dynamic> outputs) onSave;
  final Function(String goalLabel) onAddGoal;

  const PortraitBuilderWidget({
    Key? key,
    required this.onSave,
    required this.onAddGoal,
  }) : super(key: key);

  @override
  State<PortraitBuilderWidget> createState() => _PortraitBuilderWidgetState();
}

class _PortraitBuilderWidgetState extends State<PortraitBuilderWidget> {
  static const Color deepSage = Color(0xFF5C7A62);
  static const Color sagePale = Color(0xFFD4E0D6);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = deepSage;
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color petal = Color(0xFFF2EFE8);
  static const Color textBody = midSage;

  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());
  bool _generating = false;
  String? _generatedPortrait;
  int? _monthlyTarget;
  String? _errorMessage;

  static const List<Map<String, String>> _questions = [
    {
      'q': 'Where do you want to live?',
      'hint': 'A specific place, or a feeling about a place...',
      'key': 'q1',
    },
    {
      'q': 'What does a good week look like?',
      'hint': 'What are you doing, who are you with, how do you feel...',
      'key': 'q2',
    },
    {
      'q': 'What do you want to be able to do that you can\'t do now?',
      'hint': 'Travel, stop working, help someone, create something...',
      'key': 'q3',
    },
    {
      'q': 'What do you want to stop doing?',
      'hint': 'Worrying about money, working weekends, saying no to things...',
      'key': 'q4',
    },
    {
      'q': 'What does financial safety feel like to you?',
      'hint': 'A feeling, a number, a situation...',
      'key': 'q5',
    },
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _generatePortrait() async {
    setState(() {
      _generating = true;
      _errorMessage = null;
    });

    try {
      final answers = _questions.asMap().entries.map((e) => '${e.value['q']}: ${_controllers[e.key].text}').join('\n');
      debugPrint('[PortraitBuilder] Generating portrait...');
      debugPrint('[PortraitBuilder] Answers:\n$answers');

      final response = await http.post(
        Uri.parse('${SupabaseConfig.supabaseUrl}/functions/v1/generate_portrait'),
        headers: {
          'Authorization': 'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q1': _controllers[0].text,
          'q2': _controllers[1].text,
          'q3': _controllers[2].text,
          'q4': _controllers[3].text,
          'q5': _controllers[4].text,
        }),
      );

      debugPrint('[PortraitBuilder] status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _generatedPortrait = data['portrait_text'];
          _monthlyTarget = data['monthly_target_estimate'];
          _generating = false;
        });

        await widget.onSave({
          'q1': _controllers[0].text,
          'q2': _controllers[1].text,
          'q3': _controllers[2].text,
          'q4': _controllers[3].text,
          'q5': _controllers[4].text,
          'portrait_text': _generatedPortrait,
          'monthly_target': _monthlyTarget,
        });
      } else {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
          _generating = false;
        });
      }
    } catch (e) {
      debugPrint('[PortraitBuilder] FAILED: $e');
      setState(() {
        _errorMessage = 'Connection error. Please try again.';
        _generating = false;
      });
    }
  }

  bool get _allAnswered => _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (_generatedPortrait != null) return _buildPortraitResult();
    return _buildQuestions();
  }

  Widget _buildQuestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildProgressDots(),
          const SizedBox(height: 24),
          ..._questions.asMap().entries.map((e) => _buildQuestion(e.key, e.value)),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Text(_errorMessage!, style: GoogleFonts.dmSans(fontSize: 13, color: horizonOrange)),
            const SizedBox(height: 12),
          ],
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Five questions. One portrait.', style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night)),
        const SizedBox(height: 6),
        Text('Your answers become the reason behind every number in this app.', style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(
        5,
        (i) => Container(
          margin: const EdgeInsets.only(right: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _controllers[i].text.isNotEmpty ? deepSage : sagePale,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(int index, Map<String, String> q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${index + 1}. ${q['q']}', style: GoogleFonts.playfairDisplay(fontSize: 17, fontStyle: FontStyle.italic, color: deepSage)),
          const SizedBox(height: 8),
          TextField(
            controller: _controllers[index],
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.dmSans(fontSize: 15, color: textBody),
            decoration: InputDecoration(
              hintText: q['hint'],
              hintStyle: GoogleFonts.dmSans(fontSize: 14, color: midSage, fontStyle: FontStyle.italic),
              filled: true,
              fillColor: petal,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _allAnswered && !_generating ? _generatePortrait : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: horizonOrange,
          disabledBackgroundColor: sagePale,
          foregroundColor: warmCream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: _generating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text('Building your portrait...', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              )
            : Text(
                _allAnswered ? 'Build my portrait →' : 'Answer all five questions to continue',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildPortraitResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR PORTRAIT', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 2)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: night,
              borderRadius: BorderRadius.circular(16),
              border: const Border(top: BorderSide(color: Color(0xFFB8923A), width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _generatedPortrait ?? '',
                  style: GoogleFonts.playfairDisplay(fontSize: 18, fontStyle: FontStyle.italic, color: warmCream, height: 1.7),
                ),
                if (_monthlyTarget != null) ...[
                  const SizedBox(height: 20),
                  Container(height: 1, color: crownGold.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('YOUR TARGET', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('\$$_monthlyTarget/month', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700, color: crownGold)),
                  Text('to live the life you described', style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'This portrait lives on your Goal Dashboard. Every time you open the app, you\'ll see the life you\'re building toward.',
            style: GoogleFonts.dmSans(fontSize: 14, color: midSage, height: 1.6),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => widget.onAddGoal('Live the life in my portrait – \$$_monthlyTarget/month'),
              style: ElevatedButton.styleFrom(
                backgroundColor: deepSage,
                foregroundColor: warmCream,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Add to my goals', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => setState(() {
                _generatedPortrait = null;
                _monthlyTarget = null;
              }),
              style: OutlinedButton.styleFrom(
                foregroundColor: deepSage,
                side: const BorderSide(color: deepSage, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Regenerate portrait', style: GoogleFonts.dmSans(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
