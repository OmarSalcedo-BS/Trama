import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../mockup/mockup_window_bar.dart';
import '../mockup/mockup_sidebar.dart';
import '../mockup/mockup_manuscript.dart';
import '../mockup/mockup_inspector.dart';

class EditorMockupSection extends StatelessWidget {
  const EditorMockupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 1000;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.xxl,
      ),
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadii.allLg,
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: AppRadii.allLg,
              child: Column(
                children: [
                  const MockupWindowBar(),
                  SizedBox(
                    height: 540,
                    child: isNarrow
                        ? const MockupManuscript()
                        : Row(
                            children: const [
                              SizedBox(width: 260, child: MockupSidebar()),
                              VerticalDivider(
                                width: 0.5,
                                thickness: 0.5,
                                color: AppColors.outlineVariant,
                              ),
                              Expanded(child: MockupManuscript()),
                              VerticalDivider(
                                width: 0.5,
                                thickness: 0.5,
                                color: AppColors.outlineVariant,
                              ),
                              SizedBox(width: 280, child: MockupInspector()),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}