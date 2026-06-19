import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:her_long_game/data/lesson_names.dart';
import 'package:her_long_game/supabase/supabase_config.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/data/repositories/lesson_repository.dart';
import 'package:her_long_game/data/repositories/user_repository.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';
import 'package:her_long_game/widgets/lesson_body_renderer.dart';
import 'package:her_long_game/utils/lesson_flow.dart';
import 'package:her_long_game/widgets/tool_bottom_sheet.dart';
// Avoid relying on PostgrestException here because SupabaseService wraps errors.

class LessonScreenPage extends StatefulWidget {
  const LessonScreenPage({super.key, required this.lessonCode, this.initialScreenIndex = 0});

  final String lessonCode;
  final int initialScreenIndex;

  @override
  State<LessonScreenPage> createState() => _LessonScreenPageState();
}

class _LessonScreenPageState extends State<LessonScreenPage> {
  final LessonRepository _lessonRepo = LessonRepository();
  final UserRepository _userRepo = UserRepository();

  final TextEditingController _reflectionController = TextEditingController();

  int _currentScreenIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _comingSoon = false;

  _LessonScreen? _screen;
  String? _selectedOption;
  String _reflectionText = '';

  @override
  void initState() {
    super.initState();
    _currentScreenIndex = widget.initialScreenIndex;
    _reflectionController.addListener(() {
      final v = _reflectionController.text;
      if (v == _reflectionText) return;
      setState(() => _reflectionText = v);
    });
    _loadScreen();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LessonScreenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonCode != widget.lessonCode || oldWidget.initialScreenIndex != widget.initialScreenIndex) {
      _currentScreenIndex = widget.initialScreenIndex;
      _selectedOption = null;
      _screen = null;
      _error = null;
      _comingSoon = false;
      _isLoading = true;
      _loadScreen();
    }
  }

  Future<void> _loadScreen() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _comingSoon = false;
    });

    try {
      debugPrint('[loadScreen] START lessonCode=${widget.lessonCode} screenIndex=$_currentScreenIndex');
      final filters = <String, dynamic>{'lesson_code': widget.lessonCode, 'screen_index': _currentScreenIndex.toInt()};

      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        context.go('/auth');
        return;
      }

      Map<String, dynamic>? row;
      try {
        row = await SupabaseService.selectSingle(
          'lesson_screens',
          filters: filters,
          select: 'screen_type,heading,body_text,options,image_url,tool_code',
        );
      } catch (e) {
        // SupabaseService wraps errors as Strings, so we must string-match.
        final msg = e.toString().toLowerCase();
        if (msg.contains('tool_code') && msg.contains('does not exist')) {
          debugPrint('[loadScreen] tool_code missing in DB; retrying select without tool_code');
          row = await SupabaseService.selectSingle(
            'lesson_screens',
            filters: filters,
            select: 'screen_type,heading,body_text,options,image_url',
          );
        } else {
          rethrow;
        }
      }

      debugPrint('[loadScreen] RESULT: $row');

      if (row == null) {
        debugPrint('[loadScreen] NULL screen: lesson_code=${widget.lessonCode} screen_index=$_currentScreenIndex');
        debugPrint(
          '[LessonScreenPage] No content found for lesson_code=${widget.lessonCode} screen_index=$_currentScreenIndex. '
          'Auto-advancing to keep the flow smooth.',
        );

        // IMPORTANT:
        // Many lessons (especially early “Before We Begin” content) may have a
        // finite set of authored screens without an explicit `complete` screen.
        // Previously, hitting the first missing screen index would route to the
        // close page, which could appear “blank” when no complete screen exists.
        //
        // Here we:
        // 1) Check if a `complete` screen exists for this lesson.
        // 2) If it exists → route to close.
        // 3) If not → mark the lesson complete and advance to the next lesson.
        if (!mounted) return;

        bool hasCompleteScreen = false;
        try {
          final complete = await SupabaseConfig.client
              .from('lesson_screens')
              .select('screen_type')
              .eq('lesson_code', widget.lessonCode)
              .eq('screen_type', 'complete')
              .limit(1);
          // ignore: unnecessary_type_check
          hasCompleteScreen = (complete is List) && complete.isNotEmpty;
        } catch (e) {
          debugPrint('[LessonScreenPage] Failed to check complete screen for ${widget.lessonCode}: $e');
        }

        // If we are at the beginning and nothing exists, do NOT route away.
        // Show a calm “Coming soon” state so the user isn’t stranded.
        if (_currentScreenIndex == 0 && !hasCompleteScreen) {
          bool hasAnyScreens = true;
          try {
            final any = await SupabaseConfig.client
                .from('lesson_screens')
                .select('screen_index')
                .eq('lesson_code', widget.lessonCode)
                .limit(1);
            // ignore: unnecessary_type_check
            hasAnyScreens = (any is List) && any.isNotEmpty;
          } catch (e) {
            debugPrint('[LessonScreenPage] Failed to check any screen for ${widget.lessonCode}: $e');
          }

          if (!hasAnyScreens) {
            if (!mounted) return;
            setState(() {
              _comingSoon = true;
              _screen = null;
            });
            return;
          }
        }

        if (hasCompleteScreen) {
          context.pushReplacement(LessonFlow.nextRouteAfterLesson(widget.lessonCode));
          return;
        }

        // No complete screen authored: complete silently and move on.
        try {
          final userId = SupabaseConfig.auth.currentUser?.id;
          if (userId != null) {
            await _lessonRepo.completeLesson(
              userId: userId,
              lessonCode: widget.lessonCode,
              finalScreenIndex: (_currentScreenIndex - 1).clamp(0, 1 << 30),
            );
          }
        } catch (e) {
          debugPrint('[LessonScreenPage] Failed to auto-complete ${widget.lessonCode}: $e');
        }

        context.pushReplacement(LessonFlow.nextRouteAfterClose(widget.lessonCode));
        return;
      }

      // Avoid a duplicated close experience.
      // Some lesson sets include a CMS-authored `complete` screen that ONLY
      // contains placeholder text like "Lesson complete." with a Continue
      // button. Our product spec is that the structured Carry This experience
      // lives in [LessonClosePage] (3 takeaways + notes). So we treat
      // `complete` as an end-marker only: auto-complete the lesson and route
      // directly to the close page WITHOUT ever setting `_screen` (which
      // would otherwise cause the CMS complete screen to render for a frame
      // and let the user tap its Continue button — creating the duplicate
      // "Carry this / Lesson complete." screen reported in QA).
      final parsedType = (row['screen_type'] ?? '').toString().trim().toLowerCase();
      if (parsedType == 'complete') {
        try {
          final completeUserId = SupabaseConfig.auth.currentUser?.id;
          if (completeUserId != null) {
            await _lessonRepo.completeLesson(
              userId: completeUserId,
              lessonCode: widget.lessonCode,
              finalScreenIndex: _currentScreenIndex,
            );
          }
        } catch (e) {
          debugPrint('[LessonScreenPage] Failed to complete ${widget.lessonCode} at complete marker: $e');
        }
        if (!mounted) return;
        context.pushReplacement(LessonFlow.nextRouteAfterLesson(widget.lessonCode));
        return;
      }

      setState(() {
        _screen = _LessonScreen.fromJson(row!);
        _selectedOption = null;
        _reflectionController.text = '';
        _reflectionText = '';
      });
    } catch (e) {
      debugPrint(
        '[LessonScreenPage] ERROR: exception while querying lesson_screens. lessonCode=${widget.lessonCode}, currentScreenIndex=$_currentScreenIndex, error=$e',
      );
      setState(() => _error = 'Failed to load this screen. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onComingSoonBack() => context.go('/learn');

  void _onComingSoonSkip() {
    final next = LessonFlowController.instance.nextRouteAfterLesson(widget.lessonCode);
    context.go(next);
  }

  bool get _requiresSelection {
    final s = _screen;
    if (s == null) return false;
    // If the CMS authored options for this screen, treat it as a required choice.
    // We intentionally *do not* gate this by screen_type, because content authors
    // may use types like "responsibility", "interaction", "your_turn", etc.
    // and we still need choices to render + be required.
    if (s.options.isNotEmpty) return true;
    // For free-text reflection screens, require a response.
    if (s.screenType == 'interaction') return true;
    return false;
  }

  bool get _canContinue {
    if (_isLoading || _isSaving) return false;
    if (!_requiresSelection) return true;
    final s = _screen;
    if (s == null) return false;
    if (s.options.isNotEmpty) return (_selectedOption ?? '').trim().isNotEmpty;
    if (s.screenType == 'interaction') return _reflectionText.trim().isNotEmpty;
    return true;
  }

  Future<void> _onBack() async {
    // Allow stepping back through prior screens within the same lesson.
    if (_currentScreenIndex > 0) {
      setState(() {
        _currentScreenIndex -= 1;
        _selectedOption = null;
        _reflectionController.text = '';
        _reflectionText = '';
        _error = null;
      });
      await _loadScreen();
      return;
    }
    // On the first screen — leave the lesson.
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/learn');
    }
  }

  Future<void> _onContinue() async {
    final screen = _screen;
    if (screen == null) return;

    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    if (_requiresSelection) {
      if (screen.options.isNotEmpty && (_selectedOption == null || _selectedOption!.trim().isEmpty)) return;
      if (screen.screenType == 'interaction' && _reflectionText.trim().isEmpty) return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final extra = <String, dynamic>{};

      if (screen.screenType == 'feeling') {
        extra['s4_response'] = _selectedOption;

        // The ONLY place emotional_baseline is ever written.
        await _userRepo.updateEmotionalBaseline(userId: userId, baseline: _selectedOption);
      } else if (screen.screenType == 'action') {
        extra['s7_response'] = _selectedOption;
      } else if (screen.screenType == 'interaction') {
        // Free-text reflections. If the DB schema doesn't have this column yet,
        // LessonRepository will auto-retry by removing missing keys.
        extra['reflection_response'] = _reflectionText.trim();
      }

      final isComplete = screen.screenType == 'complete';
      if (isComplete) {
        await _lessonRepo.completeLesson(userId: userId, lessonCode: widget.lessonCode, finalScreenIndex: _currentScreenIndex);
      } else {
        await _lessonRepo.saveProgress(
          userId: userId,
          lessonCode: widget.lessonCode,
          status: 'in_progress',
          currentScreen: _currentScreenIndex,
          extra: extra,
        );
      }

      if (isComplete) {
        if (!mounted) return;
        // Use pushReplacement so the user can navigate "back" to where they
        // came from (e.g., Learn), without leaving the completed lesson screen
        // on the stack.
        context.pushReplacement(LessonFlow.nextRouteAfterLesson(widget.lessonCode));
        return;
      }

      setState(() {
        _currentScreenIndex += 1;
        _selectedOption = null;
      });
      await _loadScreen();
    } catch (e) {
      debugPrint('Failed to continue lesson screen: $e');
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure Android back / browser back behaves like the in-lesson back button:
    // step back through lesson screens, and only exit the lesson at screen 0.
    return PopScope(
      canPop: _currentScreenIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onBack();
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    if (_comingSoon) {
      final title = lessonDisplayNames[widget.lessonCode] ?? widget.lessonCode;
      return Scaffold(
        backgroundColor: HLGColors.warmCream,
        appBar: HerAppBar(titleText: title, showBack: true, fallbackRoute: '/learn'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coming soon', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  'This lesson isn’t available yet. You can go back to Learn, or skip ahead for now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _onComingSoonBack,
                    style: FilledButton.styleFrom(backgroundColor: HLGColors.deepSage, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
                    child: const Text('Back to Learn'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _onComingSoonSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HLGColors.deepSage,
                      side: BorderSide(color: HLGColors.deepSage.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text('Skip for now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final screen = _screen;

    return Scaffold(
      appBar: HerAppBar(
        showBack: true,
        fallbackRoute: '/learn',
        onBackPressed: _onBack,
        title: Text(lessonDisplayNames[widget.lessonCode] ?? 'Lesson', style: HLGTextStyles.labelMedium(color: HLGColors.textBody)),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            style: TextButton.styleFrom(foregroundColor: HLGColors.sageMid, textStyle: HLGTextStyles.labelMedium(color: HLGColors.sageMid), padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text('Exit'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          // Reading rhythm padding: 24px horizontal, 20px top.
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (screen == null)
                  ? _LessonErrorState(message: _error ?? 'Unknown error')
                  : _LessonScreenScaffold(
                      heading: screen.heading,
                      bodyText: screen.bodyText,
                      screenType: screen.screenType,
                      imageUrl: screen.imageUrl,
                      lessonCode: widget.lessonCode,
                      toolCode: screen.toolCode,
                      error: _error,
                      options: screen.options,
                      selectedOption: _selectedOption,
                      reflectionController: _reflectionController,
                      reflectionText: _reflectionText,
                      onSelectOption: (v) => setState(() => _selectedOption = v),
                      continueEnabled: _canContinue,
                      continueLoading: _isSaving,
                      onContinue: _onContinue,
                    ),
        ),
      ),
    );
  }
}

class _LessonScreen {
  const _LessonScreen({
    required this.screenType,
    required this.heading,
    required this.bodyText,
    required this.imageUrl,
    required this.options,
    required this.toolCode,
  });

  final String screenType;
  final String heading;
  final String bodyText;
  final String? imageUrl;
  final List<String> options;
  final String? toolCode;

  factory _LessonScreen.fromJson(Map<String, dynamic> json) {
    // These keys MUST match Supabase column names exactly.
    final screenType = (json['screen_type'] ?? '').toString().trim().toLowerCase();
    final heading = (json['heading'] ?? '').toString();
    final bodyText = (json['body_text'] ?? '').toString();
    final imageUrlRaw = json['image_url'];
    final imageUrl = (imageUrlRaw is String && imageUrlRaw.trim().isNotEmpty) ? imageUrlRaw.trim() : null;

    final toolRaw = json['tool_code'];
    final toolCode = (toolRaw is String && toolRaw.trim().isNotEmpty) ? toolRaw.trim() : null;

    debugPrint(
      '[LessonScreenPage] Parsed screen: screen_type=$screenType, toolCode=$toolCode, imageUrl=$imageUrl, headingLen=${heading.length}, bodyLen=${bodyText.length}',
    );

    final optionsRaw = json['options'];
    List<String> options = const [];
    if (optionsRaw is List) {
      // Supabase jsonb can come back as:
      // - List<String>
      // - List<dynamic>
      // - List<Map> (e.g. {label: "...", value: "..."})
      final parsed = <String>[];
      for (final e in optionsRaw) {
        if (e is Map) {
          final label = (e['label'] ?? e['text'] ?? e['value'] ?? '').toString().trim();
          if (label.isNotEmpty) parsed.add(label);
        } else {
          final v = e.toString().trim();
          if (v.isNotEmpty) parsed.add(v);
        }
      }
      options = parsed;
    } else if (optionsRaw is String) {
      // Fallback in case options is stored as a comma-separated string.
      options = optionsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return _LessonScreen(
      screenType: screenType,
      heading: heading,
      bodyText: bodyText,
      imageUrl: imageUrl,
      options: options,
      toolCode: toolCode,
    );
  }
}

class _LessonScreenScaffold extends StatelessWidget {
  const _LessonScreenScaffold({
    required this.heading,
    required this.bodyText,
    required this.screenType,
    required this.imageUrl,
    required this.lessonCode,
    required this.toolCode,
    required this.error,
    required this.options,
    required this.selectedOption,
    required this.reflectionController,
    required this.reflectionText,
    required this.onSelectOption,
    required this.continueEnabled,
    required this.continueLoading,
    required this.onContinue,
  });

  final String heading;
  final String bodyText;
  final String screenType;
  final String? imageUrl;
  final String lessonCode;
  final String? toolCode;
  final String? error;
  final List<String> options;
  final String? selectedOption;
  final TextEditingController reflectionController;
  final String reflectionText;
  final ValueChanged<String> onSelectOption;
  final bool continueEnabled;
  final bool continueLoading;
  final VoidCallback onContinue;

  static const Map<String, String> _screenTypeLabels = {
    'intro': '',
    'reminder': 'this space is yours',
    'mirror': 'REFLECTION',
    'story': 'THE STORY',
    'reveal': 'THE REVEAL',
    'reframe': 'REFRAME',
    'responsibility': 'YOUR MOVE',
    'action': 'YOUR TURN',
    'feeling': 'CHECK IN',
    'interaction': 'YOUR REFLECTION',
    'complete': 'CARRY THIS',
  };

  /// Normalizes an `image_url` value coming from Supabase.
  ///
  /// We support:
  /// - Full network URLs (http/https)
  /// - Asset paths starting with `assets/`
  /// - Common shorthand values like `images/foo.jpg` or `foo.jpg`
  static ({bool isNetwork, String resolved}) _resolveImage(String raw) {
    final trimmed = raw.trim();
    final uri = Uri.tryParse(trimmed);
    final isNetwork = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isNetwork) return (isNetwork: true, resolved: trimmed);

    // Asset-ish paths.
    if (trimmed.startsWith('assets/')) return (isNetwork: false, resolved: trimmed);
    if (trimmed.startsWith('images/')) return (isNetwork: false, resolved: 'assets/$trimmed');
    if (trimmed.startsWith('/assets/')) return (isNetwork: false, resolved: trimmed.substring(1));

    // If it's just a filename, assume it lives under assets/images.
    return (isNetwork: false, resolved: 'assets/images/$trimmed');
  }


  @override
  Widget build(BuildContext context) {
    if (screenType == 'intro') {
      return Container(
        // Premium dark intro surface; keep ink reserved for text.
        color: HLGColors.deepSage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32).copyWith(top: 48, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BEFORE WE BEGIN',
                        style: HLGTextStyles.labelMedium(color: HLGColors.crownGold).copyWith(
                          fontSize: 9,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        heading,
                        style: HLGTextStyles.h3SubheadItalic(color: HLGColors.warmCream).copyWith(fontSize: 28, height: 1.3),
                      ),
                      const SizedBox(height: 24),
                      IntroLessonBodyRenderer(bodyText: bodyText),
                      if ((error ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _InlineError(text: error!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 12),
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: continueEnabled ? onContinue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: HLGColors.crownGold,
                    disabledBackgroundColor: HLGColors.crownGold.withValues(alpha: 0.35),
                    foregroundColor: HLGColors.textBody,
                    disabledForegroundColor: HLGColors.textBody.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: continueLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(HLGColors.textBody.withValues(alpha: 0.8)),
                          ),
                        )
                      : Text(
                          'Ok, Challenge me',
                          style: HLGTextStyles.body(color: HLGColors.textBody).copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If options were authored for this screen, render them.
    final showChoices = options.isNotEmpty;
    final showFreeTextReflection = !showChoices && screenType == 'interaction';
    final eyebrow = _screenTypeLabels[screenType] ?? screenType.toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  // Neutral structural label (avoid overusing green or gold).
                  style: HLGTextStyles.labelMedium(color: HLGColors.textMuted).copyWith(
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (screenType == 'story' && (imageUrl ?? '').trim().isNotEmpty) ...[
                  // Note: Some DB rows historically stored local assets in `image_url`.
                  // We normalize to ensure they render correctly across platforms.
                  // Any failures are logged with the resolved value.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Builder(
                        builder: (context) {
                          final resolved = _resolveImage(imageUrl!);
                          debugPrint('[LessonScreenPage] Story image resolved: raw="$imageUrl" -> "${resolved.resolved}" (network=${resolved.isNetwork})');
                          if (!resolved.isNetwork) {
                            return Image.asset(
                              resolved.resolved,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) {
                                debugPrint('[LessonScreenPage] Failed to load asset image: ${resolved.resolved} | $error');
                                return Container(
                                  color: HLGColors.sagePale,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(12),
                                   child: Icon(Icons.image_not_supported_outlined, color: HLGColors.sageMid.withValues(alpha: 0.7)),
                                );
                              },
                            );
                          }

                          return CachedNetworkImage(
                            imageUrl: resolved.resolved,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: HLGColors.sagePale),
                            errorWidget: (context, url, error) {
                              debugPrint('[LessonScreenPage] Failed to load network image: $url | $error');
                              return Container(
                                color: HLGColors.sagePale,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(12),
                                 child: Icon(Icons.image_not_supported_outlined, color: HLGColors.sageMid.withValues(alpha: 0.7)),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  heading,
                  style: HLGTextStyles.h3SubheadItalic(color: HLGColors.textBody).copyWith(fontSize: 26, height: 1.3),
                ),
                const SizedBox(height: 20),
                if (showChoices)
                  Text(bodyText, style: HLGTextStyles.body(color: HLGColors.textBody).copyWith(height: 1.7))
                else
                  LessonBodyRenderer(bodyText: bodyText),
                // Embedded tools: if a screen has a tool_code, always surface it.
                // Tools are an optional helper layer and should not depend on screen_type.
                if (toolCode != null && toolCode!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => ToolBottomSheet.show(
                        context,
                        toolCode: toolCode!,
                        lessonCode: lessonCode,
                      ),
                      icon: const Icon(Icons.auto_graph_rounded, color: HLGColors.horizonOrange),
                      label: Text(
                        'Open the tool →',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: HLGColors.horizonOrange,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: HLGColors.horizonOrange, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                  ),
                ],
                if (showChoices) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Pick one:', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
                  const SizedBox(height: AppSpacing.sm),
                  // Show ALL options; do not truncate.
                  _LessonChoiceChips(
                    options: options,
                    selected: selectedOption,
                    onSelected: onSelectOption,
                  ),
                ],

                if (showFreeTextReflection) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Write it down:', style: HLGTextStyles.labelMedium(color: HLGColors.textMuted)),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: reflectionController,
                    maxLines: null,
                    minLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: HLGTextStyles.body(color: HLGColors.textBody),
                    decoration: const InputDecoration(
                      hintText: 'Type your answer…',
                    ),
                  ),
                ],
                if ((error ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _InlineError(text: error!),
                ],
                // Ensure the last option/text field is never hidden behind the bottom CTA.
                SizedBox(height: showChoices || showFreeTextReflection ? 160 : 110),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showChoices && (selectedOption ?? '').trim().isNotEmpty) ...[
                Text(
                  'Selected: ${selectedOption!.trim()}',
                  style: HLGTextStyles.labelMedium(color: HLGColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
              ],
              if (showFreeTextReflection && reflectionText.trim().isNotEmpty) ...[
                Text(
                  'Saved draft: ${reflectionText.trim()}',
                  style: HLGTextStyles.labelMedium(color: HLGColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: continueEnabled ? onContinue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: HLGColors.horizonOrange,
                    disabledBackgroundColor: HLGColors.horizonOrange.withValues(alpha: 0.35),
                    foregroundColor: HLGColors.warmCream,
                    disabledForegroundColor: HLGColors.warmCream.withValues(alpha: 0.85),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: continueLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(HLGColors.warmCream),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: HLGTextStyles.body(color: HLGColors.warmCream).copyWith(fontWeight: FontWeight.w500),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonChoiceChips extends StatelessWidget {
  const _LessonChoiceChips({required this.options, required this.selected, required this.onSelected});

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    // Use full-width “pill” rows (instead of wrap chips) so long options like
    // “Frustrated …” never truncate.
    if (options.isEmpty) return const SizedBox.shrink();
    final children = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      final opt = options[i];
      children.add(_LessonOptionPill(
        label: opt,
        selected: selected == opt,
        onTap: () => onSelected(opt),
      ));
      if (i < options.length - 1) {
        children.add(const SizedBox(height: AppSpacing.sm));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _LessonOptionPill extends StatelessWidget {
  const _LessonOptionPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? HLGColors.deepSage : HLGColors.petal,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HLGColors.textBody.withValues(alpha: 0.08)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          // No splash; just a subtle press/hover highlight.
          splashFactory: NoSplash.splashFactory,
          highlightColor: HLGColors.textBody.withValues(alpha: 0.04),
          hoverColor: HLGColors.textBody.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              label,
              style: HLGTextStyles.body(color: selected ? HLGColors.white : HLGColors.textBody).copyWith(height: 1.5),
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: HLGColors.petal,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: HLGColors.textBody.withValues(alpha: 0.08)),
      ),
       child: Text(text, style: HLGTextStyles.body(color: HLGColors.textBody)),
    );
  }
}

class _LessonErrorState extends StatelessWidget {
  const _LessonErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text('Couldn\'t load screen', style: HLGTextStyles.h2Section(color: HLGColors.textBody), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: HLGTextStyles.body(color: HLGColors.textBody), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}