import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_screen.dart';

class UploadDocumentsScreen extends StatelessWidget {
  const UploadDocumentsScreen({super.key, required this.university, required this.course});

  final UniversityData university;
  final CourseData course;

  @override
  Widget build(BuildContext context) {
    final docs = [
      ('Passport', 'Valid for at least 6 months'),
      ('Academic Transcripts', 'Copies for all semesters'),
      ('Statement of Purpose (SOP)', 'Words about your goals'),
      ('LOR', 'From 2 different academic reference'),
      ('Resume / CV', 'Latest professional experience'),
    ];

    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FlowStepHeader(currentStep: 0, title: 'Upload Documents'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  const Text('Required Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _UploadDropZone(title: docs.first.$1, subtitle: docs.first.$2),
                  const SizedBox(height: 10),
                  ...docs.skip(1).map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UploadListTile(title: doc.$1, subtitle: doc.$2),
                      )),
                  const SizedBox(height: 18),
                  AppPrimaryButton(
                    label: 'Save & Continue',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PaymentScreen(university: university, course: course)),
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

class _UploadDropZone extends StatelessWidget {
  const _UploadDropZone({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8E2D9))),
      child: Column(
        children: [
          Row(
            children: [
              _DocIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          const Icon(Icons.cloud_upload_outlined, size: 54, color: Color(0xFFB8B8B8)),
          const SizedBox(height: 10),
          const Text.rich(
            TextSpan(
              text: 'Drag & drop files or ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
              children: [TextSpan(text: 'Browse', style: TextStyle(color: AppColors.accent))],
            ),
          ),
          const SizedBox(height: 6),
          const Text('Supported : PDF, JPG, PNG', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _UploadListTile extends StatelessWidget {
  const _UploadListTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8E2D9))),
      child: Row(
        children: [
          _DocIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: const Color(0xFFA0E1BE), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.upload_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _DocIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.description_outlined, color: AppColors.accent),
    );
  }
}
