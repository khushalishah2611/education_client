import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../services/auth_api_service.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.studentId,
    required this.expectedOtp,
    required this.whatsappOtpLink,
  });

  final String studentId;
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
  final AuthApiService _authApiService = const AuthApiService();
  int _secondsRemaining = _initialSeconds;
  bool _isSubmitting = false;
  String _currentExpectedOtp = '';
  String _currentWhatsappOtpLink = '';
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _currentExpectedOtp = widget.expectedOtp;
    _currentWhatsappOtpLink = widget.whatsappOtpLink;
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

  Future<void> _resendOtp() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await _authApiService.resendStudentOtp(
        studentId: widget.studentId,
      );
      if (!mounted) return;
      setState(() {
        _currentExpectedOtp = response.otp;
        _currentWhatsappOtpLink = response.whatsappOtpLink;
      });
      showAppSnackBar(
        context,
        type: AppSnackBarType.success,
        message: response.message,
      );
      await _openWhatsappLink(_currentWhatsappOtpLink);
    } on ApiResponseException catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: error.message,
      );
      return;
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic
            ? 'تعذر إعادة إرسال OTP'
            : 'Failed to resend OTP',
      );
      return;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    for (final controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    _startResendTimer();
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

    if (otp != _currentExpectedOtp) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic ? 'OTP غير صحيح' : 'Invalid OTP',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final message = await _authApiService.verifyStudentOtp(
        studentId: widget.studentId,
        otp: otp,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      if (!mounted) return;
      showAppSnackBar(context, type: AppSnackBarType.success, message: message);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on ApiResponseException catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: error.message,
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic ? 'حدث خطأ' : 'Something went wrong',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _openWhatsappLink(String link) async {
    final whatsappUri = Uri.tryParse(link);
    if (whatsappUri == null) return;
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }


  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      isLoading: _isSubmitting,
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
            onPressed: _isSubmitting ? null : () => _verifyOtp(context),
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
