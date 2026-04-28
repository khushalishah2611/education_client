import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
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
    final bool isSmallMobile = context.isSmallMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;

    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            children: [
            FlowStepHeader(currentStep: 3, title: context.l10n.text('paymentConfirmation')),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isSmallMobile ? 14 : 18,
                  horizontalPadding,
                  20,
                ),
                children: [
                  const Icon(Icons.celebration, color: AppColors.accent, size: 20),
                  const SizedBox(height: 6),
                  CircleAvatar(
                    radius: isSmallMobile ? 38 : 44,
                    backgroundColor: Color(0xFF0E9F58),
                    child: Icon(
                      Icons.check_rounded,
                      size: isSmallMobile ? 44 : 54,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.text('applicationSubmitted'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallMobile ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0E9F58),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmallMobile ? 30 : 70,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFE9F4E6), borderRadius: BorderRadius.circular(8)),
                    child: Text(context.l10n.text('applicationIdValue'), textAlign: TextAlign.center),
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
                    '${context.l10n.text('paymentProcessedPrefix')} ${course.title} ${context.l10n.text('paymentProcessedSuffix')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.45),
                  ),
                  const SizedBox(height: 96),
                  AppPrimaryButton(
                    label: context.l10n.text('trackApplication'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TrackApplicationScreen(university: university, course: course)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppOutlinedButton(label: context.l10n.text('downloadReceipt'), onPressed: () {}),
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
