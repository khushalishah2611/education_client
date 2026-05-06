import 'package:education/core/app_localizations.dart';
import 'package:education/core/image_url_helper.dart';
import 'package:education/core/responsive_helper.dart';
import 'package:education/models/admin_university.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.university,
    required this.course,
    this.academicEntry,
    this.collegeName,
  });

  final AdminUniversity university;
  final CourseDetails course;
  final AcademicList? academicEntry;
  final String? collegeName;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  AdminUniversity get data => widget.university;

  ProgramData? get _program => widget.academicEntry?.program;

  CourseDetails get _course => CourseDetails(
    name: _firstNotEmpty(widget.course.name, _program?.name),
    isBooked: widget.course.isBooked,
    track: _firstNotEmpty(widget.course.track, _program?.track),
    duration: widget.course.duration,
    creditHours: widget.course.creditHours,
    totalFees: widget.course.totalFees,
    semesters: widget.course.semesters,
    feePerCredit: widget.course.feePerCredit,
    semesterFee: widget.course.semesterFee,
    annualFee: widget.course.annualFee,
    basePrice: widget.course.basePrice ?? _program?.basePrice,
    minAdmissionRate:
        widget.course.minAdmissionRate ?? _program?.minAdmissionRate,
    requiredScore: widget.course.requiredScore ?? _program?.requiredScore,
    discountedScore:
        widget.course.discountedScore ?? _program?.discountedScore,
    eligibility: _nonEmptyList(widget.course.eligibility) ??
        _nonEmptyList(_program?.eligibilityTitle),
    otherRequirements: widget.course.otherRequirements,
    currency: _firstNotEmpty(widget.course.currency, _program?.currency),
    applicationFee:
        widget.course.applicationFee ?? _firstProgramApplicationFee(),
    coverImagePath:
        _firstNotEmpty(widget.course.coverImagePath, _program?.coverImagePath),
    status: _firstNotEmpty(widget.course.status, _program?.status),
    minBaGpa: widget.course.minBaGpa,
  );

  String get selectedCourseTitle =>
      _course.name?.trim().isNotEmpty == true
      ? _course.name!.trim()
      : 'Course Details';

  String get selectedCollegeName => widget.collegeName?.trim() ?? '';

  List<String> get eligibilityList =>
      _course.eligibility?.where((item) => item.trim().isNotEmpty).toList() ??
      const [];

  List<String> get otherRequirementList =>
      _course.otherRequirements
          ?.where((item) => item.trim().isNotEmpty)
          .toList() ??
      const [];
  List<String> get admissionRequirementList => eligibilityList;

  String? _firstNotEmpty(String? primary, String? fallback) {
    final String primaryValue = primary?.trim() ?? '';
    if (primaryValue.isNotEmpty) return primaryValue;

    final String fallbackValue = fallback?.trim() ?? '';
    return fallbackValue.isEmpty ? null : fallbackValue;
  }

  List<String>? _nonEmptyList(List<String>? values) {
    final List<String> cleaned = values
            ?.map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList() ??
        <String>[];
    return cleaned.isEmpty ? null : cleaned;
  }

  int? _firstProgramApplicationFee() {
    for (final UniversityLinks link
        in _program?.universityLinks ?? const <UniversityLinks>[]) {
      if (link.applicationFee != null) return link.applicationFee;
    }
    return null;
  }

  String _priceWithCurrency(num? amount) {
    final currency = _course.currency?.trim() ?? '';
    if (amount == null) return '-';
    return currency.isEmpty ? amount.toString() : '$currency $amount';
  }

  void _showAddressDialog() {
    showAddressBottomSheet(
      context: context,
      address: widget.university.address,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final bool isMediumMobile = context.isMediumMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;
    final double headerHeight = isSmallMobile
        ? 220
        : isMediumMobile
        ? 245
        : 280;
    final double topGap = isSmallMobile ? 52 : 60;

    final String courseTitle = selectedCourseTitle;

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
                    height: headerHeight,
                    width: double.infinity,
                    child: Image.network(
                      ImageUrlHelper.resolveUploadUrl(
                        widget.university.coverImagePath,
                      ),
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) =>
                          Center(child: Image.asset('assets/images/logo.webp')),
                    ),
                  ),
                ),

                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
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
                                widget.university.logoPath,
                              ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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

                TopRoundedHeader(title: courseTitle),
              ],
            ),

            SizedBox(height: topGap),

            /// 🔷 SCROLLABLE CONTENT ONLY
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: isSmallMobile ? 10 : 14),
                children: [
                  if (selectedCollegeName.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        12,
                      ),
                      child: _ContextDetailsCard(
                        collegeName: selectedCollegeName,
                        academicName: widget.academicEntry?.academicname,
                        programName: _program?.name,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      0,
                    ),
                    child: _InfoDetailsCard(
                      course: _course,
                      priceWithCurrency: _priceWithCurrency,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      0,
                    ),
                    child: _RequirementSection(
                      title: 'Admission Requirements',
                      items: admissionRequirementList,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      0,
                    ),
                    child: _RequirementSection(
                      title: 'Other Requirements',
                      items: otherRequirementList,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔷 BUTTON (FIXED)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: AppPrimaryButton(
                  label: context.l10n.text('Go Back'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextDetailsCard extends StatelessWidget {
  const _ContextDetailsCard({
    required this.collegeName,
    this.academicName,
    this.programName,
  });

  final String collegeName;
  final String? academicName;
  final String? programName;

  @override
  Widget build(BuildContext context) {
    final List<_ContextItem> items = <_ContextItem>[
      _ContextItem(label: 'College', value: collegeName),
      _ContextItem(label: 'Academic', value: academicName),
      _ContextItem(label: 'Program', value: programName),
    ].where((item) => item.value?.trim().isNotEmpty == true).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7E2DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '${item.label}: ',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: item.value!.trim()),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ContextItem {
  const _ContextItem({required this.label, required this.value});

  final String label;
  final String? value;
}

class _InfoDetailsCard extends StatelessWidget {
  const _InfoDetailsCard({
    required this.course,
    required this.priceWithCurrency,
  });

  final CourseDetails course;
  final String Function(num? amount) priceWithCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7E2DA)),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE5F8F2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Information',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Details',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          _InfoRow(
            label: 'Credit Hours',
            value: '${course.creditHours ?? '-'}',
          ),
          _InfoRow(
            label: 'Min Admission Rate',
            value: '${course.minAdmissionRate ?? '-'}%',
          ),
          _InfoRow(
            label: 'Annual Fee',
            value: priceWithCurrency(course.annualFee),
          ),
          _InfoRow(
            label: 'Total Cost',
            valueWidget: _PriceValue(
              basePrice: course.basePrice,
              discountedPrice: course.discountedScore,
              priceWithCurrency: priceWithCurrency,
            ),
          ),
          _InfoRow(
            label: 'Application Fee',
            value: priceWithCurrency(course.applicationFee),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _PriceValue extends StatelessWidget {
  const _PriceValue({
    required this.basePrice,
    required this.discountedPrice,
    required this.priceWithCurrency,
  });

  final int? basePrice;
  final int? discountedPrice;
  final String Function(num? amount) priceWithCurrency;

  @override
  Widget build(BuildContext context) {
    final double base = (basePrice ?? 0).toDouble();

    // Jo discountedPrice percent hoy (e.g. 33)
    final double discountPercent = (discountedPrice ?? 0).toDouble();
    final double finalPrice = base - (base * discountPercent / 100);

    // Valid discount check
    if (basePrice != null &&
        discountedPrice != null &&
        discountPercent > 0 &&
        discountPercent < 100) {
      return Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(
            priceWithCurrency(base),
            style: const TextStyle(
              color: Colors.red,
              decoration: TextDecoration.lineThrough,
              fontSize: 13,
            ),
          ),
          Text(
            priceWithCurrency(finalPrice),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    // Fallback (no discount)
    return Text(
      priceWithCurrency(base),
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.isLast = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF1ECE4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ?? Text(value ?? '-'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementSection extends StatelessWidget {
  const _RequirementSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: 10),
        Card(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: items.isEmpty
                ? const _BulletLine('No requirements available')
                : Column(children: items.map(_BulletLine.new).toList()),
          ),
        ),
      ],
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
