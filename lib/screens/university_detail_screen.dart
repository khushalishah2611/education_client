import 'package:education/core/app_localizations.dart';
import 'package:education/core/image_url_helper.dart';
import 'package:education/models/admin_university.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'course_detail_screen.dart';
import 'upload_documents_screen.dart' show UploadDocumentsScreen;

class UniversityDetailScreen extends StatefulWidget {
  const UniversityDetailScreen({super.key, required this.data});

  final AdminUniversity data;

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  static const int _maxSelectableCourses = 5;
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

  Map<String, List<CourseDetails>> get _collegeCourses {
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
    showAddressBottomSheet(context: context, address: data.address);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallMobile = screenWidth <= 360;
    final bool isMediumMobile = screenWidth > 360 && screenWidth <= 420;
    final double headerHeight = isSmallMobile
        ? 220
        : isMediumMobile
        ? 245
        : 280;
    final double topGap = isSmallMobile ? 52 : 60;
    final double sectionPadding = isSmallMobile ? 14 : 16;

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
                      height: headerHeight,
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
                                        data.averageRating!
                                            .toDouble()
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '(${data.averageRating!.toDouble().toString()} reviews)',
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
                                          data.address ?? "",
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

                  TopRoundedHeader(title: data.name ?? ""),
                ],
              ),

              SizedBox(height: topGap),

              /// 🔥 SCROLL CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: sectionPadding + 4,
                        ),
                        child: Text(
                          'About',
                          style: TextStyle(
                            fontSize: isSmallMobile ? 16 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          sectionPadding + 4,
                          10,
                          sectionPadding + 4,
                          0,
                        ),
                        child: ReadMoreText(text: data.aboutUs.toString()),
                      ),
                      SizedBox(height: 10),
                      if (_selectedCourses.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            sectionPadding + 4,
                            0,
                            sectionPadding + 4,
                            10,
                          ),
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

                      if (data.academicList?.isNotEmpty ?? false)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: sectionPadding,
                          ),
                          child: Column(
                            children: (data.academicList ?? []).map((entry) {
                              final String collegeName =
                                  (entry.college?.trim().isNotEmpty ?? false)
                                  ? entry.college!.trim()
                                  : '';
                              final bool isExpanded = _expandedColleges
                                  .contains(collegeName);

                              return _CollegeAccordion(
                                collegeName: collegeName,
                                academicEntry: entry,
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
                                    } else if (_selectedCourses.length <
                                        _maxSelectableCourses) {
                                      _selectedCourses.add(courseKey);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'You can select up to 5 courses only.',
                                            ),
                                          ),
                                        );
                                    }
                                  });
                                },
                                adminUniversity: data,
                              );
                            }).toList(),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE6E6E6),
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              context.l10n.text('No courses available'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    sectionPadding,
                    8,
                    sectionPadding,
                    isSmallMobile ? 12 : 16,
                  ),
                  child: AppPrimaryButton(
                    label: 'View Courses (${_selectedCourses.length})',
                    onPressed: _selectedCourses.isEmpty
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selected ${_selectedCourses.length} of $_maxSelectableCourses courses',
                                ),
                              ),
                            );
                          },
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
    required this.academicEntry,
    required this.isExpanded,
    required this.selectedCourses,
    required this.onToggleExpand,
    required this.onToggleCourse,
    required this.adminUniversity,
  });

  final String collegeName;
  final AcademicList academicEntry;
  final bool isExpanded;
  final Set<String> selectedCourses;
  final AdminUniversity adminUniversity;
  final VoidCallback onToggleExpand;
  final ValueChanged<String> onToggleCourse;

  @override
  Widget build(BuildContext context) {
    final List<CourseDetails> courseDetailsList =
        academicEntry.program?.courseDetails ?? <CourseDetails>[];
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallMobile = screenWidth <= 360;
    final bool isMediumMobile = screenWidth > 360 && screenWidth <= 420;
    final double courseWidth = isSmallMobile
        ? 130
        : isMediumMobile
        ? 150
        : 180;
    final double feeWidth = isSmallMobile
        ? 72
        : isMediumMobile
        ? 84
        : 94;
    final double admissionWidth = isSmallMobile
        ? 68
        : isMediumMobile
        ? 78
        : 86;
    final double trackWidth = isSmallMobile
        ? 82
        : isMediumMobile
        ? 100
        : 115;
    final double detailsWidth = isSmallMobile
        ? 92
        : isMediumMobile
        ? 96
        : 110;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      collegeName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF595959),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(
                    courseWidth: courseWidth,
                    feeWidth: feeWidth,
                    admissionWidth: admissionWidth,
                    trackWidth: trackWidth,
                    detailsWidth: detailsWidth,
                  ),
                  ...[
                    if (courseDetailsList.isNotEmpty)
                      ...courseDetailsList.map((details) {
                        final String courseKey =
                            '$collegeName-${details.name ?? ''}';
                        final bool isSelected = selectedCourses.contains(
                          courseKey,
                        );

                        return _buildCourseRow(
                          details: details,
                          isSelected: isSelected,
                          onTap: () => onToggleCourse(courseKey),
                          context: context,
                          adminUniversity: adminUniversity,
                          courseWidth: courseWidth,
                          feeWidth: feeWidth,
                          admissionWidth: admissionWidth,
                          trackWidth: trackWidth,
                          detailsWidth: detailsWidth,
                        );
                      }).toList()
                    else
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 12,
                          bottom: 12,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'No data available',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader({
    required double courseWidth,
    required double feeWidth,
    required double admissionWidth,
    required double trackWidth,
    required double detailsWidth,
  }) {
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          _HeaderCell(width: courseWidth, label: 'Course'),
          _HeaderCell(width: feeWidth, label: 'Credit\nHour Fee'),
          _HeaderCell(width: admissionWidth, label: 'Min\nAdmis%'),
          _HeaderCell(width: trackWidth, label: 'Track'),
          _HeaderCell(width: detailsWidth, label: 'Details / Apply'),
        ],
      ),
    );
  }

  Widget _buildCourseRow({
    required CourseDetails details,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
    required adminUniversity,
    required double courseWidth,
    required double feeWidth,
    required double admissionWidth,
    required double trackWidth,
    required double detailsWidth,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.peachSoft : Colors.white,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primaryDark : Colors.transparent,
              width: 3,
            ),
            bottom: const BorderSide(color: Color(0xFFE9E9E9)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: courseWidth,
              child: Text(
                details.name ?? 'N/A',
                style: const TextStyle(fontSize: 32 / 2, height: 1.05),
              ),
            ),
            SizedBox(
              width: feeWidth,
              child: Text(
                '${details.creditHours ?? 0} ${details.currency ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: admissionWidth,
              child: Text(
                '${details.minAdmissionRate ?? 0}%',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: trackWidth,
              child: Text(
                details.track ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: detailsWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CourseDetailScreen(
                            university: adminUniversity,
                            course: details,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Details',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UploadDocumentsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBDEED3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Apply & Pay\nApplication Fee',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF206F49),
                          height: 1.2,
                        ),
                      ),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.width, required this.label});

  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, height: 1.1),
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
