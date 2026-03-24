import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'track_application_screen.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  const PaymentConfirmationScreen({super.key, required this.university, required this.course});

  final UniversityData university;
  final CourseData course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            children: [
            const FlowStepHeader(currentStep: 3, title: 'Payment Confirmation'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  const Icon(Icons.celebration, color: AppColors.accent, size: 20),
                  const SizedBox(height: 6),
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: Color(0xFF0E9F58),
                    child: Icon(Icons.check_rounded, size: 54, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('Application Submitted', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0E9F58))),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 70),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFE9F4E6), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Application ID : #12345', textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      university.heroImage,
                      height: 158,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 158, color: const Color(0xFFE3E3E3)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your payment of ₹1,500.00 for the Fall 2026 ${course.title} program has been processed. Your application is now in the review queue.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.45),
                  ),
                  const SizedBox(height: 96),
                  AppPrimaryButton(
                    label: 'Track Application',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TrackApplicationScreen(university: university, course: course)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppOutlinedButton(label: 'Download Receipt', onPressed: () {}),
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
