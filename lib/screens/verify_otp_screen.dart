import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.expectedOtp,
    required this.whatsappOtpLink,
  });

  final String expectedOtp;
  final String whatsappOtpLink;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _initialSeconds = 60;
  static const _verifyCardShade = Colors.white;

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _focusNodes;
  int _secondsRemaining = _initialSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _secondsRemaining = _initialSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining == 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsRemaining--;
      });
    });
  }

  void _resendOtp() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    setState(_startResendTimer);
  }

  String _resendText(BuildContext context) {
    if (_secondsRemaining == 0) {
      return context.l10n.isArabic ? 'إعادة إرسال OTP' : 'Resend OTP';
    }
    return context.l10n.isArabic
        ? 'إعادة إرسال OTP خلال : $_secondsRemaining ثانية'
        : 'Resend OTP in : $_secondsRemaining second';
  }

  Future<void> _verifyOtp(BuildContext context) async {
    final hasEmptyField = _otpControllers.any((c) => c.text.trim().isEmpty);

    if (hasEmptyField) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic
            ? 'يرجى إدخال OTP كامل'
            : 'Please enter complete OTP',
      );
      return;
    }

    final otp = _otpControllers.map((e) => e.text).join();

    if (otp != widget.expectedOtp) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic ? 'OTP غير صحيح' : 'Invalid OTP',
      );
      return;
    }

    final whatsappUri = Uri.tryParse(widget.whatsappOtpLink);
    if (whatsappUri != null) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      bottomCardColor: _verifyCardShade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.text('verifyOtp'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              context.l10n.text('otpHelp'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 24),
          _OtpRow(controllers: _otpControllers, focusNodes: _focusNodes),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _secondsRemaining == 0 ? _resendOtp : null,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.text,
                disabledForegroundColor: AppColors.text,
                textStyle: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              child: Text(_resendText(context)),
            ),
          ),
          const SizedBox(height: 28),
          AppPrimaryButton(
            label: context.l10n.text('verifyAndLogin'),
            onPressed: () => _verifyOtp(context),
          ),
        ],
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  const _OtpRow({required this.controllers, required this.focusNodes});

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          6,
          (index) => SizedBox(
            width: 44,
            height: 44,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
