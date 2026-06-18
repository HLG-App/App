
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeMachineWidget extends StatefulWidget {
  final Function(Map<String, dynamic> outputs) onSave;
  final Function(String goalLabel) onAddGoal;

  const TimeMachineWidget({super.key, required this.onSave, required this.onAddGoal});

  @override
  State<TimeMachineWidget> createState() => _TimeMachineWidgetState();
}

class _TimeMachineWidgetState extends State<TimeMachineWidget> {
  static const Color deepSage = Color(0xFF5C7A62);
  static const Color sagePale = Color(0xFFD4E0D6);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = deepSage;
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color petal = Color(0xFFF2EFE8);
  static const Color textBody = midSage;

  String _selectedHabit = 'Daily coffee';
  double _habitCost = 5.50;
  double _redirectPercent = 50;
  int _years = 20;

  static const Map<String, double> _habitCosts = {
    'Daily coffee': 5.50,
    'Lunch out': 18.00,
    'Streaming subs': 45.00,
    'Weekly wine': 25.00,
  };

  static const Map<String, int> _habitDaysPerYear = {
    'Daily coffee': 260,
    'Lunch out': 52,
    'Streaming subs': 12,
    'Weekly wine': 52,
  };

  double get _annualHabitCost => _habitCost * (_habitDaysPerYear[_selectedHabit] ?? 260);
  double get _annualRedirect => _annualHabitCost * (_redirectPercent / 100);

  double get _futureBBalance {
    double balance = 0;
    final annual = _annualRedirect;
    for (int i = 0; i < _years; i++) {
      balance = (balance + annual) * 1.07;
    }
    return balance;
  }

  DateTime get _doublingDate {
    if (_annualRedirect <= 0) return DateTime.now().add(const Duration(days: 36500));
    int years = 0;
    double balance = _annualRedirect;
    final target = _annualRedirect * 2;
    while (balance < target && years < 100) {
      balance = (balance + _annualRedirect) * 1.07;
      years++;
    }
    return DateTime.now().add(Duration(days: years * 365));
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}k';
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> get _outputs => {
        'habit': _selectedHabit,
        'annual_cost': _annualHabitCost,
        'redirect_percent': _redirectPercent,
        'annual_redirect': _annualRedirect,
        'future_b_balance': _futureBBalance,
        'years': _years,
        'doubling_date': _doublingDate.toIso8601String(),
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildHabitSelector(),
          const SizedBox(height: 20),
          _buildRedirectSlider(),
          const SizedBox(height: 24),
          _buildTwoFutures(),
          const SizedBox(height: 16),
          _buildDoublingDate(),
          const SizedBox(height: 28),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Two futures. One choice.',
            style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night)),
        const SizedBox(height: 6),
        Text(
          'This is not about giving up the habit. It\'s about making it a conscious choice.',
          style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildHabitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick a habit:',
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textBody)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _habitCosts.keys.map((habit) {
            final selected = _selectedHabit == habit;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedHabit = habit;
                _habitCost = _habitCosts[habit]!;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? deepSage : warmCream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? deepSage : sagePale, width: 1.5),
                ),
                child: Text(
                  habit,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected ? warmCream : textBody,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'Annual spend on $_selectedHabit: ${_formatCurrency(_annualHabitCost)}',
          style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildRedirectSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How much to redirect?',
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textBody)),
        const SizedBox(height: 4),
        Text(
          'Drag to 0% to keep the habit exactly as it is.',
          style: GoogleFonts.dmSans(fontSize: 12, color: midSage, fontStyle: FontStyle.italic),
        ),
        Row(
          children: [
            Text('0%', style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
            Expanded(
              child: Slider(
                value: _redirectPercent,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: horizonOrange,
                inactiveColor: sagePale,
                onChanged: (v) => setState(() => _redirectPercent = v),
              ),
            ),
            Text('100%', style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
          ],
        ),
        Center(
          child: Text(
            '${_redirectPercent.toStringAsFixed(0)}% redirected – ${_formatCurrency(_annualRedirect)}/year',
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: horizonOrange),
          ),
        ),
      ],
    );
  }

  Widget _buildTwoFutures() {
    return Row(
      children: [
        Expanded(
          child: _buildFutureCard(
            label: 'FUTURE A',
            subtitle: 'Keep going as is',
            value: _annualHabitCost * _years,
            note: 'spent on $_selectedHabit',
            color: petal,
            textColor: midSage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFutureCard(
            label: 'FUTURE B',
            subtitle: 'Redirect ${_redirectPercent.toStringAsFixed(0)}%',
            value: _futureBBalance,
            note: 'invested at 7% over $_years years',
            color: sagePale,
            textColor: deepSage,
          ),
        ),
      ],
    );
  }

  Widget _buildFutureCard({
    required String label,
    required String subtitle,
    required double value,
    required String note,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: textColor, letterSpacing: 1.5),
          ),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: midSage, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(value),
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: night),
          ),
          Text(note, style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
        ],
      ),
    );
  }

  Widget _buildDoublingDate() {
    if (_redirectPercent == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: petal,
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: crownGold, width: 4)),
      ),
      child: Text(
        'At this redirect rate, your invested amount first doubles around ${_formatDate(_doublingDate)}.',
        style: GoogleFonts.playfairDisplay(fontSize: 15, fontStyle: FontStyle.italic, color: deepSage),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => widget.onSave(_outputs),
            style: ElevatedButton.styleFrom(
              backgroundColor: deepSage,
              foregroundColor: warmCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Save to my dashboard', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => widget.onAddGoal(
              'Redirect ${_redirectPercent.toStringAsFixed(0)}% of my $_selectedHabit spend to investing',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: deepSage,
              side: const BorderSide(color: deepSage, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Add to my goals', style: GoogleFonts.dmSans(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
