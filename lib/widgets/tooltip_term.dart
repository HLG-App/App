import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HLGTooltipTerm extends StatelessWidget {
  const HLGTooltipTerm({super.key, required this.term, required this.plainEnglish, this.cutTheCrap});

  final String term;
  final String plainEnglish;
  final String? cutTheCrap;

  static const _warmCream = Color(0xFFF7F5F0);
  static const _crownGold = Color(0xFFB8923A);
  static const _horizonOrange = Color(0xFFD4621A);
  static const _deepSage = Color(0xFF5C7A62);
  static const _midSage = Color(0xFF8A9E8D);
  static const _textBody = _midSage;

  @override
  Widget build(BuildContext context) {
    return _DottedUnderlineTap(
      text: term,
      textStyle: DefaultTextStyle.of(context).style,
      underlineColor: _crownGold,
      onTap: () => _showSheet(context),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _warmCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      builder: (context) {
        final hasCut = (cutTheCrap != null && cutTheCrap!.trim().isNotEmpty);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HER CHEAT SHEET',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: _crownGold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  term,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: _deepSage,
                  ),
                ),
                const SizedBox(height: 14),
                Container(height: 1, width: double.infinity, color: _crownGold),
                const SizedBox(height: 14),
                Text(
                  plainEnglish,
                  style: GoogleFonts.dmSans(fontSize: 16, height: 1.55, color: _textBody),
                ),
                if (hasCut) ...[
                  const SizedBox(height: 16),
                  Text(
                    'CUT THE CRAP',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: _horizonOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cutTheCrap!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.55,
                      color: _midSage,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: _deepSage),
                    child: Text('Got it', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DottedUnderlineTap extends StatelessWidget {
  const _DottedUnderlineTap({
    required this.text,
    required this.textStyle,
    required this.underlineColor,
    required this.onTap,
  });

  final String text;
  final TextStyle textStyle;
  final Color underlineColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: CustomPaint(
        painter: _DottedUnderlinePainter(text: text, style: textStyle, color: underlineColor),
        child: Text(text, style: textStyle),
      ),
    );
  }
}

class _DottedUnderlinePainter extends CustomPainter {
  _DottedUnderlinePainter({required this.text, required this.style, required this.color});

  final String text;
  final TextStyle style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final width = textPainter.width;
    final y = textPainter.height - 1.0;

    const dotWidth = 2.0;
    const gap = 2.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    double x = 0;
    while (x < width) {
      canvas.drawLine(Offset(x, y), Offset((x + dotWidth).clamp(0, width), y), paint);
      x += dotWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedUnderlinePainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.style != style || oldDelegate.color != color;
  }
}
