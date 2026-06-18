import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:her_long_game/theme.dart';

/// Canonical learning structure.
///
/// Phase → Module → Lesson (→ screens in Supabase) → Checkpoint.
///
/// RULE: All curriculum lookups must go through this file.
@immutable
class LearningCatalog {
  LearningCatalog({required this.phases, required this.modules});

  /// Ordered phases (THE PAST → THE PRESENT → THE FUTURE).
  final List<Phase> phases;

  /// Ordered modules (index 0..n). Modules are referenced by [Phase.moduleIds].
  final List<Module> modules;

  static final LearningCatalog instance = _build();

  static LearningCatalog _build() {
    bool unlockAlways(Map<String, String> _) => true;
    bool unlockIfComplete(String code, Map<String, String> m) => (m[code] ?? '') == 'complete';

    final modules = <Module>[
      Module(
        id: '0',
        index: 0,
        label: 'Pre-Course',
        title: 'Before We Begin',
        items: const [
          Lesson(code: 'L0'),
          Lesson(code: 'L0b'),
          Lesson(code: 'LA'),
        ],
        unlockRule: unlockAlways,
      ),
      Module(
        id: '1',
        index: 1,
        label: 'Module 1',
        title: 'Foundations',
        items: const [
          Lesson(code: 'L1'),
          Lesson(code: 'L1b'),
          Lesson(code: 'LB'),
          Lesson(code: 'L2'),
          Lesson(code: 'CK1', isCheckpoint: true),
        ],
        unlockRule: (m) => unlockIfComplete('LA', m),
      ),
      Module(
        id: '2',
        index: 2,
        label: 'Module 2',
        title: 'Money & the System',
        items: const [
          Lesson(code: 'L3'),
          Lesson(code: 'L4'),
          Lesson(code: 'LD'),
          Lesson(code: 'LE'),
          Lesson(code: 'CK2', isCheckpoint: true),
        ],
        unlockRule: (m) => unlockIfComplete('CK1', m),
      ),
      Module(
        id: '3',
        index: 3,
        label: 'Module 3',
        title: 'Building the Base',
        items: const [
          Lesson(code: 'L5'),
          Lesson(code: 'L6'),
          Lesson(code: 'L7'),
          Lesson(code: 'L7b'),
          Lesson(code: 'LC'),
          Lesson(code: 'LF'),
          Lesson(code: 'CK3', isCheckpoint: true),
        ],
        unlockRule: (m) => unlockIfComplete('CK2', m),
      ),
      Module(
        id: '4',
        index: 4,
        label: 'Module 4',
        title: 'Growing Wealth',
        items: const [
          Lesson(code: 'L8'),
          Lesson(code: 'L8a'),
          Lesson(code: 'L9'),
          Lesson(code: 'L10'),
          Lesson(code: 'CK4', isCheckpoint: true),
        ],
        unlockRule: (m) => unlockIfComplete('CK3', m),
      ),
    ];

    final phases = <Phase>[
      Phase(
        id: 1,
        title: 'THE PAST',
        subtitle: 'Context & Curiosity',
        emotionalGoal: 'Turn confusion into context – and shame into curiosity.',
        focus:
            'Pre‑Course + Module 1\n• Permission & Identity\n• Foundations\n• Money’s origin story\n• Women’s role in history\n• System mechanics (1971)',
        learnerFeels: 'Seen. Curious. Not alone.',
        fromIdentity: 'I feel behind – like I missed something everyone else learned.',
        toIdentity: 'The system has a history – and I can understand it.',
        moduleIds: const ['0', '1'],
        accentColor: HLGColors.horizonOrange,
      ),
      Phase(
        id: 2,
        title: 'THE PRESENT',
        subtitle: 'Clarity & Capability',
        emotionalGoal: 'Turn awareness into action – with tools that match real life.',
        focus:
            'Modules 2 + 3\n• Money & the System\n• Building the Base\n• Inflation, pay gap, tax, credit\n• Budget, debt, super, insurance\n• HerTools activated',
        learnerFeels: 'Informed. Capable. In control.',
        fromIdentity: 'I’m overwhelmed – and I don’t know what matters first.',
        toIdentity: 'I can make decisions with clarity and confidence.',
        moduleIds: const ['2', '3'],
        accentColor: HLGColors.deepSage,
      ),
      Phase(
        id: 3,
        title: 'THE FUTURE',
        subtitle: 'Ownership & Legacy',
        emotionalGoal: 'Turn momentum into ownership – and ownership into legacy.',
        focus:
            'Module 4 + Ongoing\n• Growing Wealth\n• The Long Game\n• Compound growth, ETFs, Bitcoin\n• HerPath & HerWisdom',

        learnerFeels: 'Empowered. Intentional. Legacy‑minded.',
        fromIdentity: 'I’m trying to keep up.',
        toIdentity: 'I’m building a long game that outlives the moment.',
        moduleIds: const ['4'],
        // Phase 3 uses a deeper, premium anchor (not ink text).
        accentColor: HLGColors.deepForest,
      ),
    ];

    return LearningCatalog(phases: phases, modules: modules);
  }

  Module getModule(String moduleId) => modules.firstWhere((m) => m.id == moduleId);

  Module? maybeGetModule(String moduleId) {
    for (final m in modules) {
      if (m.id == moduleId) return m;
    }
    return null;
  }

  Lesson getLesson(String lessonCode) {
    for (final m in modules) {
      for (final item in m.items) {
        if (item.code == lessonCode) return item;
      }
    }
    throw StateError('Unknown lesson code: $lessonCode');
  }

  List<Lesson> getLessonsInModule(String moduleId) => getModule(moduleId).items;

  Phase getPhase(int id) => phases.firstWhere((p) => p.id == id);

  Phase? maybeGetPhase(int id) {
    for (final p in phases) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Flattened ordered sequence of all curriculum items (lessons + checkpoints).
  List<String> get lessonSequence => [for (final m in modules) for (final item in m.items) item.code];

  /// Returns the phase that contains a module.
  Phase? phaseForModule(String moduleId) {
    for (final p in phases) {
      if (p.moduleIds.contains(moduleId)) return p;
    }
    return null;
  }
}

@immutable
class Phase {
  const Phase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emotionalGoal,
    required this.focus,
    required this.learnerFeels,
    required this.fromIdentity,
    required this.toIdentity,
    required this.moduleIds,
    required this.accentColor,
  });

  final int id;
  final String title;
  final String subtitle;
  final String emotionalGoal;
  final String focus;
  final String learnerFeels;
  final String fromIdentity;
  final String toIdentity;
  final List<String> moduleIds;
  final Color accentColor;
}

@immutable
class Module {
  const Module({
    required this.id,
    required this.index,
    required this.label,
    required this.title,
    required this.items,
    required this.unlockRule,
  });

  final String id;
  final int index;
  final String label;
  final String title;

  /// Ordered lessons + checkpoints.
  final List<Lesson> items;

  /// Unlock rule based on loaded [lesson_progress] status map.
  final bool Function(Map<String, String> statusByLessonCode) unlockRule;
}

@immutable
class Lesson {
  const Lesson({required this.code, this.title, this.isCheckpoint = false, this.screens = const []});

  final String code;
  final String? title;
  final bool isCheckpoint;

  /// Placeholder for future metadata. Screens are stored in Supabase.
  final List<ScreenDef> screens;
}

@immutable
class ScreenDef {
  const ScreenDef({required this.type});
  final String type;
}
