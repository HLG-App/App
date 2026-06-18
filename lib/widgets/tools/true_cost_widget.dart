import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/theme.dart';

class TrueCostWidget extends StatefulWidget {
  final Function(Map<String, dynamic> outputs) onSave;
  final Function(String goalLabel) onAddGoal;

  const TrueCostWidget({super.key, required this.onSave, required this.onAddGoal});

  @override
  State<TrueCostWidget> createState() => _TrueCostWidgetState();
}

class _TrueCostWidgetState extends State<TrueCostWidget> {
  static const Color deepSage = HLGColors.deepSage;
  static Color get sagePale => HLGColors.sagePale;
  static const Color crownGold = HLGColors.crownGold;
  static const Color warmCream = HLGColors.warmCream;
  static const Color night = HLGColors.night;
  static const Color horizonOrange = HLGColors.horizonOrange;
  static const Color midSage = HLGColors.midSage;
  static const Color wine = HLGColors.antiqueRose;
  static Color get wineLight => HLGColors.antiqueRose.withValues(alpha: 0.12);
  static const Color textBody = HLGColors.textBody;

  String _selectedItem = 'A dinner out';
  double _purchaseAmount = 120;
  double _interestRate = 20.0;
  double _monthlyPayment = 30;

  static const Map<String, double> _presets = {
    'A dinner out': 120,
    'A weekend trip': 800,
    'A new phone': 1200,
    'A car upgrade': 8000,
  };

  int get _monthsToPayoff {
    if (_monthlyPayment <= 0) return 999;
    final monthlyRate = _interestRate / 100 / 12;
    if (monthlyRate == 0) return (_purchaseAmount / _monthlyPayment).ceil();
    double balance = _purchaseAmount;
    int months = 0;
    while (balance > 0 && months < 600) {
      balance = balance * (1 + monthlyRate) - _monthlyPayment;
      months++;
    }
    return months;
  }

  double get _totalPaid => _monthlyPayment * _monthsToPayoff;
  double get _interestCost => _totalPaid - _purchaseAmount;

  double get _opportunityCost {
    double balance = 0;
    for (int i = 0; i < _monthsToPayoff; i++) {
      balance = (balance + _monthlyPayment) * math.pow(1.07, 1 / 12);
    }
    return balance - _totalPaid;
  }

  double get _trueCost => _purchaseAmount + _interestCost + _opportunityCost;

  String _formatCurrency(double amount) {
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}k';
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPresets(),
          const SizedBox(height: 16),
          _buildControls(),
          const SizedBox(height: 24),
          _buildDualColumn(),
          const SizedBox(height: 16),
          _buildTrueCostStatement(),
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
          'What did that purchase actually cost you?',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night),
        ),
        const SizedBox(height: 6),
        Text(
          'The dinner is gone. The debt is not.',
          style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildPresets() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presets.keys.map((item) {
        final selected = _selectedItem == item;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedItem = item;
            _purchaseAmount = _presets[item]!;
            _monthlyPayment = (_purchaseAmount * 0.025).clamp(10, 500);
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? wine : warmCream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? wine : sagePale, width: 1.5),
            ),
            child: Text(
              item,
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? warmCream : textBody),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        _buildSliderRow(
          'Purchase amount',
          '\$${_purchaseAmount.toStringAsFixed(0)}',
          _purchaseAmount,
          10,
          10000,
          999,
          (v) => setState(() => _purchaseAmount = v),
          horizonOrange,
        ),
        const SizedBox(height: 8),
        _buildSliderRow(
          'Interest rate',
          '${_interestRate.toStringAsFixed(0)}%',
          _interestRate,
          5,
          30,
          25,
          (v) => setState(() => _interestRate = v),
          wine,
        ),
        const SizedBox(height: 8),
        _buildSliderRow(
          'Monthly payment',
          '\$${_monthlyPayment.toStringAsFixed(0)}',
          _monthlyPayment,
          10,
          500,
          49,
          (v) => setState(() => _monthlyPayment = v),
          deepSage,
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    String value,
    double current,
    double min,
    double max,
    int divisions,
    Function(double) onChanged,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: textBody))),
        Expanded(
          child: Slider(
            value: current.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            inactiveColor: sagePale,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value,
            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: color),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDualColumn() {
    return Row(
      children: [
        Expanded(
          child: _buildColumn(
            'CONSUMED',
            'What you pay',
            [
              _ColRow('Purchase price', _purchaseAmount),
              _ColRow('Interest cost', _interestCost),
              _ColRow('Months to pay off', _monthsToPayoff.toDouble(), isMonths: true),
            ],
            wine,
            wineLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildColumn(
            'PRODUCED',
            'If invested instead',
            [
              _ColRow('Monthly payment', _monthlyPayment),
              _ColRow('Over ${_monthsToPayoff} months', _totalPaid),
              _ColRow('At 7% return', _totalPaid + _opportunityCost),
            ],
            deepSage,
            sagePale,
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(String label, String subtitle, List<_ColRow> rows, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: color, letterSpacing: 1.5)),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: midSage, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.label, style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
                  Text(
                    r.isMonths ? '${r.value.toInt()} months' : _formatCurrency(r.value),
                    style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrueCostStatement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: night, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRUE COST OF THIS PURCHASE', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(_trueCost),
            style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700, color: warmCream),
          ),
          Text(
            '= \$${_purchaseAmount.toStringAsFixed(0)} purchase + ${_formatCurrency(_interestCost)} interest + ${_formatCurrency(_opportunityCost)} opportunity cost',
            style: GoogleFonts.dmSans(fontSize: 11, color: midSage, height: 1.5),
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
            onPressed: () => widget.onSave({
              'purchase_amount': _purchaseAmount,
              'interest_rate': _interestRate,
              'monthly_payment': _monthlyPayment,
              'true_cost': _trueCost,
              'months_to_payoff': _monthsToPayoff,
              'opportunity_cost': _opportunityCost,
            }),
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
            onPressed: () => widget.onAddGoal('Build a rule for when I use credit'),
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

class _ColRow {
  final String label;
  final double value;
  final bool isMonths;
  const _ColRow(this.label, this.value, {this.isMonths = false});
}
