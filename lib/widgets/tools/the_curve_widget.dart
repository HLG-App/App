import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/theme.dart';

class TheCurveWidget extends StatefulWidget {
  final Function(Map<String, dynamic> outputs) onSave;
  final Function(String goalLabel) onAddGoal;

  const TheCurveWidget({super.key, required this.onSave, required this.onAddGoal});

  @override
  State<TheCurveWidget> createState() => _TheCurveWidgetState();
}

class _TheCurveWidgetState extends State<TheCurveWidget> with SingleTickerProviderStateMixin {
  static const Color deepSage = HLGColors.deepSage;
  static Color get sagePale => HLGColors.sagePale;
  static const Color crownGold = HLGColors.crownGold;
  static const Color warmCream = HLGColors.warmCream;
  static const Color night = HLGColors.textBody;
  static const Color horizonOrange = HLGColors.horizonOrange;
  static const Color midSage = HLGColors.sageMid;
  static Color get petal => HLGColors.petal;
  static const Color pond = HLGColors.sage;

  double _monthlyAmount = 50;
  int _startAge = 30;
  late AnimationController _animController;
  late Animation<double> _drawAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _drawAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _yearsToRetirement => math.max(67 - _startAge, 1);
  double get _annualAmount => _monthlyAmount * 12;

  List<double> get _balances {
    final balances = <double>[];
    double balance = 0;
    for (int i = 0; i <= _yearsToRetirement; i++) {
      balances.add(balance);
      balance = (balance + _annualAmount) * 1.07;
    }
    return balances;
  }

  int get _doublingYears {
    final target = _annualAmount * 2;
    double balance = _annualAmount;
    for (int i = 1; i <= 100; i++) {
      balance = (balance + _annualAmount) * 1.07;
      if (balance >= target) return i;
    }
    return 100;
  }

  DateTime get _doublingDate => DateTime(DateTime.now().year + _doublingYears, DateTime.now().month, DateTime.now().day);
  int get _doublingAge => _startAge + _doublingYears;

  double get _costOfStoppingNow {
    final balances = _balances;
    if (balances.length < 6) return 0;
    final stoppedNow = balances[5] * math.pow(1.07, _yearsToRetirement - 5);
    return balances.last - stoppedNow;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(0)}k';
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> get _outputs => {
    'monthly_amount': _monthlyAmount,
    'start_age': _startAge,
    'balance_at_retirement': _balances.last,
    'doubling_date': _doublingDate.toIso8601String(),
    'doubling_age': _doublingAge,
    'cost_of_stopping_now': _costOfStoppingNow,
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
          _buildControls(),
          const SizedBox(height: 24),
          _buildChart(),
          const SizedBox(height: 16),
          _buildDoublingCard(),
          const SizedBox(height: 12),
          _buildStoppingCostCard(),
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
        Text('Your lily pad pond.', style: GoogleFonts.playfairDisplay(fontSize: 20, fontStyle: FontStyle.italic, color: night)),
        const SizedBox(height: 6),
        Text(
          'It looks flat for a long time. That\'s not nothing happening. That\'s everything being prepared.',
          style: GoogleFonts.dmSans(fontSize: 13, color: midSage, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly amount', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: night)),
                  Slider(
                    value: _monthlyAmount.clamp(25, 500),
                    min: 25,
                    max: 500,
                    divisions: 19,
                    activeColor: horizonOrange,
                    inactiveColor: sagePale,
                    onChanged: (v) {
                      setState(() => _monthlyAmount = v);
                      _animController.forward(from: 0);
                    },
                  ),
                  Center(
                    child: Text(
                      '\$${_monthlyAmount.toStringAsFixed(0)}/month',
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: horizonOrange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Starting age: ', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: night)),
            Expanded(
              child: Slider(
                value: _startAge.toDouble().clamp(20, 60),
                min: 20,
                max: 60,
                divisions: 40,
                activeColor: deepSage,
                inactiveColor: sagePale,
                onChanged: (v) {
                  setState(() => _startAge = v.toInt());
                  _animController.forward(from: 0);
                },
              ),
            ),
            Text('$_startAge', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: deepSage)),
          ],
        ),
      ],
    );
  }

  Widget _buildChart() {
    return AnimatedBuilder(
      animation: _drawAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 200),
          painter: _CurvePainter(
            balances: _balances,
            drawProgress: _drawAnimation.value,
            doublingYear: _doublingYears,
            deepSage: deepSage,
            sagePale: sagePale,
            crownGold: crownGold,
            pond: pond,
          ),
        );
      },
    );
  }

  Widget _buildDoublingCard() {
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
          Text('YOUR DAY 46', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: crownGold, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(
            'Your money first doubles in ${_formatDate(_doublingDate)}.',
            style: GoogleFonts.playfairDisplay(fontSize: 16, fontStyle: FontStyle.italic, color: deepSage),
          ),
          Text('You will be $_doublingAge.', style: GoogleFonts.dmSans(fontSize: 13, color: midSage)),
        ],
      ),
    );
  }

  Widget _buildStoppingCostCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HLGColors.antiqueRose.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: HLGColors.antiqueRose, width: 4)),
      ),
      child: Text(
        'Cost of stopping today: ${_formatCurrency(_costOfStoppingNow)} less at retirement.',
        style: GoogleFonts.dmSans(fontSize: 14, color: HLGColors.antiqueRose, height: 1.5),
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
            onPressed: () => widget.onAddGoal('Stay invested – my Day 46 is ${_formatDate(_doublingDate)}'),
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

class _CurvePainter extends CustomPainter {
  final List<double> balances;
  final double drawProgress;
  final int doublingYear;
  final Color deepSage;
  final Color sagePale;
  final Color crownGold;
  final Color pond;

  const _CurvePainter({
    required this.balances,
    required this.drawProgress,
    required this.doublingYear,
    required this.deepSage,
    required this.sagePale,
    required this.crownGold,
    required this.pond,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (balances.isEmpty) return;
    final maxBalance = balances.reduce(math.max);
    if (maxBalance <= 0) return;

    final paint = Paint()
      ..color = deepSage
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = deepSage.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final pointsToShow = (balances.length * drawProgress).ceil().clamp(2, balances.length);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < pointsToShow; i++) {
      final x = (i / (balances.length - 1)) * size.width;
      final y = size.height - (balances[i] / maxBalance) * size.height * 0.9 - 10;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(((pointsToShow - 1) / (balances.length - 1)) * size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    if (doublingYear < balances.length) {
      final markerX = (doublingYear / (balances.length - 1)) * size.width;
      final markerY = size.height - (balances[doublingYear] / maxBalance) * size.height * 0.9 - 10;

      final markerPaint = Paint()
        ..color = crownGold
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(markerX, 0), Offset(markerX, size.height), markerPaint);
      canvas.drawCircle(Offset(markerX, markerY), 5, Paint()..color = crownGold);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(text: 'Year 0', style: TextStyle(color: sagePale, fontSize: 10));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, size.height - 16));

    textPainter.text = TextSpan(text: 'Year ${balances.length - 1}', style: TextStyle(color: sagePale, fontSize: 10));
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 50, size.height - 16));
  }

  @override
  bool shouldRepaint(_CurvePainter old) => old.drawProgress != drawProgress || old.balances != balances;
}
