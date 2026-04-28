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

      /// ✅ Force Oman if +968
      _selectedCountry = _resolveAutoCountry(countries) ?? _selectedCountry;

      /// ✅ Apply university filter
      universities = _filterUniversities(universitiesResponse);

      trackOptions = tracks
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !_isScientificAndLiterary(e))
          .toList();

      academicOptions = academics;

      /// 🔥 COUNTRY LIST FIX (MAIN PART)
      final isOmanUser =
          (_loginDialCode ?? '').trim() == '+968' ||
          (_selectedCountry ?? '').toLowerCase() == 'oman';

      countryOptions = countries
          .where((c) {
            final name = (c.nameEn.isNotEmpty ? c.nameEn : c.value)
                .toLowerCase()
                .trim();

            if (isOmanUser) {
              return name.contains('oman'); // only Oman
            }

            return name.isNotEmpty;
          })
          .map(
            (c) => CountryOption(
              name: c.nameEn.isNotEmpty ? c.nameEn : c.value,
              flagEmoji: c.flagEmoji,
              flagImageUrl: _resolveCountryFlag(c),
              dialCode: c.dialCode,
            ),
          )
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
      if (u.accredited != true) return false;
      if ((u.status ?? '').trim().toLowerCase() != 'active') return false;
      final effectiveCountry = (_loginDialCode ?? '').trim() == '+968'
          ? 'Oman'
          : _selectedCountry;

      if (effectiveCountry != null &&
          effectiveCountry.isNotEmpty &&
          (u.country ?? '').toLowerCase() != effectiveCountry.toLowerCase()) {
        return false;
      }

      if (_selectedAcademic != null && _selectedAcademic!.isNotEmpty) {
        final selectedAcademic = _normalizeValue(_selectedAcademic);
        final match =
            u.academicList?.any((a) {
              final academicValues = _splitCsvValues(a.academicname);
              return academicValues.contains(selectedAcademic);
            }) ??
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

  bool _matchesTrack(AdminUniversity u) {
    if (_selectedTrack == null || _selectedTrack!.isEmpty) return true;

    final tracks = _trackTypes(u);
    return tracks.contains(_normalizeValue(_selectedTrack));
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
      return 'Oman';
    }
    return null;
  }

  Set<String> _trackTypes(AdminUniversity u) {
    final tracks = <String>{};

    final topLevelTrack = _normalizeValue(u.track);
    if (topLevelTrack.isNotEmpty) {
      tracks.add(topLevelTrack);
    }

    for (final link in u.programLinks ?? const <ProgramLinks>[]) {
      final value = _normalizeValue(link.program?.track);
      if (value.isNotEmpty) {
        tracks.add(value);
      }
    }

    for (final academic in u.academicList ?? const <AcademicList>[]) {
      final value = _normalizeValue(academic.program?.track);
      if (value.isNotEmpty) {
        tracks.add(value);
      }
    }

    return tracks;
  }

  double? _minimumAdmissionRate(AdminUniversity u) {
    final rates = <double>[];

    rates.addAll(
      (u.programLinks ?? const <ProgramLinks>[])
          .map((e) => e.program?.minAdmissionRate?.toDouble())
          .whereType<double>(),
    );

    rates.addAll(
      (u.academicList ?? const <AcademicList>[])
          .map((e) => e.program?.minAdmissionRate?.toDouble())
          .whereType<double>(),
    );

    if (rates.isEmpty) return null;

    return rates.reduce((a, b) => a < b ? a : b);
  }

  bool _isScientificAndLiterary(String v) {
    return v.replaceAll(' ', '').toUpperCase() == 'SCIENTIFICANDLITERARY';
  }

  List<String> _splitCsvValues(String? csv) {
    if (csv == null || csv.trim().isEmpty) return const [];
    return csv
        .split(',')
        .map(_normalizeValue)
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _normalizeValue(String? value) {
    return (value ?? '').trim().toUpperCase();
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
