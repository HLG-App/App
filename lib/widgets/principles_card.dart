import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:her_long_game/theme.dart';

class PrinciplesCard extends StatelessWidget {
  const PrinciplesCard({super.key, this.compact = false});

  /// When true, renders a slim display-only teaser (no full 10-item list).
  /// Tapping still navigates to the full `/principles` page.
  final bool compact;

  static const List<String> _principles = [
    'The system was not built for you.',
    'Money is a tool. Understand the tool first.',
    'Sound money holds its value.',
    'Inflation quietly changes the game.',
    'Assets beat cash over time.',
    'Time does the heavy lifting.',
    'Spend less than you earn. Shockingly revolutionary.',
    'Your income is not fixed.',
    'Debt is a tool, not a character flaw.',
    'Financial education is intergenerational.',
  ];

  @override
  Widget build(BuildContext context) {
    final Color warmCream = HLGColors.warmCream;
    final Color crownGold = HLGColors.crownGold;
    final Color midSage = HLGColors.midSage;

    if (compact) {
      return GestureDetector(
        onTap: () => context.push('/principles'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: warmCream,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: crownGold, width: 3)),
            boxShadow: [
              BoxShadow(
                color: HLGColors.midSage.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
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
                    const SizedBox(height: 6),
                    Text(
                      'The foundations Her Long Game is built on.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: HLGColors.night,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to read · 3 min',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: midSage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, color: crownGold, size: 22),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.push('/principles'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: warmCream,
          borderRadius: BorderRadius.circular(16),
          border: Border(top: BorderSide(color: crownGold, width: 4)),
          boxShadow: [
            BoxShadow(color: HLGColors.midSage.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HER LONG GAME: THE TEN PRINCIPLES',
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
                color: HLGColors.night,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool twoColumn = constraints.maxWidth >= 360;
                final List<String> left = _principles.take(5).toList(growable: false);
                final List<String> right = _principles.skip(5).take(5).toList(growable: false);

                return twoColumn
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _PrinciplesMiniList(items: left, startIndex: 0)),
                          const SizedBox(width: 14),
                          Expanded(child: _PrinciplesMiniList(items: right, startIndex: 5)),
                        ],
                      )
                    : _PrinciplesMiniList(items: _principles, startIndex: 0);
              },
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: crownGold.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tap to read the deeper notes →',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: crownGold,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
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

class _PrinciplesMiniList extends StatelessWidget {
  const _PrinciplesMiniList({required this.items, required this.startIndex});

  final List<String> items;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    final Color crownGold = HLGColors.crownGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        items.length,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: crownGold.withValues(alpha: 0.55), width: 1),
                ),
                child: Center(
                  child: Text(
                    '${startIndex + i + 1}',
                    style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: crownGold),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  items[i],
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: HLGColors.textBody,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
