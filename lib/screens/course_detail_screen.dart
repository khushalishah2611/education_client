import 'package:education/core/app_localizations.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'upload_documents_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.university,
    required this.course,
  });

  final UniversityData university;
  final CourseData course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final List<_IntakeOption> _availableIntakes = const [
    _IntakeOption(
      month: 'September',
      year: '2026',
      deadlineDate: '30 June 2026',
    ),
    _IntakeOption(
      month: 'October',
      year: '2026',
      deadlineDate: '15 July 2026',
    ),
    _IntakeOption(
      month: 'March',
      year: '2027',
      deadlineDate: '15 December 2026',
    ),
  ];

  int _selectedIntakeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedIntake = _availableIntakes[_selectedIntakeIndex];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔷 TOP IMAGE + CARD
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        /// IMAGE
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Image.network(
                              widget.course.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: const Color(0xFFE2E2E2)),
                            ),
                          ),
                        ),

                        /// FLOATING CARD
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: -50,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F4),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.university.shortCode,
                                        style: TextStyle(
                                          color: widget.university.color,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    /// TEXT
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.university.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            widget.course.title,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                /// LOCATION + RATING
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 15,
                                        color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.university.location,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFB300), size: 16),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '4.6',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                /// DURATION + PRICE
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 18,
                                        color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(widget.course.duration),
                                    const Spacer(),
                                    const Text(
                                      '₹4,50,000 / Year',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// HEADER
                        TopRoundedHeader(title: widget.course.title),
                      ],
                    ),

                    const SizedBox(height: 70),

                    /// 🔷 ELIGIBILITY
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Eligibility',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        children: [
                          _BulletLine(
                              'Bachelor’s degree from a recognized university'),
                          _BulletLine('Minimum 50% aggregate marks'),
                          _BulletLine(
                              'English proficiency (IELTS/TOEFL if applicable)'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔷 DOCUMENTS
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Required Documents',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔷 INTAKE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month_outlined,
                                    color: AppColors.accent),
                                SizedBox(width: 8),
                                Text('Available Intake',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (var i = 0; i < _availableIntakes.length; i++)
                                  _IntakeChip(
                                    month: _availableIntakes[i].month,
                                    year: _availableIntakes[i].year,
                                    isSelected: i == _selectedIntakeIndex,
                                    onTap: () {
                                      setState(() => _selectedIntakeIndex = i);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFC4C4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4F4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fact_check_outlined,
                                color: Color(0xFFEB5757),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Application Deadline',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textMuted,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: selectedIntake.deadlineDate,
                                          style: const TextStyle(
                                            color: Color(0xFFEB5757),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' (For ${selectedIntake.month} ${selectedIntake.year} Intake)',
                                        ),
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

                  ],
                ),
              ),

              /// 🔷 BUTTON
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: AppPrimaryButton(
                  label: context.l10n.text('Save'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadDocumentsScreen(
                        university: widget.university,
                        course: widget.course,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
          ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7E2DA)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntakeChip extends StatelessWidget {
  const _IntakeChip({
    required this.month,
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  final String month;
  final String year;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : const Color(0xFFE7E2DA),
          ),
        ),
        child: Column(
          children: [
            Text(month, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              year,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntakeOption {
  const _IntakeOption({
    required this.month,
    required this.year,
    required this.deadlineDate,
  });

  final String month;
  final String year;
  final String deadlineDate;
}
