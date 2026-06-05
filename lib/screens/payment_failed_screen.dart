import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/responsive_helper.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'help_screen.dart';
import 'payment_screen.dart';

enum PaymentFailureType { failed, cancelled }

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({
    super.key,
    this.universityName,
    this.universityHeroImage,
    this.courseTitle,
    this.applicationsPayload = const <Map<String, dynamic>>[],
    this.createdApplicationsResponse,
    this.studentOverview,
    this.failureType = PaymentFailureType.failed,
  });

  final String? universityName;
  final String? universityHeroImage;
  final String? courseTitle;
  final List<Map<String, dynamic>> applicationsPayload;
  final Map<String, dynamic>? createdApplicationsResponse;
  final Map<String, dynamic>? studentOverview;
  final PaymentFailureType failureType;

  double get _applicationFeeTotal {
    return applicationsPayload.fold<double>(0, (total, payload) {
      final double? selectedTotal =
          _parseApplicationFee(payload['selectedApplicationFeeTotal']);
      if (selectedTotal != null) return total + selectedTotal;

      final double? directFee = _parseApplicationFee(payload['applicationFee']);
      if (directFee != null) return total + directFee;

      final Object? courseDetails = payload['courseDetails'];
      if (courseDetails is! Map) return total;

      return total +
          (_parseApplicationFee(courseDetails['applicationFee']) ?? 0);
    });
  }

  String _applicationFeeText(BuildContext context) {
    final double total = _applicationFeeTotal;
    final String amount = total % 1 == 0
        ? total.toInt().toString()
        : total.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');

    return '$amount ${context.l10n.text('omaniRial')}';
  }

  double? _parseApplicationFee(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  void _retryPayment(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          universityName: universityName,
          universityHeroImage: universityHeroImage,
          courseTitle: courseTitle,
          applicationsPayload: applicationsPayload,
        ),
      ),
    );
  }

  void _openContactSupport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;
    final bool isCancelled = failureType == PaymentFailureType.cancelled;

    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            children: [
              FlowStepHeader(
                currentStep: 1,
                title: context.l10n.text('paymentConfirmation'),
                onBack: () => _retryPayment(context),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isSmallMobile ? 28 : 36,
                    horizontalPadding,
                    20,
                  ),
                  children: [
                    const Center(child: _StopSignIcon()),
                    const SizedBox(height: 20),
                    Text(
                      context.l10n.text('applicationFailed'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 20 : 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD30000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCancelled
                          ? context.l10n.text('paymentCancelled')
                          : context.l10n.text('paymentUnsuccessful'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 15 : 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isCancelled
                          ? context.l10n
                              .text('paymentCancelledDescription')
                              .replaceAll(
                                '{amount}',
                                _applicationFeeText(context),
                              )
                          : context.l10n
                              .text('paymentFailedDescription')
                              .replaceAll(
                                '{amount}',
                                _applicationFeeText(context),
                              ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PaymentFailedPrimaryButton(
                        label: context.l10n.text('retryPayment'),
                        onPressed: () => _retryPayment(context),
                      ),
                      const SizedBox(height: 12),
                      AppOutlinedButton(
                        label: context.l10n.text('contactSupport'),
                        onPressed: () => _openContactSupport(context),
                      ),
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

class _StopSignIcon extends StatelessWidget {
  const _StopSignIcon();

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double size = isSmallMobile ? 72 : 84;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: const _StopSignPainter(color: Color(0xFFD30000)),
        child: Center(
          child: Text(
            '!',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallMobile ? 38 : 44,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StopSignPainter extends CustomPainter {
  const _StopSignPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double inset = w * 0.22;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w - inset, inset);
    path.lineTo(w, h * 0.5);
    path.lineTo(w - inset, h - inset);
    path.lineTo(w * 0.5, h);
    path.lineTo(inset, h - inset);
    path.lineTo(0, h * 0.5);
    path.lineTo(inset, inset);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StopSignPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PaymentFailedPrimaryButton extends StatelessWidget {
  const _PaymentFailedPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;

    return SizedBox(
      width: double.infinity,
      height: isSmallMobile ? 42 : 45,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFD30000),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: isSmallMobile ? 15 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
