import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_university.dart';
import '../models/banner_item.dart';
import '../models/country_master.dart';
import '../models/country_option.dart';
import '../services/home_api_service.dart';
import '../core/bloc/app_cubit.dart';

class HomeController extends AppCubit<int> {
  HomeController({
    required HomeApiService homeApiService,
    String? initialCountry,
    String? initialDialCode,
  })  : _homeApiService = homeApiService,
        super(0) {
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
  List<AcademicMasterOption> academicOptions = [];
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

  void refreshView() {
    emit(state + 1);
  }

  Future<void> initialize() async {
    await _loadSessionDefaults();

    await Future.wait([
      loadBanners(),
      loadUniversities(),
    ]);
  }

  Future<void> refreshHomeData() async {
    await Future.wait([
      loadBanners(),
      loadUniversities(),
    ]);
  }

  Future<void> loadBanners() async {
    isLoadingBanners = true;
    refreshView();

    try {
      banners = await _homeApiService.fetchBanners(
        page: 1,
        limit: 10,
      );
    } catch (_) {
      banners = [];
    }

    isLoadingBanners = false;
    refreshView();
  }

  Future<void> loadUniversities() async {
    isLoadingUniversities = true;
    refreshView();

    try {
      final responses = await Future.wait<Object>([
        _homeApiService
            .fetchUniversities(
              country: _selectedCountry,
              academic: _selectedAcademic,
              track: _selectedTrack,
              search: resultController.text.trim(),
            )
            .catchError((_) => <AdminUniversity>[]),
        _homeApiService.fetchTrackMasters().catchError((_) => <String>[]),
        _homeApiService
            .fetchAcademicMasters()
            .catchError((_) => <AcademicMasterOption>[]),
        _homeApiService.fetchCountries().catchError((_) => <CountryMaster>[]),
      ]);

      final universitiesResponse = responses[0] as List<AdminUniversity>;

      final tracks = responses[1] as List<String>;

      final academics = responses[2] as List<AcademicMasterOption>;

      final countries = responses[3] as List<CountryMaster>;

      /// Auto Oman selection
      _selectedCountry = _resolveAutoCountry(countries) ?? _selectedCountry;

      /// Apply local filters
      universities = _filterUniversities(universitiesResponse);

      /// Track options
      trackOptions = tracks
          .map((e) => e.trim())
          .where(
            (e) => e.isNotEmpty && !_isScientificAndLiterary(e),
          )
          .toList();

      /// Academic options keep English values for filtering/API requests while
      /// exposing Arabic labels to the UI when Arabic is selected.
      academicOptions = academics;

      /// Country options
      countryOptions = countries
          .where((c) {
            final name = (c.nameEn.isNotEmpty ? c.nameEn : c.value).trim();

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
    } catch (e) {
      debugPrint("LOAD UNIVERSITY ERROR: $e");

      universities = [];
      trackOptions = [];
      academicOptions = [];
      countryOptions = [];
    }

    isLoadingUniversities = false;
    refreshView();
  }

  /// MAIN FILTER APPLY
  Future<void> applyFilters() async {
    await loadUniversities();
  }

  void updateCountry(String? value) {
    _selectedCountry = value?.trim();
    refreshView();
  }

  void updateAcademic(String? value) {
    _selectedAcademic = value?.trim();
    refreshView();
  }

  void updateTrack(String? value) {
    _selectedTrack = value?.trim();
    refreshView();
  }

  void resetFilters() {
    _selectedCountry = null;
    _selectedAcademic = null;
    _selectedTrack = null;

    resultController.clear();

    refreshView();

    loadUniversities();
  }

  List<AdminUniversity> _filterUniversities(
    List<AdminUniversity> source,
  ) {
    final enteredResult = double.tryParse(resultController.text.trim());

    return source.where((u) {
      /// Accredited check
      if (u.accredited != true) {
        return false;
      }

      /// Active status check
      if ((u.status ?? '').trim().toLowerCase() != 'active') {
        return false;
      }

      /// Country filter
      final effectiveCountry = _selectedCountry;

      if (effectiveCountry != null &&
          effectiveCountry.isNotEmpty &&
          _normalizeValue(u.country) != _normalizeValue(effectiveCountry)) {
        return false;
      }

      /// Academic filter
      if (!_matchesAcademic(u)) {
        return false;
      }

      /// Track filter
      if (!_matchesTrack(u)) {
        return false;
      }

      /// Result filter
      if (enteredResult != null) {
        final minRate = _minimumAdmissionRate(u);

        if (minRate != null && enteredResult < minRate) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _matchesAcademic(AdminUniversity u) {
    if (_selectedAcademic == null || _selectedAcademic!.isEmpty) {
      return true;
    }

    final selectedAcademic = _normalizeValue(_selectedAcademic);

    return _academicValues(u).contains(selectedAcademic);
  }

  Set<String> _academicValues(AdminUniversity u) {
    final values = <String>{};

    void addValue(String? value) {
      values.addAll(_splitCsvValues(value));
    }

    for (final academic in u.academicList ?? const <AcademicList>[]) {
      addValue(academic.academicname);
      addValue(academic.academicProgramAr);
      addValue(
        academic.program?.academicProgram,
      );
      addValue(
        academic.program?.academicProgramAr,
      );
    }

    for (final link in u.programLinks ?? const <ProgramLinks>[]) {
      addValue(
        link.program?.academicProgram,
      );
      addValue(
        link.program?.academicProgramAr,
      );
    }

    for (final academic in u.academicPrograms ?? const <AcademicPrograms>[]) {
      addValue(academic.academicname);
      addValue(academic.academicProgramAr);

      for (final college in academic.colleges ?? const <Colleges>[]) {
        for (final course in college.courses ?? const <Courses>[]) {
          addValue(course.academicProgram);
          addValue(course.academicProgramAr);
        }
      }
    }

    return values;
  }

  bool _matchesTrack(AdminUniversity u) {
    if (_selectedTrack == null || _selectedTrack!.isEmpty) {
      return true;
    }

    final tracks = _trackTypes(u);

    return tracks.contains(
      _normalizeValue(_selectedTrack),
    );
  }

  Future<void> _loadSessionDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _selectedCountry ??= prefs.getString('loginCountry');

      _loginDialCode ??= prefs.getString('loginDialCode');
    } catch (_) {}
  }

  String? _resolveAutoCountry(
    List<CountryMaster> countries,
  ) {
    if ((_loginDialCode ?? '').trim() == '+968') {
      return _selectedCountry ?? 'Oman';
    }

    return null;
  }

  Set<String> _trackTypes(AdminUniversity u) {
    final tracks = <String>{};

    for (final link in u.programLinks ?? const <ProgramLinks>[]) {
      final value = _normalizeValue(
        link.program?.track,
      );

      if (value.isNotEmpty) {
        tracks.add(value);
      }
    }

    for (final academic in u.academicList ?? const <AcademicList>[]) {
      final value = _normalizeValue(
        academic.program?.track,
      );

      if (value.isNotEmpty) {
        tracks.add(value);
      }
    }

    for (final academic in u.academicPrograms ?? const <AcademicPrograms>[]) {
      for (final college in academic.colleges ?? const <Colleges>[]) {
        for (final course in college.courses ?? const <Courses>[]) {
          final value = _normalizeValue(course.track);

          if (value.isNotEmpty) {
            tracks.add(value);
          }
        }
      }
    }

    return tracks;
  }

  double? _minimumAdmissionRate(
    AdminUniversity u,
  ) {
    final rates = <double>[];

    rates.addAll(
      (u.programLinks ?? const <ProgramLinks>[])
          .map(
            (e) => e.program?.minAdmissionRate?.toDouble(),
          )
          .whereType<double>(),
    );

    rates.addAll(
      (u.academicList ?? const <AcademicList>[])
          .map(
            (e) => e.program?.minAdmissionRate?.toDouble(),
          )
          .whereType<double>(),
    );

    for (final academic in u.academicPrograms ?? const <AcademicPrograms>[]) {
      for (final college in academic.colleges ?? const <Colleges>[]) {
        rates.addAll(
          (college.courses ?? const <Courses>[])
              .map(
                (e) => e.minAdmissionRate?.toDouble(),
              )
              .whereType<double>(),
        );
      }
    }

    if (rates.isEmpty) {
      return null;
    }

    return rates.reduce(
      (a, b) => a < b ? a : b,
    );
  }

  bool _isScientificAndLiterary(
    String value,
  ) {
    return value.replaceAll(' ', '').toUpperCase() == 'SCIENTIFICANDLITERARY';
  }

  List<String> _splitCsvValues(
    String? csv,
  ) {
    if (csv == null || csv.trim().isEmpty) {
      return const [];
    }

    return csv
        .split(',')
        .map(_normalizeValue)
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _normalizeValue(String? value) {
    return (value ?? '').trim().toUpperCase();
  }

  String _resolveCountryFlag(
    CountryMaster c,
  ) {
    if (c.value.startsWith('http')) {
      return c.value;
    }

    final code = c.value.toLowerCase();

    return code.length == 2 ? 'https://flagcdn.com/w40/$code.png' : '';
  }

  void dispose() {
    resultController.dispose();
    close();
  }
}
