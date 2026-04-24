import 'package:education/core/app_localizations.dart';
import 'package:education/core/image_url_helper.dart';
import 'package:education/models/admin_university.dart';
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

  final AdminUniversity university;
  final CourseDetails course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {

  final List<String> eligibilityList = [
    'Bachelor’s degree from a recognized university',
    'Minimum 50% aggregate marks',
    'English proficiency (IELTS/TOEFL if applicable)',
  ];

  final List<String> documentsList = [
    'Academic Transcripts',
    'Passport Copy',
    'Statement of Purpose (SOP)',
    'Resume / CV',
  ];

  @override
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            /// 🔷 FIXED HEADER (NO SCROLL)
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Image.network(
                      ImageUrlHelper.resolveUploadUrl(widget.university.coverImagePath),
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => Center(
                        child: Image.asset('assets/images/logo.webp'),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -40,
                  child: InkWell(
                    onTap: _showAddressDialog,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Image.network(
                              ImageUrlHelper.resolveUploadUrl(widget.university.logoPath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Image.asset('assets/images/logo.webp'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFFFFB300),
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      widget.university.averageRating!
                                          .toDouble()
                                          .toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '(${widget.university.averageRating!.toDouble().toString()} reviews)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.university.name ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 15,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),

                                    Expanded(
                                      child: Text(
                                        widget.university.address ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                TopRoundedHeader(title: widget.course.name ?? ""),
              ],
            ),

            const SizedBox(height: 60),


            /// 🔷 SCROLLABLE CONTENT ONLY
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  /// 🔷 ELIGIBILITY
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Eligibility',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      children: List.generate(
                        eligibilityList.length,
                            (index) =>
                            _BulletLine(eligibilityList[index]),
                      ),
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

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: List.generate(
                        documentsList.length,
                            (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _DocTile(documentsList[index]),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            /// 🔷 BUTTON (FIXED)
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppPrimaryButton(
                label: context.l10n.text('Save'),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => UploadDocumentsScreen(
                  //       university: widget.university,
                  //       course: widget.course,
                  //     ),
                  //   ),
                  // );
                }
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
