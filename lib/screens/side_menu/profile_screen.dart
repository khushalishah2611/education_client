import 'package:education/core/app_localizations.dart';
import 'package:education/core/student_session.dart';
import 'package:education/screens/home_screen.dart';
import 'package:education/services/application_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart' show AppPrimaryButton, showAppSnackBar, AppSnackBarType;
import 'side_menu_common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SideMenuScaffold(title: 'My Profile', child: ProfileBody());
  }
}

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final ApplicationApiService _api = const ApplicationApiService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _emergencyMobileController = TextEditingController();
  final TextEditingController _emergencyEmailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isActive = true;
  String _gender = 'FEMALE';
  String _studentUserId = '';
  String? _profileImagePath;
  PlatformFile? _selectedProfileImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in <TextEditingController>[
      _fullNameController,
      _firstNameController,
      _lastNameController,
      _emailController,
      _countryController,
      _ageController,
      _dobController,
      _phoneController,
      _guardianController,
      _relationshipController,
      _emergencyMobileController,
      _emergencyEmailController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final String userId = await StudentSession.currentStudentUserId();
      final List<Map<String, dynamic>> students = await _api.fetchStudents();
      final Map<String, dynamic>? current = students.cast<Map<String, dynamic>?>().firstWhere(
            (item) => (item?['userId'] ?? '').toString() == userId,
            orElse: () => students.isNotEmpty ? students.first : null,
          );

      if (current == null) {
        throw Exception('Student not found');
      }

      _studentUserId = (current['userId'] ?? '').toString();
      final Map<String, dynamic> user = (current['user'] is Map<String, dynamic>)
          ? current['user'] as Map<String, dynamic>
          : <String, dynamic>{};

      _firstNameController.text = (current['firstName'] ?? '').toString();
      _lastNameController.text = (current['lastName'] ?? '').toString();
      _fullNameController.text =
          '${_firstNameController.text} ${_lastNameController.text}'.trim();
      _emailController.text = (user['email'] ?? '').toString();
      _countryController.text = (current['country'] ?? '').toString();
      _ageController.text = (current['age'] ?? '').toString();
      _dobController.text = (current['dateOfBirth'] ?? '').toString();
      _phoneController.text = (current['phone'] ?? '').toString();
      _guardianController.text =
          (current['emergencyContactGuardianName'] ?? '').toString();
      _relationshipController.text =
          (current['emergencyContactRelationship'] ?? '').toString();
      _emergencyMobileController.text =
          (current['emergencyContactMobile'] ?? '').toString();
      _emergencyEmailController.text =
          (current['emergencyContactEmail'] ?? '').toString();
      _gender = (current['gender'] ?? 'FEMALE').toString();
      _isActive = (user['isActive'] ?? true) == true;
      _profileImagePath = (current['profileImagePath'] ?? '').toString();

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, type: AppSnackBarType.error, message: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _selectedProfileImage = result.files.first;
    });
  }

  Future<void> _saveProfile() async {
    if (_studentUserId.isEmpty) {
      showAppSnackBar(context, type: AppSnackBarType.error, message: 'studentUserId not found');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> res = await _api.updateStudentProfile(
        studentUserId: _studentUserId,
        fullName: _fullNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        country: _countryController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        dateOfBirth: _dobController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _gender,
        emergencyContactGuardianName: _guardianController.text.trim(),
        emergencyContactRelationship: _relationshipController.text.trim(),
        emergencyContactMobile: _emergencyMobileController.text.trim(),
        emergencyContactEmail: _emergencyEmailController.text.trim(),
        isActive: _isActive,
        profileImagePath: _selectedProfileImage?.path,
        profileImageName: _selectedProfileImage?.name,
      );
      if (!mounted) return;
      showAppSnackBar(context, type: AppSnackBarType.success, message: res['message']?.toString() ?? 'Student updated successfully.');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, type: AppSnackBarType.error, message: e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const SizedBox(height: 6),
          ProfileAvatar(imagePath: _profileImagePath, onEdit: _pickProfileImage),
          const SizedBox(height: 18),
          const ProfileSectionTitle('Basic Information'),
          const SizedBox(height: 10),
          const ProfileLabel('Full Name'),
          ProfileInput(controller: _fullNameController, hint: 'Full Name', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const ProfileLabel('First Name'),
          ProfileInput(controller: _firstNameController, hint: 'First Name', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const ProfileLabel('Last Name'),
          ProfileInput(controller: _lastNameController, hint: 'Last Name', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const ProfileLabel('Gender'),
          GenderSelector(selected: _gender, onChanged: (v) => setState(() => _gender = v)),
          const SizedBox(height: 12),
          const ProfileLabel('Date of Birth'),
          ProfileInput(controller: _dobController, hint: 'YYYY-MM-DD', icon: Icons.calendar_month_outlined),
          const SizedBox(height: 12),
          const ProfileLabel('Country'),
          ProfileInput(controller: _countryController, hint: 'Country', icon: Icons.public_outlined),
          const SizedBox(height: 12),
          const ProfileLabel('Age'),
          ProfileInput(controller: _ageController, hint: 'Age', icon: Icons.numbers_outlined),
          const SizedBox(height: 12),
          const ProfileLabel('Mobile Number'),
          ProfileInput(controller: _phoneController, hint: 'Mobile Number', icon: Icons.call_outlined),
          const SizedBox(height: 12),
          const ProfileLabel('Email Address'),
          ProfileInput(controller: _emailController, hint: 'Email Address', icon: Icons.mail_outline_rounded),
          const SizedBox(height: 18),
          const ProfileSectionTitle('Emergency Contact'),
          const SizedBox(height: 10),
          const ProfileLabel('Guardian Name'),
          ProfileInput(controller: _guardianController, hint: 'Guardian Name', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const ProfileLabel('Relationship'),
          ProfileInput(controller: _relationshipController, hint: 'Relationship', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const ProfileLabel('Mobile Number'),
          ProfileInput(controller: _emergencyMobileController, hint: 'Mobile Number', icon: Icons.call_outlined),
          const SizedBox(height: 12),
          const ProfileLabel('Email Address'),
          ProfileInput(controller: _emergencyEmailController, hint: 'Email Address', icon: Icons.mail_outline_rounded),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Active Status'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: 22),
          AppPrimaryButton(label: context.l10n.text('save'), onPressed: _isSaving ? null : _saveProfile),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.onEdit, this.imagePath});

  final VoidCallback onEdit;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final String url = (imagePath ?? '').startsWith('http')
        ? imagePath!
        : 'https://arab.vedx.cloud${imagePath ?? ''}';
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accent, width: 3)),
            child: CircleAvatar(
              backgroundImage: (imagePath ?? '').isEmpty ? null : NetworkImage(url),
              child: (imagePath ?? '').isEmpty ? const Icon(Icons.person, color: AppColors.textMuted) : null,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 0,
            child: InkWell(
              onTap: onEdit,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.edit_rounded, size: 15, color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget { const ProfileSectionTitle(this.title, {super.key}); final String title; @override Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800)); }
class ProfileLabel extends StatelessWidget { const ProfileLabel(this.text, {super.key}); final String text; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))); }

class ProfileInput extends StatelessWidget {
  const ProfileInput({super.key, required this.controller, required this.hint, required this.icon});
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD7D5D3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD7D5D3))),
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key, required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Radio<String>(value: 'MALE', groupValue: selected, onChanged: (v) => onChanged(v ?? 'MALE')),
      const Text('Male'),
      Radio<String>(value: 'FEMALE', groupValue: selected, onChanged: (v) => onChanged(v ?? 'FEMALE')),
      const Text('Female'),
    ]);
  }
}
