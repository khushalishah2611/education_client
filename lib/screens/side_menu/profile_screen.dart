import 'dart:io';

import 'package:education/core/api_config.dart';
import 'package:education/core/app_localizations.dart';
import 'package:education/core/bloc/app_cubit.dart';
import 'package:education/core/student_session.dart';
import 'package:education/models/country_master.dart';
import 'package:education/screens/home_screen.dart';
import 'package:education/services/application_api_service.dart';
import 'package:education/services/auth_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../services/snackbar_service.dart';
import '../../widgets/common_widgets.dart' show AppPrimaryButton;
import 'side_menu_common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('myProfile'),
      child: const ProfileBody(),
    );
  }
}

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody>
    with CubitStateMixin<ProfileBody> {
  final ApplicationApiService _api = const ApplicationApiService();
  final AuthApiService _authApi = const AuthApiService();

  final TextEditingController _fullNameController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController();
  final TextEditingController _ageController =
  TextEditingController();
  final TextEditingController _dobController =
  TextEditingController();
  final TextEditingController _phoneController =
  TextEditingController();
  final TextEditingController _guardianController =
  TextEditingController();
  final TextEditingController _relationshipController =
  TextEditingController();
  final TextEditingController _emergencyMobileController =
  TextEditingController();
  final TextEditingController _emergencyEmailController =
  TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoadingCountries = true;

  String _gender = 'FEMALE';
  String _studentUserId = '';

  String? _profileImagePath;
  PlatformFile? _selectedProfileImage;

  List<CountryMaster> _countries = <CountryMaster>[];
  CountryMaster? _selectedCountry;
  static final RegExp _emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _fieldKeys = <String, GlobalKey>{
    'fullName': GlobalKey(),
    'dateOfBirth': GlobalKey(),
    'country': GlobalKey(),
    'mobileNumber': GlobalKey(),
    'age': GlobalKey(),
    'email': GlobalKey(),
    'guardianName': GlobalKey(),
    'relationship': GlobalKey(),
    'emergencyMobile': GlobalKey(),
    'emergencyEmail': GlobalKey(),
  };
  Map<String, String> _fieldErrors = <String, String>{};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadCountries();
      await _loadProfile();
    } finally {
      if (mounted) {
        updateView(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _guardianController.dispose();
    _relationshipController.dispose();
    _emergencyMobileController.dispose();
    _emergencyEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      updateView(() {
        _isLoadingCountries = true;
      });

      /// CALL API
      /// https://arab.vedx.cloud/api/admin/masters/country
      final List<CountryMaster> countries =
      await _authApi.fetchCountries();

      _countries = countries;

      if (_countries.isNotEmpty) {
        _selectedCountry = _countries.first;
      } else {
        _selectedCountry = null;
      }
    } catch (_) {
      if (!mounted) return;
      snackBarService.showError(
        message: context.l10n.text('failedLoadLoginData'),
      );
    } finally {
      if (mounted) {
        updateView(() {
          _isLoadingCountries = false;
        });
      }
    }
  }

  Future<void> _loadProfile() async {
    try {
      final String userId =
      await StudentSession.currentStudentUserId();

      final List<Map<String, dynamic>> students =
      await _api.fetchStudents();

      final Map<String, dynamic>? current =
      students.cast<Map<String, dynamic>?>().firstWhere(
            (item) =>
        (item?['userId'] ?? '').toString() ==
            userId,
        orElse: () =>
        students.isNotEmpty ? students.first : null,
      );

      if (current == null) {
        throw Exception('Student not found');
      }

      _studentUserId =
          (current['userId'] ?? '').toString();

      final Map<String, dynamic> user =
      (current['user'] is Map<String, dynamic>)
          ? current['user'] as Map<String, dynamic>
          : <String, dynamic>{};

      final String first =
      (current['firstName'] ?? '').toString().trim();

      final String middle =
      (current['middleName'] ?? '').toString().trim();

      final String last =
      (current['lastName'] ?? '').toString().trim();

      _fullNameController.text = [
        first,
        middle,
        last,
      ].where((e) => e.isNotEmpty).join(' ');

      _emailController.text =
          (user['email'] ?? '').toString();

      _ageController.text =
          (current['age'] ?? '').toString();

      _dobController.text = _displayDate(
        (current['dateOfBirth'] ?? '').toString(),
      );

      _phoneController.text = _phoneWithoutCode(
        (current['phone'] ?? '').toString(),
      );

      _guardianController.text =
          (current['emergencyContactGuardianName'] ?? '')
              .toString();

      _relationshipController.text =
          (current['emergencyContactRelationship'] ?? '')
              .toString();

      _emergencyMobileController.text =
          (current['emergencyContactMobile'] ?? '')
              .toString();

      _emergencyEmailController.text =
          (current['emergencyContactEmail'] ?? '')
              .toString();

      _gender =
          (current['gender'] ?? 'FEMALE').toString();

      _profileImagePath =
          (current['profileImagePath'] ?? '').toString();

      /// COUNTRY BIND
      final String country =
      (current['country'] ?? '').toString().trim();

      if (country.isNotEmpty &&
          _countries.isNotEmpty) {
        try {
          _selectedCountry = _countries.firstWhere(
                (c) =>
            c.value.toLowerCase() ==
                country.toLowerCase() ||
                c.nameEn.toLowerCase() ==
                    country.toLowerCase(),
          );
        } catch (_) {}
      }

      if (mounted) {
        refreshView();
      }
    } catch (e) {
      snackBarService.showError(message: e.toString());
    }
  }

  String _displayDate(String raw) {
    if (raw.isEmpty) return '';

    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _apiDate(String raw) {
    if (raw.isEmpty) return '';

    for (final String format
    in <String>['dd-MM-yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat('yyyy-MM-dd').format(
          DateFormat(format).parseStrict(raw),
        );
      } catch (_) {}
    }

    return raw;
  }

  String _phoneWithoutCode(String full) {
    final String dial =
        _selectedCountry?.dialCode ?? '';

    if (dial.isNotEmpty &&
        full.startsWith(dial)) {
      return full.substring(dial.length).trim();
    }

    return full;
  }

  Future<void> _pickDob() async {
    DateTime initialDate =
    DateTime.now().subtract(
      const Duration(days: 365 * 18),
    );

    try {
      initialDate = DateFormat('dd-MM-yyyy')
          .parseStrict(_dobController.text);
    } catch (_) {}

    final DateTime? date =
    await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      updateView(() {
        _dobController.text =
            DateFormat('dd-MM-yyyy')
                .format(date);
        _fieldErrors.remove('dateOfBirth');
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final result =
    await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    updateView(() {
      _selectedProfileImage =
          result.files.first;
    });
  }

  void _clearFieldError(String fieldKey) {
    if (!_fieldErrors.containsKey(fieldKey)) return;
    updateView(() {
      _fieldErrors.remove(fieldKey);
    });
  }

  void _scrollToFirstError(Map<String, String> errors) {
    if (errors.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final String fieldKey in _fieldKeys.keys) {
        if (!errors.containsKey(fieldKey)) continue;

        final BuildContext? fieldContext =
            _fieldKeys[fieldKey]?.currentContext;
        if (fieldContext == null) return;

        Scrollable.ensureVisible(
          fieldContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
        return;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_studentUserId.isEmpty) return;
    final Map<String, String> validationErrors = _validateProfileForm();
    if (validationErrors.isNotEmpty) {
      updateView(() {
        _fieldErrors = validationErrors;
      });
      _scrollToFirstError(validationErrors);
      return;
    }

    final List<String> parts =
    _fullNameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final String first =
    parts.isNotEmpty ? parts.first : '';

    final String last =
    parts.length > 1 ? parts.last : '';

    final String mobile =
        '${_selectedCountry?.dialCode ?? ''}${_phoneController.text.trim()}';

    updateView(() {
      _isSaving = true;
      _fieldErrors = <String, String>{};
    });

    try {
      final res =
      await _api.updateStudentProfile(
        studentUserId: _studentUserId,
        fullName:
        _fullNameController.text.trim(),
        firstName: first,
        lastName: last,
        email: _emailController.text.trim(),
        country:
        _selectedCountry?.value ?? '',
        age: int.tryParse(
          _ageController.text.trim(),
        ),
        dateOfBirth:
        _apiDate(_dobController.text.trim()),
        phone: mobile,
        gender: _gender,
        emergencyContactGuardianName:
        _guardianController.text.trim(),
        emergencyContactRelationship:
        _relationshipController.text.trim(),
        emergencyContactMobile:
        _emergencyMobileController.text
            .trim(),
        emergencyContactEmail:
        _emergencyEmailController.text
            .trim(),
        isActive: true,
        profileImagePath:
        _selectedProfileImage?.path,
        profileImageName:
        _selectedProfileImage?.name,
      );

      if (!mounted) return;

      snackBarService.showSuccess(
        message:
        res['message']?.toString() ??
            'Student updated successfully.',
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      snackBarService.showError(message: e.toString());
    } finally {
      if (mounted) {
        updateView(() {
          _isSaving = false;
        });
      }
    }
  }

  Map<String, String> _validateProfileForm() {
    final Map<String, String> errors = <String, String>{};

    final String fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      errors['fullName'] = 'Please enter full name.';
    }

    final String dob = _dobController.text.trim();
    if (dob.isEmpty) {
      errors['dateOfBirth'] = 'Please select date of birth.';
    }

    final String country = (_selectedCountry?.value ?? '').trim();
    if (country.isEmpty) {
      errors['country'] = 'Please select country.';
    }

    final String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      errors['mobileNumber'] = 'Please enter mobile number.';
    }

    final String ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      errors['age'] = 'Please enter age.';
    } else {
      final int? age = int.tryParse(ageText);
      if (age == null || age <= 0) {
        errors['age'] = 'Please enter a valid age.';
      }
    }

    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      errors['email'] = 'Please enter email address.';
    } else if (!_emailRegex.hasMatch(email)) {
      errors['email'] = 'Please enter a valid email address.';
    }

    final String guardian = _guardianController.text.trim();
    if (guardian.isEmpty) {
      errors['guardianName'] = 'Please enter guardian name.';
    }

    final String relationship = _relationshipController.text.trim();
    if (relationship.isEmpty) {
      errors['relationship'] = 'Please enter relationship.';
    }

    final String emergencyMobile = _emergencyMobileController.text.trim();
    if (emergencyMobile.isEmpty) {
      errors['emergencyMobile'] = 'Please enter emergency mobile number.';
    }

    final String emergencyEmail = _emergencyEmailController.text.trim();
    if (emergencyEmail.isEmpty) {
      errors['emergencyEmail'] = 'Please enter emergency email address.';
    } else if (!_emailRegex.hasMatch(emergencyEmail)) {
      errors['emergencyEmail'] = 'Please enter a valid emergency email address.';
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return buildCubitView((context) {
      if (_isLoading) {
      return const _ProfileShimmer();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: _scrollController,
        children: [
          const SizedBox(height: 8),

          ProfileAvatar(
            imagePath: _profileImagePath,
            selectedImagePath: _selectedProfileImage?.path,
            onEdit: _pickProfileImage,
          ),

          const SizedBox(height: 22),

          ProfileSectionTitle(
            context.l10n.text('basicInformation'),
          ),

          const SizedBox(height: 14),

          ProfileLabel(context.l10n.text('fullName')),

          KeyedSubtree(
            key: _fieldKeys['fullName'],
            child: ProfileInput(
              controller: _fullNameController,
              hint: context.l10n.text('firstMiddleLast'),
              icon: Icons.person_outline_rounded,
              errorText: _fieldErrors['fullName'],
              onChanged: (_) => _clearFieldError('fullName'),
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(context.l10n.text('gender')),

          GenderSelector(
            selected: _gender,
            onChanged: (v) {
              updateView(() {
                _gender = v;
              });
            },
          ),

          const SizedBox(height: 14),

          ProfileLabel(context.l10n.text('dateOfBirth')),

          KeyedSubtree(
            key: _fieldKeys['dateOfBirth'],
            child: ProfileInput(
              controller: _dobController,
              hint: 'DD-MM-YYYY',
              icon: Icons.calendar_month_outlined,
              readOnly: true,
              errorText: _fieldErrors['dateOfBirth'],
              onTap: _pickDob,
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(context.l10n.text('country')),

          KeyedSubtree(
            key: _fieldKeys['country'],
            child: CountryDropdownField(
              countries: _countries,
              selectedCountry: _selectedCountry,
              isLoading: _isLoadingCountries,
              errorText: _fieldErrors['country'],
              onCountryChanged: (v) {
                updateView(() {
                  _selectedCountry = v;
                  _fieldErrors.remove('country');
                });
              },
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(context.l10n.text('mobileNumber')),

          KeyedSubtree(
            key: _fieldKeys['mobileNumber'],
            child: MobileNumberField(
              dialCode: _selectedCountry?.dialCode ?? '',
              mobileController: _phoneController,
              errorText: _fieldErrors['mobileNumber'],
              onChanged: (_) => _clearFieldError('mobileNumber'),
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(context.l10n.text('age')),

          KeyedSubtree(
            key: _fieldKeys['age'],
            child: ProfileInput(
              controller: _ageController,
              hint: context.l10n.text('age'),
              icon: Icons.numbers_outlined,
              errorText: _fieldErrors['age'],
              onChanged: (_) => _clearFieldError('age'),
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(
            context.l10n.text('emailAddress'),
          ),

          KeyedSubtree(
            key: _fieldKeys['email'],
            child: ProfileInput(
              controller: _emailController,
              hint: context.l10n.text('emailAddress'),
              icon: Icons.mail_outline_rounded,
              errorText: _fieldErrors['email'],
              onChanged: (_) => _clearFieldError('email'),
            ),
          ),

          const SizedBox(height: 22),

          ProfileSectionTitle(
            context.l10n.text('emergencyContact'),
          ),

          const SizedBox(height: 14),

          ProfileLabel(
            context.l10n.text('guardianName'),
          ),

          KeyedSubtree(
            key: _fieldKeys['guardianName'],
            child: ProfileInput(
              controller: _guardianController,
              hint: context.l10n.text('guardianName'),
              icon: Icons.person_outline_rounded,
              errorText: _fieldErrors['guardianName'],
              onChanged: (_) => _clearFieldError('guardianName'),
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(
            context.l10n.text('relationship'),
          ),

          KeyedSubtree(
            key: _fieldKeys['relationship'],
            child: ProfileInput(
              controller: _relationshipController,
              hint: context.l10n.text('relationship'),
              icon: Icons.people_outline_rounded,
              errorText: _fieldErrors['relationship'],
              onChanged: (_) => _clearFieldError('relationship'),
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(
            context.l10n.text('mobileNumber'),
          ),

          KeyedSubtree(
            key: _fieldKeys['emergencyMobile'],
            child: ProfileInput(
              controller: _emergencyMobileController,
              hint: context.l10n.text('mobileNumber'),
              icon: Icons.call_outlined,
              errorText: _fieldErrors['emergencyMobile'],
              onChanged: (_) => _clearFieldError('emergencyMobile'),
            ),
          ),

          const SizedBox(height: 14),

          ProfileLabel(
            context.l10n.text('emailAddress'),
          ),

          KeyedSubtree(
            key: _fieldKeys['emergencyEmail'],
            child: ProfileInput(
              controller: _emergencyEmailController,
              hint: context.l10n.text('emailAddress'),
              icon: Icons.mail_outline_rounded,
              errorText: _fieldErrors['emergencyEmail'],
              onChanged: (_) => _clearFieldError('emergencyEmail'),
            ),
          ),

          const SizedBox(height: 28),

          AppPrimaryButton(
            label: context.l10n.text('save'),
            onPressed:
            _isSaving ? null : _saveProfile,
          ),

          const SizedBox(height: 20),
        ],
        ),
      );
    });
  }
}

class _ProfileShimmer extends StatefulWidget {
  const _ProfileShimmer();

  @override
  State<_ProfileShimmer> createState() =>
      _ProfileShimmerState();
}

class _ProfileShimmerState
    extends State<_ProfileShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Padding(
          padding:
          const EdgeInsets.all(16),
          child: ListView(
            children: [
              Center(
                child: _shimmerCircle(100),
              ),

              const SizedBox(height: 24),

              ...List.generate(
                10,
                    (index) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: _shineBox(
                    height: 58,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shineBox({
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment(
            -1 + 2 * _controller.value,
            0,
          ),
          end: Alignment(
            1 + 2 * _controller.value,
            0,
          ),
          colors: const [
            Color(0xFFEAEAEA),
            Color(0xFFF7F7F7),
            Color(0xFFEAEAEA),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(
            -1 + 2 * _controller.value,
            0,
          ),
          end: Alignment(
            1 + 2 * _controller.value,
            0,
          ),
          colors: const [
            Color(0xFFEAEAEA),
            Color(0xFFF7F7F7),
            Color(0xFFEAEAEA),
          ],
        ),
      ),
    );
  }
}

class CountryDropdownField extends StatelessWidget {
  const CountryDropdownField({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.isLoading,
    required this.onCountryChanged,
    this.errorText,
  });

  final List<CountryMaster> countries;
  final CountryMaster? selectedCountry;
  final bool isLoading;
  final ValueChanged<CountryMaster?> onCountryChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final bool hasError = (errorText ?? '').isNotEmpty;
    final Color borderColor =
        hasError ? Colors.red.shade700 : AppColors.border;
    final CountryMaster? dropdownValue = selectedCountry == null
        ? null
        : countries.cast<CountryMaster?>().firstWhere(
              (country) => country?.id == selectedCountry!.id,
              orElse: () => null,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CountryMaster>(
              isExpanded: true,
              value: dropdownValue,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
              items: countries
                  .map(
                    (c) => DropdownMenuItem<CountryMaster>(
                      value: c,
                      child: Text(
                        '${c.flagEmoji} ${c.nameEn}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: isLoading ? null : onCountryChanged,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class MobileNumberField extends StatelessWidget {
  const MobileNumberField({
    super.key,
    required this.dialCode,
    required this.mobileController,
    this.errorText,
    this.onChanged,
  });

  final String dialCode;
  final TextEditingController mobileController;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool hasError = (errorText ?? '').isNotEmpty;
    final Color borderColor =
        hasError ? Colors.red.shade700 : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dialCode.isEmpty ? '--' : dialCode,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 30, color: AppColors.border),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: context.l10n.text('enterMobileNumber'),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.onEdit,
    this.imagePath,
    this.selectedImagePath,
  });

  final VoidCallback onEdit;
  final String? imagePath;
  final String? selectedImagePath;

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedImage =
        (selectedImagePath ?? '').trim().isNotEmpty;
    final String url =
    (imagePath ?? '').startsWith('http')
        ? imagePath!
        : '${ApiConfig.baseUrl}${imagePath ?? ''}';

    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            padding:
            const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: hasSelectedImage
                  ? FileImage(File(selectedImagePath!)) as ImageProvider
                  : (imagePath ?? '').isEmpty
                  ? null
                  : NetworkImage(url) as ImageProvider,
              child:
              (imagePath ?? '').isEmpty &&
                  !hasSelectedImage
                  ? const Icon(
                Icons.person,
                size: 42,
                color:
                AppColors.textMuted,
              )
                  : null,
            ),
          ),

          Positioned(
            bottom: 4,
            right: 0,
            child: InkWell(
              onTap: onEdit,
              child: Container(
                width: 30,
                height: 30,
                decoration:
                const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionTitle
    extends StatelessWidget {
  const ProfileSectionTitle(
      this.title, {
        super.key,
      });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class ProfileLabel extends StatelessWidget {
  const ProfileLabel(
      this.text, {
        super.key,
      });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProfileInput extends StatelessWidget {
  const ProfileInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          size: 18,
          color: AppColors.textMuted,
        ),
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD7D5D3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (errorText ?? '').isNotEmpty
                ? Colors.red.shade700
                : const Color(0xFFD7D5D3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (errorText ?? '').isNotEmpty
                ? Colors.red.shade700
                : AppColors.accent,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade700,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          value: 'MALE',
          groupValue: selected,
          onChanged: (v) =>
              onChanged(v ?? 'MALE'),
        ),
        Text(context.l10n.text('male')),

        const SizedBox(width: 14),

        Radio<String>(
          value: 'FEMALE',
          groupValue: selected,
          onChanged: (v) =>
              onChanged(v ?? 'FEMALE'),
        ),
        Text(context.l10n.text('female')),
      ],
    );
  }
}
