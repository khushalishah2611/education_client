import 'package:education/core/app_localizations.dart';
import 'package:education/core/student_session.dart';
import 'package:education/models/country_master.dart';
import 'package:education/screens/home_screen.dart';
import 'package:education/services/application_api_service.dart';
import 'package:education/services/auth_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart' show AppPrimaryButton, AppSnackBarType, showAppSnackBar;
import 'side_menu_common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const SideMenuScaffold(title: 'My Profile', child: ProfileBody());
}

class ProfileBody extends StatefulWidget { const ProfileBody({super.key}); @override State<ProfileBody> createState() => _ProfileBodyState(); }

class _ProfileBodyState extends State<ProfileBody> {
  final ApplicationApiService _api = const ApplicationApiService();
  final AuthApiService _authApi = const AuthApiService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _emergencyMobileController = TextEditingController();
  final TextEditingController _emergencyEmailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoadingMeta = true;
  String _gender = 'FEMALE';
  String _studentUserId = '';
  String? _profileImagePath;
  PlatformFile? _selectedProfileImage;
  List<CountryMaster> _countries = const <CountryMaster>[];
  CountryMaster? _selectedCountry;

  @override
  void initState() { super.initState(); _initialize(); }

  Future<void> _initialize() async {
    await Future.wait<void>(<Future<void>>[_loadCountries(), _loadProfile()]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    for (final c in <TextEditingController>[_fullNameController, _emailController, _ageController, _dobController, _phoneController, _guardianController, _relationshipController, _emergencyMobileController, _emergencyEmailController]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _authApi.fetchCountries();
      _countries = countries;
      _selectedCountry = countries.isNotEmpty ? countries.first : null;
    } catch (_) {} finally { _isLoadingMeta = false; }
  }

  Future<void> _loadProfile() async {
    try {
      final String userId = await StudentSession.currentStudentUserId();
      final List<Map<String, dynamic>> students = await _api.fetchStudents();
      final Map<String, dynamic>? current = students.cast<Map<String, dynamic>?>().firstWhere((item) => (item?['userId'] ?? '').toString() == userId, orElse: () => students.isNotEmpty ? students.first : null);
      if (current == null) throw Exception('Student not found');
      _studentUserId = (current['userId'] ?? '').toString();
      final Map<String, dynamic> user = (current['user'] is Map<String, dynamic>) ? current['user'] as Map<String, dynamic> : <String, dynamic>{};
      final first = (current['firstName'] ?? '').toString().trim();
      final middle = (current['middleName'] ?? '').toString().trim();
      final last = (current['lastName'] ?? '').toString().trim();
      _fullNameController.text = [first, middle, last].where((e) => e.isNotEmpty).join(' ');
      _emailController.text = (user['email'] ?? '').toString();
      _ageController.text = (current['age'] ?? '').toString();
      _dobController.text = _displayDate((current['dateOfBirth'] ?? '').toString());
      _phoneController.text = _phoneWithoutCode((current['phone'] ?? '').toString());
      _guardianController.text = (current['emergencyContactGuardianName'] ?? '').toString();
      _relationshipController.text = (current['emergencyContactRelationship'] ?? '').toString();
      _emergencyMobileController.text = (current['emergencyContactMobile'] ?? '').toString();
      _emergencyEmailController.text = (current['emergencyContactEmail'] ?? '').toString();
      _gender = (current['gender'] ?? 'FEMALE').toString();
      _profileImagePath = (current['profileImagePath'] ?? '').toString();
      final country = (current['country'] ?? '').toString().trim();
      if (country.isNotEmpty && _countries.isNotEmpty) {
        _selectedCountry = _countries.where((c) => c.value == country || c.nameEn.toLowerCase() == country.toLowerCase()).cast<CountryMaster?>().firstWhere((e) => e != null, orElse: () => _selectedCountry);
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) showAppSnackBar(context, type: AppSnackBarType.error, message: e.toString());
    }
  }

  String _displayDate(String raw) {
    if (raw.isEmpty) return '';
    try { return DateFormat('dd-MM-yyyy').format(DateTime.parse(raw)); } catch (_) { return raw; }
  }
  String _apiDate(String raw) {
    if (raw.isEmpty) return '';
    for (final f in <String>['dd-MM-yyyy', 'yyyy-MM-dd']) {
      try { return DateFormat('yyyy-MM-dd').format(DateFormat(f).parseStrict(raw)); } catch (_) {}
    }
    return raw;
  }

  String _phoneWithoutCode(String full) {
    final dial = _selectedCountry?.dialCode ?? '';
    if (dial.isNotEmpty && full.startsWith(dial)) return full.substring(dial.length).trim();
    return full;
  }

  Future<void> _pickDob() async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    try { initialDate = DateFormat('dd-MM-yyyy').parseStrict(_dobController.text); } catch (_) {}
    final date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1950), lastDate: DateTime.now());
    if (date != null) setState(() => _dobController.text = DateFormat('dd-MM-yyyy').format(date));
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    setState(() => _selectedProfileImage = result.files.first);
  }

  Future<void> _saveProfile() async {
    if (_studentUserId.isEmpty) return;
    final parts = _fullNameController.text.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList(growable: false);
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.last : '';
    final mobile = '${_selectedCountry?.dialCode ?? ''}${_phoneController.text.trim()}';
    setState(() => _isSaving = true);
    try {
      final res = await _api.updateStudentProfile(
        studentUserId: _studentUserId,
        fullName: _fullNameController.text.trim(),
        firstName: first,
        lastName: last,
        email: _emailController.text.trim(),
        country: _selectedCountry?.value ?? '',
        age: int.tryParse(_ageController.text.trim()),
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
      showAppSnackBar(context, type: AppSnackBarType.success, message: res['message']?.toString() ?? 'Student updated successfully.');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (mounted) showAppSnackBar(context, type: AppSnackBarType.error, message: e.toString());
    } finally { if (mounted) setState(() => _isSaving = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _ProfileShimmer();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(children: [
        const SizedBox(height: 6),
        ProfileAvatar(imagePath: _profileImagePath, onEdit: _pickProfileImage),
        const SizedBox(height: 18),
        const ProfileSectionTitle('Basic Information'),
        const SizedBox(height: 10),
        const ProfileLabel('Full Name'),
        ProfileInput(controller: _fullNameController, hint: 'First Middle Last', icon: Icons.person_outline_rounded),
        const SizedBox(height: 12),
        const ProfileLabel('Gender'),
        GenderSelector(selected: _gender, onChanged: (v) => setState(() => _gender = v)),
        const SizedBox(height: 12),
        const ProfileLabel('Date of Birth'),
        ProfileInput(controller: _dobController, hint: 'DD-MM-YYYY', icon: Icons.calendar_month_outlined, readOnly: true, onTap: _pickDob),
        const SizedBox(height: 12),
        const ProfileLabel('Country & Mobile Number'),
        CountryMobileField(countries: _countries, selectedCountry: _selectedCountry, mobileController: _phoneController, isLoading: _isLoadingMeta, onCountryChanged: (v) => setState(() => _selectedCountry = v)),
        const SizedBox(height: 12),
        const ProfileLabel('Age'),
        ProfileInput(controller: _ageController, hint: 'Age', icon: Icons.numbers_outlined),
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
        const SizedBox(height: 22),
        AppPrimaryButton(label: context.l10n.text('save'), onPressed: _isSaving ? null : _saveProfile),
      ]),
    );
  }
}

class _ProfileShimmer extends StatefulWidget { const _ProfileShimmer(); @override State<_ProfileShimmer> createState() => _ProfileShimmerState(); }
class _ProfileShimmerState extends State<_ProfileShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (_, __) {
      return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: List<Widget>.generate(8, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _shineBox(height: i == 0 ? 90 : 52)))));
    });
  }
  Widget _shineBox({required double height}) => Container(height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment(-1 + 2 * _controller.value, 0), end: Alignment(1 + 2 * _controller.value, 0), colors: const [Color(0xFFECECEC), Color(0xFFF8F8F8), Color(0xFFECECEC)])));
}

class CountryMobileField extends StatelessWidget {
  const CountryMobileField({super.key, required this.countries, required this.selectedCountry, required this.mobileController, required this.isLoading, required this.onCountryChanged});
  final List<CountryMaster> countries; final CountryMaster? selectedCountry; final TextEditingController mobileController; final bool isLoading; final ValueChanged<CountryMaster?> onCountryChanged;
  @override Widget build(BuildContext context) {
    return Container(height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Row(children: [
      const SizedBox(width: 12),
      DropdownButtonHideUnderline(child: DropdownButton<CountryMaster>(value: selectedCountry, borderRadius: BorderRadius.circular(12), icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18), style: const TextStyle(fontSize: 16, color: AppColors.text), items: countries.map((c) => DropdownMenuItem<CountryMaster>(value: c, child: Text('${c.flagEmoji} ${c.dialCode}'))).toList(growable: false), onChanged: isLoading ? null : onCountryChanged)),
      const SizedBox(width: 10), Container(width: 1, height: 30, color: AppColors.border),
      Expanded(child: TextField(controller: mobileController, keyboardType: TextInputType.phone, decoration: const InputDecoration(contentPadding: EdgeInsets.all(5), hintText: 'Enter mobile number', border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none))),
      const SizedBox(width: 12),
    ]));
  }
}

class ProfileAvatar extends StatelessWidget { const ProfileAvatar({super.key, required this.onEdit, this.imagePath}); final VoidCallback onEdit; final String? imagePath;
  @override Widget build(BuildContext context) { final String url = (imagePath ?? '').startsWith('http') ? imagePath! : 'https://arab.vedx.cloud${imagePath ?? ''}'; return Center(child: Stack(children: [Container(width: 100, height: 100, padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accent, width: 3)), child: CircleAvatar(backgroundImage: (imagePath ?? '').isEmpty ? null : NetworkImage(url), child: (imagePath ?? '').isEmpty ? const Icon(Icons.person, color: AppColors.textMuted) : null)), Positioned(bottom: 4, right: 0, child: InkWell(onTap: onEdit, child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.edit_rounded, size: 15, color: AppColors.accent))))])); }
}
class ProfileSectionTitle extends StatelessWidget { const ProfileSectionTitle(this.title, {super.key}); final String title; @override Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800)); }
class ProfileLabel extends StatelessWidget { const ProfileLabel(this.text, {super.key}); final String text; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))); }
class ProfileInput extends StatelessWidget {
  const ProfileInput({super.key, required this.controller, required this.hint, required this.icon, this.readOnly = false, this.onTap});
  final TextEditingController controller; final String hint; final IconData icon; final bool readOnly; final VoidCallback? onTap;
  @override Widget build(BuildContext context) => TextField(controller: controller, readOnly: readOnly, onTap: onTap, decoration: InputDecoration(prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted), hintText: hint, filled: true, fillColor: const Color(0xFFF4F4F4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD7D5D3))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD7D5D3)))));
}
class GenderSelector extends StatelessWidget { const GenderSelector({super.key, required this.selected, required this.onChanged}); final String selected; final ValueChanged<String> onChanged;
  @override Widget build(BuildContext context) => Row(children: [Radio<String>(value: 'MALE', groupValue: selected, onChanged: (v) => onChanged(v ?? 'MALE')), const Text('Male'), Radio<String>(value: 'FEMALE', groupValue: selected, onChanged: (v) => onChanged(v ?? 'FEMALE')), const Text('Female')]);
}
