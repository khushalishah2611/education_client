import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';
import '../models/admin_university.dart';
import '../models/app_models.dart';
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
  List<BannerItem> banners = const [];
  List<AdminUniversity> allUniversities = const [];
  List<AdminUniversity> universities = const [];
  List<String> trackOptions = const [];
  List<String> academicOptions = const [];
  List<String> currencyOptions = const [];
  List<CountryOption> countryOptions = const [];
  String? _selectedCountry;
  String? _selectedAcademic;
  String? _selectedTrack;
  String? _loginDialCode;
  bool _skipAutoCountrySelection = false;
  final TextEditingController resultController = TextEditingController();

  String? get selectedCountry => _selectedCountry;
  String? get selectedAcademic => _selectedAcademic;
  String? get selectedTrack => _selectedTrack;

  Future<void> initialize() async {
    await _loadSessionDefaults();
    await Future.wait<void>([loadBanners(), loadUniversities()]);
  }

  Future<void> refreshHomeData() async {
    await Future.wait<void>([loadBanners(), loadUniversities()]);
  }

  Future<void> loadBanners() async {
    isLoadingBanners = true;
    notifyListeners();
    try {
      banners = await _homeApiService.fetchBanners(page: 1, limit: 10);
    } catch (_) {
      banners = const [];
    } finally {
      isLoadingBanners = false;
      notifyListeners();
    }
  }

  Future<void> loadUniversities() async {
    isLoadingUniversities = true;
    notifyListeners();
    try {
      final responses = await Future.wait<dynamic>([
        _homeApiService.fetchUniversities(
          country: _selectedCountry,
          academic: _selectedAcademic,
          track: _selectedTrack,
          search: resultController.text,
        ),
        _homeApiService.fetchTrackMasters(),
        _homeApiService.fetchAcademicMasters(),
        _homeApiService.fetchCountries(),
      ]);
      final universitiesResponse = responses[0] as List<AdminUniversity>;
      final tracks = responses[1] as List<String>;
      final academics = responses[2] as List<String>;
      final countries = responses[3] as List<CountryMaster>;

      _selectedCountry = _resolveAutoCountry(countries);
      allUniversities = universitiesResponse;
      universities = _filterUniversities(
        universitiesResponse,
      ).map(_toUniversityData).toList(growable: false);
      trackOptions = tracks
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty && !_isScientificAndLiterary(item))
          .toList(growable: false);
      final allCountryOptions = countries
          .map(
            (item) => CountryOption(
              name: item.nameEn.isNotEmpty ? item.nameEn : item.value,
              flagEmoji: item.flagEmoji,
              flagImageUrl: _resolveCountryFlag(item),
              dialCode: item.dialCode,
            ),
          )
          .where((item) => item.name.trim().isNotEmpty)
          .toList(growable: false);
      academicOptions = academics;
      final shouldRestrictToOman = _shouldRestrictToOmanCountryList(
        allCountryOptions,
      );
      countryOptions = shouldRestrictToOman
          ? allCountryOptions
              .where((item) => item.dialCode.trim() == '+968')
              .toList(growable: false)
          : allCountryOptions;
      if (shouldRestrictToOman &&
          countryOptions.isNotEmpty &&
          !countryOptions.any(
            (item) =>
                item.name.trim().toLowerCase() ==
                (_selectedCountry ?? '').trim().toLowerCase(),
          )) {
        _selectedCountry = countryOptions.first.name;
      }
      currencyOptions = const [];
    } catch (_) {
      allUniversities = const [];
      universities = const [];
      trackOptions = const [];
      academicOptions = const [];
      currencyOptions = const [];
      countryOptions = const [];
    } finally {
      isLoadingUniversities = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters() async {
    universities = _filterUniversities(
      allUniversities,
    ).map(_toUniversityData).toList(growable: false);
    notifyListeners();
    await loadUniversities();
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
    final isOmanLogin = (_loginDialCode ?? '').trim() == '+968';
    _skipAutoCountrySelection = !isOmanLogin;
    _selectedCountry = isOmanLogin ? resolveMandatoryOmanCountryName() : null;
    _selectedAcademic = null;
    _selectedTrack = null;
    resultController.clear();
    notifyListeners();
    loadUniversities();
  }

  String resolveMandatoryOmanCountryName() {
    for (final country in countryOptions) {
      if (country.dialCode.trim() == '+968') {
        return country.name;
      }
    }
    return 'Oman';
  }

  List<AdminUniversity> _filterUniversities(List<AdminUniversity> source) {
    final enteredResult = double.tryParse(resultController.text.trim());
    return source
        .where((university) {
          final countryMatch =
              _selectedCountry == null ||
              _selectedCountry!.trim().isEmpty ||
              university.country?.toLowerCase() ==
                  _selectedCountry!.trim().toLowerCase();
          if (!countryMatch) {
            return false;
          }

          if (_shouldRestrictToAccredited() && !(university.accredited ?? false)) {
            return false;
          }

          if (_selectedAcademic != null && _selectedAcademic!.trim().isNotEmpty) {
            final academicName = _selectedAcademic!.trim().toLowerCase();
            AcademicList? requirement;
            for (final item in university ?? []) {
              if (item.academicName.toLowerCase() == academicName) {
                requirement = item;
                break;
              }
            }
            if (requirement == null) {
              return false;
            }
            if (enteredResult != null && enteredResult > requirement.percentage) {
              return false;
            }
          }

          if (!_matchesTrack(university)) {
            return false;
          }

          return true;
        })
        .toList(growable: false);
  }

  bool _matchesTrack(AdminUniversity university) {
    final selectedTrack = _selectedTrack?.trim().toUpperCase() ?? '';
    final trackTypes = _trackTypes(university);
    if (selectedTrack.isEmpty) return true;
    if (selectedTrack == 'SCIENTIFIC') {
      return true;
    }
    if (trackTypes.isEmpty) {
      return true;
    }
    if (selectedTrack == 'LITERARY') {
      return trackTypes.contains('LITERARY') ||
          trackTypes.contains('SCIENTIFIC_AND_LITERARY');
    }
    if (selectedTrack == 'SCIENTIFIC_AND_LITERARY') {
      return trackTypes.contains('SCIENTIFIC_AND_LITERARY');
    }
    return true;
  }

  bool _shouldRestrictToAccredited() {
    final selected = _selectedCountry?.trim().toLowerCase() ?? '';
    if (selected == 'oman') return true;
    if (_loginDialCode?.trim() == '+968') return true;
    if (selected.isEmpty) return false;
    CountryOption? option;
    for (final item in countryOptions) {
      if (item.name.trim().toLowerCase() == selected) {
        option = item;
        break;
      }
    }
    if (option == null) return false;
    return option.dialCode.trim() == '+968';
  }

  bool _shouldRestrictToOmanCountryList(List<CountryOption> options) {
    if ((_loginDialCode ?? '').trim() == '+968') return true;
    final selected = _selectedCountry?.trim().toLowerCase() ?? '';
    if (selected == 'oman') return true;
    if (selected.isEmpty) return false;
    for (final item in options) {
      if (item.name.trim().toLowerCase() == selected) {
        return item.dialCode.trim() == '+968';
      }
    }
    return false;
  }

  bool _isScientificAndLiterary(String value) {
    final normalized =
        value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    return normalized == 'SCIENTIFICANDLITERARY';
  }

  Future<void> _loadSessionDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCountry = prefs.getString('loginCountry')?.trim() ?? '';
      final storedDialCode = prefs.getString('loginDialCode')?.trim() ?? '';
      if ((_selectedCountry ?? '').trim().isEmpty && storedCountry.isNotEmpty) {
        _selectedCountry = storedCountry;
      }
      if ((_loginDialCode ?? '').trim().isEmpty && storedDialCode.isNotEmpty) {
        _loginDialCode = storedDialCode;
      }
    } catch (_) {
      // Ignore shared preferences read failures.
    }
  }

  String? _resolveAutoCountry(List<CountryMaster> countries) {
    if (_skipAutoCountrySelection) {
      _skipAutoCountrySelection = false;
      return null;
    }
    final selected = _selectedCountry?.trim() ?? '';
    if (selected.isNotEmpty) {
      return selected;
    }
    if ((_loginDialCode ?? '').trim() == '+968') {
      for (final country in countries) {
        if (country.dialCode.trim() == '+968') {
          return country.nameEn.trim().isNotEmpty
              ? country.nameEn.trim()
              : country.value.trim();
        }
      }
      return 'Oman';
    }
    return null;
  }

  AdminUniversity _toUniversityData(AdminUniversity university) {
    final country = university.country!.isNotEmpty
        ? university.country
        : university.state;
    final location = [
      university.city,
      country,
    ].where((item) => item!.trim().isNotEmpty).join(', ');
    return AdminUniversity(
      name: university.name,
      country: location.isEmpty ? 'N/A' : location,
      logoPath: _toAbsoluteUrl(university.logoPath ?? ""),
    );
  }

  Set<String> _trackTypes(AdminUniversity university) {
    final values = <String>{};
    void add(String raw) {
      final normalized = raw.trim().toUpperCase();
      if (normalized.isNotEmpty) values.add(normalized);
    }

    add(university.track);
    for (final link in university.programLinks) {
      final program = link.program;
      if (program == null) continue;
      add(program.track);
      for (final detail in program.courseDetails) {
        add(detail.track);
      }
    }
    for (final course in university.courses) {
      add(course.track);
      final program = course.program;
      if (program == null) continue;
      add(program.track);
      for (final detail in program.courseDetails) {
        add(detail.track);
      }
    }
    return values;
  }

  String _shortCode(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'UNI';
    if (parts.length == 1) {
      final end = parts.first.length > 3 ? 3 : parts.first.length;
      return parts.first.substring(0, end).toUpperCase();
    }
    return parts.take(3).map((part) => part[0].toUpperCase()).join();
  }

  Color _colorFromSeed(String seed) {
    final hash = seed.hashCode.abs();
    final colors = <Color>[
      const Color(0xFF2E5FA7),
      const Color(0xFFBD1F2D),
      const Color(0xFF1A8A52),
      const Color(0xFF8351C9),
      const Color(0xFF00838F),
    ];
    return colors[hash % colors.length];
  }

  String _resolveCountryFlag(CountryMaster country) {
    if (country.value.startsWith('http://') ||
        country.value.startsWith('https://')) {
      return country.value;
    }
    final code = country.value.trim().toLowerCase();
    if (code.length == 2) {
      return 'https://flagcdn.com/w40/$code.png';
    }
    return '';
  }

  String _toAbsoluteUrl(String pathOrUrl) {
    if (pathOrUrl.isEmpty) return '';
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }
    final normalized = pathOrUrl.startsWith('/') ? pathOrUrl : '/$pathOrUrl';
    return '${ApiConfig.baseUrl}$normalized';
  }

  @override
  void dispose() {
    resultController.dispose();
    super.dispose();
  }
}
