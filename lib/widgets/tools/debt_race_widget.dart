import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DebtRaceWidget extends StatefulWidget {
  final Function(Map<String, dynamic> outputs) onSave;
  final Function(String goalLabel) onAddGoal;

  const DebtRaceWidget({
    super.key,
    required this.onSave,
    required this.onAddGoal,
  });

  @override
  State<DebtRaceWidget> createState() => _DebtRaceWidgetState();
}

class _DebtRaceWidgetState extends State<DebtRaceWidget> {
  static const Color deepSage = Color(0xFF5C7A62);
  static const Color sagePale = Color(0xFFD4E0D6);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = deepSage;
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color petal = Color(0xFFF2EFE8);
  static const Color textBody = midSage;

  final List<_DebtEntry> _debts = [
    _DebtEntry(name: 'Credit card', balance: 4800, rate: 20.99, minPayment: 120),
    _DebtEntry(name: 'Personal loan', balance: 9500, rate: 12.5, minPayment: 250),
  ];
  double _extraPayment = 200;
  String _selectedStrategy = 'avalanche';

  _RaceResult _calculateAvalanche() => _calculate(sortByRate: true);

  _RaceResult _calculateSnowball() => _calculate(sortByRate: false);

  _RaceResult _calculate({required bool sortByRate}) {
    final debts =
        _debts.where((d) => d.balance > 0).map((d) => _DebtCalc(name: d.name, balance: d.balance, rate: d.rate / 100 / 12, minPayment: d.minPayment)).toList();

    if (debts.isEmpty) return const _RaceResult(0, 0, []);

    if (sortByRate) {
      debts.sort((a, b) => b.rate.compareTo(a.rate));
    } else {
      debts.sort((a, b) => a.balance.compareTo(b.balance));
    }

    double totalInterest = 0;
    int months = 0;
    final wins = <String>[];

    while (debts.any((d) => d.balance > 0) && months < 600) {
      months++;
      double extra = _extraPayment;

      for (final debt in debts) {
        if (debt.balance <= 0) continue;

        // Apply interest.
        debt.balance += debt.balance * debt.rate;
        totalInterest += debt.balance * debt.rate;

        // Pay minimum; plus all extra to the current target debt (debts.first).
        final payment = (debt.minPayment + (debt == debts.first ? extra : 0)).clamp(0, debt.balance);
        debt.balance -= payment;

        if (debt.balance <= 0) {
          debt.balance = 0;
          wins.add(debt.name);
          extra += debt.minPayment;
        }
      }
    }

    return _RaceResult(totalInterest, months, wins);
  }

  String _monthsToDate(int months) {
    final date = DateTime.now().add(Duration(days: months * 30));
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}k';
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final avalanche = _calculateAvalanche();
    final snowball = _calculateSnowball();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildDebtInputs(),
          const SizedBox(height: 16),
          _buildExtraPayment(),
          const SizedBox(height: 24),
          _buildRaceTrack(avalanche, snowball),
          const SizedBox(height: 20),
          _buildStrategyComparison(avalanche, snowball),
          const SizedBox(height: 20),
          _buildStrategySelector(),
          const SizedBox(height: 28),
          _buildButtons(avalanche, snowball),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Two strategies. One finish line.', style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night)),
        const SizedBox(height: 6),
        Text('Both strategies work. The question is which one you\'ll stick to.', style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildDebtInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your debts:', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textBody)),
        const SizedBox(height: 10),
        ..._debts.asMap().entries.map((e) => _buildDebtRow(e.key, e.value)),
        if (_debts.length < 5)
          TextButton.icon(
            onPressed: () =>
                setState(() => _debts.add(_DebtEntry(name: 'Debt ${_debts.length + 1}', balance: 1000, rate: 15, minPayment: 50))),
            icon: const Icon(Icons.add, size: 16),
            label: Text('Add another debt', style: GoogleFonts.dmSans(fontSize: 13)),
            style: TextButton.styleFrom(foregroundColor: deepSage),
          ),
      ],
    );
  }

  Widget _buildDebtRow(int index, _DebtEntry debt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: petal, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(child: Text(debt.name, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: night))),
          Text(_formatCurrency(debt.balance), style: GoogleFonts.dmSans(fontSize: 13, color: textBody)),
          const SizedBox(width: 8),
          Text('${debt.rate.toStringAsFixed(1)}%', style: GoogleFonts.dmSans(fontSize: 13, color: horizonOrange)),
        ],
      ),
    );
  }

  Widget _buildExtraPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Extra monthly payment:', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textBody)),
        Row(
          children: [
            Text('\$50', style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
            Expanded(
              child: Slider(
                value: _extraPayment.clamp(50, 1000),
                min: 50,
                max: 1000,
                divisions: 19,
                activeColor: horizonOrange,
                inactiveColor: sagePale,
                onChanged: (v) => setState(() => _extraPayment = v),
              ),
            ),
            Text('\$1k', style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
          ],
        ),
        Center(child: Text('\$${_extraPayment.toStringAsFixed(0)}/month extra', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: horizonOrange))),
      ],
    );
  }

  Widget _buildRaceTrack(_RaceResult avalanche, _RaceResult snowball) {
    final maxMonths = [avalanche.months, snowball.months, 1].reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: night, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('THE RACE', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _buildRaceHorse('AVALANCHE', avalanche.months, maxMonths, horizonOrange, Icons.directions_run_rounded),
          const SizedBox(height: 12),
          _buildRaceHorse('SNOWBALL', snowball.months, maxMonths, deepSage, Icons.pets_rounded),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('FINISH LINE', style: GoogleFonts.dmSans(fontSize: 11, color: crownGold, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRaceHorse(String label, int months, int maxMonths, Color color, IconData endIcon) {
    final progress = maxMonths > 0 ? months / maxMonths : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: color, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 32,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
            ),
            FractionallySizedBox(
              widthFactor: (1 - (progress - 1).abs()).clamp(0.05, 0.95),
              child: Container(
                height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8),
                child: Icon(endIcon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ),
          ],
        ),
        Text('${months} months · Debt free ${_monthsToDate(months)}', style: GoogleFonts.dmSans(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _buildStrategyComparison(_RaceResult avalanche, _RaceResult snowball) {
    return Row(
      children: [
        Expanded(child: _buildStratCard('AVALANCHE', 'Highest rate first', avalanche.months, avalanche.totalInterest, horizonOrange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStratCard('SNOWBALL', 'Smallest balance first', snowball.months, snowball.totalInterest, deepSage)),
      ],
    );
  }

  Widget _buildStratCard(String label, String subtitle, int months, double interest, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: color, letterSpacing: 1.5)),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
          const SizedBox(height: 8),
          Text('$months months', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: night)),
          Text('Total interest: ${_formatCurrency(interest)}', style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
        ],
      ),
    );
  }

  Widget _buildStrategySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Which horse are you backing?', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textBody)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _strategyChip('avalanche', 'Avalanche – save the most money', horizonOrange)),
            const SizedBox(width: 8),
            Expanded(child: _strategyChip('snowball', 'Snowball – early wins', deepSage)),
          ],
        ),
      ],
    );
  }

  Widget _strategyChip(String value, String label, Color color) {
    final selected = _selectedStrategy == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStrategy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: selected ? color : warmCream, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? color : sagePale, width: 1.5)),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? warmCream : textBody), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildButtons(_RaceResult avalanche, _RaceResult snowball) {
    final chosen = _selectedStrategy == 'avalanche' ? avalanche : snowball;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => widget.onSave({
              'strategy': _selectedStrategy,
              'months': chosen.months,
              'debt_free_date': DateTime.now().add(Duration(days: chosen.months * 30)).toIso8601String(),
              'total_interest': chosen.totalInterest,
            }),
            style: ElevatedButton.styleFrom(backgroundColor: deepSage, foregroundColor: warmCream, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
            child: Text('Save to my dashboard', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => widget.onAddGoal('Debt free by ${_monthsToDate(chosen.months)} – ${_selectedStrategy} strategy'),
            style: OutlinedButton.styleFrom(foregroundColor: deepSage, side: const BorderSide(color: deepSage, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
            child: Text('Add to my goals', style: GoogleFonts.dmSans(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}

class _DebtEntry {
  String name;
  double balance;
  double rate;
  double minPayment;
  _DebtEntry({required this.name, required this.balance, required this.rate, required this.minPayment});
}

class _DebtCalc {
  final String name;
  double balance;
  final double rate;
  final double minPayment;
  _DebtCalc({required this.name, required this.balance, required this.rate, required this.minPayment});
}

class _RaceResult {
  final double totalInterest;
  final int months;
  final List<String> wins;
  const _RaceResult(this.totalInterest, this.months, this.wins);
}
