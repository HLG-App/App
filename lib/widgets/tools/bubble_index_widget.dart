import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/theme.dart';

class BubbleIndexWidget extends StatefulWidget {
  final Function(Map<String, dynamic> outputs)? onSave;
  final Future<void> Function(String goalLabel)? onAddGoal;

  const BubbleIndexWidget({super.key, this.onSave, this.onAddGoal});

  @override
  State<BubbleIndexWidget> createState() => _BubbleIndexWidgetState();
}

class _BubbleIndexWidgetState extends State<BubbleIndexWidget> {
  static const Color deepSage = HLGColors.deepSage;
  static Color get sagePale => HLGColors.sagePale;
  static const Color crownGold = HLGColors.crownGold;
  static const Color warmCream = HLGColors.warmCream;
  static const Color night = HLGColors.night;
  static const Color horizonOrange = HLGColors.horizonOrange;
  static const Color midSage = HLGColors.midSage;
  static Color get petal => HLGColors.petal;
  static const Color textBody = HLGColors.textBody;

  // Historical Bubble O Bill prices
  static const Map<int, double> _bobPrices = {
    2015: 2.25,
    2016: 2.40,
    2017: 2.50,
    2018: 2.60,
    2019: 2.75,
    2020: 2.80,
    2021: 2.90,
    2022: 3.20,
    2023: 3.50,
    2024: 4.50,
    2025: 5.00,
  };

  static const List<String> _snackNames = [
    'Bubble O\' Bill',
    'Chiko Roll',
    'Paddle Pop',
    'Servo pie',
    'Freddo Frog',
  ];

  String _selectedSnack = 'Bubble O\' Bill';
  double _snackPriceThen = 2.25;
  double _snackPriceNow = 5.00;
  double _assetValueThen = 10000;
  double _assetValueNow = 12000;
  bool _hasResult = false;
  Map<String, dynamic> _outputs = const {};

  double get _iceCreamsThen => _assetValueThen / _snackPriceThen;
  double get _iceCreamsNow => _assetValueNow / _snackPriceNow;
  double get _dollarGrowth => _assetValueNow - _assetValueThen;
  double get _dollarGrowthPercent => _assetValueThen > 0 ? (_dollarGrowth / _assetValueThen) * 100 : 0;
  double get _iceCreamChange => _iceCreamsNow - _iceCreamsThen;
  double get _iceCreamChangePercent => _iceCreamsThen > 0 ? (_iceCreamChange / _iceCreamsThen) * 100 : 0;

  bool get _gotRicherInDollars => _dollarGrowth > 0;
  bool get _gotRicherInIceCreams => _iceCreamChange > 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPriceChart(),
          const SizedBox(height: 24),
          _buildSnackSelector(),
          const SizedBox(height: 20),
          _buildSnackPriceInputs(),
          const SizedBox(height: 20),
          _buildAssetInputs(),
          const SizedBox(height: 20),
          _buildRunButton(),
          if (_hasResult) ...[
            const SizedBox(height: 24),
            _buildResult(),
            const SizedBox(height: 18),
            _buildButtons(),
          ],
          const SizedBox(height: 16),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final canSave = widget.onSave != null && _outputs.isNotEmpty;
    final canAddGoal = widget.onAddGoal != null && _outputs.isNotEmpty;

    if (!canSave && !canAddGoal) return const SizedBox.shrink();

    return Column(
      children: [
        if (canSave)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => widget.onSave?.call(_outputs),
              style: ElevatedButton.styleFrom(
                backgroundColor: deepSage,
                foregroundColor: warmCream,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Save to my dashboard', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        if (canSave && canAddGoal) const SizedBox(height: 10),
        if (canAddGoal)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => widget.onAddGoal?.call('Track purchasing power monthly (not just dollars)'),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🍦', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'The Bubble O\' Bill Index',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: night,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: horizonOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '+122% since 2015',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: horizonOrange,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The number goes up. But what it buys you quietly goes down. This tool shows you both – because the system only ever shows you one.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: midSage,
            fontStyle: FontStyle.italic,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChart() {
    final years = _bobPrices.keys.toList()..sort();
    final maxPrice = _bobPrices.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: night,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUBBLE O\' BILL PRICE 2015–2025',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: crownGold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: years
                  .map(
                    (year) {
                      final price = _bobPrices[year]!;
                      final heightFactor = price / maxPrice;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '\$${price.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 8,
                                  color: crownGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                height: 80 * heightFactor,
                                decoration: BoxDecoration(
                                  color: horizonOrange.withOpacity(0.4 + (heightFactor * 0.6)),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "'${year.toString().substring(2)}",
                                style: GoogleFonts.dmSans(
                                  fontSize: 8,
                                  color: midSage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated retail prices. Servo / convenience store. Community-reported + ABS CPI food sub-index.',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: midSage,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnackSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your snack benchmark',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textBody,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Not a Bubble O' Bill person? Swap it for whatever your benchmark snack is. Same maths, different existential crisis.",
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: midSage,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _snackNames.map((snack) {
            final selected = _selectedSnack == snack;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedSnack = snack;
                if (snack == 'Bubble O\' Bill') {
                  _snackPriceThen = 2.25;
                  _snackPriceNow = 5.00;
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? deepSage : warmCream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? deepSage : sagePale,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  snack,
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
      ],
    );
  }

  Widget _buildSnackPriceInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_selectedSnack price',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textBody,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceField(
                label: 'Price then',
                value: _snackPriceThen,
                onChanged: (v) => setState(() => _snackPriceThen = v),
                min: 0.50,
                max: 20.0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceField(
                label: 'Price now',
                value: _snackPriceNow,
                onChanged: (v) => setState(() => _snackPriceNow = v),
                min: 0.50,
                max: 20.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required String label,
    required double value,
    required Function(double) onChanged,
    required double min,
    required double max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: midSage)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: petal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                '\$',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: textBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                value.toStringAsFixed(2),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: night,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 4).toInt(),
          activeColor: horizonOrange,
          inactiveColor: sagePale,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAssetInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your asset',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textBody,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What did you pay?', style: GoogleFonts.dmSans(fontSize: 12, color: midSage)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: petal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${_formatNumber(_assetValueThen)}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: night,
                      ),
                    ),
                  ),
                  Slider(
                    value: _assetValueThen.clamp(1000, 500000),
                    min: 1000,
                    max: 500000,
                    divisions: 499,
                    activeColor: deepSage,
                    inactiveColor: sagePale,
                    onChanged: (v) => setState(() => _assetValueThen = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What's it worth now?", style: GoogleFonts.dmSans(fontSize: 12, color: midSage)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sagePale,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${_formatNumber(_assetValueNow)}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: deepSage,
                      ),
                    ),
                  ),
                  Slider(
                    value: _assetValueNow.clamp(1000, 1000000),
                    min: 1000,
                    max: 1000000,
                    divisions: 999,
                    activeColor: horizonOrange,
                    inactiveColor: sagePale,
                    onChanged: (v) => setState(() => _assetValueNow = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRunButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          final outputs = <String, dynamic>{
            'snack': _selectedSnack,
            'snack_price_then': _snackPriceThen,
            'snack_price_now': _snackPriceNow,
            'asset_value_then': _assetValueThen,
            'asset_value_now': _assetValueNow,
            'snacks_then': _iceCreamsThen,
            'snacks_now': _iceCreamsNow,
            'dollar_growth': _dollarGrowth,
            'dollar_growth_percent': _dollarGrowthPercent,
            'snack_change': _iceCreamChange,
            'snack_change_percent': _iceCreamChangePercent,
          };

          setState(() {
            _hasResult = true;
            _outputs = outputs;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: horizonOrange,
          foregroundColor: warmCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          'Run the index →',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        // Dollar result
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _gotRicherInDollars ? deepSage.withOpacity(0.08) : horizonOrange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: _gotRicherInDollars ? deepSage : horizonOrange,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IN DOLLARS',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _gotRicherInDollars ? deepSage : horizonOrange,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${_formatNumber(_assetValueThen)} → \$${_formatNumber(_assetValueNow)}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: night,
                          ),
                        ),
                        Text(
                          '${_gotRicherInDollars ? '+' : ''}\$${_formatNumber(_dollarGrowth.abs())} (${_dollarGrowthPercent.toStringAsFixed(1)}%)',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: _gotRicherInDollars ? deepSage : horizonOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _gotRicherInDollars ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    size: 34,
                    color: (_gotRicherInDollars ? deepSage : horizonOrange).withValues(alpha: 0.9),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Ice cream result
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _gotRicherInIceCreams
                ? deepSage.withValues(alpha: 0.08)
                : HLGColors.antiqueRose.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: _gotRicherInIceCreams ? deepSage : HLGColors.antiqueRose,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IN ${_selectedSnack.toUpperCase()}S',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _gotRicherInIceCreams ? deepSage : HLGColors.antiqueRose,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_iceCreamsThen.toStringAsFixed(0)} → ${_iceCreamsNow.toStringAsFixed(0)} ${_selectedSnack.toLowerCase()}s',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: night,
                          ),
                        ),
                        Text(
                          '${_gotRicherInIceCreams ? '+' : ''}${_iceCreamChange.toStringAsFixed(0)} ${_selectedSnack.toLowerCase()}s (${_iceCreamChangePercent.toStringAsFixed(1)}%)',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: _gotRicherInIceCreams ? deepSage : HLGColors.antiqueRose,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _gotRicherInIceCreams ? '🍦' : '😬',
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // The verdict
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: night,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _gotRicherInDollars && !_gotRicherInIceCreams
                ? "You got richer in dollars. You got poorer in ${_selectedSnack.toLowerCase()}s. That's inflation."
                : _gotRicherInDollars && _gotRicherInIceCreams
                    ? 'You outran inflation. In dollars AND in ${_selectedSnack.toLowerCase()}s. That\'s a real return.'
                    : !_gotRicherInDollars && !_gotRicherInIceCreams
                        ? 'You lost in dollars and in ${_selectedSnack.toLowerCase()}s. That\'s the cost of staying still.'
                        : 'Interesting result. The ${_selectedSnack.toLowerCase()} index tells a different story than the dollar one.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: warmCream,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      "ⓘ Exact retail data for individual ice cream products is not publicly reported. Prices estimated from community sources, supermarket historical data, and ABS CPI food sub-index. The vibe is accurate even if the cents aren't exact.",
      style: GoogleFonts.dmSans(
        fontSize: 10,
        color: midSage,
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
    );
  }

  String _formatNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}k';
    return n.toStringAsFixed(0);
  }
}
