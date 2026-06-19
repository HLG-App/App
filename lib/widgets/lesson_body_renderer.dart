import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:her_long_game/widgets/her_cheat_sheet.dart';
import 'package:her_long_game/widgets/research_ref_widget.dart';
import 'package:her_long_game/theme.dart';

/// Renders lesson body text with inline glossary terms wrapped in **double asterisks**.
///
/// Parsing rules:
/// - Split by '\n' into lines
/// - Terms wrapped in **term** become tappable [HerCheatSheet]
/// - Empty lines separate paragraphs
/// - Adds 16px gap between paragraphs and 80px bottom padding after all content
class LessonBodyRenderer extends StatelessWidget {
  final String bodyText;
  /// Optional screen type (e.g. 'mirror', 'story').
  ///
  /// If provided as 'mirror', the renderer will emphasize the final sentence
  /// per product spec. When omitted, the renderer behaves as before.
  final String? screenType;

  const LessonBodyRenderer({super.key, required this.bodyText, this.screenType});

  static String _normalizeSpoilerLineBreaks(String input) {
    // If lesson content contains an inline "Spoiler" clause, force it to start on a
    // new paragraph line for readability.
    // Example: "... journey. Spoiler: ..." -> "... journey.\n\nSpoiler: ..."
    return input.replaceAllMapped(
      RegExp(r'([^\n])\s+(Spoiler\b)', caseSensitive: false),
      (m) => '${m.group(1)}\n\n${m.group(2)}',
    );
  }


  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeSpoilerLineBreaks(bodyText);
    final lastSentence = normalized.split('. ').last.trim();
    final emphasizeLastSentence = (screenType ?? '').toLowerCase() == 'mirror' && lastSentence.isNotEmpty;
    final blocks = _parseBlocks(normalized);

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < blocks.length; i++) ...[
            _BodyBlockWidget(block: blocks[i], emphasizeLastSentence: emphasizeLastSentence, lastSentence: lastSentence),
            if (i != blocks.length - 1)
              SizedBox(height: blocks[i].kind == _BodyBlockKind.definitionOrList ? 12 : 16),
          ],
        ],
      ),
    );
  }

  List<_BodyBlock> _parseBlocks(String text) {
    // First split on explicit newlines: each newline creates a new paragraph block.
    final rawBlocks = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);

    final blocks = <_BodyBlock>[];
    for (final raw in rawBlocks) {
      // Special-case: some screens include multiple "Layer X — ..." definition lines
      // inside a single paragraph. Split them so each layer renders as its own
      // definition callout card.
      final layerSplit = _splitLayerDefinitions(raw);
      if (layerSplit.length > 1) {
        for (final piece in layerSplit) {
          if (piece.length > 180) {
            blocks.addAll(_splitLongBlock(piece).map(_classifyBlock));
          } else {
            blocks.add(_classifyBlock(piece));
          }
        }
        continue;
      }

      if (raw.length > 180) {
        blocks.addAll(_splitLongBlock(raw).map(_classifyBlock));
      } else {
        blocks.add(_classifyBlock(raw));
      }
    }

    // Lead-in: first paragraph first sentence slightly larger/bolder.
    final firstIndex = blocks.indexWhere((b) => b.kind == _BodyBlockKind.normal && !b.isPunchy);
    if (firstIndex != -1) {
      final first = blocks[firstIndex];
      final sentences = _splitIntoSentences(first.text);
      if (sentences.length > 1) {
        blocks[firstIndex] = first.copyWith(text: sentences.first, isLead: true);
        final remaining = sentences.skip(1).join(' ').trim();
        if (remaining.isNotEmpty) {
          blocks.insert(firstIndex + 1, _classifyBlock(remaining));
        }
      } else {
        blocks[firstIndex] = first.copyWith(isLead: true);
      }
    }

    return blocks;
  }

  /// Splits a paragraph that contains multiple "Layer X" definitions into
  /// separate blocks so each definition can render cleanly.
  ///
  /// Example input:
  /// "Layer 1 – ... Layer 2 – ... Layer 3 – ..."
  static List<String> _splitLayerDefinitions(String block) {
    final regex = RegExp(r'(?:^|\s)(Layer\s+[0-9]+[A-Za-z]?\s+[—–]\s+)');
    final matches = regex.allMatches(block).toList(growable: false);
    if (matches.length <= 1) return [block.trim()];

    // We split by finding each "Layer X" prefix and taking text until the next.
    final starts = <int>[];
    for (final m in matches) {
      // Use the start of the word "Layer" not the preceding whitespace.
      final full = m.group(0) ?? '';
      final layerIndex = full.indexOf('Layer');
      starts.add(m.start + (layerIndex < 0 ? 0 : layerIndex));
    }

    final out = <String>[];
    for (var i = 0; i < starts.length; i++) {
      final start = starts[i];
      final end = (i + 1 < starts.length) ? starts[i + 1] : block.length;
      final piece = block.substring(start, end).trim();
      if (piece.isNotEmpty) out.add(piece);
    }
    return out.isEmpty ? [block.trim()] : out;
  }

  List<String> _splitLongBlock(String block) {
    final sentences = _splitIntoSentences(block);
    if (sentences.length <= 1) return [block];

    final grouped = <String>[];
    for (var i = 0; i < sentences.length; i += 2) {
      final chunk = <String>[sentences[i]];
      if (i + 1 < sentences.length) chunk.add(sentences[i + 1]);
      grouped.add(chunk.join(' ').trim());
    }
    return grouped;
  }

  List<String> _splitIntoSentences(String text) {
    // Patterns are tried in priority order until we get a useful split.
    final splitters = <_SentenceSplitter>[
      _SentenceSplitter.regex(RegExp(r'\. (?=[A-Z])')),
      _SentenceSplitter.literal('. Then '),
      _SentenceSplitter.literal('. But '),
      _SentenceSplitter.literal('. And '),
      _SentenceSplitter.literal('. The '),
      _SentenceSplitter.literal('. In '),
      _SentenceSplitter.literal('. After '),
      _SentenceSplitter.literal('. When '),
    ];

    for (final splitter in splitters) {
      final parts = splitter.split(text);
      if (parts.length > 1) return parts;
    }
    return [text];
  }

  _BodyBlock _classifyBlock(String text) {
    final t = text.trim();

    final isNumbered = RegExp(r'^\s*\d+[\.)]\s+').hasMatch(t);
    final isBulleted = RegExp(r'^\s*[-•]\s+').hasMatch(t);

    final dashIndex = t.indexOf(' — ') >= 0 ? t.indexOf(' — ') : t.indexOf(' – ');
    final isDefinition = dashIndex != -1 && _wordCount(t.substring(0, dashIndex)) <= 4;

    if (isNumbered || isBulleted || isDefinition) {
      return _BodyBlock(text: t, kind: _BodyBlockKind.definitionOrList, isDefinition: isDefinition);
    }

    final isPunchy = t.length < 60;
    return _BodyBlock(text: t, kind: _BodyBlockKind.normal, isPunchy: isPunchy);
  }

  int _wordCount(String s) => s.trim().isEmpty ? 0 : s.trim().split(RegExp(r'\s+')).length;
}

/// Intro-screen renderer: clean reading (no **term** highlighting, no {{ref}} widgets).
/// Splits on double newlines into paragraph blocks and supports "Word – definition" formatting.
class IntroLessonBodyRenderer extends StatelessWidget {
  final String bodyText;

  const IntroLessonBodyRenderer({super.key, required this.bodyText});

  static final RegExp _definitionLine = RegExp(r'^([A-Z][A-Za-z]+)\s+[—–]\s+(.+)$');

  @override
  Widget build(BuildContext context) {
    final normalized = LessonBodyRenderer._normalizeSpoilerLineBreaks(bodyText);
    final blocks = normalized.split(RegExp(r'\n\n+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          _IntroParagraph(text: blocks[i]),
          if (i != blocks.length - 1) const SizedBox(height: 16),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class _IntroParagraph extends StatelessWidget {
  final String text;

  const _IntroParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
    final m = IntroLessonBodyRenderer._definitionLine.firstMatch(text);
    if (m == null) {
      return Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 15, color: HLGColors.warmCream.withValues(alpha: 0.85), height: 1.8),
      );
    }

    final leading = (m.group(1) ?? '').trim();
    final rest = (m.group(2) ?? '').trim();
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: leading,
            style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: HLGColors.crownGold, height: 1.8),
          ),
          TextSpan(
            text: ' – ',
            style: GoogleFonts.dmSans(fontSize: 15, color: HLGColors.warmCream.withValues(alpha: 0.4), height: 1.8),
          ),
          TextSpan(
            text: rest,
            style: GoogleFonts.dmSans(fontSize: 15, color: HLGColors.warmCream.withValues(alpha: 0.85), height: 1.8),
          ),
        ],
      ),
    );
  }
}

enum _BodyBlockKind { normal, definitionOrList }

class _BodyBlock {
  final String text;
  final _BodyBlockKind kind;
  final bool isLead;
  final bool isPunchy;
  final bool isDefinition;

  const _BodyBlock({required this.text, required this.kind, this.isLead = false, this.isPunchy = false, this.isDefinition = false});

  _BodyBlock copyWith({String? text, _BodyBlockKind? kind, bool? isLead, bool? isPunchy, bool? isDefinition}) =>
      _BodyBlock(
        text: text ?? this.text,
        kind: kind ?? this.kind,
        isLead: isLead ?? this.isLead,
        isPunchy: isPunchy ?? this.isPunchy,
        isDefinition: isDefinition ?? this.isDefinition,
      );
}

class _BodyBlockWidget extends StatelessWidget {
  final _BodyBlock block;
  final bool emphasizeLastSentence;
  final String lastSentence;
  const _BodyBlockWidget({required this.block, required this.emphasizeLastSentence, required this.lastSentence});

  static const String _finalLandingQuote =
      'It is a technology that was invented designed and its controlled by people.';

  static const Set<String> _finalLandingLines = {
    'The tools existed.',
    'Women were locked out of owning them.',
  };

  static String _normalizeWhitespace(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static final RegExp _termRegex = RegExp(r'\*\*([^*]+)\*\*');
  static final RegExp _refRegex = RegExp(r'\{\{([^}]+)\}\}');

  @override
  Widget build(BuildContext context) {
    final normalizedBlock = _normalizeWhitespace(block.text);

    if (normalizedBlock == _normalizeWhitespace(_finalLandingQuote) ||
        _finalLandingLines.any((l) => normalizedBlock == _normalizeWhitespace(l))) {
      return FinalLandingQuoteCallout(text: block.text);
    }
    if (block.kind == _BodyBlockKind.definitionOrList) {
      return _DefinitionOrListBlock(text: block.text, isDefinition: block.isDefinition);
    }

    if (block.isPunchy) {
      return Text(
        block.text,
        style: GoogleFonts.playfairDisplay(
          fontSize: 17,
          fontStyle: FontStyle.italic,
          color: HLGColors.deepSage,
          height: 1.5,
        ),
      );
    }

    final baseStyle = block.isLead
        ? GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: HLGColors.textBody, height: 1.7)
        : GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: HLGColors.textBody, height: 1.7);

    return RichText(text: _buildRhythmSpan(block.text, baseStyle));
  }

  static const Set<String> _humourEndings = {'anyway.', 'speaking.', 'trying.', 'ever since.', 'thing.'};

  TextSpan _buildRhythmSpan(String text, TextStyle plainStyle) {
    // If this block contains multiple sentences, we still want to detect humour
    // sentences ending with the specified tokens and render them in Playfair.
    // We build a sequence of InlineSpans sentence-by-sentence.
    final sentenceParts = text.split('. ');
    if (sentenceParts.length <= 1) return _buildSpanWithMarkers(text, plainStyle);

    final spans = <InlineSpan>[];
    for (var i = 0; i < sentenceParts.length; i++) {
      var sentence = sentenceParts[i].trim();
      if (sentence.isEmpty) continue;
      final isLastInBlock = i == sentenceParts.length - 1;
      // Re-add the period that was removed by split, except possibly when
      // the original sentence already ended in punctuation.
      if (!sentence.endsWith('.') && !sentence.endsWith('!') && !sentence.endsWith('?')) sentence = '$sentence.';

      final normalizedEnd = sentence.toLowerCase();
      final isHumour = _humourEndings.any((ending) => normalizedEnd.endsWith(ending));
      final isMirrorLastSentence = emphasizeLastSentence && sentence.replaceAll('.', '').trim() == lastSentence.replaceAll('.', '').trim();

      final style = isHumour
          ? GoogleFonts.playfairDisplay(fontSize: 16, fontStyle: FontStyle.italic, color: HLGColors.deepSage, height: 1.7)
          : (isMirrorLastSentence
              ? plainStyle.copyWith(fontWeight: FontWeight.w600, color: HLGColors.textBody)
              : plainStyle);

      spans.add(_buildSpanWithMarkers(sentence, style));
      if (!isLastInBlock) spans.add(TextSpan(text: ' ', style: plainStyle));
    }
    return TextSpan(children: spans, style: plainStyle);
  }

  TextSpan _buildSpanWithMarkers(String line, TextStyle plainStyle) {
    // Required parsing order:
    // 1) **term** markers
    // 2) {{refId}} markers
    final spansAfterTerms = _splitByTermMarkers(line, plainStyle);
    final spansAfterRefs = <InlineSpan>[];
    for (final span in spansAfterTerms) {
      if (span is TextSpan && (span.text?.isNotEmpty ?? false) && (span.children?.isEmpty ?? true)) {
        spansAfterRefs.addAll(_splitTextSpanByRefMarkers(span, plainStyle));
      } else {
        spansAfterRefs.add(span);
      }
    }
    return TextSpan(children: spansAfterRefs, style: plainStyle);
  }

  List<InlineSpan> _splitByTermMarkers(String line, TextStyle plainStyle) {
    final matches = _termRegex.allMatches(line).toList(growable: false);
    if (matches.isEmpty) return [TextSpan(text: line, style: plainStyle)];

    final children = <InlineSpan>[];
    var cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) children.add(TextSpan(text: line.substring(cursor, m.start), style: plainStyle));
      final extracted = (m.group(1) ?? '').trim();
      if (extracted.isNotEmpty) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HerCheatSheet(term: extracted, displayText: extracted),
          ),
        );
      }
      cursor = m.end;
    }
    if (cursor < line.length) children.add(TextSpan(text: line.substring(cursor), style: plainStyle));
    return children;
  }

  List<InlineSpan> _splitTextSpanByRefMarkers(TextSpan span, TextStyle plainStyle) {
    final text = span.text ?? '';
    final matches = _refRegex.allMatches(text).toList(growable: false);
    if (matches.isEmpty) return [TextSpan(text: text, style: plainStyle)];

    final out = <InlineSpan>[];
    var cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) out.add(TextSpan(text: text.substring(cursor, m.start), style: plainStyle));
      final refId = (m.group(1) ?? '').trim();
      if (refId.isNotEmpty) {
        out.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ResearchRefWidget(refId: refId),
            ),
          ),
        );
      }
      cursor = m.end;
    }
    if (cursor < text.length) out.add(TextSpan(text: text.substring(cursor), style: plainStyle));
    return out;
  }
}

/// A "final landing" callout used when a lesson ends on a key reframing line.
///
/// This is intentionally editorial (Playfair italic) and centered, so the point
/// lands as a standalone thought.
class FinalLandingQuoteCallout extends StatelessWidget {
  const FinalLandingQuoteCallout({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: HLGColors.warmCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HLGColors.sageTint),
          boxShadow: [
            BoxShadow(
              color: HLGColors.deepSage.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Text(
          text.trim(),
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            height: 1.35,
            color: HLGColors.textBody,
          ),
        ),
      ),
    );
  }
}

class _DefinitionOrListBlock extends StatelessWidget {
  final String text;
  final bool isDefinition;
  const _DefinitionOrListBlock({required this.text, required this.isDefinition});

  static final RegExp _termRegex = RegExp(r'\*\*([^*]+)\*\*');
  static final RegExp _refRegex = RegExp(r'\{\{([^}]+)\}\}');

  @override
  Widget build(BuildContext context) {
    // Definition-style: 'Short term – explanation'
    if (isDefinition && (text.contains(' — ') || text.contains(' – '))) {
      final parts = text.contains(' – ') ? text.split(' – ') : text.split(' — ');
      final left = parts.first.trim();
      final right = parts.skip(1).join(' – ').trim();

      final leftStyle = GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: HLGColors.textBody, height: 1.7);
      final dashStyle = GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: HLGColors.sageMid, height: 1.7);
      final rightStyle = GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: HLGColors.textBody, height: 1.7);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: HLGColors.petal,
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: HLGColors.crownGold, width: 4)),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              ..._inlineSpansFromText(left, leftStyle),
              TextSpan(text: ' – ', style: dashStyle),
              ..._inlineSpansFromText(right, rightStyle),
            ],
          ),
        ),
      );
    }

    // Numbered/bulleted lines: keep rhythm but still allow **term** parsing.
    final style = GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: HLGColors.textBody, height: 1.7);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: RichText(text: TextSpan(children: _inlineSpansFromText(text, style))),
    );
  }

  List<InlineSpan> _inlineSpansFromText(String line, TextStyle plainStyle) {
    // Keep the same parsing order as normal blocks: **term** first, then {{refId}}.
    final afterTerms = _splitByTermMarkers(line, plainStyle);
    final afterRefs = <InlineSpan>[];
    for (final span in afterTerms) {
      if (span is TextSpan && (span.text?.isNotEmpty ?? false) && (span.children?.isEmpty ?? true)) {
        afterRefs.addAll(_splitTextSpanByRefMarkers(span, plainStyle));
      } else {
        afterRefs.add(span);
      }
    }
    return afterRefs;
  }

  List<InlineSpan> _splitByTermMarkers(String line, TextStyle plainStyle) {
    final matches = _termRegex.allMatches(line).toList(growable: false);
    if (matches.isEmpty) return [TextSpan(text: line, style: plainStyle)];

    final children = <InlineSpan>[];
    var cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) children.add(TextSpan(text: line.substring(cursor, m.start), style: plainStyle));
      final extracted = (m.group(1) ?? '').trim();
      if (extracted.isNotEmpty) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HerCheatSheet(term: extracted, displayText: extracted),
          ),
        );
      }
      cursor = m.end;
    }
    if (cursor < line.length) children.add(TextSpan(text: line.substring(cursor), style: plainStyle));
    return children;
  }

  List<InlineSpan> _splitTextSpanByRefMarkers(TextSpan span, TextStyle plainStyle) {
    final text = span.text ?? '';
    final matches = _refRegex.allMatches(text).toList(growable: false);
    if (matches.isEmpty) return [TextSpan(text: text, style: plainStyle)];

    final out = <InlineSpan>[];
    var cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) out.add(TextSpan(text: text.substring(cursor, m.start), style: plainStyle));
      final refId = (m.group(1) ?? '').trim();
      if (refId.isNotEmpty) {
        out.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ResearchRefWidget(refId: refId),
            ),
          ),
        );
      }
      cursor = m.end;
    }
    if (cursor < text.length) out.add(TextSpan(text: text.substring(cursor), style: plainStyle));
    return out;
  }
}

class _SentenceSplitter {
  final RegExp? _regex;
  final String? _literal;

  const _SentenceSplitter._({RegExp? regex, String? literal}) : _regex = regex, _literal = literal;

  factory _SentenceSplitter.regex(RegExp regex) => _SentenceSplitter._(regex: regex);
  factory _SentenceSplitter.literal(String literal) => _SentenceSplitter._(literal: literal);

  List<String> split(String text) {
    if (_regex != null) return _splitByRegex(text, _regex);
    if (_literal != null) return _splitByLiteral(text, _literal);
    return [text];
  }

  List<String> _splitByRegex(String text, RegExp delimiter) {
    final matches = delimiter.allMatches(text).toList(growable: false);
    if (matches.isEmpty) return [text];

    final out = <String>[];
    var cursor = 0;
    for (final m in matches) {
      final end = m.start + 1; // include '.'
      final sentence = text.substring(cursor, end).trim();
      if (sentence.isNotEmpty) out.add(sentence);
      cursor = m.end;
    }
    final tail = text.substring(cursor).trim();
    if (tail.isNotEmpty) out.add(tail);
    return out;
  }

  List<String> _splitByLiteral(String text, String literal) {
    final idx = text.indexOf(literal);
    if (idx == -1) return [text];

    // Split into pseudo-sentences by keeping the delimiter word with the next part.
    final parts = text.split(literal);
    if (parts.length <= 1) return [text];

    final out = <String>[];
    out.add(parts.first.trim());
    for (final p in parts.skip(1)) {
      out.add('${literal.trimLeft()}${p}'.trim());
    }
    return out.where((e) => e.isNotEmpty).toList(growable: false);
  }
}
