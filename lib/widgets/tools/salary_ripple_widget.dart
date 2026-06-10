import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SalaryRippleWidget extends StatefulWidget {
  final double initialSalary;
  final int currentAge;
  final Future<void> Function(Map<String, dynamic> inputs, Map<String, dynamic> outputs) onSave;
  final Future<void> Function(String goalLabel) onAddGoal;

  const SalaryRippleWidget({
    super.key,
    required this.initialSalary,
    required this.currentAge,
    required this.onSave,
    required this.onAddGoal,
  });

  @override
  State<SalaryRippleWidget> createState() => _SalaryRippleWidgetState();
}

class _SalaryRippleWidgetState extends State<SalaryRippleWidget> with SingleTickerProviderStateMixin {
  static const Color deepSage = Color(0xFF5C7A62);
  static const Color sagePale = Color(0xFFD4E0D6);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = Color(0xFF161E17);
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color petal = Color(0xFFEDE0D4);
  static const Color textBody = Color(0xFF2A3A2C);

  double _raisePercent = 5.0;
  int _tappedRing = -1;
  late final AnimationController _animController;
  late final Animation<double> _rippleAnimation;

  late final TextEditingController _salaryController;
  late final FocusNode _salaryFocusNode;
  late double _currentSalary;

  @override
  void initState() {
    super.initState();
    _currentSalary = widget.initialSalary;
    _salaryController = TextEditingController(text: _formatSalaryInput(_currentSalary));
    _salaryFocusNode = FocusNode();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _salaryFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  int get _yearsToRetirement => math.max(67 - widget.currentAge, 1);
  double get _raiseAmount => _currentSalary * (_raisePercent / 100);
  double get _taxRate => 0.325;

  double get _ring1 => _raiseAmount * (1 - _taxRate);
  double get _ring2 => _raiseAmount * _yearsToRetirement;
  double get _ring3 => _raiseAmount * 0.115 * _yearsToRetirement;

  double get _ring4 {
    double balance = 0;
    for (int i = 0; i < _yearsToRetirement; i++) {
      balance = (balance + _raiseAmount * 0.115) * 1.07;
    }
    return balance;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(0)}k';
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatSalaryInput(double salary) => salary.toStringAsFixed(0);

  double? _parseSalary(String raw) {
    final normalized = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Map<String, dynamic> get _outputs => {
    'current_salary': _currentSalary,
    'current_age': widget.currentAge,
    'raise_percent': _raisePercent,
    'raise_amount': _raiseAmount,
    'ring1_take_home': _ring1,
    'ring2_lifetime': _ring2,
    'ring3_super_contrib': _ring3,
    'ring4_retirement': _ring4,
    'total_ripple': _ring1 + _ring2 + _ring3 + _ring4,
  };

  Map<String, dynamic> get _inputs => {
    'current_salary': _currentSalary,
    'current_age': widget.currentAge,
    'raise_percent': _raisePercent,
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
          _buildSalaryDisplay(),
          const SizedBox(height: 16),
          _buildRaiseSelector(),
          const SizedBox(height: 24),
          _buildRippleVisual(),
          const SizedBox(height: 16),
          _buildRingDetails(),
          const SizedBox(height: 24),
          _buildTotalStatement(),
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
          'One conversation. Four rings.',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap each ring to see what it holds.',
          style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildSalaryDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: petal, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT SALARY',
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: midSage, letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('\$', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: night)),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _salaryController,
                        focusNode: _salaryFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                        style: GoogleFonts.playfairDisplay(fontSize: 30, fontWeight: FontWeight.w700, color: night),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) {
                          final parsed = _parseSalary(v);
                          if (parsed == null) return;
                          setState(() => _currentSalary = parsed.clamp(0, 100000000));
                          _animController.forward(from: 0);
                        },
                        onEditingComplete: () {
                          final parsed = _parseSalary(_salaryController.text);
                          if (parsed == null) {
                            setState(() {
                              _currentSalary = widget.initialSalary;
                              _salaryController.text = _formatSalaryInput(_currentSalary);
                            });
                          } else {
                            final sanitized = parsed.clamp(0, 100000000).toDouble();
                            setState(() {
                              _currentSalary = sanitized;
                              _salaryController.text = _formatSalaryInput(_currentSalary);
                              _salaryController.selection = TextSelection.fromPosition(TextPosition(offset: _salaryController.text.length));
                            });
                          }
                          _salaryFocusNode.unfocus();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RAISE',
                style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: midSage, letterSpacing: 1.5),
              ),
              Text(
                '+${_raisePercent.toStringAsFixed(0)}%',
                style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: horizonOrange),
              ),
              Text(
                '+${_formatCurrency(_raiseAmount)}/yr',
                style: GoogleFonts.dmSans(fontSize: 12, color: midSage),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRaiseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a raise scenario:',
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: textBody),
        ),
        const SizedBox(height: 10),
        Row(
          children: [3.0, 5.0, 10.0, 15.0].map((pct) {
            final selected = _raisePercent == pct;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _raisePercent = pct);
                  _animController.forward(from: 0);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? deepSage : warmCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? deepSage : sagePale, width: 1.5),
                  ),
                  child: Text(
                    '+${pct.toStringAsFixed(0)}%',
                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? warmCream : textBody),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRippleVisual() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildRing(4, 110, const Color(0xFF1A4A6B), _ring4, 'Ring 4'),
              _buildRing(3, 85, deepSage, _ring3, 'Ring 3'),
              _buildRing(2, 60, const Color(0xFF7A9178), _ring2, 'Ring 2'),
              _buildRing(1, 35, horizonOrange, _ring1, 'Ring 1'),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: crownGold, shape: BoxShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRing(int ringNum, double radius, Color color, double value, String label) {
    final scale = _rippleAnimation.value;
    final isSelected = _tappedRing == ringNum;
    return GestureDetector(
      onTap: () => setState(() => _tappedRing = _tappedRing == ringNum ? -1 : ringNum),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: isSelected ? 0.3 : 0.15),
            border: Border.all(color: color.withValues(alpha: isSelected ? 1.0 : 0.6), width: isSelected ? 2.5 : 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildRingDetails() {
    final rings = [
      _RingData(1, horizonOrange, 'Extra take-home this year', _ring1),
      _RingData(2, const Color(0xFF7A9178), 'Extra lifetime earnings', _ring2),
      _RingData(3, deepSage, 'Extra super contributions', _ring3),
      _RingData(4, const Color(0xFF1A4A6B), 'Extra in your retirement account', _ring4),
    ];
    return Column(
      children: rings
          .map(
            (r) {
              final isSelected = _tappedRing == r.ring;
              return GestureDetector(
                onTap: () => setState(() => _tappedRing = _tappedRing == r.ring ? -1 : r.ring),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? r.color.withValues(alpha: 0.1) : warmCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? r.color : sagePale, width: isSelected ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ring ${r.ring} — ${r.label}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: isSelected ? r.color : midSage,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        _formatCurrency(r.value),
                        style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? r.color : textBody),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
          .toList(),
    );
  }

  Widget _buildTotalStatement() {
    final total = _ring1 + _ring2 + _ring3 + _ring4;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: night, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ONE CONVERSATION WORTH',
            style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(total),
            style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700, color: warmCream),
          ),
          Text(
            'across career and super — in today\'s dollars',
            style: GoogleFonts.dmSans(fontSize: 12, color: midSage, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Text(
            'Projections are illustrative. Not personal financial advice.',
            style: GoogleFonts.dmSans(fontSize: 10, color: midSage),
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
            onPressed: () async {
              try {
                debugPrint('[SalaryRipple] Save tapped inputs=$_inputs outputs=$_outputs');
                await widget.onSave(_inputs, _outputs);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Saved to your dashboard.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: deepSage,
                  ),
                );
              } catch (e) {
                debugPrint('[SalaryRipple] Save failed: $e');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Couldn\'t save right now. Please try again.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
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
            onPressed: () async {
              try {
                debugPrint('[SalaryRipple] AddGoal tapped');
                await widget.onAddGoal('Ask for a raise this month');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to your goals.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: deepSage,
                  ),
                );
              } catch (e) {
                debugPrint('[SalaryRipple] AddGoal failed: $e');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Couldn\'t add goal right now. Please try again.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
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

class _RingData {
  final int ring;
  final Color color;
  final String label;
  final double value;

  const _RingData(this.ring, this.color, this.label, this.value);
}
