import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:her_long_game/theme.dart';

class NowPage extends StatefulWidget {
  const NowPage({super.key});

  @override
  State<NowPage> createState() => _NowPageState();
}

class _NowPageState extends State<NowPage> {
  static const Color deepSage = HLGColors.deepSage;
  static Color get sagePale => HLGColors.sagePale;
  static const Color crownGold = HLGColors.crownGold;
  static const Color warmCream = HLGColors.warmCream;
  static const Color night = HLGColors.night;
  static const Color horizonOrange = HLGColors.horizonOrange;
  static const Color midSage = HLGColors.midSage;
  static Color get petal => HLGColors.petal;
  static const Color textBody = HLGColors.textBody;

  List<Map<String, dynamic>> _weeklyGoals = [];
  List<Map<String, dynamic>> _longtermGoals = [];
  bool _loading = true;
  bool _showArchived = false;
  List<Map<String, dynamic>> _archivedGoals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }


  Future<void> _loadGoals() async {
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      final rows = await Supabase.instance.client
          .from('goals')
          .select()
          .eq('user_id', userId)
          .isFilter('archived_at', null)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);

      final archived = await Supabase.instance.client
          .from('goals')
          .select()
          .eq('user_id', userId)
          .not('archived_at', 'is', null)
          .order('archived_at', ascending: false)
          .limit(10);

      final castRows = (rows as List).cast<Map<String, dynamic>>();
      setState(() {
        _weeklyGoals = castRows.where((g) => g['goal_type'] == 'weekly').toList();
        _longtermGoals = castRows
            .where((g) => g['goal_type'] == 'longterm' || (g['goal_type'] == null || g['goal_type'] == ''))
            .toList();
        _archivedGoals = (archived as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      debugPrint('[NowPage] load error: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleComplete(Map<String, dynamic> goal) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final isComplete = goal['completed_at'] != null;
    await Supabase.instance.client
        .from('goals')
        .update({'completed_at': isComplete ? null : DateTime.now().toIso8601String()})
        .eq('id', goal['id'])
        .eq('user_id', userId);
    _loadGoals();
  }

  Future<void> _archiveGoal(Map<String, dynamic> goal) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client
        .from('goals')
        .update({'archived_at': DateTime.now().toIso8601String()})
        .eq('id', goal['id'])
        .eq('user_id', userId);
    _loadGoals();
  }

  Future<void> _addGoal({required String type}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final controller = TextEditingController();
    DateTime? targetDate;
    double? targetAmount;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: warmCream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: midSage.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                type == 'weekly' ? 'Add a this week goal' : 'Add a long game goal',
                style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night),
              ),
              if (type == 'weekly')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Something specific. Completable this week.',
                    style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                style: GoogleFonts.dmSans(fontSize: 15, color: textBody),
                decoration: InputDecoration(
                  hintText: type == 'weekly'
                      ? 'e.g. Log into myGov and find my super accounts'
                      : r'e.g. Build a $3,000 emergency fund by October',
                  hintStyle: GoogleFonts.dmSans(fontSize: 14, color: midSage, fontStyle: FontStyle.italic),
                  filled: true,
                  fillColor: petal,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              if (type == 'longterm') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 90)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (picked != null) setModalState(() => targetDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: petal, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            targetDate == null
                                ? 'Target date (optional)'
                                : '${targetDate!.day}/${targetDate!.month}/${targetDate!.year}',
                            style: GoogleFonts.dmSans(fontSize: 13, color: targetDate == null ? midSage : textBody),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    await Supabase.instance.client.from('goals').insert({
                      'user_id': userId,
                      'goal_code': '${type}_${DateTime.now().millisecondsSinceEpoch}',
                      'label': controller.text.trim(),
                      'goal_type': type,
                      'target_date': targetDate?.toIso8601String(),
                      'target_amount': targetAmount,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                    if (context.mounted) context.pop();
                    _loadGoals();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepSage,
                    foregroundColor: warmCream,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Add goal', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: HLGColors.warmCream,
        body: Center(
          child: CircularProgressIndicator(color: HLGColors.deepSage, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: warmCream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadGoals,
          color: deepSage,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildWeeklySection(),
                const SizedBox(height: 32),
                _buildLongtermSection(),
                if (_archivedGoals.isNotEmpty) ...[const SizedBox(height: 32), _buildArchivedSection()],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Her ',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: horizonOrange,
              ),
            ),
            Text(
              'LONG GAME',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: night,
                letterSpacing: 3.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Now.', style: GoogleFonts.playfairDisplay(fontSize: 32, fontStyle: FontStyle.italic, color: night)),
        const SizedBox(height: 4),
        Text(
          'What you\'re doing – not just what you\'re learning.',
          style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: crownGold.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildWeeklySection() {
    final activeWeekly = _weeklyGoals.where((g) => g['completed_at'] == null).toList();
    final completedWeekly = _weeklyGoals.where((g) => g['completed_at'] != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THIS WEEK', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: horizonOrange, letterSpacing: 2)),
                  Text('Small. Specific. This week.', style: GoogleFonts.dmSans(fontSize: 12, color: midSage, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            if (activeWeekly.length < 3)
              TextButton.icon(
                onPressed: () => _addGoal(type: 'weekly'),
                icon: const Icon(Icons.add, size: 16, color: horizonOrange),
                label: Text('Add', style: GoogleFonts.dmSans(fontSize: 13, color: horizonOrange, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_weeklyGoals.isEmpty)
          _buildEmptyState('No goals this week yet.', 'Tools from your lessons will add goals here automatically.')
        else ...[
          ...activeWeekly.map((g) => _buildGoalCard(g, 'weekly')),
          if (completedWeekly.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${completedWeekly.length} completed this week',
              style: GoogleFonts.dmSans(fontSize: 12, color: midSage, fontStyle: FontStyle.italic),
            ),
            ...completedWeekly.map((g) => _buildGoalCard(g, 'weekly')),
          ],
        ],
        if (activeWeekly.length >= 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Three is enough for one week.', style: GoogleFonts.dmSans(fontSize: 12, color: midSage, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  Widget _buildLongtermSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HER LONG GAME GOALS',
                    style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 2),
                  ),
                  Text('Bigger. Longer. Still yours.', style: GoogleFonts.dmSans(fontSize: 12, color: midSage, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _addGoal(type: 'longterm'),
              icon: const Icon(Icons.add, size: 16, color: crownGold),
              label: Text('Add', style: GoogleFonts.dmSans(fontSize: 13, color: crownGold, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_longtermGoals.isEmpty)
          _buildEmptyState(
            'No long game goals yet.',
            'Add something you\'re building toward. A number. A date. A feeling. Whatever makes it real.',
          )
        else
          ..._longtermGoals.map((g) => _buildGoalCard(g, 'longterm')),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, String type) {
    final isComplete = goal['completed_at'] != null;
    final hasDate = goal['target_date'] != null;
    final hasAmount = goal['target_amount'] != null;

    DateTime? targetDate;
    if (hasDate) targetDate = DateTime.tryParse(goal['target_date']);

    return Dismissible(
      key: Key('${goal['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: midSage.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
        child: Text('Archive', style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontWeight: FontWeight.w600)),
      ),
      onDismissed: (_) => _archiveGoal(goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isComplete ? sagePale.withValues(alpha: 0.5) : warmCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isComplete ? deepSage.withValues(alpha: 0.3) : sagePale, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _toggleComplete(goal),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 1, right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete ? deepSage : Colors.transparent,
                  border: Border.all(color: isComplete ? deepSage : midSage, width: 1.5),
                ),
                child: isComplete ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['label'] ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: isComplete ? midSage : textBody,
                      decoration: isComplete ? TextDecoration.lineThrough : null,
                      decorationColor: midSage,
                      height: 1.4,
                    ),
                  ),
                  if (hasDate || hasAmount) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (hasDate && targetDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: petal, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              '${targetDate.day}/${targetDate.month}/${targetDate.year}',
                              style: GoogleFonts.dmSans(fontSize: 11, color: midSage),
                            ),
                          ),
                        if (hasDate && hasAmount) const SizedBox(width: 6),
                        if (hasAmount)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: crownGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              '\$${goal['target_amount']}',
                              style: GoogleFonts.dmSans(fontSize: 11, color: crownGold, fontWeight: FontWeight.w600),
                            ),
                          ),
                        if (goal['linked_tool'] != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: horizonOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              '${goal['linked_tool']}',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: horizonOrange,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showArchived = !_showArchived),
          child: Row(
            children: [
              Text('DONE & ARCHIVED', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: midSage, letterSpacing: 2)),
              const SizedBox(width: 6),
              Icon(_showArchived ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: midSage),
            ],
          ),
        ),
        if (_showArchived) ...[
          const SizedBox(height: 10),
          ..._archivedGoals.map(
            (g) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: warmCream, borderRadius: BorderRadius.circular(8), border: Border.all(color: sagePale)),
              child: Text(
                g['label'] ?? '',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: midSage,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: midSage,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(String heading, String body) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: petal.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sagePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: GoogleFonts.playfairDisplay(fontSize: 16, fontStyle: FontStyle.italic, color: midSage)),
          const SizedBox(height: 6),
          Text(body, style: GoogleFonts.dmSans(fontSize: 13, color: midSage, height: 1.6)),
        ],
      ),
    );
  }
}
