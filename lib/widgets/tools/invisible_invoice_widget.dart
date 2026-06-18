import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvisibleInvoiceWidget extends StatefulWidget {
  final Function(Map<String, dynamic> outputs) onSave;
  final Function(String goalLabel) onAddGoal;

  const InvisibleInvoiceWidget({super.key, required this.onSave, required this.onAddGoal});

  @override
  State<InvisibleInvoiceWidget> createState() => _InvisibleInvoiceWidgetState();
}

class _InvisibleInvoiceWidgetState extends State<InvisibleInvoiceWidget> {
  static const Color deepSage = Color(0xFF5C7A62);
  static const Color sagePale = Color(0xFFD4E0D6);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = deepSage;
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color petal = Color(0xFFF2EFE8);
  static const Color textBody = midSage;

  double _salary = 75000;
  int _age = 35;
  int _yearsInWorkforce = 10;
  String _selectedOccupation = 'National average';
  double _gapPercent = 0.17;
  bool _loading = false;

  static const Map<String, double> _occupationGaps = {
    'National average': 0.17,
    'Financial services': 0.26,
    'Health & social care': 0.14,
    'Education': 0.11,
    'Professional services': 0.22,
    'Construction': 0.31,
    'Retail': 0.13,
    'Technology': 0.24,
    'Government': 0.09,
  };

  int get _yearsRemaining => (67 - _age).clamp(1, 45);
  double get _annualGap => _salary * _gapPercent;
  double get _careerToDateGap => _annualGap * _yearsInWorkforce;
  double get _futureGap => _annualGap * _yearsRemaining;
  double get _superGapToDate => _careerToDateGap * 0.115 * 1.5;
  double get _superGapFuture => _futureGap * 0.115 * 2.0;
  double get _totalInvoice => _careerToDateGap + _futureGap + _superGapToDate + _superGapFuture;

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(0)}k';
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
          _buildControls(),
          const SizedBox(height: 24),
          _buildInvoice(),
          const SizedBox(height: 16),
          _buildActions(),
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
          'The system has never sent you this invoice.',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night),
        ),
        const SizedBox(height: 6),
        Text(
          'So we built it for you.',
          style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your occupation:', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textBody)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: warmCream, borderRadius: BorderRadius.circular(8), border: Border.all(color: sagePale)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedOccupation,
              isExpanded: true,
              items: _occupationGaps.keys
                  .map((occ) => DropdownMenuItem(value: occ, child: Text(occ, style: GoogleFonts.dmSans(fontSize: 14, color: textBody))))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _selectedOccupation = v;
                  _gapPercent = _occupationGaps[v]!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSlider('Annual salary', '\$${(_salary / 1000).toStringAsFixed(0)}k', _salary, 30000, 200000, 170, (v) => setState(() => _salary = v), horizonOrange),
        const SizedBox(height: 8),
        _buildSlider('Your age', '$_age', _age.toDouble(), 20, 65, 45, (v) => setState(() => _age = v.toInt()), deepSage),
        const SizedBox(height: 8),
        _buildSlider('Years in workforce', '$_yearsInWorkforce', _yearsInWorkforce.toDouble(), 1, 40, 39, (v) => setState(() => _yearsInWorkforce = v.toInt()), crownGold),
      ],
    );
  }

  Widget _buildSlider(String label, String value, double current, double min, double max, int divisions, Function(double) onChanged, Color color) {
    return Row(
      children: [
        SizedBox(width: 130, child: Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: textBody))),
        Expanded(
          child: Slider(
            value: current.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            inactiveColor: sagePale,
            onChanged: _loading ? null : onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: color), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildInvoice() {
    return Container(
      decoration: BoxDecoration(color: night, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'INVISIBLE INVOICE',
                        style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 2),
                      ),
                    ),
                    Text(_selectedOccupation, style: GoogleFonts.dmSans(fontSize: 11, color: midSage)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_gapPercent * 100).toStringAsFixed(0)}% gender pay gap applied',
                  style: GoogleFonts.dmSans(fontSize: 11, color: midSage, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white12),
                const SizedBox(height: 16),
              ],
            ),
          ),
          ...[
            _InvoiceLine('Annual gap – this year', _annualGap),
            _InvoiceLine('Career-to-date gap (${_yearsInWorkforce} yrs)', _careerToDateGap),
            _InvoiceLine('Projected future gap (${_yearsRemaining} yrs)', _futureGap),
            _InvoiceLine('Super impact – to date', _superGapToDate),
            _InvoiceLine('Super impact – projected', _superGapFuture),
          ].map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(line.label, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white70))),
                  Text(_formatCurrency(line.amount), style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: warmCream)),
                ],
              ),
            ),
          ),
          Container(margin: const EdgeInsets.fromLTRB(20, 12, 20, 0), height: 1, color: crownGold.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'TOTAL CAREER INVOICE',
                    style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: crownGold, letterSpacing: 1),
                  ),
                ),
                Text(
                  _formatCurrency(_totalInvoice),
                  style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: crownGold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: petal, borderRadius: BorderRadius.circular(10), border: const Border(left: BorderSide(color: crownGold, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THREE RESPONSES', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Text('1. Ask for a raise → see the Salary Ripple tool (T2)', style: GoogleFonts.dmSans(fontSize: 13, color: textBody)),
          const SizedBox(height: 6),
          Text('2. Add \$25/fortnight voluntary super → see Super Time Warp (T6)', style: GoogleFonts.dmSans(fontSize: 13, color: textBody)),
          const SizedBox(height: 6),
          Text('3. Build income outside employment – where you set the rate', style: GoogleFonts.dmSans(fontSize: 13, color: textBody)),
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
            onPressed: _loading
                ? null
                : () {
                    widget.onSave({
                      'occupation': _selectedOccupation,
                      'salary': _salary,
                      'gap_percent': _gapPercent,
                      'annual_gap': _annualGap,
                      'total_invoice': _totalInvoice,
                      'years_remaining': _yearsRemaining,
                    });
                  },
            style: ElevatedButton.styleFrom(backgroundColor: deepSage, foregroundColor: warmCream, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
            child: Text('Save to my dashboard', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _loading ? null : () => widget.onAddGoal('Ask for a raise – my annual gap is ${_formatCurrency(_annualGap)}'),
            style: OutlinedButton.styleFrom(foregroundColor: deepSage, side: const BorderSide(color: deepSage, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
            child: Text('Add to my goals', style: GoogleFonts.dmSans(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}

class _InvoiceLine {
  final String label;
  final double amount;
  const _InvoiceLine(this.label, this.amount);
}
