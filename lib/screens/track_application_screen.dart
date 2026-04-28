import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'home_screen.dart';

class TrackApplicationScreen extends StatelessWidget {
  const TrackApplicationScreen({super.key, required this.university, required this.course});

  final UniversityData university;
  final CourseData course;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;

    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            children: [
            TopRoundedHeader(
              title: context.l10n.text('trackApplication'),
              onBack: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isSmallMobile ? 14 : 18,
                  horizontalPadding,
                  20,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8E2D9))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.text('applicationIdValue'), style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 10),
                        Text(
                          university.name,
                          style: TextStyle(
                            fontSize: isSmallMobile ? 16 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                course.title,
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            university.heroImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 150, color: const Color(0xFFE2E2E2)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.l10n.text('applicationProgress'),
                          style: TextStyle(
                            fontSize: isSmallMobile ? 16 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ProgressStep(title: context.l10n.text('submitted'), subtitle: context.l10n.text('completedOnDate'), state: _StepState.done, showLine: true),
                        _ProgressStep(title: context.l10n.text('underReview'), subtitle: context.l10n.text('underReviewSubtitle'), state: _StepState.done, showLine: true),
                        _ProgressStep(title: context.l10n.text('documentsVerified'), subtitle: context.l10n.text('pendingReview'), state: _StepState.active, showLine: true),
                        _ProgressStep(title: context.l10n.text('acceptedRejected'), subtitle: context.l10n.text('waitingDecision'), state: _StepState.pending, showLine: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.showLine,
  });

  final String title;
  final String subtitle;
  final _StepState state;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.done => const Color(0xFF0E9F58),
      _StepState.active => AppColors.accent,
      _StepState.pending => const Color(0xFF777777),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: state == _StepState.active ? Colors.white : color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: state == _StepState.done ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 42,
                  color: state == _StepState.pending ? const Color(0xFFD7D7D7) : const Color(0xFF0E9F58),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: state == _StepState.pending ? const Color(0xFF777777) : AppColors.text)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
