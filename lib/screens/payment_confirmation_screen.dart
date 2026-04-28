import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../services/selected_course_storage.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'track_application_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  SelectedCourseData? _selectedCourseData;

  @override
  void initState() {
    super.initState();
    _loadAndClearPendingCourse();
  }

  Future<void> _loadAndClearPendingCourse() async {
    final data = await SelectedCourseStorage.load();
    await SelectedCourseStorage.clear();
    if (!mounted) return;
    setState(() => _selectedCourseData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            children: [
            FlowStepHeader(currentStep: 3, title: context.l10n.text('paymentConfirmation')),
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
                  Text(context.l10n.text('applicationSubmitted'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0E9F58))),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 70),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFFE9F4E6), borderRadius: BorderRadius.circular(8)),
                    child: Text(context.l10n.text('applicationIdValue'), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _selectedCourseData == null
                        ? Container(height: 158, color: const Color(0xFFE3E3E3))
                        : Image.network(
                            _selectedCourseData!.universityImage,
                            height: 158,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 158, color: const Color(0xFFE3E3E3)),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${context.l10n.text('paymentProcessedPrefix')} ${_selectedCourseData?.course.name ?? ''} ${context.l10n.text('paymentProcessedSuffix')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.45),
                  ),
                  const SizedBox(height: 96),
                  AppPrimaryButton(
                    label: context.l10n.text('trackApplication'),
                    onPressed: _selectedCourseData == null
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TrackApplicationScreen(
                                university: _toUniversityData(_selectedCourseData!),
                                course: _toCourseData(_selectedCourseData!),
                              ),
                            ),
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

  UniversityData _toUniversityData(SelectedCourseData data) {
    return UniversityData(
      name: data.universityName,
      location: data.universityAddress,
      shortCode: data.universityName.isNotEmpty
          ? data.universityName.substring(0, 1).toUpperCase()
          : 'U',
      color: AppColors.accent,
      heroImage: data.universityImage,
    );
  }

  CourseData _toCourseData(SelectedCourseData data) {
    return CourseData(
      title: data.course.name ?? '',
      duration: data.course.duration ?? '',
      fee: '${data.course.currency ?? ''} ${data.course.basePrice ?? 0}'.trim(),
      image: data.universityImage,
    );
  }
}
