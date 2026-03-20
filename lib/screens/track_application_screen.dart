import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';

class TrackApplicationScreen extends StatelessWidget {
  const TrackApplicationScreen({super.key, required this.university, required this.course});

  final UniversityData university;
  final CourseData course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const TopRoundedHeader(title: 'Track Application'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8E2D9))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Application ID : #12345', style: TextStyle(fontSize: 11)),
                        const SizedBox(height: 10),
                        Text(university.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(course.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                        const Text('Application Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 18),
                        const _ProgressStep(title: 'Submitted', subtitle: 'Completed on Feb 13', state: _StepState.done, showLine: true),
                        const _ProgressStep(title: 'Under Review', subtitle: 'Our admission team is reviewing your profile', state: _StepState.done, showLine: true),
                        const _ProgressStep(title: 'Documents Verified', subtitle: 'Pending review', state: _StepState.active, showLine: true),
                        const _ProgressStep(title: 'Accepted/Rejected', subtitle: 'Waiting for decision', state: _StepState.pending, showLine: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
