import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'upload_documents_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.university, required this.course});

  final UniversityData university;
  final CourseData course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            TopRoundedHeader(title: course.title),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 214,
                      width: double.infinity,
                      child: Image.network(
                        course.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE4E4E4)),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 8))],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(10)),
                                    child: Text(university.shortCode, style: TextStyle(color: university.color, fontWeight: FontWeight.w900)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(university.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text(course.title, style: const TextStyle(color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(university.location, style: const TextStyle(color: AppColors.textMuted))),
                                  const Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                                  const SizedBox(width: 4),
                                  const Text('4.6', style: TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 18, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(course.duration),
                                  const Spacer(),
                                  Text('₹4,50,000 / Year', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Eligibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BulletLine('Bachelor’s degree from a recognized university'),
                          _BulletLine('Minimum 50% aggregate marks'),
                          _BulletLine('English proficiency (IELTS/TOEFL if applicable)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Required Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        children: [
                          _DocTile('Academic Transcripts'),
                          SizedBox(height: 8),
                          _DocTile('Passport Copy'),
                          SizedBox(height: 8),
                          _DocTile('Statement of Purpose (SOP)'),
                          SizedBox(height: 8),
                          _DocTile('Resume / CV'),
                          SizedBox(height: 8),
                          _DocTile('English Proficiency Test Score'),
                          SizedBox(height: 8),
                          _DocTile('Passport Size Photographs'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, color: AppColors.accent),
                                SizedBox(width: 8),
                                Text('Available Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Expanded(child: _IntakeChip(month: 'September', year: '2026')),
                                SizedBox(width: 14),
                                Expanded(child: _IntakeChip(month: 'October', year: '2026')),
                                SizedBox(width: 14),
                                Expanded(child: _IntakeChip(month: 'March', year: '2027')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_late_outlined, color: AppColors.accent),
                                SizedBox(width: 8),
                                Text('Application Deadline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text('30 June 2026', style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.w700)),
                            SizedBox(height: 4),
                            Text('(For September 2026 Intake)', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: AppPrimaryButton(
                label: 'Save',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => UploadDocumentsScreen(university: university, course: course)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline_rounded, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: AppColors.textMuted))),
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE7E2DA))),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.insert_drive_file_outlined, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 15))),
        ],
      ),
    );
  }
}

class _IntakeChip extends StatelessWidget {
  const _IntakeChip({required this.month, required this.year});

  final String month;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.accent)),
      child: Column(
        children: [
          Text(month, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(year, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
