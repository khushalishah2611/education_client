import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';
import '../services/application_api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'home_screen.dart';
import 'track_application_screen.dart';

class PaymentConfirmationScreen extends StatelessWidget {
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
  final ApplicationApiService _applicationApiService =
      const ApplicationApiService();

  List<Map<String, dynamic>> get _createdApplications {
    final Object? applications = createdApplicationsResponse?['applications'];
    if (applications is! List) return const <Map<String, dynamic>>[];

    return applications
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }

  List<Map<String, dynamic>> get _overviewPayments {
    final Object? payments = studentOverview?['payments'];
    if (payments is! List) return const <Map<String, dynamic>>[];

    return payments
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }

  Map<String, dynamic>? get _primaryApplication {
    final List<Map<String, dynamic>> applications = _createdApplications;
    if (applications.isNotEmpty) return applications.first;
    if (applicationsPayload.isNotEmpty) return applicationsPayload.first;
    return null;
  }

  Map<String, dynamic>? get _primaryPayload {
    if (applicationsPayload.isNotEmpty) return applicationsPayload.first;
    return null;
  }

  Map<String, dynamic>? get _primaryPayment {
    final String applicationId = _textFrom(_primaryApplication?['id']);
    for (final Map<String, dynamic> payment in _overviewPayments) {
      if (applicationId.isNotEmpty &&
          _textFrom(payment['applicationId']) == applicationId) {
        return payment;
      }
    }

    return _overviewPayments.isNotEmpty ? _overviewPayments.first : null;
  }

  String get _applicationId => _textFrom(_primaryApplication?['id']);

  String get _applicationIdText {
    if (_applicationId.isEmpty) return 'Application ID: -';
    return 'Application ID: ${_shortId(_applicationId)}';
  }

  String get _paymentId => _textFrom(_primaryPayment?['id']);

  String get _displayUniversityName {
    final Map<String, dynamic>? application = _primaryApplication;
    final Object? nestedUniversity = application?['university'];
    if (nestedUniversity is Map) {
      final String nestedName = _textFrom(nestedUniversity['name']);
      if (nestedName.isNotEmpty) return nestedName;
    }

    return _textFrom(application?['universityName']).isNotEmpty
        ? _textFrom(application?['universityName'])
        : (universityName ?? '');
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

    return courseTitle ?? '';
  }

  String _selectedCourseName(Object? selectedCourses) {
    if (selectedCourses is! List || selectedCourses.isEmpty) return '';

    final Object? selectedCourse = selectedCourses.first;
    if (selectedCourse is! Map) return '';

    final String name = _textFrom(selectedCourse['name']);
    if (name.isNotEmpty) return name;

    return _textFrom(selectedCourse['courseName']);
  }

  String get _displayStatus {
    final String status = _textFrom(_primaryApplication?['status']);
    return status.isEmpty ? '-' : status;
  }

  String get _displayApplicationFee {
    final Map<String, dynamic>? application = _primaryApplication;
    final Map<String, dynamic>? payload = _primaryPayload;
    final double? responseFee =
        _parseAmount(application?['selectedApplicationFeeTotal']) ??
            _parseAmount(application?['applicationFee']) ??
            _parseAmount(_selectedCourseValue(application, 'applicationFee')) ??
            _parseAmount(_courseDetailsValue(application, 'applicationFee'));
    final double? payloadFee =
        _parseAmount(payload?['selectedApplicationFeeTotal']) ??
            _parseAmount(payload?['applicationFee']) ??
            _parseAmount(_selectedCourseValue(payload, 'applicationFee')) ??
            _parseAmount(_courseDetailsValue(payload, 'applicationFee'));
    final double? fee = responseFee == null || responseFee == 0
        ? payloadFee ?? responseFee
        : responseFee;
    final String responseCurrency = _textFrom(
      application?['applicationFeeCurrency'],
    ).isNotEmpty
        ? _textFrom(application?['applicationFeeCurrency'])
        : _textFrom(_selectedCourseValue(application, 'currency')).isNotEmpty
            ? _textFrom(_selectedCourseValue(application, 'currency'))
            : _textFrom(_courseDetailsValue(application, 'currency'));
    final String payloadCurrency = _textFrom(payload?['applicationFeeCurrency'])
            .isNotEmpty
        ? _textFrom(payload?['applicationFeeCurrency'])
        : _textFrom(_selectedCourseValue(payload, 'currency')).isNotEmpty
            ? _textFrom(_selectedCourseValue(payload, 'currency'))
            : _textFrom(_courseDetailsValue(payload, 'currency'));
    final String currency = responseCurrency.isNotEmpty
        ? responseCurrency
        : payloadCurrency;

    if (fee == null) return currency.isEmpty ? '-' : currency;
    return '${_formatAmount(fee)}${currency.isEmpty ? '' : ' $currency'}';
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    final String paymentId = _paymentId;
    if (paymentId.isEmpty) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: 'Receipt is not available yet.',
      );
      return;
    }

    try {
      final String receiptHtml =
          await _applicationApiService.fetchPaymentReceiptHtml(
        paymentId: paymentId,
      );
      final Uint8List receiptPdf = await Printing.convertHtml(
        format: PdfPageFormat.a4,
        html: receiptHtml,
      );
      await Printing.sharePdf(
        bytes: receiptPdf,
        filename: 'payment_receipt_$paymentId.pdf',
      );
    } catch (e) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: e.toString(),
      );
    }
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

    return WillPopScope(
      onWillPop: () async {
        _goHome(context);
        return false;
      },
      child: Scaffold(
        body: AppBackground(
          child: AppPageEntrance(
            child: Column(
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
                        backgroundColor: Color(0xFF0E9F58),
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
                          _applicationIdText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ConfirmationDetailsCard(
                        universityName: resolvedUniversityName,
                        courseTitle: resolvedCourseTitle,
                        status: _displayStatus,
                        applicationFee: _displayApplicationFee,
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          universityHeroImage ??
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
                        '${context.l10n.text('paymentProcessedPrefix')} ${resolvedCourseTitle.isEmpty ? context.l10n.text('courseOrProgram') : resolvedCourseTitle} ${context.l10n.text('paymentProcessedSuffix')}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textMuted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 96),
                      AppPrimaryButton(
                        label: context.l10n.text('trackApplication'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrackApplicationScreen(
                              universityName: resolvedUniversityName.isEmpty
                                  ? universityName
                                  : resolvedUniversityName,
                              universityHeroImage: universityHeroImage,
                              courseTitle: resolvedCourseTitle.isEmpty
                                  ? courseTitle
                                  : resolvedCourseTitle,
                              applicationId: _applicationId,
                              studentOverview: studentOverview,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppOutlinedButton(
                        label: context.l10n.text('downloadReceipt'),
                        onPressed: () => _downloadReceipt(context),
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
          _DetailRow(label: 'University', value: universityName),
          const Divider(height: 18),
          _DetailRow(label: 'Course', value: courseTitle),
          const Divider(height: 18),
          _DetailRow(label: 'Status', value: status),
          const Divider(height: 18),
          _DetailRow(label: 'Application Fee', value: applicationFee),
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
