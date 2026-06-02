import 'package:education/core/app_localizations.dart';
import 'package:education/core/bloc/app_cubit.dart';
import 'package:education/core/image_url_helper.dart';
import 'package:education/core/selected_course_storage.dart';
import 'package:education/models/admin_university.dart';
import 'package:education/models/selected_course_data.dart';
import 'package:education/models/master_option.dart';
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
    this.selectedAcademic,
    this.selectedTrack,
    this.selectedResult,
    this.academicOptions = const <MasterOption>[],
    this.trackOptions = const <MasterOption>[],
  });

  final AdminUniversity data;
  final Set<String> initialSelectedCourseKeys;
  final String? selectedAcademic;
  final String? selectedTrack;
  final String? selectedResult;
  final List<MasterOption> academicOptions;
  final List<MasterOption> trackOptions;

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen>
    with CubitStateMixin<UniversityDetailScreen> {
  final Set<String> _expandedColleges = <String>{};
  final Set<String> _selectedCourses = <String>{};

  AdminUniversity get data => widget.data;

  String _localizedText(String? englishValue, String? arabicValue) {
    final localized = context.l10n.isArabic ? arabicValue : englishValue;
    if ((localized ?? '').trim().isNotEmpty) return localized!.trim();

    final fallback = context.l10n.isArabic ? englishValue : arabicValue;
    return (fallback ?? '').trim();
  }

  List<AcademicList> get _localizedAcademicList {
    if (context.l10n.isArabic && (data.academicListAr?.isNotEmpty ?? false)) {
      return data.academicListAr!;
    }
    if (data.academicList?.isNotEmpty ?? false) {
      return data.academicList!;
    }
    return <AcademicList>[];
  }

  List<AcademicPrograms> get _localizedAcademicPrograms {
    if (data.academicPrograms?.isNotEmpty ?? false) {
      return data.academicPrograms!;
    }
    if (context.l10n.isArabic && (data.academicListAr?.isNotEmpty ?? false)) {
      return _academicProgramsFromEntries(data.academicListAr!);
    }
    return _academicProgramsFromEntries(_localizedAcademicList);
  }

  Map<String, List<AcademicList>> get _academicGroups {
    final Map<String, List<AcademicList>> grouped =
        <String, List<AcademicList>>{};

    for (final AcademicList entry in _localizedAcademicList) {
      final String academicName = entry.academicname?.trim() ?? '';
      if (!_matchesSelectedAcademic(academicName) &&
          !_matchesSelectedAcademic(entry.program?.academicProgram)) {
        continue;
      }
      grouped.putIfAbsent(academicName, () => <AcademicList>[]).add(entry);
    }

    return grouped;
  }

  List<AcademicPrograms> _academicProgramsFromEntries(
    List<AcademicList> entries,
  ) {
    final grouped = <String, AcademicPrograms>{};

    for (final entry in entries) {
      final program = entry.program;
      final academicName = (entry.academicname ??
              program?.academicProgram ??
              program?.name ??
              '')
          .trim();
      final collegeName =
          (entry.college ?? program?.educationInstitute ?? '').trim();

      if (academicName.isEmpty && collegeName.isEmpty && program == null) {
        continue;
      }

      final academicProgram = grouped.putIfAbsent(
        academicName,
        () => AcademicPrograms(academicname: academicName, colleges: []),
      );
      final colleges = academicProgram.colleges ?? <Colleges>[];
      academicProgram.colleges = colleges;

      final college = colleges.firstWhere(
        (item) => (item.college ?? '') == collegeName,
        orElse: () {
          final created = Colleges(college: collegeName, courses: []);
          colleges.add(created);
          return created;
        },
      );
      final courses = college.courses ?? <Courses>[];
      college.courses = courses;

      final details = program?.courseDetails ?? <CourseDetails>[];
      if (details.isNotEmpty) {
        courses.addAll(details.map(
          (course) => Courses.fromCourseDetails(
            course,
            program: program,
            academicName: academicName,
            collegeName: collegeName,
          ),
        ));
        continue;
      }

      final courseNames = program?.courses?.isNotEmpty == true
          ? program?.courses
          : program?.courseNames;
      for (final courseName in _splitCourseNames(courseNames)) {
        courses.add(Courses.fromCourseDetails(
          CourseDetails(name: courseName),
          program: program,
          academicName: academicName,
          collegeName: collegeName,
        ));
      }
    }

    return grouped.values.toList(growable: false);
  }

  List<String> _splitCourseNames(dynamic value) {
    if (value == null) return const [];
    if (value is Iterable) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return value
        .toString()
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  bool _matchesSelectedAcademic(String? value) {
    final selected = _normalizeFilterValue(widget.selectedAcademic);
    if (selected.isEmpty) return true;
    final aliases = _selectedAliases(
      widget.selectedAcademic,
      widget.academicOptions,
    );
    return aliases.contains(_normalizeFilterValue(value));
  }

  Set<String> _selectedAliases(String? selected, List<MasterOption> options) {
    final aliases = <String>{};
    final normalizedSelected = _normalizeFilterValue(selected);
    if (normalizedSelected.isEmpty) return aliases;

    aliases.add(normalizedSelected);
    for (final option in options) {
      final optionValues = <String>[
        option.nameEn,
        option.nameAr,
        option.value,
        option.key,
      ].map(_normalizeFilterValue).where((value) => value.isNotEmpty).toSet();

      if (optionValues.contains(normalizedSelected)) {
        aliases.addAll(optionValues);
      }
    }

    return aliases;
  }

  static String _normalizeFilterValue(String? value) {
    return (value ?? '').trim().toUpperCase();
  }

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
    showAddressBottomSheet(
      context: context,
      address: _localizedText(data.address, data.addressAr),
    );
  }

  Future<void> _restoreSelectedCourses() async {
    final SelectedCourseData? savedData = await SelectedCourseStorage.load();
    if (savedData != null && savedData.universityKey == _universityKey) {
      _selectedCourses.addAll(savedData.courseKeys);
    }

    if (!mounted) return;
    refreshView();
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
    final bool hasDifferentUniversitySelection = selectingNewCourse &&
        _selectedCourses.isEmpty &&
        savedData != null &&
        savedData.universityKey.isNotEmpty &&
        savedData.universityKey != _universityKey &&
        savedData.courseKeys.isNotEmpty;

    if (hasDifferentUniversitySelection) {
      await SelectedCourseStorage.clear();
    }

    updateView(() {
      if (_selectedCourses.contains(courseKey)) {
        _selectedCourses.remove(courseKey);
      } else {
        _selectedCourses
          ..clear()
          ..add(courseKey);
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

    return buildCubitView(
      (context) => Directionality(
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
                                  ImageUrlHelper.resolveUploadUrl(
                                      data.logoPath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child:
                                        Image.asset('assets/images/logo.webp'),
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
                                          '(${data.ratingCount!.toDouble().toString()} reviews)',
                                          style: TextStyle(
                                            fontSize: isSmallMobile ? 11 : 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _localizedText(data.name, data.nameAr),
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
                                            _localizedText(
                                              data.address,
                                              data.addressAr,
                                            ),
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
                    TopRoundedHeader(
                        title: _localizedText(data.name, data.nameAr)),
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
                            context.l10n.text('about'),
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
                          child: ReadMoreText(
                            text: _localizedText(data.aboutUs, data.aboutUsAr),
                          ),
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
                        if (_localizedAcademicList.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: sectionPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  _academicGroups.entries.map((groupEntry) {
                                final String academicName = groupEntry.key;
                                final bool isExpanded =
                                    _expandedColleges.contains(academicName);

                                return _CollegeAccordion(
                                  academicName: academicName,
                                  academicEntries: groupEntry.value,
                                  isExpanded: isExpanded,
                                  selectedCourses: _selectedCourses,
                                  onToggleExpand: () {
                                    updateView(() {
                                      if (isExpanded) {
                                        _expandedColleges.remove(academicName);
                                      } else {
                                        _expandedColleges.add(academicName);
                                      }
                                    });
                                  },
                                  onToggleCourse: _toggleCourseSelection,
                                  adminUniversity: data,
                                  selectedAcademic: widget.selectedAcademic,
                                  selectedTrack: widget.selectedTrack,
                                  selectedResult: widget.selectedResult,
                                  academicOptions: widget.academicOptions,
                                  trackOptions: widget.trackOptions,
                                  academicPrograms: _localizedAcademicPrograms,
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

                // SafeArea(
                //   top: false,
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(
                //       sectionPadding,
                //       8,
                //       sectionPadding,
                //       isSmallMobile ? 12 : 16,
                //     ),
                //     child: AppPrimaryButton(
                //       label: 'View Courses (${_selectedCourses.length})',
                //       onPressed: _selectedCourses.isEmpty
                //           ? null
                //           : () {
                //               final String selectedCourseTitle =
                //                   _selectedCourses.first.split('-').last.trim();
                //               Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                   builder: (_) => UploadDocumentsScreen(
                //                     universityName: data.name,
                //                     universityHeroImage:
                //                         ImageUrlHelper.resolveUploadUrl(
                //                           data.coverImagePath,
                //                         ),
                //                     courseTitle: selectedCourseTitle,
                //                   ),
                //                 ),
                //               );
                //             },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollegeAccordion extends StatefulWidget {
  const _CollegeAccordion({
    super.key,
    required this.academicName,
    required this.academicEntries,
    required this.isExpanded,
    required this.selectedCourses,
    required this.onToggleExpand,
    required this.onToggleCourse,
    required this.adminUniversity,
    required this.selectedAcademic,
    required this.selectedTrack,
    required this.selectedResult,
    required this.academicOptions,
    required this.trackOptions,
    required this.academicPrograms,
  });

  final String academicName;
  final List<AcademicList> academicEntries;
  final bool isExpanded;
  final Set<String> selectedCourses;
  final AdminUniversity adminUniversity;
  final String? selectedAcademic;
  final String? selectedTrack;
  final String? selectedResult;
  final List<MasterOption> academicOptions;
  final List<MasterOption> trackOptions;
  final List<AcademicPrograms> academicPrograms;
  final VoidCallback onToggleExpand;
  final ValueChanged<String> onToggleCourse;

  @override
  State<_CollegeAccordion> createState() => _CollegeAccordionState();
}

class _CollegeAccordionState extends State<_CollegeAccordion> {
  bool _isSmallMobile(double width) => width <= 360;

  String _normalizeFilterValue(String? value) {
    return (value ?? '').trim().toUpperCase();
  }

  String _localizedMasterLabel(
    BuildContext context,
    String? value,
    List<MasterOption> options, {
    bool uppercaseEnglish = false,
  }) {
    final String normalizedValue = _normalizeFilterValue(value);
    if (normalizedValue.isEmpty) return '';

    for (final option in options) {
      final matches = <String>[
        option.nameEn,
        option.nameAr,
        option.value,
        option.key,
      ].any((candidate) => _normalizeFilterValue(candidate) == normalizedValue);

      if (matches) {
        final label =
            option.displayName(isArabic: context.l10n.isArabic).trim();
        if (label.isNotEmpty) {
          return !context.l10n.isArabic && uppercaseEnglish
              ? label.toUpperCase()
              : label;
        }
      }
    }

    final fallback = value?.trim() ?? '';
    return !context.l10n.isArabic && uppercaseEnglish
        ? fallback.toUpperCase()
        : fallback;
  }

  Set<String> _selectedAliases(String? selected, List<MasterOption> options) {
    final aliases = <String>{};
    final normalizedSelected = _normalizeFilterValue(selected);
    if (normalizedSelected.isEmpty) return aliases;

    aliases.add(normalizedSelected);
    for (final option in options) {
      final optionValues = <String>[
        option.nameEn,
        option.nameAr,
        option.value,
        option.key,
      ].map(_normalizeFilterValue).where((value) => value.isNotEmpty).toSet();

      if (optionValues.contains(normalizedSelected)) {
        aliases.addAll(optionValues);
      }
    }

    return aliases;
  }

  bool _matchesSelectedTrack(Courses course) {
    final selected = _normalizeFilterValue(widget.selectedTrack);
    if (selected.isEmpty) return true;
    return _splitFilterValues(course.track).contains(selected);
  }

  bool _matchesSelectedAcademic(Courses course) {
    final selected = _normalizeFilterValue(widget.selectedAcademic);
    if (selected.isEmpty) return true;
    final aliases = _selectedAliases(
      widget.selectedAcademic,
      widget.academicOptions,
    );
    return _splitFilterValues(course.academicProgram).any(aliases.contains) ||
        aliases.contains(_normalizeFilterValue(widget.academicName));
  }

  bool _matchesSelectedResult(Courses course) {
    final selectedResult = double.tryParse(widget.selectedResult?.trim() ?? '');
    if (selectedResult == null) return true;

    final minAdmissionRate = course.minAdmissionRate?.toDouble();
    return minAdmissionRate == null || selectedResult >= minAdmissionRate;
  }

  Set<String> _splitFilterValues(String? value) {
    final values = (value ?? '')
        .split(',')
        .map(_normalizeFilterValue)
        .where((entry) => entry.isNotEmpty)
        .toSet();

    if (values.any(_isScientificAndLiterary)) {
      values.addAll(const {'SCIENTIFIC', 'LITERARY'});
    }

    return values;
  }

  bool _isScientificAndLiterary(String value) {
    return value.replaceAll(' ', '').replaceAll('&', 'AND') ==
        'SCIENTIFICANDLITERARY';
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallMobile = _isSmallMobile(screenWidth);
    final double tableWidth = screenWidth;

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
              padding: EdgeInsets.symmetric(
                horizontal: isSmallMobile ? 10 : 12,
                vertical: isSmallMobile ? 12 : 14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _localizedMasterLabel(
                        context,
                        widget.academicName,
                        widget.academicOptions,
                        uppercaseEnglish: true,
                      ),
                      style: TextStyle(
                        fontSize: isSmallMobile ? 12.5 : 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (widget.isExpanded)
            Column(
              children: widget.academicPrograms
                  .where(
                (academicProgram) =>
                    (academicProgram.academicname ?? '').trim() ==
                    widget.academicName.trim(),
              )
                  .map((academicProgram) {
                final String academicName = academicProgram.academicname ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (academicProgram.colleges ?? []).map((collegeData) {
                    final String collegeName = collegeData.college ?? '';

                    final List<Courses> collegeCourses =
                        (collegeData.courses ?? <Courses>[])
                            .where(_matchesSelectedAcademic)
                            .where(_matchesSelectedTrack)
                            .where(_matchesSelectedResult)
                            .toList(growable: false);
                    return Column(
                      children: [
                        _buildTableHeader(
                          context,
                          isSmallMobile: isSmallMobile,
                          tableWidth: tableWidth,
                          isEmpty: false,
                          collegeName: collegeName,
                        ),
                        ...(collegeCourses.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'No courses available',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ),
                              ]
                            : collegeCourses.asMap().entries.map((entry) {
                                final int index = entry.key;
                                final Courses details = entry.value;

                                final String courseKey = [
                                  academicName,
                                  collegeName,
                                  details.programId ??
                                      details.programName ??
                                      '',
                                  details.name ?? '',
                                ].map((e) => e.trim()).join('-');

                                final bool isSelected =
                                    widget.selectedCourses.contains(courseKey);

                                return _buildCourseRow(
                                  index: index,
                                  details: details,
                                  isSelected: isSelected,
                                  onTap: () => widget.onToggleCourse(courseKey),
                                  context: context,
                                  adminUniversity: widget.adminUniversity,
                                  academicProgram: academicProgram,
                                  collegeName: collegeName,
                                  isSmallMobile: isSmallMobile,
                                  tableWidth: tableWidth,
                                );
                              }).toList()),
                      ],
                    );
                  }).toList(),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(
    BuildContext context, {
    required bool isSmallMobile,
    required double tableWidth,
    required bool isEmpty,
    required String collegeName,
  }) {
    String formattedName = collegeName.split('-').first.trim();
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 4 : 5,
        vertical: isSmallMobile ? 4 : 5,
      ),
      child: SizedBox(
        width: tableWidth,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  formattedName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  context.l10n.text('Credit Fee\n(Hourly)'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  context.l10n.text('Min\nAdmis%'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  isEmpty
                      ? context.l10n.text('minBaGpa')
                      : context.l10n.text('Track'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  context.l10n.text('Details / Apply'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _buildApplicationPayload({
    required AdminUniversity adminUniversity,
    required String collegeName,
    required Courses courseDetails,
    required String courseKey,
  }) {
    final double applicationFee = courseDetails.applicationFee ?? 0;
    final double basePrice = courseDetails.basePrice ?? 0;
    const int discountedScore = 0;
    final String currency = (courseDetails.currency ?? '').trim();
    final Map<String, dynamic> selectedCourse = <String, dynamic>{
      'key': courseKey,
      'name': courseDetails.name,
      'track': courseDetails.track,
      'college': collegeName,
      'educationInstitute': courseDetails.educationInstitute ?? collegeName,
      'totalSemesters': courseDetails.totalSemesters,
      'applicationFee': applicationFee,
      'basePrice': basePrice,
      'discountedPrice': basePrice,
      'discountedScore': discountedScore,
      'currency': currency,
    }..removeWhere((_, value) {
        if (value == null) return true;
        if (value is String) return value.trim().isEmpty;
        return false;
      });

    final Map<String, dynamic> payload = <String, dynamic>{
      'universityId': adminUniversity.id,
      'programId': courseDetails.programId,
      'selectedCourseKeys': <String>[courseKey],
      'selectedCollege': collegeName,
      'selectedCourses': <Map<String, dynamic>>[selectedCourse],
      'selectedApplicationFeeTotal': applicationFee,
    };

    payload.removeWhere((_, value) {
      if (value == null) return true;
      if (value is String) return value.trim().isEmpty;
      if (value is Map) return value.isEmpty;
      return false;
    });
    return payload;
  }

  Widget _buildCourseRow({
    required int index,
    required Courses details,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
    required AdminUniversity adminUniversity,
    required AcademicPrograms academicProgram,
    required String collegeName,
    required bool isSmallMobile,
    required double tableWidth,
  }) {
    final String courseKey = [
      academicProgram.academicname ?? '',
      collegeName,
      details.programId ?? details.programName ?? '',
      details.name ?? '',
    ].map((e) => e.trim()).join('-');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallMobile ? 4 : 5,
          vertical: isSmallMobile ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark.withOpacity(0.2)
              : (index % 2 == 0 ? Colors.white : AppColors.peachSoft),
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primaryDark : Colors.transparent,
              width: 3,
            ),
            bottom: const BorderSide(
              color: Color(0xFFE9E9E9),
            ),
          ),
        ),
        child: SizedBox(
          width: tableWidth,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  details.name ?? 'N/A',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${details.annualFee?.toInt() ?? 0}\n${details.currency}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${details.minAdmissionRate?.toInt() ?? 0}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  details.track == null || details.track!.isEmpty
                      ? details.minBaGpa ?? "-"
                      : _localizedMasterLabel(
                          context,
                          details.track,
                          widget.trackOptions,
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: isSmallMobile ? 11 : 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        widget.onToggleCourse(courseKey);

                        if (!context.mounted) return;

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
                          fontWeight: FontWeight.w400,
                          fontSize: isSmallMobile ? 11 : 12,
                        ),
                      ),
                    ),
                    // Visibility(
                    //   visible: !(details.isBooked ?? false),
                    //   child:
                    InkWell(
                      onTap: () async {
                        widget.onToggleCourse(courseKey);

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UploadDocumentsScreen(
                              universityName: adminUniversity.name,
                              universityHeroImage:
                                  ImageUrlHelper.resolveUploadUrl(
                                adminUniversity.coverImagePath,
                              ),
                              courseTitle: details.name,
                              applicationsPayload: <Map<String, dynamic>>[
                                _buildApplicationPayload(
                                  adminUniversity: adminUniversity,
                                  collegeName: collegeName,
                                  courseDetails: details,
                                  courseKey: courseKey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0070e2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF0070e2),
                          ),
                        ),
                        child: Text(
                          context.l10n.text(
                            'Apply & Pay\nApplication Fee',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.6,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    // )
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

class _ReadMoreTextState extends State<ReadMoreText>
    with CubitStateMixin<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return buildCubitView(
      (context) => LayoutBuilder(
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
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
              if (isOverflowing)
                GestureDetector(
                  onTap: () {
                    updateView(() => isExpanded = !isExpanded);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isExpanded
                          ? context.l10n.text('readLess')
                          : context.l10n.text('readMore'),
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
      ),
    );
  }
}
