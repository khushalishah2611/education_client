import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/bloc/app_cubit.dart';
import '../core/url_launcher_helper.dart';
import '../models/agreement_template.dart';
import '../models/country_master.dart';
import '../models/student_login_response.dart';
import '../services/auth_api_service.dart';
import '../services/snackbar_service.dart';
import '../widgets/common_widgets.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with CubitStateMixin<LoginScreen> {
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
    updateView(() => _isLoadingMeta = true);
    try {
      final countries = await _authApiService.fetchCountries();
      final agreements = await _authApiService.fetchAgreementTemplates();

      if (!mounted) return;
      setState(() {
        _countries = countries;
        _agreementTemplates = agreements;
        // debug info to confirm agreements loaded
        debugPrint('_loadMetaData: agreements count=${_agreementTemplates.length}');
        if (_agreementTemplates.isNotEmpty) {
          debugPrint('_loadMetaData: first agreement=${_agreementTemplates.first.toJson()}');
        }
        _selectedCountry = countries.isEmpty
            ? null
            : countries.firstWhere(
                (c) => c.nameEn.toLowerCase() == 'oman',
                orElse: () => countries.first,
              );
      });
    } catch (_) {
      if (!mounted) return;
      snackBarService.showError(
        message: context.l10n.text('failedLoadLoginData'),
      );
    } finally {
      if (mounted) {
        updateView(() => _isLoadingMeta = false);
      }
    }
  }

  Future<void> _onSendOtpTap() async {
    if (_mobileController.text.isEmpty) {
      snackBarService.showError(
        message: context.l10n.text('enterMobileNumber'),
      );
      return;
    }

    if (!_isChecked) {
      snackBarService.showError(
        message: context.l10n.text('pleaseAcceptTermsPrivacy'),
      );
      return;
    }

    if (_selectedCountry == null) {
      snackBarService.showError(
        message: context.l10n.text('selectCountryFirst'),
      );
      return;
    }

    updateView(() => _isSubmitting = true);
    try {
      final StudentLoginResponse response =
          await _authApiService.createStudentForOtp(
        country: _selectedCountry!.nameEn,
        phone: _mobileController.text.trim(),
        preferredLanguage: context.l10n.locale.languageCode,
      );
      if (response.whatsappOtpLink.trim().isNotEmpty) {
        await openExternalLink(response.whatsappOtpLink);
      }
      if (!mounted) return;
      if (!response.existingUser) {
        snackBarService.showSuccess(message: response.message);
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            studentId: response.id,
            expectedOtp: response.otp,
            whatsappOtpLink: response.whatsappOtpLink,
            loginCountry: response.country.isNotEmpty
                ? response.country
                : _selectedCountry!.nameEn,
            loginDialCode: response.dialCode.isNotEmpty
                ? response.dialCode
                : _selectedCountry!.dialCode,
            loginPhone: _mobileController.text.trim(),
          ),
        ),
      );
    } on ApiResponseException catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
      snackBarService.showError(message: error.message);
    } catch (_) {
      if (!mounted) return;
      snackBarService.showError(
        message: context.l10n.text('failedSendOtp'),
      );
    } finally {
      if (mounted) {
        updateView(() => _isSubmitting = false);
      }
    }
  }

  AgreementTemplate? get agreement {
    return _agreementTemplates.isNotEmpty ? _agreementTemplates.first : null;
  }

  String _localizedAgreementTitle(BuildContext context, AgreementTemplate? agreement) {
    if (agreement == null) return '';

    String lang;
    try {
      lang = Localizations.localeOf(context).languageCode;
    } catch (_) {
      // Fallback: try app localizations or default to English
      try {
        lang = context.l10n.locale.languageCode;
      } catch (_) {
        lang = 'en';
      }
    }
    lang = lang.toLowerCase();

    final String ar = agreement.titleAr.trim();
    final String en = agreement.titleEn.trim();

    debugPrint('localizedAgreementTitle: locale=$lang, titleAr="$ar", titleEn="$en"');

    if (lang == 'ar') return ar.isNotEmpty ? ar : (en.isNotEmpty ? en : '');
    return en.isNotEmpty ? en : (ar.isNotEmpty ? ar : '');
  }

  String _localizedAgreementContent(BuildContext context, AgreementTemplate? agreement) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final String? ar = agreement?.contentAr;
    final String? en = agreement?.contentEn;
    final String? arText = ar?.trim();
    final String? enText = en?.trim();
    if (lang == 'ar') {
      return (arText != null && arText.isNotEmpty) ? arText : (enText ?? '');
    }
    return (enText != null && enText.isNotEmpty) ? enText : (arText ?? '');
  }

  void _openTermsBottomSheet() {
    final AgreementTemplate? item = agreement;

    if (item == null) return;

    final String title = _localizedAgreementTitle(context, item);

    final String content = _localizedAgreementContent(context, item);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                8,
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        content,
                        style: const TextStyle(
                          height: 1.4,
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AgreementTemplate? agreement =
        _agreementTemplates.isNotEmpty ? _agreementTemplates.first : null;
    debugPrint('LoginScreen build: agreements=${_agreementTemplates.length}, loading=$_isLoadingMeta');
    return buildCubitView(
      (context) => AuthScaffold(
        isLoading: _isLoadingMeta || _isSubmitting,
        child: Column(
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
                      style:
                          const TextStyle(fontSize: 16, color: AppColors.text),
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
                              updateView(() => _selectedCountry = value);
                            },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 30, color: AppColors.border),
                  Expanded(
                    child: TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        hintText: context.l10n.text('enterMobileNumber'),
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
              icon: Image.asset(
                'assets/images/whatsapp.png',
                width: 22,
                height: 22,
              ),
              trailingIcon: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.text,
              ),
              onPressed: _isLoadingMeta || _isSubmitting ? null : _onSendOtpTap,
            ),
            const SizedBox(height: 14),
            Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                value: _isChecked,
                onChanged: agreement == null
                    ? null
                    : (value) => updateView(() => _isChecked = value ?? false),
                title: GestureDetector(
                  onTap: agreement == null ? null : _openTermsBottomSheet,
                  child: Text(
                    _localizedAgreementTitle(context, agreement),
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
