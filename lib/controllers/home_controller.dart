import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/bloc/app_cubit.dart';
import '../models/admin_university.dart';
import '../models/banner_item.dart';
import '../models/country_master.dart';
import '../models/country_option.dart';
import '../models/master_option.dart';
import '../services/home_api_service.dart';
import '../services/network_event_service.dart';

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

    _networkSubscription = NetworkEventService.onInternetRestored.listen((_) {
      if (!isClosed) {
        refreshHomeData();
      }
    });
  }

  final HomeApiService _homeApiService;
  late final StreamSubscription<void> _networkSubscription;

  bool isLoadingUniversities = true;
  bool isLoadingBanners = true;

  List<BannerItem> banners = [];
  List<AdminUniversity> universities = [];

  List<MasterOption> trackOptions = [];
  List<MasterOption> academicOptions = [];
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
        _homeApiService
            .fetchTrackMasters()
            .catchError((_) => <MasterOption>[]),
        _homeApiService
            .fetchAcademicMasters()
            .catchError((_) => <MasterOption>[]),
        _homeApiService.fetchCountries().catchError((_) => <CountryMaster>[]),
      ]);

      final universitiesResponse = responses[0] as List<AdminUniversity>;

      final tracks = responses[1] as List<MasterOption>;

      final academics = responses[2] as List<MasterOption>;

      final countries = responses[3] as List<CountryMaster>;

      _selectedCountry = _canonicalCountryName(_selectedCountry, countries);

      /// Auto Oman selection
      _selectedCountry = _resolveAutoCountry(countries) ?? _selectedCountry;

      /// Apply local filters
      universities = _filterUniversities(universitiesResponse);

      /// Track options
      trackOptions = tracks
          .where(
            (e) => e.key.isNotEmpty && !_isScientificAndLiterary(e.key),
          )
          .toList(growable: false);

      /// Academic options
      academicOptions = academics
          .where((e) => e.key.isNotEmpty)
          .toList(growable: false);

      /// Country options
      countryOptions = countries
          .where((c) {
            final name = (c.nameEn.isNotEmpty ? c.nameEn : c.value).trim();
            return name.isNotEmpty;
          })
          .map(
            (c) => CountryOption(
              nameEn: c.nameEn.isNotEmpty ? c.nameEn : c.value,
              nameAr: c.nameAr.isNotEmpty
                  ? c.nameAr
                  : (c.nameEn.isNotEmpty ? c.nameEn : c.value),
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

  String? _canonicalCountryName(
    String? value,
    List<CountryMaster> countries,
  ) {
    final normalizedValue = _normalizeValue(value);
    if (normalizedValue.isEmpty) return null;

    for (final country in countries) {
      final names = [country.nameEn, country.nameAr, country.value];
      if (names.any((name) => _normalizeValue(name) == normalizedValue)) {
        return (country.nameEn.isNotEmpty ? country.nameEn : country.value)
            .trim();
      }
    }

    return value?.trim();
  }

  String? _canonicalCountryOptionName(String? value) {
    final normalizedValue = _normalizeValue(value);
    if (normalizedValue.isEmpty) return null;

    for (final country in countryOptions) {
      final names = [country.nameEn, country.nameAr];
      if (names.any((name) => _normalizeValue(name) == normalizedValue)) {
        return country.nameEn.trim();
      }
    }

    return value?.trim();
  }

  void updateCountry(String? value) {
    _selectedCountry = value?.trim();
    if (countryOptions.isNotEmpty) {
      _selectedCountry = _canonicalCountryOptionName(_selectedCountry);
    }
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

    final values = _academicValues(u);

    return _selectedAliases(
      _selectedAcademic,
      academicOptions,
    ).any(values.contains);
  }

  Set<String> _academicValues(AdminUniversity u) {
    final values = <String>{};

    void addValue(String? value) {
      values.addAll(_splitCsvValues(value));
    }

    for (final academic in u.academicList ?? const <AcademicList>[]) {
      addValue(academic.academicname);

      addValue(
        academic.program?.academicProgram,
      );
    }

    for (final link in u.programLinks ?? const <ProgramLinks>[]) {
      addValue(
        link.program?.academicProgram,
      );
    }

    for (final academic in u.academicPrograms ?? const <AcademicPrograms>[]) {
      addValue(academic.academicname);

      for (final college in academic.colleges ?? const <Colleges>[]) {
        for (final course in college.courses ?? const <Courses>[]) {
          addValue(course.academicProgram);
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

    return _selectedAliases(
      _selectedTrack,
      trackOptions,
    ).any(tracks.contains);
  }

  Set<String> _selectedAliases(
    String? selected,
    List<MasterOption> options,
  ) {
    final aliases = <String>{};
    final normalizedSelected = _normalizeValue(selected);
    if (normalizedSelected.isEmpty) {
      return aliases;
    }

    aliases.add(normalizedSelected);
    for (final option in options) {
      final optionValues = <String>[
        option.nameEn,
        option.nameAr,
        option.value,
        option.key,
      ].map(_normalizeValue).where((value) => value.isNotEmpty).toSet();
      if (optionValues.contains(normalizedSelected)) {
        aliases.addAll(optionValues);
      }
    }

    return aliases;
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
    return _selectedCountry ?? 'Oman';
  }

  Set<String> _trackTypes(AdminUniversity u) {
    final tracks = <String>{};

    for (final link in u.programLinks ?? const <ProgramLinks>[]) {
      final value = _normalizeValue(
        link.program?.track,
      );

      if (value.isNotEmpty) {
        tracks.add(value);
        if (_isScientificAndLiterary(value)) {
          tracks.addAll(const ['SCIENTIFIC', 'LITERARY']);
        }
      }
    }

    for (final academic in u.academicList ?? const <AcademicList>[]) {
      final value = _normalizeValue(
        academic.program?.track,
      );

      if (value.isNotEmpty) {
        tracks.add(value);
        if (_isScientificAndLiterary(value)) {
          tracks.addAll(const ['SCIENTIFIC', 'LITERARY']);
        }
      }
    }

    for (final academic in u.academicPrograms ?? const <AcademicPrograms>[]) {
      for (final college in academic.colleges ?? const <Colleges>[]) {
        for (final course in college.courses ?? const <Courses>[]) {
          final value = _normalizeValue(course.track);

          if (value.isNotEmpty) {
            tracks.add(value);
            if (_isScientificAndLiterary(value)) {
              tracks.addAll(const ['SCIENTIFIC', 'LITERARY']);
            }
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
    return value.replaceAll(' ', '').replaceAll('&', 'AND').toUpperCase() ==
        'SCIENTIFICANDLITERARY';
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
    close();
  }

  @override
  Future<void> close() {
    resultController.dispose();
    _networkSubscription.cancel();
    return super.close();
  }
}
