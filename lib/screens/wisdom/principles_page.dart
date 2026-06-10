import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PrinciplesPage extends StatelessWidget {
  const PrinciplesPage({super.key});

  static const Color deepSage = Color(0xFF5C7A62);
  static const Color crownGold = Color(0xFFB8923A);
  static const Color warmCream = Color(0xFFF7F5F0);
  static const Color night = Color(0xFF161E17);
  static const Color midSage = Color(0xFF8A9E8D);
  static const Color horizonOrange = Color(0xFFD4621A);
  static const Color petal = Color(0xFFEDE0D4);
  static const Color sagePale = Color(0xFFD4E0D6);
  static const Color textBody = Color(0xFF2A3A2C);

  static const List<Map<String, String>> _principles = [
    {
      'number': '01',
      'heading': 'Spend less than you earn.',
      'body': 'The oldest principle in personal finance. Everything else builds on this one. Not glamorous. Not optional.',
    },
    {
      'number': '02',
      'heading': 'Understand what money actually is.',
      'body': 'Money is a tool for storing your time, effort, and skill so you can exchange it later. It is not a measure of your worth. It is an agreement — and agreements can be understood.',
    },
    {
      'number': '03',
      'heading': 'Inflation is not neutral.',
      'body': 'Cash held still moves backwards. Every year. Quietly. No notification. Understanding this changes every decision you make about where your money sits.',
    },
    {
      'number': '04',
      'heading': 'Assets beat cash over time.',
      'body': 'Things that hold or grow their value outperform cash over long periods. Not always. Not without risk. But consistently enough to matter across a lifetime.',
    },
    {
      'number': '05',
      'heading': 'Time is the most powerful variable.',
      'body': 'Compound growth is not about returns. It is about time. Starting earlier with less beats starting later with more — almost every time.',
    },
    {
      'number': '06',
      'heading': 'The system was not built for you.',
      'body': 'The gender pay gap, the super gap, the unpaid labour gap — structural, not personal. The gap was never in you. The gap was in what you were given.',
    },
    {
      'number': '07',
      'heading': 'Your income is not fixed.',
      'body': 'A salary is a starting point. Skills compound. Negotiation works. Your earning capacity is a lever — and levers can be pulled.',
    },
    {
      'number': '08',
      'heading': 'Debt is a tool, not a character flaw.',
      'body': 'Productive debt builds assets. Consumptive debt funds things that disappear. The question is: will what I borrowed for still exist when the debt is paid?',
    },
    {
      'number': '09',
      'heading': 'Sound money holds its value.',
      'body': 'Hard money is scarce by design. Fiat currency is printed by choice. Since 1971 every dollar has been backed by a promise. Understanding this is 21st century financial literacy.',
    },
    {
      'number': '10',
      'heading': 'Financial education is intergenerational.',
      'body': 'What you learn, you pass on. The principles that built wealth in 1971 are the same ones that build it now. Teaching them forward is the whole point.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: warmCream,
              surfaceTintColor: Colors.transparent,
              floating: true,
              leadingWidth: 132,
              leading: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: deepSage),
                      onPressed: () => context.pop(),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 6),
                    Image.asset('assets/images/Her_Long_Game-01.png', height: 20, fit: BoxFit.contain),
                  ],
                ),
              ),
              title: Text(
                'The Ten Principles',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textBody,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The foundations Her Long Game is built on.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontStyle: FontStyle.italic,
                        color: night,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Not rules. Not advice. Principles — the kind that held true in 1971 and will hold true when you explain them to your daughter.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: midSage,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(height: 1, color: crownGold.withValues(alpha: 0.3)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == _principles.length) return _buildClosingStatement();
                  return _buildPrincipleCard(_principles[index], index);
                },
                childCount: _principles.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipleCard(Map<String, String> principle, int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: index.isEven ? petal : warmCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: crownGold.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16, top: 2),
            decoration: BoxDecoration(
              color: crownGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                principle['number']!,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: crownGold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  principle['heading']!,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: night,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  principle['body']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: textBody,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingStatement() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 48),
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
            'THE ONE SENTENCE',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: crownGold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Earn more than you spend, protect what you earn from inflation, put it in things that grow, give it time, and understand the system you are operating inside.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: warmCream,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          // Removed per product direction.
        ],
      ),
    );
  }
}
