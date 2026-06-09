import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thawani_payment/models/products.dart';
import 'package:thawani_payment/pay.dart';

import '../core/api_config.dart';
import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
import '../core/url_launcher_helper.dart';
import '../core/app_theme.dart';
import '../core/bloc/app_cubit.dart';
import '../core/selected_course_storage.dart';
import '../models/country_master.dart';
import '../services/application_api_service.dart';
import '../services/auth_api_service.dart';
import '../services/snackbar_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_confirmation_screen.dart';
import 'payment_failed_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.universityName,
    this.universityHeroImage,
    this.courseTitle,
    this.applicationsPayload = const <Map<String, dynamic>>[],
  });

  final String? universityName;
  final String? universityHeroImage;
  final String? courseTitle;
  final List<Map<String, dynamic>> applicationsPayload;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with CubitStateMixin<PaymentScreen> {
  static const List<String> _genderOptions = <String>['FEMALE', 'MALE'];

  int selected = 1;
  bool _isSubmitting = false;

  final ApplicationApiService _applicationApiService =
      const ApplicationApiService();
  final AuthApiService _authApiService = const AuthApiService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountry = '';
  String _selectedCountryDialCode = '';
  String _gender = _genderOptions.first;
  List<CountryMaster> _countries = const [];
  bool _isLoadingCountries = true;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentScreen();
  }

  Future<void> _initializePaymentScreen() async {
    await _loadLoginSessionData();
    await _loadCountryOptions();
    await _loadStudentProfile();
  }

  Future<void> _loadLoginSessionData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String loginCountry = prefs.getString('loginCountry')?.trim() ?? '';
    final String loginDialCode = prefs.getString('loginDialCode')?.trim() ?? '';
    final String loginPhone = prefs.getString('loginPhone')?.trim() ?? '';

    updateView(() {
      if (loginCountry.isNotEmpty) {
        _selectedCountry = loginCountry;
      }
      if (loginDialCode.isNotEmpty) {
        _selectedCountryDialCode = loginDialCode;
      }
      if (loginPhone.isNotEmpty) {
        _phoneController.text = loginPhone;
      }
    });
  }

  Future<void> _loadCountryOptions() async {
    updateView(() => _isLoadingCountries = true);
    try {
      final List<CountryMaster> countries =
          await _authApiService.fetchCountries();
      if (!mounted) return;
      setState(() {
        _countries = countries;
        final CountryMaster? matchedCountry = _findMatchingLoginCountry();
        if (matchedCountry != null) {
          _selectedCountry = matchedCountry.nameEn;
          _selectedCountryDialCode = matchedCountry.dialCode;
        } else if (_countries.isNotEmpty && _selectedCountry.trim().isEmpty) {
          _selectedCountry = _countries.first.nameEn;
          _selectedCountryDialCode = _countries.first.dialCode;
        }
      });
    } catch (_) {
      if (!mounted) return;
      snackBarService.showError(
        message: context.l10n.text('failedLoadLoginData'),
      );
    } finally {
      if (mounted) {
        updateView(() => _isLoadingCountries = false);
      }
    }
  }

  String _normalizeGender(String? raw) {
    final String normalized = (raw ?? '').trim().toUpperCase();
    if (_genderOptions.contains(normalized)) {
      return normalized;
    }
    return _genderOptions.first;
  }

  CountryMaster? _findMatchingLoginCountry() {
    for (final country in _countries) {
      if (country.nameEn == _selectedCountry ||
          country.dialCode == _selectedCountryDialCode) {
        return country;
      }
    }
    return null;
  }

  Future<void> _loadStudentProfile() async {
    if (_profileLoaded || _isSubmitting) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String studentUserId = prefs.getString('studentUserId')?.trim() ?? '';
    if (studentUserId.isEmpty) return;

    try {
      final List<Map<String, dynamic>> students =
          await _applicationApiService.fetchStudents();
      final Map<String, dynamic>? current =
          students.cast<Map<String, dynamic>?>().firstWhere(
                (item) => (item?['userId'] ?? '').toString() == studentUserId,
                orElse: () => students.isNotEmpty ? students.first : null,
              );

      if (current == null) {
        return;
      }
      _profileLoaded = true;

      final Map<String, dynamic> user =
          (current['user'] is Map<String, dynamic>)
              ? current['user'] as Map<String, dynamic>
              : <String, dynamic>{};

      final String first = (current['firstName'] ?? '').toString().trim();
      final String middle = (current['middleName'] ?? '').toString().trim();
      final String last = (current['lastName'] ?? '').toString().trim();

      final String country = (current['country'] ?? '').toString().trim();
      final String fullPhone = (current['phone'] ?? '').toString().trim();

      updateView(() {
        _fullNameController.text =
            [first, middle, last].where((e) => e.isNotEmpty).join(' ');
        _emailController.text = (user['email'] ?? '').toString().trim();
        _phoneController.text = _phoneWithoutCode(fullPhone);
        _gender = _normalizeGender((current['gender'] ?? 'FEMALE').toString());

        if (country.isNotEmpty && _countries.isNotEmpty) {
          try {
            final CountryMaster matchedCountry = _countries.firstWhere(
              (c) =>
                  c.value.toLowerCase() == country.toLowerCase() ||
                  c.nameEn.toLowerCase() == country.toLowerCase(),
            );
            _selectedCountry = matchedCountry.nameEn;
            _selectedCountryDialCode = matchedCountry.dialCode;
          } catch (_) {
            // preserve login country if no match
          }
        }
      });
    } catch (_) {
      // ignore profile load failures here; keep login session defaults
    }
  }

  String _phoneWithoutCode(String full) {
    final String dial = _selectedCountryDialCode;
    if (dial.isNotEmpty && full.startsWith(dial)) {
      return full.substring(dial.length).trim();
    }
    return full;
  }

  Future<void> _handlePayNow() async {
    if (_isSubmitting) return;
    if (_emailController.text.trim().isEmpty &&
        _fullNameController.text.trim().isEmpty) {
      await _openUpdateProfileBottomSheet();
      return;
    }

    await _submitApplicationsAndPayOnline();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _applicationFeeTotal {
    return widget.applicationsPayload.fold<double>(0, (total, payload) {
      final Object? selectedApplicationFeeTotal =
          payload['selectedApplicationFeeTotal'];

      final double? selectedTotal =
          _parseApplicationFee(selectedApplicationFeeTotal);

      if (selectedTotal != null) {
        return total + selectedTotal;
      }

      final Object? directApplicationFee = payload['applicationFee'];

      final double? directFee = _parseApplicationFee(directApplicationFee);

      if (directFee != null) {
        return total + directFee;
      }

      final Object? courseDetails = payload['courseDetails'];

      if (courseDetails is! Map) {
        return total;
      }

      final Object? applicationFee = courseDetails['applicationFee'];

      return total + (_parseApplicationFee(applicationFee) ?? 0);
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
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim());
    }

    return null;
  }

  Future<Map<String, dynamic>?> _fetchStudentOverview(
    String studentUserId,
  ) async {
    if (studentUserId.isEmpty) return null;

    try {
      return await _applicationApiService.fetchStudentOverview(
        studentUserId: studentUserId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _createApplicationsAfterPayment({
    required String studentUserId,
  }) async {
    Map<String, dynamic>? createdApplicationsResponse;
    Map<String, dynamic>? studentOverview;

    createdApplicationsResponse =
        await _applicationApiService.createBulkApplications(
      studentUserId: studentUserId,
      applications: widget.applicationsPayload,
    );

    studentOverview = await _fetchStudentOverview(studentUserId);

    await SelectedCourseStorage.clear();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentConfirmationScreen(
          universityName: widget.universityName,
          universityHeroImage: widget.universityHeroImage,
          courseTitle: widget.courseTitle,
          applicationsPayload: widget.applicationsPayload,
          createdApplicationsResponse: createdApplicationsResponse,
          studentOverview: studentOverview,
        ),
      ),
    );
  }

  Future<void> _submitApplicationsAndPayOnline() async {
    if (_isSubmitting) return;

    updateView(() => _isSubmitting = true);

    try {
      if (widget.applicationsPayload.isEmpty) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';

      if (studentUserId.isEmpty) {
        throw Exception('Unable to find student user ID.');
      }

      final double total = _applicationFeeTotal;
      final String clientReferenceId =
          '${studentUserId}_${DateTime.now().millisecondsSinceEpoch}';

      Thawani.pay(
        context,
        testMode: true,
        api: ApiConfig.secretKey,
        pKey: ApiConfig.publishableKey,
        clintID: studentUserId,
        metadata: {
          'order_id': clientReferenceId,
          'customer_id': studentUserId,
          'customer_name': _fullNameController.text.trim(),
          'customer_email': _emailController.text.trim(),
          'platform': 'education_client',
        },
        products: [
          Product(
            name: 'University Application Fee',
            quantity: 1,
            unitAmount: (total * 1000).toInt(),
          ),
        ],
        saveCard: true,
        getSavedCustomer: (customerId) {
          debugPrint('Saved Customer ID: $customerId');
        },
        onCreateCustomer: (data) {
          debugPrint('Customer Created: $data');
        },
        savedCards: (cards) {
          debugPrint('Saved Cards: $cards');
        },
        onCreate: (response) {
          debugPrint('Session Created');
          debugPrint(response.data.toString());
        },
        onPaid: (response) async {
          debugPrint('Payment Success');
          debugPrint(response.toString());

          if (!mounted) return;

          _showProcessingDialog();

          try {
            await _createApplicationsAfterPayment(
              studentUserId: studentUserId,
            );

            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop(); // dismiss loading dialog
            }
          } on ApplicationApiException catch (e) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }

            if (e.statusCode == 409) {
              await SelectedCourseStorage.clear();
            }

            snackBarService.showError(message: e.message);
          } catch (e) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }

            snackBarService.showError(message: e.toString());
          }
        },
        onCancelled: (response) {
          debugPrint('Payment Cancelled');
          debugPrint(response.toString());

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentFailedScreen(
                universityName: widget.universityName,
                universityHeroImage: widget.universityHeroImage,
                courseTitle: widget.courseTitle,
                applicationsPayload: widget.applicationsPayload,
                failureType: PaymentFailureType.cancelled,
              ),
            ),
          );
        },
        onError: (error) {
          debugPrint('Payment Error');
          debugPrint(error.toString());

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentFailedScreen(
                universityName: widget.universityName,
                universityHeroImage: widget.universityHeroImage,
                courseTitle: widget.courseTitle,
                applicationsPayload: widget.applicationsPayload,
                failureType: PaymentFailureType.failed,
              ),
            ),
          );
        },
      );
    } catch (e) {
      snackBarService.showError(message: e.toString());
    } finally {
      if (mounted) {
        updateView(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitApplicationsAndContinue() async {
    if (_isSubmitting) return;

    updateView(() => _isSubmitting = true);

    Map<String, dynamic>? createdApplicationsResponse;
    Map<String, dynamic>? studentOverview;

    try {
      if (widget.applicationsPayload.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final String studentUserId =
            prefs.getString('studentUserId')?.trim() ?? '';

        if (studentUserId.isNotEmpty) {
          createdApplicationsResponse =
              await _applicationApiService.createBulkApplications(
            studentUserId: studentUserId,
            applications: widget.applicationsPayload,
          );

          studentOverview = await _fetchStudentOverview(studentUserId);
        }
      }

      await SelectedCourseStorage.clear();

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationScreen(
            universityName: widget.universityName,
            universityHeroImage: widget.universityHeroImage,
            courseTitle: widget.courseTitle,
            applicationsPayload: widget.applicationsPayload,
            createdApplicationsResponse: createdApplicationsResponse,
            studentOverview: studentOverview,
          ),
        ),
      );
    } on ApplicationApiException catch (e) {
      if (e.statusCode == 409) {
        await SelectedCourseStorage.clear();
      }

      snackBarService.showError(message: e.message);
    } catch (e) {
      snackBarService.showError(message: e.toString());
    } finally {
      if (mounted) {
        updateView(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _openUpdateProfileBottomSheet() async {
    if (_isSubmitting) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

    if (studentUserId.isEmpty) {
      snackBarService.showError(
        message: 'Unable to find student user ID.',
      );
      return;
    }

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        String gender = _normalizeGender(_gender);
        bool isUpdating = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D1D1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.text('updateProfile'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.text('fullName'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.text('email'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          Builder(
                            builder: (BuildContext context) {
                              final List<CountryMaster> countryOptions =
                                  <CountryMaster>[..._countries];
                              if (_selectedCountry.isNotEmpty &&
                                  countryOptions.every((entry) =>
                                      entry.nameEn != _selectedCountry)) {
                                countryOptions.insert(
                                  0,
                                  CountryMaster(
                                    id: 'fallback',
                                    nameEn: _selectedCountry,
                                    nameAr: '',
                                    value: '',
                                    dialCode: _selectedCountryDialCode,
                                    flagEmoji: '🌍',
                                    isActive: true,
                                  ),
                                );
                              }

                              return Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCountry.isNotEmpty
                                        ? _selectedCountry
                                        : null,
                                    hint: Text(_isLoadingCountries
                                        ? 'Loading countries...'
                                        : context.l10n.text('selectCountry')),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(12),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.text,
                                    ),
                                    items: countryOptions
                                        .map(
                                          (country) => DropdownMenuItem<String>(
                                            value: country.nameEn,
                                            child: Text(
                                              '${country.nameEn} ${country.dialCode}',
                                            ),
                                          ),
                                        )
                                        .toList(growable: false),
                                    onChanged: countryOptions.isEmpty
                                        ? null
                                        : (value) {
                                            if (value == null) return;
                                            final CountryMaster
                                                selectedCountry =
                                                countryOptions.firstWhere(
                                              (country) =>
                                                  country.nameEn == value,
                                              orElse: () => CountryMaster(
                                                id: 'fallback',
                                                nameEn: value,
                                                nameAr: '',
                                                value: '',
                                                dialCode:
                                                    _selectedCountryDialCode,
                                                flagEmoji: '🌍',
                                                isActive: true,
                                              ),
                                            );
                                            setState(() {
                                              _selectedCountry = value;
                                              _selectedCountryDialCode =
                                                  selectedCountry.dialCode;
                                            });
                                          },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Container(
                              width: 1, height: 30, color: AppColors.border),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
                                hintText: _phoneController.text.isEmpty
                                    ? context.l10n.text('enterMobileNumber')
                                    : null,
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(
                        labelText: context.l10n.text('gender'),
                        border: const OutlineInputBorder(),
                      ),
                      items: _genderOptions
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            gender = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    AppPrimaryButton(
                      label: context.l10n.text('updateProfile'),
                      onPressed: isUpdating
                          ? null
                          : () async {
                              final String fullName =
                                  _fullNameController.text.trim();
                              final String email = _emailController.text.trim();
                              final String phone = _phoneController.text.trim();
                              final String country = _selectedCountry.trim();

                              if (fullName.isEmpty ||
                                  email.isEmpty ||
                                  phone.isEmpty ||
                                  country.isEmpty) {
                                snackBarService.showError(
                                  message: 'Please fill all fields.',
                                );
                                return;
                              }

                              setState(() => isUpdating = true);

                              final List<String> parts = fullName
                                  .split(RegExp(r'\s+'))
                                  .where((e) => e.isNotEmpty)
                                  .toList(growable: false);
                              final String firstName =
                                  parts.isNotEmpty ? parts.first : fullName;
                              final String lastName =
                                  parts.length > 1 ? parts.last : fullName;

                              try {
                                if (!context.mounted) return;
                                setState(() => isUpdating = true);

                                await _applicationApiService
                                    .updateStudentProfileQuick(
                                  studentUserId: studentUserId,
                                  fullName: fullName,
                                  firstName: firstName,
                                  lastName: lastName,
                                  email: email,
                                  country: country,
                                  phone: phone,
                                  gender: gender,
                                  preferredLanguage:
                                      context.l10n.locale.languageCode,
                                  isActive: true,
                                );

                                if (!mounted) return;
                                Navigator.of(context).pop(true);
                                await _submitApplicationsAndContinue();
                              } on ApplicationApiException catch (e) {
                                if (!mounted) return;
                                snackBarService.showError(message: e.message);
                              } catch (e) {
                                if (!mounted) return;
                                snackBarService.showError(
                                    message: e.toString());
                              } finally {
                                if (context.mounted) {
                                  setState(() => isUpdating = false);
                                }
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;

    final double horizontalPadding = context.responsiveHorizontalPadding;

    return buildCubitView(
      (context) => Scaffold(
        body: AppBackground(
          child: AppPageEntrance(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlowStepHeader(
                      currentStep: 2,
                      title: context.l10n.text('payment'),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isSmallMobile ? 14 : 20,
                          horizontalPadding,
                          20,
                        ),
                        children: [
                          Text(
                            context.l10n.text('applicationFeeSummary'),
                            style: TextStyle(
                              fontSize: isSmallMobile ? 16 : 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE8E2D9),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      context.l10n.text('applicationFee'),
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _applicationFeeText(context),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Text(
                                      context.l10n.text('totalAmount'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _applicationFeeText(context),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Text(
                          //   context.l10n.text('paymentMethod'),
                          //   style: TextStyle(
                          //     fontSize: isSmallMobile ? 16 : 18,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          // _PaymentMethodTile(
                          //   label: context.l10n.text('COD'),
                          //   iconText: 'COD',
                          //   selected: selected == 0,
                          //   onTap: () => updateView(() => selected = 0),
                          // ),
                          // const SizedBox(height: 12),
                          // _PaymentMethodTile(
                          //   label: context.l10n.text('onlinePayment'),
                          //   iconText: 'ONLINE',
                          //   selected: selected == 1,
                          //   onTap: () => updateView(() => selected = 1),
                          // ),
                          // const SizedBox(height: 30),
                          AppPrimaryButton(
                            label: context.l10n.text('payNow'),
                            onPressed: _isSubmitting ? null : _handlePayNow,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isSubmitting)
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
    );
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Text('Payment received. Processing application...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.label,
    required this.iconText,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : const Color(0xFFE8E2D9),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                iconText,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallMobile ? 14 : 16,
                color: AppColors.textMuted,
              ),
            ),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.textMuted,
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: AppColors.accent,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
