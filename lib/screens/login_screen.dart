import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../models/agreement_template.dart';
import '../models/country_master.dart';
import '../models/student_login_response.dart';
import '../services/auth_api_service.dart';
import '../widgets/common_widgets.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final AuthApiService _authApiService = const AuthApiService();

  List<CountryMaster> _countries = const [];
  List<AgreementTemplate> _agreementTemplates = const [];
  CountryMaster? _selectedCountry;
  bool _isChecked = false;
  bool _isLoadingMeta = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMetaData();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadMetaData() async {
    setState(() => _isLoadingMeta = true);
    try {
      final countries = await _authApiService.fetchCountries();
      final agreements = await _authApiService.fetchAgreementTemplates();

      if (!mounted) return;
      setState(() {
        _countries = countries;
        _agreementTemplates = agreements;
        _selectedCountry = countries.isEmpty ? null : countries.first;
      });
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic
            ? 'تعذر تحميل بيانات تسجيل الدخول'
            : 'Failed to load login data',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingMeta = false);
      }
    }
  }

  Future<void> _onSendOtpTap() async {
    if (_mobileController.text.length < 10) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic
            ? 'أدخل رقم هاتف صحيح'
            : 'Enter valid mobile number',
      );
      return;
    }

    if (!_isChecked) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic
            ? 'يرجى قبول الشروط وسياسة الخصوصية'
            : 'Please accept Terms & Privacy',
      );
      return;
    }

    if (_selectedCountry == null) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic ? 'اختر الدولة أولًا' : 'Select country first',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final StudentLoginResponse response = await _authApiService
          .createStudentForOtp(
            country: _selectedCountry!.nameEn,
            phone: _mobileController.text.trim(),
            gender: 'MALE',
          );

      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.success,
        message: response.message,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            expectedOtp: response.otp,
            whatsappOtpLink: response.whatsappOtpLink,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.isArabic
            ? 'تعذر إرسال OTP، حاول مرة أخرى'
            : 'Failed to send OTP, try again',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openTermsBottomSheet() {
    final AgreementTemplate? agreement = _agreementTemplates.isEmpty
        ? null
        : _agreementTemplates.first;

    if (agreement == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        agreement.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: MaterialLocalizations.of(context)
                          .closeButtonTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  agreement.content,
                  style: const TextStyle(
                    height: 1.4,
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AgreementTemplate? agreement = _agreementTemplates.isEmpty
        ? null
        : _agreementTemplates.first;

    return AuthScaffold(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.text('loginWithOtp'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.text('mobileNumber'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<CountryMaster>(
                        value: _selectedCountry,
                        borderRadius: BorderRadius.circular(12),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
                        style: const TextStyle(fontSize: 16, color: AppColors.text),
                        items: _countries
                            .map(
                              (country) => DropdownMenuItem<CountryMaster>(
                                value: country,
                                child: Text(
                                  '${country.flagEmoji} ${country.dialCode}',
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _isLoadingMeta
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() => _selectedCountry = value);
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 30, color: AppColors.border),
                    Expanded(
                      child: TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          hintText: 'Enter mobile number',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              AppPrimaryButton(
                label: context.l10n.text('sendOtp'),
                isLoading: _isSubmitting,
                onPressed: _isLoadingMeta ? null : _onSendOtpTap,
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                value: _isChecked,
                onChanged: agreement == null
                    ? null
                    : (value) => setState(() => _isChecked = value ?? false),
                title: GestureDetector(
                  onTap: agreement == null ? null : _openTermsBottomSheet,
                  child: Text(
                    agreement?.title ?? context.l10n.text('termsPrivacy'),
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (_isLoadingMeta)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.white.withOpacity(0.6),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
