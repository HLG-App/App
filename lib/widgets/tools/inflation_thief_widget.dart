import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:her_long_game/theme.dart';

class InflationThiefWidget extends StatefulWidget {
  final double cashAmount;
  final Function(Map<String, dynamic> outputs) onSave;
  final Future<void> Function(String goalLabel)? onAddGoal;

  const InflationThiefWidget({
    Key? key,
    required this.cashAmount,
    required this.onSave,
    this.onAddGoal,
  }) : super(key: key);

  @override
  State<InflationThiefWidget> createState() => _InflationThiefWidgetState();
}

class _InflationThiefWidgetState extends State<InflationThiefWidget> {
  static const Color deepSage = HLGColors.deepSage;
  static Color get sagePale => HLGColors.sagePale;
  static const Color crownGold = HLGColors.crownGold;
  static const Color warmCream = HLGColors.warmCream;
  static const Color night = HLGColors.textBody;
  static const Color horizonOrange = HLGColors.horizonOrange;
  static const Color midSage = HLGColors.sageMid;
  static Color get petal => HLGColors.petal;
  static const Color textBody = HLGColors.textBody;

  double _years = 10;
  String _selectedAsset = 'HISA';
  double _cashInput = 0;

  static const Map<String, double> _assetRates = {
    'HISA': 0.045,
    'Index Fund': 0.07,
    'Gold': 0.05,
  };

  static const double _inflationRate = 0.03;

  @override
  void initState() {
    super.initState();
    _cashInput = widget.cashAmount;
  }

  double get _cashRealValue => _cashInput / math.pow(1 + _inflationRate, _years);

  double get _comparisonValue =>
      _cashInput * math.pow(1 + (_assetRates[_selectedAsset] ?? 0.045), _years);

  double get _gap => _comparisonValue - _cashRealValue;

  String _humanTerms(double gap) {
    if (gap < 500) return 'a week of groceries';
    if (gap < 2000) return 'a month of rent';
    if (gap < 10000) return 'several months of rent';
    if (gap < 30000) return 'a year of rent';
    return 'years of financial breathing room';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}k';
    return '\$${amount.toStringAsFixed(0)}';
  }

  Map<String, dynamic> get _outputs => {
    'cash_real_value': _cashRealValue,
    'comparison_value': _comparisonValue,
    'gap': _gap,
    'years': _years.toInt(),
    'selected_asset': _selectedAsset,
    'cash_input': _cashInput,
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
          _buildCashInput(),
          const SizedBox(height: 20),
          _buildAssetSelector(),
          const SizedBox(height: 20),
          _buildJars(),
          const SizedBox(height: 16),
          _buildGapStatement(),
          const SizedBox(height: 20),
          _buildYearSlider(),
          const SizedBox(height: 28),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        _buildSaveButton(),
        if (widget.onAddGoal != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => widget.onAddGoal?.call('Move some cash into a growth asset (so inflation stops winning by default)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: deepSage,
                side: const BorderSide(color: deepSage, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Add to my goals', style: GoogleFonts.dmSans(fontSize: 14)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meet the Inflation Thief.',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: night,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'He doesn\'t break in. He just quietly shrinks Jar A every year.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: midSage,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCashInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How much do you have in cash savings?',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textBody,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('\$', style: TextStyle(fontSize: 18, color: HLGColors.textBody)),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: _cashInput.clamp(1000, 100000),
                min: 1000,
                max: 100000,
                divisions: 99,
                activeColor: horizonOrange,
                inactiveColor: sagePale,
                onChanged: (v) => setState(() => _cashInput = v),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                _formatCurrency(_cashInput),
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textBody,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What does Jar B hold?',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textBody,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _assetRates.keys.map((asset) {
            final selected = _selectedAsset == asset;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedAsset = asset),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? deepSage : warmCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? deepSage : sagePale,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        asset,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? warmCream : textBody,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${((_assetRates[asset] ?? 0) * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                            color: selected ? sagePale : midSage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildJars() {
    final jarAPercent = (_cashRealValue / _cashInput).clamp(0.0, 1.0);
    final jarBPercent = (_comparisonValue / _cashInput).clamp(0.0, 2.0);

    return Row(
      children: [
        Expanded(
          child: _buildJar(
            label: 'JAR A',
            sublabel: 'Your cash',
            value: _cashRealValue,
            original: _cashInput,
            fillPercent: jarAPercent,
            fillColor: midSage,
            note: 'Purchasing power: ${(jarAPercent * 100).toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildJar(
            label: 'JAR B',
            sublabel: _selectedAsset,
            value: _comparisonValue,
            original: _cashInput,
            fillPercent: (jarBPercent / 2).clamp(0.0, 1.0),
            fillColor: deepSage,
            note: '+${_formatCurrency(_comparisonValue - _cashInput)}',
          ),
        ),
      ],
    );
  }

  Widget _buildJar({
    required String label,
    required String sublabel,
    required double value,
    required double original,
    required double fillPercent,
    required Color fillColor,
    required String note,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: midSage,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          sublabel,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: midSage,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: warmCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sagePale, width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              FractionallySizedBox(
                heightFactor: fillPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatCurrency(value),
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: label == 'JAR A' ? midSage : deepSage,
          ),
        ),
        Text(
          note,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: midSage,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildGapStatement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: petal,
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: crownGold, width: 4)),
      ),
      child: Text(
        'The gap: ${_formatCurrency(_gap)} – that\'s about ${_humanTerms(_gap)}.',
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: deepSage,
        ),
      ),
    );
  }

  Widget _buildYearSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drag to see what happens over time',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: midSage,
            fontStyle: FontStyle.italic,
          ),
        ),
        Row(
          children: [
            Text('1yr', style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
            Expanded(
              child: Slider(
                value: _years,
                min: 1,
                max: 30,
                divisions: 29,
                activeColor: horizonOrange,
                inactiveColor: sagePale,
                onChanged: (v) => setState(() => _years = v),
              ),
            ),
            Text('30yr', style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
          ],
        ),
        Center(
          child: Text(
            '${_years.toInt()} years',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textBody,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          debugPrint('[InflationThiefWidget] onSave outputs=$_outputs');
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
    );
  }
}
