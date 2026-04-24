import 'package:education/core/app_localizations.dart';
import 'package:education/core/image_url_helper.dart';
import 'package:education/models/admin_university.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';

class UniversityDetailScreen extends StatefulWidget {
  const UniversityDetailScreen({super.key, required this.data});

  final AdminUniversity data;

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  final Set<String> _expandedColleges = <String>{};
  final Set<String> _selectedCourses = <String>{};

  AdminUniversity get data => widget.data;

  bool get _showCollegeCourseTable {
    final bool isAccredited = data.accredited == true;
    final String normalizedCountry = (data.country ?? '').trim().toLowerCase();
    final String normalizedMobile = (data.mobile ?? '').trim();
    final bool isOman =
        normalizedCountry == 'oman' ||
        normalizedCountry == 'om' ||
        normalizedMobile.startsWith('+968');

    return isAccredited && isOman;
  }

  Map<String, List<AdminUniversity>> get _collegeCourses {
    final Map<String, List<CourseDetails>> grouped =
        <String, List<CourseDetails>>{};
    final List<ProgramLinks> links = data.programLinks ?? <ProgramLinks>[];

    for (final ProgramLinks link in links) {
      final Program? program = link.program;
      if (program == null) continue;
      final String collegeName =
          (program.educationInstitute?.trim().isNotEmpty ?? false)
          ? program.educationInstitute!.trim().toUpperCase()
          : 'COLLEGE';
      final CourseDetails course = CourseDetails(
        name: program.name ?? 'N/A',
        feePerCredit: program.basePrice,
        currency: program.currency ?? '',
        minAdmissionRate: program.minAdmissionRate,
        track: program.track ?? 'N/A',
        applicationFee: link.applicationFee,
      );
      grouped.putIfAbsent(collegeName, () => <CourseDetails>[]).add(course);
    }

    return grouped;
  }

  void _showAddressDialog() {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(context.l10n.text('location')),
          content: Text(
            data.address?.trim().isNotEmpty == true ? data.address! : '-',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<AdminUniversity>> collegeCourses = _collegeCourses;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: [
              /// 🔹 TOP HEADER
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
                        ImageUrlHelper.resolveUploadUrl(data.coverImagePath),
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
                              ImageUrlHelper.resolveUploadUrl(data.logoPath),
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
                                      data.rating!.toDouble().toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '(reviews)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data.name ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 15,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),

                                    Expanded(
                                      child: InkWell(
                                        onTap: _showAddressDialog,
                                        child: Text(
                                          data.address ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                          ),
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

                  TopRoundedHeader(title: data.name ?? ""),
                ],
              ),

              const SizedBox(height: 60),

              /// 🔥 SCROLL CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: ReadMoreText(text: data.aboutUs.toString()),
                      ),
                      SizedBox(height: 10),
                      if (_selectedCourses.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Selected Courses: ${_selectedCourses.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      if (_showCollegeCourseTable && collegeCourses.isNotEmpty)
                        ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: collegeCourses.entries.map((entry) {
                              final String collegeName = entry.key;
                              final List<AdminUniversity> courses = entry.value;
                              final bool isExpanded = _expandedColleges
                                  .contains(collegeName);
                              return _CollegeAccordion(
                                collegeName: collegeName,
                                courses: courses,
                                isExpanded: isExpanded,
                                selectedCourses: _selectedCourses,
                                onToggleExpand: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedColleges.remove(collegeName);
                                    } else {
                                      _expandedColleges.add(collegeName);
                                    }
                                  });
                                },
                                onToggleCourse: (courseKey) {
                                  setState(() {
                                    if (_selectedCourses.contains(courseKey)) {
                                      _selectedCourses.remove(courseKey);
                                    } else {
                                      _selectedCourses.add(courseKey);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
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

class _CollegeAccordion extends StatelessWidget {
  const _CollegeAccordion({
    required this.collegeName,
    required this.courses,
    required this.isExpanded,
    required this.selectedCourses,
    required this.onToggleExpand,
    required this.onToggleCourse,
  });

  final String collegeName;
  final List<AdminUniversity> courses;
  final bool isExpanded;
  final Set<String> selectedCourses;
  final VoidCallback onToggleExpand;
  final ValueChanged<String> onToggleCourse;
  static const double _courseWidth = 240;
  static const double _feeWidth = 110;
  static const double _admissionWidth = 100;
  static const double _trackWidth = 120;
  static const double _detailsWidth = 190;
  static const double _tableWidth =
      _courseWidth + _feeWidth + _admissionWidth + _trackWidth + _detailsWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isExpanded ? AppColors.primaryDark : const Color(0xFFD8D8D8),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      collegeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF868686),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF3A3A3A),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _tableWidth,
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFFE5E5E5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: _courseWidth,
                            child: Text(
                              'Course',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: _feeWidth,
                            child: Text(
                              'Credit\nHour Fee',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: _admissionWidth,
                            child: Text(
                              'Min\nAdmis%',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: _trackWidth,
                            child: Text(
                              'Track',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: _detailsWidth,
                            child: Text(
                              'Details\n/ Apply',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: courses.map((course) {
                          final String courseKey = '$collegeName-${course.name}';
                          final bool isSelected = selectedCourses.contains(
                            courseKey,
                          );

                          return InkWell(
                            onTap: () => onToggleCourse(courseKey),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.peachSoft
                                    : Colors.white,
                                border: Border(
                                  left: BorderSide(
                                    color: isSelected
                                        ? AppColors.primaryDark
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  top: const BorderSide(
                                    color: Color(0xFFE5E5E5),
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: _courseWidth,
                                    child: Text(course.academicList ?? 'N/A'),
                                  ),
                                  SizedBox(
                                    width: _feeWidth,
                                    child: Text(
                                      '${course.feePerCredit ?? '-'} ${course.currency ?? ''}'
                                          .trim(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: _admissionWidth,
                                    child: Text(
                                      '${course.minAdmissionRate ?? '-'}%',
                                    ),
                                  ),
                                  SizedBox(
                                    width: _trackWidth,
                                    child: Text(course.track ?? '-'),
                                  ),
                                  SizedBox(
                                    width: _detailsWidth,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Details ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Icon(Icons.chevron_right)
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // OutlinedButton(
                                        //   onPressed: () {},
                                        //   style: OutlinedButton.styleFrom(
                                        //     backgroundColor: const Color(
                                        //       0xFFC8F3DF,
                                        //     ),
                                        //     foregroundColor:
                                        //     const Color(0xFF126F4A),
                                        //     side: const BorderSide(
                                        //       color: Color(0xFF93D8BC),
                                        //     ),
                                        //     minimumSize: const Size(120, 34),
                                        //     padding:
                                        //     const EdgeInsets.symmetric(
                                        //       horizontal: 8,
                                        //       vertical: 6,
                                        //     ),
                                        //     textStyle: const TextStyle(
                                        //       fontSize: 10,
                                        //       fontWeight: FontWeight.w700,
                                        //     ),
                                        //   ),
                                        //   child: const Text(
                                        //     'Apply & Pay\nApplication Fee',
                                        //     textAlign: TextAlign.center,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InfoItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;

  InfoItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

class ReadMoreText extends StatefulWidget {
  const ReadMoreText({super.key, required this.text, this.trimLines = 3});

  final String text;
  final int trimLines;

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final textSpan = TextSpan(
          text: widget.text,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textMuted,
            height: 1.35,
          ),
        );

        final tp = TextPainter(
          text: textSpan,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: isExpanded ? null : widget.trimLines,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),

            if (isOverflowing)
              GestureDetector(
                onTap: () {
                  setState(() => isExpanded = !isExpanded);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
