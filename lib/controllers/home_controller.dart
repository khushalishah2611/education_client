import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_university.dart';
import '../models/banner_item.dart';
import '../models/country_master.dart';
import '../models/country_option.dart';
import '../services/home_api_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required HomeApiService homeApiService,
    String? initialCountry,
    String? initialDialCode,
  }) : _homeApiService = homeApiService {
    _selectedCountry = initialCountry?.trim().isNotEmpty == true
        ? initialCountry!.trim()
        : null;
    _loginDialCode = initialDialCode?.trim().isNotEmpty == true
        ? initialDialCode!.trim()
        : null;
  }

  final HomeApiService _homeApiService;

  bool isLoadingUniversities = true;
  bool isLoadingBanners = true;

  List<BannerItem> banners = [];
  List<AdminUniversity> universities = [];

  List<String> trackOptions = [];
  List<String> academicOptions = [];
  List<String> currencyOptions = [];
  List<CountryOption> countryOptions = [];

  String? _selectedCountry;
  String? _selectedAcademic;
  String? _selectedTrack;
  String? _loginDialCode;

  final TextEditingController resultController = TextEditingController();

  String? get selectedCountry => _selectedCountry;
  String? get selectedAcademic => _selectedAcademic;
  String? get selectedTrack => _selectedTrack;

  Future<void> initialize() async {
    await _loadSessionDefaults();
    await Future.wait([loadBanners(), loadUniversities()]);
  }

  Future<void> refreshHomeData() async {
    await Future.wait([loadBanners(), loadUniversities()]);
  }

  Future<void> loadBanners() async {
    isLoadingBanners = true;
    notifyListeners();

    try {
      banners = await _homeApiService.fetchBanners(page: 1, limit: 10);
    } catch (_) {
      banners = [];
    }

    isLoadingBanners = false;
    notifyListeners();
  }

  Future<void> loadUniversities() async {
    isLoadingUniversities = true;
    notifyListeners();

    try {
      final responses = await Future.wait<Object>([
        _homeApiService
            .fetchUniversities(
              country: _selectedCountry,
              academic: _selectedAcademic,
              track: _selectedTrack,
              search: resultController.text,
            )
            .catchError((_) => <AdminUniversity>[]),
        _homeApiService.fetchTrackMasters().catchError((_) => <String>[]),
        _homeApiService.fetchAcademicMasters().catchError((_) => <String>[]),
        _homeApiService.fetchCountries().catchError((_) => <CountryMaster>[]),
      ]);

      final universitiesResponse = responses[0] as List<AdminUniversity>;
      final tracks = responses[1] as List<String>;
      final academics = responses[2] as List<String>;
      final countries = responses[3] as List<CountryMaster>;

      _selectedCountry ??= _resolveAutoCountry(countries);

      universities = _filterUniversities(universitiesResponse);

      trackOptions = tracks
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !_isScientificAndLiterary(e))
          .toList();

      academicOptions = academics;

      countryOptions = countries
          .map(
            (c) => CountryOption(
              name: c.nameEn.isNotEmpty ? c.nameEn : c.value,
              flagEmoji: c.flagEmoji,
              flagImageUrl: _resolveCountryFlag(c),
              dialCode: c.dialCode,
            ),
          )
          .where((e) => e.name.trim().isNotEmpty)
          .toList();
    } catch (_) {
      universities = [];
      trackOptions = [];
      academicOptions = [];
      countryOptions = [];
    }

    isLoadingUniversities = false;
    notifyListeners();
  }

  Future<void> applyFilters() async {
    universities = _filterUniversities(universities);
    notifyListeners();
  }

  void updateCountry(String? value) {
    _selectedCountry = value;
    notifyListeners();
  }

  void updateAcademic(String? value) {
    _selectedAcademic = value;
    notifyListeners();
  }

  void updateTrack(String? value) {
    _selectedTrack = value;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCountry = null;
    _selectedAcademic = null;
    _selectedTrack = null;
    resultController.clear();
    notifyListeners();
    loadUniversities();
  }

  List<AdminUniversity> _filterUniversities(List<AdminUniversity> source) {
    final enteredResult = double.tryParse(resultController.text.trim());

    return source.where((u) {
      if (!_isEligibleOmanUniversity(u)) {
        return false;
      }

      if (_selectedCountry != null &&
          _selectedCountry!.isNotEmpty &&
          (u.country ?? '').toLowerCase() != _selectedCountry!.toLowerCase()) {
        return false;
      }

      if (_selectedAcademic != null && _selectedAcademic!.isNotEmpty) {
        final match =
            u.academicList?.any(
              (a) =>
                  (a.academicname ?? '').toLowerCase() ==
                  _selectedAcademic!.toLowerCase(),
            ) ??
            false;
        if (!match) return false;
      }

      if (!_matchesTrack(u)) return false;

      if (enteredResult != null) {
        final minRate = _minimumAdmissionRate(u);
        if (minRate != null && enteredResult < minRate) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _isEligibleOmanUniversity(AdminUniversity u) {
    final bool isAccredited = u.accredited == true;
    final String normalizedCountry = (u.country ?? '').trim().toLowerCase();
    final String normalizedMobile = (u.mobile ?? '').trim();
    final bool isOman =
        normalizedCountry == 'oman' ||
        normalizedCountry == 'om' ||
        normalizedMobile.startsWith('+968');

    return isAccredited && isOman;
  }

  bool _matchesTrack(AdminUniversity u) {
    if (_selectedTrack == null || _selectedTrack!.isEmpty) return true;

    final tracks = _trackTypes(u);
    return tracks.contains(_selectedTrack!.toUpperCase());
  }

  Future<void> _loadSessionDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedCountry ??= prefs.getString('loginCountry');
      _loginDialCode ??= prefs.getString('loginDialCode');
    } catch (_) {}
  }

  String? _resolveAutoCountry(List<CountryMaster> countries) {
    if ((_loginDialCode ?? '').trim() == '+968') {
      final match = countries.where((c) => c.dialCode.trim() == '+968');

      if (match.isNotEmpty) {
        final country = match.first;
        return country.nameEn.trim().isNotEmpty
            ? country.nameEn.trim()
            : country.value.trim();
      }

      // fallback if API doesn't return Oman
      return 'Oman';
    }

    return null;
  }

  Set<String> _trackTypes(AdminUniversity u) {
    return u.programLinks
            ?.map((e) => e.program?.track?.toUpperCase() ?? '')
            .where((e) => e.isNotEmpty)
            .toSet() ??
        {};
  }

  double? _minimumAdmissionRate(AdminUniversity u) {
    return u.programLinks
        ?.map((e) => e.program?.minAdmissionRate?.toDouble())
        .whereType<double>()
        .fold<double?>(
          null,
          (min, val) => min == null || val < min ? val : min,
        );
  }

  bool _isScientificAndLiterary(String v) {
    return v.replaceAll(' ', '').toUpperCase() == 'SCIENTIFICANDLITERARY';
  }

  String _resolveCountryFlag(CountryMaster c) {
    if (c.value.startsWith('http')) return c.value;
    final code = c.value.toLowerCase();
    return code.length == 2 ? 'https://flagcdn.com/w40/$code.png' : '';
  }

  @override
  void dispose() {
    resultController.dispose();
    super.dispose();
  }
}
