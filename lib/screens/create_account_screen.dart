import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'academic_info_screen.dart';
import 'login_screen.dart';


class CountryOption {
  const CountryOption({required this.value, required this.label});

  final String value;
  final String label;

  factory CountryOption.fromJson(Map<String, dynamic> json) {
    return CountryOption(
      value: (json['value'] ?? '').toString(),
      label: (json['label'] ?? json['nameEn'] ?? '').toString(),
    );
  }
}

class AgreementTemplate {
  const AgreementTemplate({required this.title, required this.content});

  final String title;
  final String content;

  factory AgreementTemplate.fromJson(Map<String, dynamic> json) {
    return AgreementTemplate(
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoadingCountries = false;
  bool _isLoadingAgreement = false;
  List<CountryOption> _countries = const [];
  CountryOption? _selectedCountry;
  AgreementTemplate? _agreementTemplate;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_fetchCountries(), _fetchAgreementTemplate()]);
  }

  Future<void> _fetchCountries() async {
    setState(() => _isLoadingCountries = true);
    try {
      final response = await http.get(
        Uri.parse('http://arab.vedx.cloud:8000/api/admin/masters/country'),
      );

      if (response.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (decoded['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CountryOption.fromJson)
          .where((country) => country.label.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _countries = data;
        if (_countries.isNotEmpty) {
          _selectedCountry = _countries.first;
        }
      });
    } catch (_) {
      // Keep UI usable even when endpoint fails.
    } finally {
      if (mounted) {
        setState(() => _isLoadingCountries = false);
      }
    }
  }

  Future<void> _fetchAgreementTemplate() async {
    setState(() => _isLoadingAgreement = true);
    try {
      final response = await http.get(
        Uri.parse('http://arab.vedx.cloud:8000/api/student/agreements/templates'),
      );

      if (response.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      final template = decoded
          .whereType<Map<String, dynamic>>()
          .map(AgreementTemplate.fromJson)
          .firstWhere(
            (item) => item.title.isNotEmpty && item.content.isNotEmpty,
            orElse: () => const AgreementTemplate(title: '', content: ''),
          );

      if (!mounted || template.title.isEmpty) return;
      setState(() => _agreementTemplate = template);
    } catch (_) {
      // Keep localized fallback when endpoint fails.
    } finally {
      if (mounted) {
        setState(() => _isLoadingAgreement = false);
      }
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<void> _onCreateAccountTap() async {
    FocusScope.of(context).unfocus();

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      showAppSnackBar(
        context,
        message: context.l10n.text('noInternetMessage'),
        type: AppSnackBarType.error,
      );
      return;
    }

    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty) {
      showAppSnackBar(
        context,
        message: context.l10n.text('completeAllFieldsMessage'),
        type: AppSnackBarType.error,
      );
      return;
    }

    if (_selectedCountry == null) {
      showAppSnackBar(
        context,
        message: context.l10n.text('completeAllFieldsMessage'),
        type: AppSnackBarType.error,
      );
      return;
    }

    if (!_acceptedTerms) {
      showAppSnackBar(
        context,
        message: context.l10n.text('acceptTermsMessage'),
        type: AppSnackBarType.error,
      );
      return;
    }

    showAppSnackBar(
      context,
      message: context.l10n.text('accountReadyMessage'),
      type: AppSnackBarType.success,
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AcademicInfoScreen(flowLabel: 'Register'),
      ),
    );
  }

  void _openTermsBottomSheet() {
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
                        _agreementTemplate?.title.isNotEmpty == true
                            ? _agreementTemplate!.title
                            : context.l10n.text('termsAndConditionsTitle'),
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
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _agreementTemplate?.content.isNotEmpty == true
                      ? _agreementTemplate!.content
                      : context.l10n.text('termsAndConditionsDescription'),
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
    return AppScaffoldBody(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const AppLogo(center: true),
                    const SizedBox(height: 34),
                    Text(
                      context.l10n.text('createYourAccount'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: context.l10n.text('fullName'),
                      hint: context.l10n.text('fullName'),
                      icon: Icons.person_outline,
                      controller: _fullNameController,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: context.l10n.text('email'),
                      hint: context.l10n.text('email'),
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: context.l10n.text('mobileNumber'),
                      hint: context.l10n.text('mobileNumber'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _mobileController,
                    ),
                    const SizedBox(height: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.text('country'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedCountry?.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            prefixIcon: const Icon(
                              Icons.public,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: _countries
                              .map(
                                (country) => DropdownMenuItem<String>(
                                  value: country.value,
                                  child: Text(country.label),
                                ),
                              )
                              .toList(),
                          onChanged: _isLoadingCountries
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedCountry = _countries.firstWhere(
                                      (country) => country.value == value,
                                    );
                                  });
                                },
                          hint: _isLoadingCountries
                              ? const Text('Loading countries...')
                              : const Text('Select country'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) =>
                              setState(() => _acceptedTerms = value ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              children: [
                                Text(
                                  context.l10n.text('termsPrefix'),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                                GestureDetector(
                                  onTap: (_isLoadingAgreement || _agreementTemplate == null)
                                      ? null
                                      : _openTermsBottomSheet,
                                  child: Text(
                                    _agreementTemplate?.title.isNotEmpty == true
                                        ? _agreementTemplate!.title
                                        : context.l10n.text('termsLink'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AppPrimaryButton(
                      label: context.l10n.text('createAccount'),
                      onPressed: _onCreateAccountTap,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: AppTextLink(
                        prefix: context.l10n.text('alreadyHaveAccount'),
                        link: context.l10n.text('login'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
