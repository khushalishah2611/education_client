import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';
import '../core/bloc/app_cubit.dart';
import '../services/snackbar_service.dart';
import '../services/application_api_service.dart';
import '../utils/payment_receipt_pdf.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'home_screen.dart';
import 'track_application_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({
    super.key,
    this.universityName,
    this.universityHeroImage,
    this.courseTitle,
    this.applicationsPayload = const <Map<String, dynamic>>[],
    this.createdApplicationsResponse,
    this.studentOverview,
  });

  final String? universityName;
  final String? universityHeroImage;
  final String? courseTitle;
  final List<Map<String, dynamic>> applicationsPayload;
  final Map<String, dynamic>? createdApplicationsResponse;
  final Map<String, dynamic>? studentOverview;
  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen>
    with CubitStateMixin<PaymentConfirmationScreen> {
  bool _isDownloadingReceipt = false;
  Map<String, dynamic>? _studentOverview;
  final ApplicationApiService _applicationApiService =
      const ApplicationApiService();

  @override
  void initState() {
    super.initState();
    _studentOverview = widget.studentOverview;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_studentOverview == null) {
        _loadStudentOverview();
      }
    });
  }

  Future<void> _loadStudentOverview() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';

      if (studentUserId.isEmpty || !mounted) return;

      final Map<String, dynamic> overview =
          await _applicationApiService.fetchStudentOverview(
        studentUserId: studentUserId,
      );

      if (!mounted) return;

      updateView(() => _studentOverview = overview);
    } catch (_) {
      // Keep using createdApplicationsResponse fallbacks for payment details.
    }
  }

  List<Map<String, dynamic>> get _createdApplications {
    final Object? applications = widget.createdApplicationsResponse?['applications'];
    if (applications is! List) return const <Map<String, dynamic>>[];

    return applications
        .whereType<Map>()
        .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }

  List<Map<String, dynamic>> get _overviewPayments {
    final Map<String, dynamic> overview = _overviewData(_studentOverview);
    final Object? payments = overview['payments'];
    if (payments is! List) return const <Map<String, dynamic>>[];

    return payments
        .whereType<Map>()
        .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }

  Map<String, dynamic>? get _primaryApplication {
    final List<Map<String, dynamic>> applications = _createdApplications;
    if (applications.isNotEmpty) return applications.first;
    if (widget.applicationsPayload.isNotEmpty) return widget.applicationsPayload.first;
    return null;
  }

  Map<String, dynamic>? get _primaryPayload {
    if (widget.applicationsPayload.isNotEmpty) return widget.applicationsPayload.first;
    return null;
  }

  Map<String, dynamic>? get _primaryPayment {
    final String primaryApplicationId = _applicationId;
    if (primaryApplicationId.isNotEmpty) {
      for (final Map<String, dynamic> payment in _overviewPayments) {
        if (_paymentApplicationId(payment) == primaryApplicationId) {
          return payment;
        }
      }
    }

    final Set<String> allKnownApplicationIds = <String>{
      ..._createdApplications
          .map((application) => _textFrom(application['id']))
          .where((id) => id.isNotEmpty),
      ...widget.applicationsPayload
          .map((application) => _textFrom(application['id']))
          .where((id) => id.isNotEmpty),
    };

    if (allKnownApplicationIds.isNotEmpty) {
      for (final Map<String, dynamic> payment in _overviewPayments) {
        if (allKnownApplicationIds.contains(_paymentApplicationId(payment))) {
          return payment;
        }
      }
    }

    final Map<String, dynamic>? createdPayment = _paymentFromCreatedResponse;
    if (createdPayment != null) {
      return createdPayment;
    }

    return _overviewPayments.isNotEmpty ? _overviewPayments.first : null;
  }

  Map<String, dynamic>? get _paymentFromCreatedResponse {
    final Object? directPayment = widget.createdApplicationsResponse?['payment'];
    if (directPayment is Map) {
      return directPayment.map((k, v) => MapEntry(k.toString(), v));
    }

    final Object? createdPayments = widget.createdApplicationsResponse?['payments'];
    if (createdPayments is List && createdPayments.isNotEmpty) {
      final Object? first = createdPayments.first;
      if (first is Map) {
        return first.map((k, v) => MapEntry(k.toString(), v));
      }
    }
    return null;
  }

  String get _applicationId => _textFrom(_primaryApplication?['id']);

  String _applicationIdText(BuildContext context) {
    final String applicationId = _shortId(_applicationId);
    final String template = context.l10n.text('applicationIdValue');

    if (applicationId.isEmpty) {
      return template;
    }

    return '$template $applicationId';
  }

  String get _paymentId => resolvePaymentId(_primaryPayment);

  String _paymentApplicationId(Map<String, dynamic> payment) {
    final String directApplicationId = _textFrom(payment['applicationId']);
    if (directApplicationId.isNotEmpty) return directApplicationId;

    final Object? nestedApplication = payment['application'];
    if (nestedApplication is Map) {
      return _textFrom(nestedApplication['id']);
    }

    return '';
  }

  String get _displayUniversityName {
    final Map<String, dynamic>? application = _primaryApplication;
    final Object? nestedUniversity = application?['university'];
    if (nestedUniversity is Map) {
      final String nestedName = _textFrom(nestedUniversity['name']);
      if (nestedName.isNotEmpty) return nestedName;
    }

    return _textFrom(application?['universityName']).isNotEmpty
        ? _textFrom(application?['universityName'])
        : (widget.universityName ?? '');
  }

  String get _displayCourseTitle {
    final Map<String, dynamic>? application = _primaryApplication;
    final Object? selectedCourses = application?['selectedCourses'];
    final String selectedCourseName = _selectedCourseName(selectedCourses);
    if (selectedCourseName.isNotEmpty) return selectedCourseName;

    final Object? notes = application?['notes'];
    if (notes is Map) {
      final String notesCourseName =
          _selectedCourseName(notes['selectedCourses']);
      if (notesCourseName.isNotEmpty) return notesCourseName;
    }

    final String courseName = _textFrom(application?['courseName']);
    if (courseName.isNotEmpty) return courseName;

    final Object? courseDetails = application?['courseDetails'];
    if (courseDetails is Map) {
      final String detailsName = _textFrom(courseDetails['name']);
      if (detailsName.isNotEmpty) return detailsName;
    }

    return widget.courseTitle ?? '';
  }

  String _selectedCourseName(Object? selectedCourses) {
    if (selectedCourses is! List || selectedCourses.isEmpty) return '';

    final Object? selectedCourse = selectedCourses.first;
    if (selectedCourse is! Map) return '';

    final String name = _textFrom(selectedCourse['name']);
    if (name.isNotEmpty) return name;

    return _textFrom(selectedCourse['courseName']);
  }

  String _displayApplicationFee(BuildContext context) {
    final Map<String, dynamic>? application = _primaryApplication;
    final Map<String, dynamic>? payload = _primaryPayload;

    final double? responseFee =
        _parseAmount(application?['selectedApplicationFeeTotal']) ??
            _parseAmount(application?['applicationFee']) ??
            _parseAmount(
              _selectedCourseValue(application, 'applicationFee'),
            ) ??
            _parseAmount(
              _courseDetailsValue(application, 'applicationFee'),
            );

    final double? payloadFee =
        _parseAmount(payload?['selectedApplicationFeeTotal']) ??
            _parseAmount(payload?['applicationFee']) ??
            _parseAmount(
              _selectedCourseValue(payload, 'applicationFee'),
            ) ??
            _parseAmount(
              _courseDetailsValue(payload, 'applicationFee'),
            );

    final double? fee = responseFee == null || responseFee == 0
        ? payloadFee ?? responseFee
        : responseFee;

    final String currency = context.l10n.text('omaniRial');

    if (fee == null) return currency;

    return '${_formatAmount(fee)} $currency';
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    if (_isDownloadingReceipt) return;

    final String paymentId = _paymentId;
    if (paymentId.isEmpty) {
      snackBarService.showError(
        message: context.l10n.text('receiptNotAvailableYet'),
      );
      return;
    }

    updateView(() => _isDownloadingReceipt = true);
    try {
      final String receiptHtml =
          await _applicationApiService.fetchPaymentReceiptHtml(
        paymentId: paymentId,
      );
      final Uint8List receiptPdf = await buildPaymentReceiptPdf(receiptHtml);
      await Printing.sharePdf(
        bytes: receiptPdf,
        filename: 'payment_receipt_$paymentId.pdf',
      );
    } catch (e) {
      snackBarService.showError(
        message: e.toString(),
      );
    } finally {
      if (mounted) updateView(() => _isDownloadingReceipt = false);
    }
  }

  Map<String, dynamic> _overviewData(Map<String, dynamic>? rawOverview) {
    if (rawOverview == null) return const <String, dynamic>{};
    final Object? data = rawOverview['data'];
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return rawOverview;
  }

  Object? _selectedCourseValue(Map<String, dynamic>? application, String key) {
    final Object? selectedCourses = application?['selectedCourses'];
    if (selectedCourses is! List || selectedCourses.isEmpty) return null;

    final Object? selectedCourse = selectedCourses.first;
    if (selectedCourse is Map) return selectedCourse[key];
    return null;
  }

  Object? _courseDetailsValue(Map<String, dynamic>? application, String key) {
    final Object? courseDetails = application?['courseDetails'];
    if (courseDetails is Map) return courseDetails[key];
    return null;
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

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;
    final String resolvedCourseTitle = _displayCourseTitle;
    final String resolvedUniversityName = _displayUniversityName;

    return buildCubitView(
      (context) => WillPopScope(
        onWillPop: () async {
        _goHome(context);
        return false;
      },
      child: Scaffold(
        body: AppBackground(
          child: AppPageEntrance(
            child: Stack(
              children: [
                Column(
                  children: [
                    FlowStepHeader(
                      currentStep: 3,
                      title: context.l10n.text('paymentConfirmation'),
                      onBack: () => _goHome(context),
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
                          const Icon(
                            Icons.celebration,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          CircleAvatar(
                            radius: isSmallMobile ? 38 : 44,
                            backgroundColor: const Color(0xFF0E9F58),
                            child: Icon(
                              Icons.check_rounded,
                              size: isSmallMobile ? 44 : 54,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.text('applicationSubmitted'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallMobile ? 18 : 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0E9F58),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: isSmallMobile ? 30 : 70,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F4E6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _applicationIdText(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              widget.universityHeroImage ??
                                  'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=1200&q=80',
                              height: 158,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 158,
                                color: const Color(0xFFE3E3E3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${context.l10n.text('paymentProcessedPrefix')} '
                            '${_displayApplicationFee(context)} '
                            '${resolvedCourseTitle.isEmpty ? context.l10n.text('courseOrProgram') : resolvedCourseTitle} '
                            '${context.l10n.text('paymentProcessedSuffix')}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textMuted,
                              height: 1.45,
                            ),
                          ),
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppPrimaryButton(
                                    label: context.l10n.text('trackApplication'),
                                    onPressed: _isDownloadingReceipt
                                        ? null
                                        : () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TrackApplicationScreen(
                                                  universityName:
                                                      resolvedUniversityName
                                                              .isEmpty
                                                          ? widget.universityName
                                                          : resolvedUniversityName,
                                                  universityHeroImage: widget
                                                      .universityHeroImage,
                                                  courseTitle:
                                                      resolvedCourseTitle.isEmpty
                                                          ? widget.courseTitle
                                                          : resolvedCourseTitle,
                                                  applicationId: _applicationId,
                                                  studentOverview:
                                                      _studentOverview,
                                                ),
                                              ),
                                            ),
                                  ),
                                  const SizedBox(height: 12),
                                  AppOutlinedButton(
                                    label: context.l10n.text('downloadReceipt'),
                                    onPressed: () {
                                      if (_isDownloadingReceipt) return;
                                      _downloadReceipt(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isDownloadingReceipt)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationDetailsCard extends StatelessWidget {
  const _ConfirmationDetailsCard({
    required this.universityName,
    required this.courseTitle,
    required this.status,
    required this.applicationFee,
  });

  final String universityName;
  final String courseTitle;
  final String status;
  final String applicationFee;

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
        children: [
          _DetailRow(label: context.l10n.text('university'), value: universityName),
          const Divider(height: 18),
          _DetailRow(label: context.l10n.text('Course'), value: courseTitle),
          const Divider(height: 18),
          _DetailRow(label: context.l10n.text('status'), value: status),
          const Divider(height: 18),
          _DetailRow(label: context.l10n.text('applicationFee'), value: applicationFee),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.trim().isEmpty ? '-' : value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
