import 'package:flutter/material.dart';
import 'package:her_long_game/theme.dart';
import 'package:her_long_game/widgets/her_app_bar.dart';

/// Placeholder module page for `/learn/module/:moduleId`.
///
/// This will later list lessons for a module.
class LearnModulePage extends StatelessWidget {
  const LearnModulePage({super.key, required this.moduleId});

  final int moduleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HerAppBar(showBack: true, fallbackRoute: '/learn', title: Text('Module $moduleId', style: HLGTextStyles.labelMedium(color: HLGColors.textBody))),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Text('Module detail (placeholder)', style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
