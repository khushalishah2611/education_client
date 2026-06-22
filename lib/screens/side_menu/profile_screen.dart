import 'dart:async';
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

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
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

  String? _validationMessage;
  Timer? _validationTimer;

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
    _fullNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _guardianController.dispose();
    _relationshipController.dispose();
    _emergencyMobileController.dispose();
    _emergencyEmailController.dispose();
    _validationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      updateView(() {
        _isLoadingCountries = true;
      });

      /// CALL API
      /// https://arab.vedx.cloud/api/admin/masters/country
      final List<CountryMaster> countries = await _authApi.fetchCountries();

      _countries = countries;

      if (_countries.isNotEmpty) {
        _selectedCountry = _countries.firstWhere(
          (c) => c.nameEn.toLowerCase() == 'oman',
          orElse: () => _countries.first,
        );
      } else {
        _selectedCountry = null;
      }
    } catch (_) {
      if (!mounted) return;
      _showValidationError(context.l10n.text('failedLoadLoginData'));
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
      final String userId = await StudentSession.currentStudentUserId();

      final List<Map<String, dynamic>> students = await _api.fetchStudents();

      final Map<String, dynamic>? current =
          students.cast<Map<String, dynamic>?>().firstWhere(
                (item) => (item?['userId'] ?? '').toString() == userId,
                orElse: () => students.isNotEmpty ? students.first : null,
              );

      if (current == null) {
        throw Exception('Student not found');
      }

      _studentUserId = (current['userId'] ?? '').toString();

      final Map<String, dynamic> user =
          (current['user'] is Map<String, dynamic>)
              ? current['user'] as Map<String, dynamic>
              : <String, dynamic>{};

      final String first = (current['firstName'] ?? '').toString().trim();

      final String middle = (current['middleName'] ?? '').toString().trim();

      final String last = (current['lastName'] ?? '').toString().trim();

      _fullNameController.text = [
        first,
        middle,
        last,
      ].where((e) => e.isNotEmpty).join(' ');

      _emailController.text = (user['email'] ?? '').toString();

      _ageController.text = (current['age'] ?? '').toString();

      _dobController.text = _displayDate(
        (current['dateOfBirth'] ?? '').toString(),
      );

      _phoneController.text = _phoneWithoutCode(
        (current['phone'] ?? '').toString(),
      );

      _guardianController.text =
          (current['emergencyContactGuardianName'] ?? '').toString();

      _relationshipController.text =
          (current['emergencyContactRelationship'] ?? '').toString();

      _emergencyMobileController.text =
          (current['emergencyContactMobile'] ?? '').toString();

      _emergencyEmailController.text =
          (current['emergencyContactEmail'] ?? '').toString();

      _gender = (current['gender'] ?? 'FEMALE').toString();

      _profileImagePath = (current['profileImagePath'] ?? '').toString();

      /// COUNTRY BIND
      final String country = (current['country'] ?? '').toString().trim();

      if (country.isNotEmpty && _countries.isNotEmpty) {
        try {
          _selectedCountry = _countries.firstWhere(
            (c) =>
                c.value.toLowerCase() == country.toLowerCase() ||
                c.nameEn.toLowerCase() == country.toLowerCase(),
          );
        } catch (_) {}
      }

      if (mounted) {
        refreshView();
      }
    } catch (_) {
      // Keep login session defaults when profile load fails.
    }
  }

  String _displayDate(String raw) {
    if (raw.isEmpty) return '';

    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _apiDate(String raw) {
    if (raw.isEmpty) return '';

    for (final String format in <String>['dd-MM-yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat('yyyy-MM-dd').format(
          DateFormat(format).parseStrict(raw),
        );
      } catch (_) {}
    }

    return raw;
  }

  String _phoneWithoutCode(String full) {
    final String dial = _selectedCountry?.dialCode ?? '';

    if (dial.isNotEmpty && full.startsWith(dial)) {
      return full.substring(dial.length).trim();
    }

    return full;
  }

  Future<void> _pickDob() async {
    DateTime initialDate = DateTime.now().subtract(
      const Duration(days: 365 * 18),
    );

    try {
      initialDate = DateFormat('dd-MM-yyyy').parseStrict(_dobController.text);
    } catch (_) {}

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      updateView(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(date);
        _validationMessage = null;
      });
    }
  }

  void _showValidationError(String message) {
    _validationTimer?.cancel();
    updateView(() {
      _validationMessage = message;
    });
    _validationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _clearValidationError();
      }
    });
  }

  void _clearValidationError() {
    _validationTimer?.cancel();
    if (_validationMessage == null) return;
    updateView(() {
      _validationMessage = null;
    });
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    updateView(() {
      _selectedProfileImage = result.files.first;
    });
  }

  Future<void> _saveProfile() async {
    if (_studentUserId.isEmpty) return;

    final String? validationMessage = _firstValidationMessage(
      _validateProfileForm(),
    );
    if (validationMessage != null) {
      _showValidationError(validationMessage);
      return;
    }

    final List<String> parts = _fullNameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final String first = parts.isNotEmpty ? parts.first : '';

    final String last = parts.length > 1 ? parts.last : '';

    final String mobile =
        '${_selectedCountry?.dialCode ?? ''}${_phoneController.text.trim()}';

    updateView(() {
      _isSaving = true;
      _validationMessage = null;
    });

    try {
      final res = await _api.updateStudentProfile(
        studentUserId: _studentUserId,
        fullName: _fullNameController.text.trim(),
        firstName: first,
        lastName: last,
        email: _emailController.text.trim(),
        country: _selectedCountry?.value ?? '',
        age: int.tryParse(
          _ageController.text.trim(),
        ),
        dateOfBirth: _apiDate(_dobController.text.trim()),
        phone: mobile,
        gender: _gender,
        emergencyContactGuardianName: _guardianController.text.trim(),
        emergencyContactRelationship: _relationshipController.text.trim(),
        emergencyContactMobile: _emergencyMobileController.text.trim(),
        emergencyContactEmail: _emergencyEmailController.text.trim(),
        isActive: true,
        profileImagePath: _selectedProfileImage?.path,
        profileImageName: _selectedProfileImage?.name,
      );

      if (!mounted) return;

      snackBarService.showSuccess(
        message: res['message']?.toString() ??
            context.l10n.text('studentUpdatedSuccessfully'),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } on ApplicationApiException catch (e) {
      if (!mounted) return;
      _showValidationError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showValidationError(context.l10n.text('somethingWentWrong'));
    } finally {
      if (mounted) {
        updateView(() {
          _isSaving = false;
        });
      }
    }
  }

  Map<String, String> _validateProfileForm() {
    final AppLocalizations l10n = context.l10n;
    final Map<String, String> errors = <String, String>{};

    if (_fullNameController.text.trim().isEmpty) {
      errors['fullName'] = l10n.text('pleaseEnterFullName');
    }

    if (_dobController.text.trim().isEmpty) {
      errors['dateOfBirth'] = l10n.text('pleaseSelectDateOfBirth');
    }

    if ((_selectedCountry?.value ?? '').trim().isEmpty) {
      errors['country'] = l10n.text('pleaseSelectCountry');
    }

    if (_phoneController.text.trim().isEmpty) {
      errors['mobileNumber'] = l10n.text('pleaseEnterMobileNumber');
    }

    final String ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      errors['age'] = l10n.text('pleaseEnterAge');
    } else {
      final int? age = int.tryParse(ageText);
      if (age == null || age <= 0) {
        errors['age'] = l10n.text('pleaseEnterValidAge');
      }
    }

    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      errors['email'] = l10n.text('pleaseEnterEmailAddress');
    } else if (!_emailRegex.hasMatch(email)) {
      errors['email'] = l10n.text('pleaseEnterValidEmailAddress');
    }

    if (_guardianController.text.trim().isEmpty) {
      errors['guardianName'] = l10n.text('pleaseEnterGuardianName');
    }

    if (_relationshipController.text.trim().isEmpty) {
      errors['relationship'] = l10n.text('pleaseEnterRelationship');
    }

    if (_emergencyMobileController.text.trim().isEmpty) {
      errors['emergencyMobile'] =
          l10n.text('pleaseEnterEmergencyMobileNumber');
    }

    final String emergencyEmail = _emergencyEmailController.text.trim();
    if (emergencyEmail.isEmpty) {
      errors['emergencyEmail'] =
          l10n.text('pleaseEnterEmergencyEmailAddress');
    } else if (!_emailRegex.hasMatch(emergencyEmail)) {
      errors['emergencyEmail'] =
          l10n.text('pleaseEnterValidEmergencyEmailAddress');
    }

    return errors;
  }

  String? _firstValidationMessage(Map<String, String> errors) {
    if (errors.isEmpty) return null;

    const List<String> fieldOrder = <String>[
      'fullName',
      'dateOfBirth',
      'country',
      'mobileNumber',
      'age',
      'email',
      'guardianName',
      'relationship',
      'emergencyMobile',
      'emergencyEmail',
    ];

    for (final String fieldKey in fieldOrder) {
      final String? message = errors[fieldKey];
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return errors.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return buildCubitView((context) {
      if (_isLoading) {
        return const _ProfileShimmer();
      }

      final AppLocalizations l10n = context.l10n;

      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  ProfileAvatar(
                    imagePath: _profileImagePath,
                    selectedImagePath: _selectedProfileImage?.path,
                    onEdit: _pickProfileImage,
                  ),
                  const SizedBox(height: 22),
                  ProfileSectionTitle(
                    l10n.text('basicInformation'),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('fullName')),
                  ProfileInput(
                    controller: _fullNameController,
                    hint: l10n.text('firstMiddleLast'),
                    icon: Icons.person_outline_rounded,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('gender')),
                  GenderSelector(
                    selected: _gender,
                    onChanged: (v) {
                      updateView(() {
                        _gender = v;
                        _validationMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('dateOfBirth')),
                  ProfileInput(
                    controller: _dobController,
                    hint: l10n.text('dateFormatHint'),
                    icon: Icons.calendar_month_outlined,
                    readOnly: true,
                    onTap: _pickDob,
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('country')),
                  CountryDropdownField(
                    countries: _countries,
                    selectedCountry: _selectedCountry,
                    isLoading: _isLoadingCountries,
                    onCountryChanged: (CountryMaster? value) {
                      updateView(() {
                        _selectedCountry = value;
                        _validationMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('mobileNumber')),
                  MobileNumberField(
                    dialCode: _selectedCountry?.dialCode ?? '',
                    mobileController: _phoneController,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('age')),
                  ProfileInput(
                    controller: _ageController,
                    hint: l10n.text('age'),
                    icon: Icons.numbers_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('emailAddress')),
                  ProfileInput(
                    controller: _emailController,
                    hint: l10n.text('emailAddress'),
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 22),
                  ProfileSectionTitle(
                    l10n.text('emergencyContact'),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('guardianName')),
                  ProfileInput(
                    controller: _guardianController,
                    hint: l10n.text('guardianName'),
                    icon: Icons.person_outline_rounded,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('relationship')),
                  ProfileInput(
                    controller: _relationshipController,
                    hint: l10n.text('relationship'),
                    icon: Icons.people_outline_rounded,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('mobileNumber')),
                  ProfileInput(
                    controller: _emergencyMobileController,
                    hint: l10n.text('mobileNumber'),
                    icon: Icons.call_outlined,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 14),
                  ProfileLabel(l10n.text('emailAddress')),
                  ProfileInput(
                    controller: _emergencyEmailController,
                    hint: l10n.text('emailAddress'),
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _clearValidationError(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_validationMessage != null)
            _ProfileValidationBanner(message: _validationMessage!),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppPrimaryButton(
                label: l10n.text('save'),
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ProfileShimmer extends StatefulWidget {
  const _ProfileShimmer();

  @override
  State<_ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<_ProfileShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
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
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Center(
                child: _shimmerCircle(100),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                10,
                (index) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: _shineBox(
                    height: 45,
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
        borderRadius: BorderRadius.circular(14),
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
    final Color borderColor = hasError ? Colors.red.shade700 : AppColors.border;
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
          height: 50,
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
    final Color borderColor = hasError ? Colors.red.shade700 : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
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
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: context.l10n.text('enterMobileNumber'),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
    final bool hasSelectedImage = (selectedImagePath ?? '').trim().isNotEmpty;
    final String url = (imagePath ?? '').startsWith('http')
        ? imagePath!
        : '${ApiConfig.baseUrl}${imagePath ?? ''}';

    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(4),
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
              child: (imagePath ?? '').isEmpty && !hasSelectedImage
                  ? const Icon(
                      Icons.person,
                      size: 42,
                      color: AppColors.textMuted,
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
                decoration: const BoxDecoration(
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

class ProfileSectionTitle extends StatelessWidget {
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
      padding: const EdgeInsets.only(bottom: 8),
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
    this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            size: 18,
            color: AppColors.textMuted,
          ),
          hintText: hint,
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
            borderSide: const BorderSide(
              color: Color(0xFFD7D5D3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileValidationBanner extends StatelessWidget {
  const _ProfileValidationBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
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
          onChanged: (v) => onChanged(v ?? 'MALE'),
        ),
        Text(context.l10n.text('male')),
        const SizedBox(width: 14),
        Radio<String>(
          value: 'FEMALE',
          groupValue: selected,
          onChanged: (v) => onChanged(v ?? 'FEMALE'),
        ),
        Text(context.l10n.text('female')),
      ],
    );
  }
}
