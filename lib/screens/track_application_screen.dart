import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/image_url_helper.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';
import '../services/application_api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'home_screen.dart';

class TrackApplicationScreen extends StatefulWidget {
  const TrackApplicationScreen({
    super.key,
    this.universityName,
    this.universityHeroImage,
    this.courseTitle,
    this.applicationId,
    this.studentOverview,
  });

  final String? universityName;
  final String? universityHeroImage;
  final String? courseTitle;
  final String? applicationId;
  final Map<String, dynamic>? studentOverview;

  @override
  State<TrackApplicationScreen> createState() => _TrackApplicationScreenState();
}

class _TrackApplicationScreenState extends State<TrackApplicationScreen> {
  final ApplicationApiService _applicationApiService =
      const ApplicationApiService();
  Map<String, dynamic>? _studentOverview;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _studentOverview = widget.studentOverview;
    if (_studentOverview == null) {
      _fetchStudentOverview();
    }
  }

  Future<void> _fetchStudentOverview() async {
    setState(() => _isLoading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';
      if (studentUserId.isEmpty) return;

      final Map<String, dynamic> overview =
          await _applicationApiService.fetchStudentOverview(
        studentUserId: studentUserId,
      );
      if (!mounted) return;
      setState(() => _studentOverview = overview);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  List<Map<String, dynamic>> get _applications =>
      _listFromOverview('applications');

  List<Map<String, dynamic>> get _payments => _listFromOverview('payments');

  List<Map<String, dynamic>> get _documents => _listFromOverview('documents');

  List<Map<String, dynamic>> _listFromOverview(String key) {
    final Object? items = _studentOverview?[key];
    if (items is! List) return const <Map<String, dynamic>>[];

    return items
        .whereType<Map>()
        .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }

  Map<String, dynamic>? get _application {
    final String selectedApplicationId = widget.applicationId?.trim() ?? '';
    for (final Map<String, dynamic> application in _applications) {
      if (selectedApplicationId.isNotEmpty &&
          _textFrom(application['id']) == selectedApplicationId) {
        return application;
      }
    }

    return _applications.isNotEmpty ? _applications.first : null;
  }

  Map<String, dynamic>? get _payment {
    final String selectedApplicationId = _textFrom(_application?['id']);
    for (final Map<String, dynamic> payment in _payments) {
      if (selectedApplicationId.isNotEmpty &&
          _textFrom(payment['applicationId']) == selectedApplicationId) {
        return payment;
      }
    }

    return _payments.isNotEmpty ? _payments.first : null;
  }

  String get _applicationId {
    final String id =
        _textFrom(_application?['id']).ifEmpty(widget.applicationId);
    return id.isEmpty ? '-' : '#${_shortId(id)}';
  }

  String get _universityName {
    final Object? university = _application?['university'];
    if (university is Map) {
      final String name = _textFrom(university['name']);
      if (name.isNotEmpty) return name;
    }
    return widget.universityName ?? context.l10n.text('university');
  }

  String get _heroImage {
    if (widget.universityHeroImage?.trim().isNotEmpty == true) {
      return widget.universityHeroImage!.trim();
    }

    final Object? university = _application?['university'];
    if (university is Map) {
      final String coverImagePath = _textFrom(university['coverImagePath']);
      if (coverImagePath.isNotEmpty) {
        return ImageUrlHelper.resolveUploadUrl(coverImagePath);
      }
    }

    return 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=1200&q=80';
  }

  String get _courseTitle {
    if (widget.courseTitle?.trim().isNotEmpty == true) {
      return widget.courseTitle!.trim();
    }

    final Object? selectedCourses = _application?['selectedCourses'];
    if (selectedCourses is List && selectedCourses.isNotEmpty) {
      final Object? selectedCourse = selectedCourses.first;
      if (selectedCourse is Map) {
        final String name = _textFrom(selectedCourse['name']);
        if (name.isNotEmpty) return name;

        final String courseName = _textFrom(selectedCourse['courseName']);
        if (courseName.isNotEmpty) return courseName;
      }
    }

    final Object? program = _application?['program'];
    if (program is Map) {
      final String programName = _textFrom(program['name']);
      if (programName.isNotEmpty) return programName;
    }

    return context.l10n.text('courseOrProgram');
  }

  String get _educationInstitute {
    final Object? selectedCourses = _application?['selectedCourses'];
    if (selectedCourses is List && selectedCourses.isNotEmpty) {
      final Object? selectedCourse = selectedCourses.first;
      if (selectedCourse is Map) {
        final String educationInstitute =
            _textFrom(selectedCourse['educationInstitute']);
        if (educationInstitute.isNotEmpty) return educationInstitute;
      }
    }
    return '-';
  }

  String get _status => _textFrom(_application?['status']).ifEmpty('NEW');

  String get _paymentStatus => _textFrom(_payment?['status']).ifEmpty('-');

  String get _applicationFee {
    final double? appFee = _parseAmount(_application?['applicationFee']);
    final double? paymentAmount = _parseAmount(_payment?['amount']);
    final double? fee =
        appFee == null || appFee == 0 ? paymentAmount ?? appFee : appFee;
    final String currency =
        _textFrom(_application?['applicationFeeCurrency']).isNotEmpty
            ? _textFrom(_application?['applicationFeeCurrency'])
            : _textFrom(_payment?['currency']);

    if (fee == null) return currency.isEmpty ? '-' : currency;
    return '${_formatAmount(fee)}${currency.isEmpty ? '' : ' $currency'}';
  }

  String get _submittedDate {
    final String createdAt = _textFrom(_application?['createdAt']);
    if (createdAt.isEmpty) return context.l10n.text('completedOnDate');
    final DateTime? parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return createdAt;
    return 'Completed on ${parsed.day}/${parsed.month}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;

    return WillPopScope(
      onWillPop: () async {
        _goHome();
        return false;
      },
      child: Scaffold(
        body: AppBackground(
          child: AppPageEntrance(
            child: Column(
              children: [
                TopRoundedHeader(
                  title: context.l10n.text('trackApplication'),
                  onBack: _goHome,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isSmallMobile ? 14 : 18,
                      horizontalPadding,
                      20,
                    ),
                    children: [
                      _ApplicationOverviewCard(
                        applicationId: _applicationId,
                        universityName: _universityName,
                        courseTitle: _courseTitle,
                        educationInstitute: _educationInstitute,
                        status: _status,
                        applicationFee: _applicationFee,
                        paymentStatus: _paymentStatus,
                        documentsCount: _documents.length,
                        universityHeroImage: _heroImage,
                        isSmallMobile: isSmallMobile,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        context.l10n.text('applicationProgress'),
                        style: TextStyle(
                          fontSize: isSmallMobile ? 16 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ProgressStep(
                        title: context.l10n.text('submitted'),
                        subtitle: _submittedDate,
                        state: _StepState.done,
                        showLine: true,
                      ),
                      _ProgressStep(
                        title: context.l10n.text('underReview'),
                        subtitle: context.l10n.text('underReviewSubtitle'),
                        state: _status == 'NEW'
                            ? _StepState.active
                            : _StepState.done,
                        showLine: true,
                      ),
                      _ProgressStep(
                        title: context.l10n.text('documentsVerified'),
                        subtitle: _documents.isEmpty
                            ? context.l10n.text('pendingReview')
                            : '${_documents.length} document(s) uploaded',
                        state: _documents.isEmpty
                            ? _StepState.pending
                            : _StepState.done,
                        showLine: true,
                      ),
                      _ProgressStep(
                        title: context.l10n.text('acceptedRejected'),
                        subtitle: context.l10n.text('waitingDecision'),
                        state: _StepState.pending,
                        showLine: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _textFrom(Object? value) => value?.toString().trim() ?? '';

  static double? _parseAmount(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static String _formatAmount(double amount) => amount % 1 == 0
      ? amount.toInt().toString()
      : amount.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');

  static String _shortId(String id) => id.length > 8 ? id.substring(0, 8) : id;
}

class _ApplicationOverviewCard extends StatelessWidget {
  const _ApplicationOverviewCard({
    required this.applicationId,
    required this.universityName,
    required this.courseTitle,
    required this.educationInstitute,
    required this.status,
    required this.applicationFee,
    required this.paymentStatus,
    required this.documentsCount,
    required this.universityHeroImage,
    required this.isSmallMobile,
  });

  final String applicationId;
  final String universityName;
  final String courseTitle;
  final String educationInstitute;
  final String status;
  final String applicationFee;
  final String paymentStatus;
  final int documentsCount;
  final String universityHeroImage;
  final bool isSmallMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E2D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application ID: $applicationId',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 10),
          Text(
            universityName,
            style: TextStyle(
              fontSize: isSmallMobile ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  courseTitle,
                  style: TextStyle(
                    fontSize: isSmallMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            educationInstitute,
            style: TextStyle(
              fontSize: isSmallMobile ? 13 : 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // _OverviewGrid(
          //   rows: [
          //     ('Status', status),
          //     ('Application Fee', applicationFee),
          //     ('Payment', paymentStatus),
          //     ('Documents', '$documentsCount uploaded'),
          //   ],
          // ),
          // const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              universityHeroImage,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: const Color(0xFFE2E2E2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rows
          .map(
            (row) => Container(
              width: (MediaQuery.sizeOf(context).width -
                      (context.responsiveHorizontalPadding * 2) -
                      44) /
                  2,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5EA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8E2D9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.$1,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    row.$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

enum _StepState { done, active, pending }

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.showLine,
  });

  final String title;
  final String subtitle;
  final _StepState state;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.done => const Color(0xFF0E9F58),
      _StepState.active => AppColors.accent,
      _StepState.pending => const Color(0xFF777777),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: state == _StepState.active ? Colors.white : color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: state == _StepState.done
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 42,
                  color: state == _StepState.pending
                      ? const Color(0xFFD7D7D7)
                      : const Color(0xFF0E9F58),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: state == _StepState.pending
                        ? const Color(0xFF777777)
                        : AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension _StringFallback on String {
  String ifEmpty(String? fallback) => isEmpty ? (fallback ?? '') : this;
}
