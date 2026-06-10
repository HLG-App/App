import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PrinciplesCard extends StatelessWidget {
  const PrinciplesCard({super.key});

  static const Color deepSage = Color(0xFF5C7A62);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = Color(0xFF161E17);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color petal = Color(0xFFEDE0D4);

  static const List<String> _principles = [
    'Spend less than you earn.',
    'Understand what money actually is.',
    'Inflation is not neutral.',
    'Assets beat cash over time.',
    'Time is the most powerful variable.',
    'The system was not built for you.',
    'Your income is not fixed.',
    'Debt is a tool, not a character flaw.',
    'Sound money holds its value.',
    'Financial education is intergenerational.',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/principles'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: night,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            top: BorderSide(color: Color(0xFFB8923A), width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE TEN PRINCIPLES',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: crownGold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The foundations Her Long Game is built on.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: warmCream,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 10, top: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: crownGold.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: crownGold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _principles[i],
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: warmCream.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: crownGold.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '+7 more principles →',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: crownGold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Text(
                  '3 min',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: midSage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
