import 'package:education/core/app_localizations.dart';
import 'package:education/core/image_url_helper.dart';
import 'package:education/core/selected_course_storage.dart';
import 'package:education/models/admin_university.dart';
import 'package:education/models/selected_course_data.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'course_detail_screen.dart';
import 'upload_documents_screen.dart' show UploadDocumentsScreen;

class UniversityDetailScreen extends StatefulWidget {
  const UniversityDetailScreen({
    super.key,
    required this.data,
    this.initialSelectedCourseKeys = const <String>{},
  });

  final AdminUniversity data;
  final Set<String> initialSelectedCourseKeys;

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  final Set<String> _expandedColleges = <String>{};
  final Set<String> _selectedCourses = <String>{};

  AdminUniversity get data => widget.data;
  String get _universityKey => data.id?.trim().isNotEmpty == true
      ? data.id!.trim()
      : (data.name ?? '').trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _selectedCourses.addAll(widget.initialSelectedCourseKeys);
    _restoreSelectedCourses();
  }

  void _showAddressDialog() {
    showAddressBottomSheet(context: context, address: data.address);
  }

  Future<void> _restoreSelectedCourses() async {
    final SelectedCourseData? savedData = await SelectedCourseStorage.load();
    if (savedData != null && savedData.universityKey == _universityKey) {
      _selectedCourses.addAll(savedData.courseKeys);
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _syncSelectedCourses() async {
    if (_selectedCourses.isEmpty) {
      final SelectedCourseData? current = await SelectedCourseStorage.load();
      if (current != null && current.universityKey == _universityKey) {
        await SelectedCourseStorage.clear();
      }
      return;
    }

    await SelectedCourseStorage.save(
      SelectedCourseData(
        universityKey: _universityKey,
        courseKeys: _selectedCourses.toList(),
      ),
    );
  }

  Future<void> _toggleCourseSelection(String courseKey) async {
    final SelectedCourseData? savedData = await SelectedCourseStorage.load();
    final bool selectingNewCourse = !_selectedCourses.contains(courseKey);
    final bool hasDifferentUniversitySelection =
        selectingNewCourse &&
        _selectedCourses.isEmpty &&
        savedData != null &&
        savedData.universityKey.isNotEmpty &&
        savedData.universityKey != _universityKey &&
        savedData.courseKeys.isNotEmpty;

    if (hasDifferentUniversitySelection) {
      final bool? shouldReplaceSelection = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,

        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D1D1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Replace selected courses?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  const Text(
                    'You already selected courses in another university. '
                    'Do you want to clear them and continue here?',
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppOutlinedButton(
                          label: context.l10n.text('Cancel'),
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppPrimaryButton(
                          label: context.l10n.text('Continue'),
                          onPressed: () => Navigator.of(sheetContext).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (shouldReplaceSelection != true) {
        return;
      }

      await SelectedCourseStorage.clear();
    }

    setState(() {
      if (_selectedCourses.contains(courseKey)) {
        _selectedCourses.remove(courseKey);
      } else {
        _selectedCourses.add(courseKey);
      }
    });
    await _syncSelectedCourses();
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
                                          fontSize: isSmallMobile ? 11 : 12,
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
                                onToggleCourse: _toggleCourseSelection,
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
                            final String selectedCourseTitle = _selectedCourses
                                .first
                                .split('-')
                                .last
                                .trim();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadDocumentsScreen(
                                  universityName: data.name,
                                  universityHeroImage:
                                      ImageUrlHelper.resolveUploadUrl(
                                        data.coverImagePath,
                                      ),
                                  courseTitle: selectedCourseTitle,
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

class _CollegeAccordion extends StatefulWidget {
  const _CollegeAccordion({
    super.key,
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
  State<_CollegeAccordion> createState() => _CollegeAccordionState();
}

class _CollegeAccordionState extends State<_CollegeAccordion> {
  bool _isSmallMobile(double width) => width <= 360;

  bool _isMediumMobile(double width) => width > 360 && width <= 420;

  @override
  Widget build(BuildContext context) {
    final List<CourseDetails> courseDetailsList =
        widget.academicEntry.program?.courseDetails ?? <CourseDetails>[];
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallMobile = _isSmallMobile(screenWidth);
    final bool isMediumMobile = _isMediumMobile(screenWidth);
    final double minTableWidth = isSmallMobile
        ? 620
        : isMediumMobile
        ? 680
        : 740;

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
            onTap: widget.onToggleExpand,
            child: Container(
              width: double.infinity,
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 10 : 12, vertical: isSmallMobile ? 12 : 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.collegeName.toUpperCase(),
                      style: TextStyle(
                        fontSize: isSmallMobile ? 12.5 : 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                  ),
                  Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF595959),
                  ),
                ],
              ),
            ),
          ),

          if (widget.isExpanded)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minTableWidth),
                child: Column(
                  children: [
                    _buildTableHeader(
                      context,
                      isSmallMobile: isSmallMobile,
                      tableWidth: minTableWidth,
                    ),
                    if (courseDetailsList.isNotEmpty)
                      ...courseDetailsList.map((details) {
                        final String courseKey =
                            '${widget.collegeName}-${details.name ?? ''}';
                        final bool isSelected = widget.selectedCourses.contains(
                          courseKey,
                        );

                        return _buildCourseRow(
                          details: details,
                          isSelected: isSelected,
                          onTap: () => widget.onToggleCourse(courseKey),
                          context: context,
                          adminUniversity: widget.adminUniversity,
                          isSmallMobile: isSmallMobile,
                          tableWidth: minTableWidth,
                        );
                      }).toList()
                    else
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(context.l10n.text('No data available')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(
    BuildContext context, {
    required bool isSmallMobile,
    required double tableWidth,
  }) {
    final double totalFlex = 12;
    final double availableWidth = tableWidth - 6;
    final double col3 = availableWidth * (3 / totalFlex);
    final double col2 = availableWidth * (2 / totalFlex);

    return Container(
      color: const Color(0xFFE3E3E3),
      padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 4 : 5, vertical: isSmallMobile ? 4 : 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: col3,
            child: Center(
              child: Text(
                context.l10n.text('Course'),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallMobile ? 11 : 12),
              ),
            ),
          ),
          SizedBox(
            width: col2,
            child: Center(
              child: Text(
                context.l10n.text('Credit\nHour Fee'),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallMobile ? 11 : 12),
              ),
            ),
          ),
          SizedBox(
            width: col2,
            child: Center(
              child: Text(
                context.l10n.text('Min\nAdmis%'),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallMobile ? 11 : 12),
              ),
            ),
          ),
          SizedBox(
            width: col2,
            child: Center(
              child: Text(
                context.l10n.text('Track'),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallMobile ? 11 : 12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: col3,
            child: Center(
              child: Text(
                context.l10n.text('Details / Apply'),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallMobile ? 11 : 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseRow({
    required CourseDetails details,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
    required AdminUniversity adminUniversity,
    required bool isSmallMobile,
    required double tableWidth,
  }) {
    final double totalFlex = 12;
    final double availableWidth = tableWidth - 6;
    final double col3 = availableWidth * (3 / totalFlex);
    final double col2 = availableWidth * (2 / totalFlex);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 4 : 5, vertical: isSmallMobile ? 4 : 5),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: col3,
              child: Text(
                details.name ?? 'N/A',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallMobile ? 11 : 12,
                ),
              ),
            ),
            SizedBox(
              width: col2,
              child: Text(
                '${details.creditHours ?? 0}\n${details.currency ?? ''}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallMobile ? 11 : 12,
                ),
              ),
            ),
            SizedBox(
              width: col2,
              child: Text(
                '${details.minAdmissionRate ?? 0}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallMobile ? 11 : 12,
                ),
              ),
            ),
            SizedBox(
              width: col2,
              child: Text(
                details.track ?? 'N/A',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallMobile ? 11 : 12,
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: col3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // 👈 important
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
                    child: Text(
                      context.l10n.text('Details'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallMobile ? 11 : 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UploadDocumentsScreen(
                            universityName: widget.adminUniversity.name,
                            universityHeroImage:
                                ImageUrlHelper.resolveUploadUrl(
                                  widget.adminUniversity.coverImagePath,
                                ),
                            courseTitle: details.name,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center, // 👈 important
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFADE8C9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Color(0xFF78D09F)),
                      ),
                      child: Text(
                        context.l10n.text('Apply & Pay\nApplication Fee'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.2,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF206F49),
                          height: 1.1,
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
