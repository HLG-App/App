import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SuperWarpWidget extends StatefulWidget {
  final int currentAge;
  final double superBalance;
  final double annualSalary;
  final String currentOption;
  final Function(Map<String, dynamic> outputs) onSave;
  final Function(String goalLabel) onAddGoal;

  const SuperWarpWidget({
    Key? key,
    required this.currentAge,
    required this.superBalance,
    required this.annualSalary,
    required this.currentOption,
    required this.onSave,
    required this.onAddGoal,
  }) : super(key: key);

  @override
  State<SuperWarpWidget> createState() => _SuperWarpWidgetState();
}

class _SuperWarpWidgetState extends State<SuperWarpWidget> {
  static const Color deepSage = Color(0xFF5C7A62);
  static const Color sagePale = Color(0xFFD4E0D6);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = deepSage;
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color petal = Color(0xFFF2EFE8);

  bool _consolidate = false;
  bool _switchToGrowth = false;
  bool _voluntaryContrib = false;
  bool _updateBeneficiary = false;
  double _voluntaryAmount = 50;

  static const Map<String, double> _returnRates = {
    'Conservative': 0.04,
    'Balanced': 0.06,
    'Growth': 0.075,
    'HighGrowth': 0.085,
  };

  double _projectBalance(double startBalance, double annualContrib, double returnRate, int years) {
    double balance = startBalance;
    for (int i = 0; i < years; i++) {
      balance = (balance + annualContrib) * (1 + returnRate);
    }
    return balance;
  }

  int get _yearsToRetirement => math.max(67 - widget.currentAge, 1);

  double get _employerContrib => widget.annualSalary * 0.115;

  double get _trackARate => _returnRates[widget.currentOption] ?? 0.06;

  double get _trackBRate => _switchToGrowth ? 0.075 : _trackARate;

  double get _trackBExtraContrib => _voluntaryContrib ? (_voluntaryAmount * 26) : 0;

  double get _trackABalance => _projectBalance(widget.superBalance, _employerContrib, _trackARate, _yearsToRetirement);

  double get _trackBBalance => _projectBalance(widget.superBalance, _employerContrib + _trackBExtraContrib, _trackBRate, _yearsToRetirement);

  double get _gap => _trackBBalance - _trackABalance;

  double _yearsOfIncome(double balance) => balance / 45000;

  DateTime _doublingDate(double balance, double rate) {
    if (rate <= 0) return DateTime.now().add(const Duration(days: 36500));
    final years = (math.log(2) / math.log(1 + rate)).ceil();
    return DateTime.now().add(Duration(days: years * 365));
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  Map<String, dynamic> get _outputs => {
    'track_a_balance': _trackABalance,
    'track_b_balance': _trackBBalance,
    'gap': _gap,
    'years_income_a': _yearsOfIncome(_trackABalance),
    'years_income_b': _yearsOfIncome(_trackBBalance),
    'consolidate': _consolidate,
    'switch_to_growth': _switchToGrowth,
    'voluntary_contrib': _voluntaryContrib,
    'voluntary_amount': _voluntaryAmount,
    'update_beneficiary': _updateBeneficiary,
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
          _buildTracks(),
          const SizedBox(height: 24),
          _buildGapStatement(),
          const SizedBox(height: 24),
          _buildToggles(),
          const SizedBox(height: 24),
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
        Text(
          'Two tracks. Same starting point.',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: night,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Toggle the switches to see what Track B looks like.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: midSage,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTracks() {
    return Row(
      children: [
        Expanded(
          child: _buildTrackCard(
            label: 'TRACK A',
            subtitle: 'Do nothing',
            balance: _trackABalance,
            years: _yearsOfIncome(_trackABalance),
            color: petal,
            labelColor: midSage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTrackCard(
            label: 'TRACK B',
            subtitle: 'The switch',
            balance: _trackBBalance,
            years: _yearsOfIncome(_trackBBalance),
            color: sagePale,
            labelColor: deepSage,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackCard({
    required String label,
    required String subtitle,
    required double balance,
    required double years,
    required Color color,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: midSage,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(balance),
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: night,
            ),
          ),
          Text(
            'at age 67',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: midSage,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${years.toStringAsFixed(1)} years',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          Text(
            'of income at \$45k/yr',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: midSage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGapStatement() {
    final gapYears = (_yearsOfIncome(_trackBBalance) - _yearsOfIncome(_trackABalance));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: night,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE GAP',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: crownGold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatCurrency(_gap)} more',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    color: warmCream,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${gapYears.toStringAsFixed(1)} more years of income',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: midSage,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggles() {
    return Column(
      children: [
        _toggle(
          label: 'Consolidate accounts',
          subtitle: 'Stop paying multiple sets of fees',
          value: _consolidate,
          onChanged: (v) => setState(() => _consolidate = v),
          note: 'Check insurance before consolidating',
        ),
        _toggle(
          label: 'Switch to Growth option',
          subtitle: 'From ${widget.currentOption} (${(_trackARate * 100).toStringAsFixed(0)}%) to Growth (7.5%)',
          value: _switchToGrowth,
          onChanged: (v) => setState(() => _switchToGrowth = v),
        ),
        _toggle(
          label: 'Add voluntary contributions',
          subtitle: '\$${_voluntaryAmount.toStringAsFixed(0)}/fortnight extra',
          value: _voluntaryContrib,
          onChanged: (v) => setState(() => _voluntaryContrib = v),
          slider: _voluntaryContrib
              ? Slider(
                  value: _voluntaryAmount,
                  min: 25,
                  max: 500,
                  divisions: 19,
                  activeColor: horizonOrange,
                  inactiveColor: sagePale,
                  onChanged: (v) => setState(() => _voluntaryAmount = v),
                )
              : null,
        ),
        _toggle(
          label: 'Update beneficiary',
          subtitle: 'Who receives your super if you die',
          value: _updateBeneficiary,
          onChanged: (v) => setState(() => _updateBeneficiary = v),
          note: 'Check this is still the right person',
        ),
      ],
    );
  }

  Widget _toggle({
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    String? note,
    Widget? slider,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: value ? sagePale : warmCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: value ? deepSage : sagePale,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: night,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: midSage,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: deepSage,
              ),
            ],
          ),
          if (slider != null) ...[
            const SizedBox(height: 4),
            slider,
          ],
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: horizonOrange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoublingDate() {
    final doublingDate = _doublingDate(widget.superBalance, _trackBRate);
    final age = widget.currentAge + (doublingDate.year - DateTime.now().year);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: petal,
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: crownGold, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR DOUBLING DATE',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: crownGold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your super first doubles in ${_formatDate(doublingDate)}.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: deepSage,
            ),
          ),
          Text(
            'You will be $age.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: midSage,
            ),
          ),
        ],
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
            onPressed: () {
              debugPrint('[SuperWarpWidget] onSave outputs=$_outputs');
              widget.onSave(_outputs);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: deepSage,
              foregroundColor: warmCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(
              'Save to my dashboard',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              const goal = 'Review and switch my super this week';
              debugPrint('[SuperWarpWidget] onAddGoal: $goal');
              widget.onAddGoal(goal);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: deepSage,
              side: const BorderSide(color: deepSage, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(
              'Add to my goals',
              style: GoogleFonts.dmSans(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
