import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../models/banner_item.dart';
import '../models/country_master.dart';
import '../services/home_api_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'university_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialCountry, this.initialDialCode});

  final String? initialCountry;
  final String? initialDialCode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeApiService _homeApiService = const HomeApiService();
  int _activeTab = 0;
  bool _isLoadingUniversities = true;
  bool _isLoadingBanners = true;
  final PageController _bannerPageController = PageController(
    viewportFraction: 1,
  );
  List<BannerItem> _banners = const [];
  List<HomeUniversity> _allUniversities = const [];
  List<UniversityData> _universities = const [];
  List<String> _trackOptions = const [];
  List<String> _academicOptions = const [];
  List<String> _currencyOptions = const [];
  int _activeBannerIndex = 0;
  List<_CountryOption> _countryOptions = const [];
  String? _selectedCountry;
  String? _selectedAcademic;
  String? _selectedTrack;
  String? _loginDialCode;
  final TextEditingController _resultController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry?.trim().isNotEmpty == true
        ? widget.initialCountry!.trim()
        : null;
    _loginDialCode = widget.initialDialCode?.trim().isNotEmpty == true
        ? widget.initialDialCode!.trim()
        : null;
    _loadSessionDefaults();
    _loadBanners();
    _loadUniversities();
  }

  @override
  void dispose() {
    _resultController.dispose();
    _bannerPageController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    setState(() => _isLoadingUniversities = true);
    try {
      final responses = await Future.wait<dynamic>([
        _homeApiService.fetchUniversities(
          country: _selectedCountry,
          academic: _selectedAcademic,
          track: _selectedTrack,
          search: _resultController.text,
        ),
        _homeApiService.fetchTrackMasters(),
        _homeApiService.fetchAcademicMasters(),
        _homeApiService.fetchCountries(),
      ]);
      final universities = responses[0] as List<HomeUniversity>;
      final tracks = responses[1] as List<String>;
      final academics = responses[2] as List<String>;
      final countries = responses[3] as List<CountryMaster>;

      if (!mounted) return;
      final autoSelectedCountry = _resolveAutoCountry(countries);
      setState(() {
        _selectedCountry = autoSelectedCountry;
        _allUniversities = universities;
        _universities = _filterUniversities(
          universities,
        ).map(_toUniversityData).toList(growable: false);
        _trackOptions = tracks
            .map((item) => item.trim())
            .where(
              (item) =>
                  item.isNotEmpty &&
                  item.toUpperCase() != 'SCIENTIFIC_AND_LITERARY',
            )
            .toList(growable: false);
        final allCountryOptions = countries
            .map(
              (item) => _CountryOption(
                name: item.nameEn.isNotEmpty ? item.nameEn : item.value,
                flagEmoji: item.flagEmoji,
                flagImageUrl: _resolveCountryFlag(item),
                dialCode: item.dialCode,
              ),
            )
            .where((item) => item.name.trim().isNotEmpty)
            .toList(growable: false);
        _academicOptions = academics;
        final shouldRestrictToOman = _shouldRestrictToOmanCountryList(
          allCountryOptions,
        );
        _countryOptions = shouldRestrictToOman
            ? allCountryOptions
                  .where((item) => item.dialCode.trim() == '+968')
                  .toList(growable: false)
            : allCountryOptions;
        if (shouldRestrictToOman &&
            _countryOptions.isNotEmpty &&
            !_countryOptions.any(
              (item) =>
                  item.name.trim().toLowerCase() ==
                  (_selectedCountry ?? '').trim().toLowerCase(),
            )) {
          _selectedCountry = _countryOptions.first.name;
        }
        _currencyOptions = const [];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allUniversities = const [];
        _universities = const [];
        _trackOptions = const [];
        _academicOptions = const [];
        _currencyOptions = const [];
        _countryOptions = const [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingUniversities = false);
      }
    }
  }

  List<HomeUniversity> _filterUniversities(List<HomeUniversity> source) {
    final enteredResult = double.tryParse(_resultController.text.trim());
    return source
        .where((university) {
          final countryMatch =
              _selectedCountry == null ||
              _selectedCountry!.trim().isEmpty ||
              university.country.toLowerCase() ==
                  _selectedCountry!.trim().toLowerCase();
          if (!countryMatch) {
            return false;
          }

          if (_shouldRestrictToAccredited() && !university.isAccredited) {
            return false;
          }

          if (_selectedAcademic != null &&
              _selectedAcademic!.trim().isNotEmpty) {
            final academicName = _selectedAcademic!.trim().toLowerCase();
            AcademicRequirement? requirement;
            for (final item in university.academicRequirements) {
              if (item.academic.toLowerCase() == academicName) {
                requirement = item;
                break;
              }
            }
            if (requirement == null) {
              return false;
            }
            if (enteredResult != null &&
                enteredResult > requirement.minResult) {
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

  bool _matchesTrack(HomeUniversity university) {
    final selectedTrack = _selectedTrack?.trim().toUpperCase() ?? '';
    if (selectedTrack.isEmpty) return true;
    if (selectedTrack == 'SCIENTIFIC') {
      return true;
    }
    if (university.trackTypes.isEmpty) {
      return true;
    }
    if (selectedTrack == 'LITERARY') {
      return university.trackTypes.contains('LITERARY') ||
          university.trackTypes.contains('SCIENTIFIC_AND_LITERARY');
    }
    if (selectedTrack == 'SCIENTIFIC_AND_LITERARY') {
      return university.trackTypes.contains('SCIENTIFIC_AND_LITERARY');
    }
    return true;
  }

  bool _shouldRestrictToAccredited() {
    final selected = _selectedCountry?.trim().toLowerCase() ?? '';
    if (selected == 'oman') return true;
    if (_loginDialCode?.trim() == '+968') return true;
    if (selected.isEmpty) return false;
    _CountryOption? option;
    for (final item in _countryOptions) {
      if (item.name.trim().toLowerCase() == selected) {
        option = item;
        break;
      }
    }
    if (option == null) return false;
    return option.dialCode.trim() == '+968';
  }

  bool _shouldRestrictToOmanCountryList(List<_CountryOption> options) {
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

  Future<void> _loadSessionDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCountry = prefs.getString('loginCountry')?.trim() ?? '';
      final storedDialCode = prefs.getString('loginDialCode')?.trim() ?? '';
      if (!mounted) return;
      var shouldReload = false;
      setState(() {
        if ((_selectedCountry ?? '').trim().isEmpty &&
            storedCountry.isNotEmpty) {
          _selectedCountry = storedCountry;
          shouldReload = true;
        }
        if ((_loginDialCode ?? '').trim().isEmpty &&
            storedDialCode.isNotEmpty) {
          _loginDialCode = storedDialCode;
          shouldReload = true;
        }
      });
      if (shouldReload) {
        await _loadUniversities();
      }
    } catch (_) {
      // Ignore shared preferences read failures.
    }
  }

  String? _resolveAutoCountry(List<CountryMaster> countries) {
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

  Future<void> _refreshHomeData() async {
    await Future.wait<void>([_loadBanners(), _loadUniversities()]);
  }

  Future<void> _applyFilters() async {
    setState(() {
      _universities = _filterUniversities(
        _allUniversities,
      ).map(_toUniversityData).toList(growable: false);
    });
    await _loadUniversities();
  }

  Future<void> _loadBanners() async {
    setState(() => _isLoadingBanners = true);
    try {
      final banners = await _homeApiService.fetchBanners(page: 1, limit: 10);
      if (!mounted) return;
      setState(() {
        _banners = banners;
        _activeBannerIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _banners = const []);
    } finally {
      if (mounted) {
        setState(() => _isLoadingBanners = false);
      }
    }
  }

  Future<void> _openCountryDialog() async {
    final selected = await showDialog<_CountryOption>(
      context: context,
      builder: (_) => _CountrySelectionDialog(
        countries: _countryOptions,
        selected: _selectedCountry,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedCountry = selected.name);
    await _applyFilters();
  }

  Future<void> _openAdvanceSearchDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AdvanceSearchDialog(
        countryOptions: _countryOptions
            .map((item) => item.name)
            .toList(growable: false),
        academicOptions: _academicOptions,
        trackOptions: _trackOptions,
        currencyOptions: _currencyOptions,
        selectedCountry: _selectedCountry,
        selectedAcademic: _selectedAcademic,
        selectedTrack: _selectedTrack,
        resultController: _resultController,
        onCountryChanged: (value) => setState(() => _selectedCountry = value),
        onAcademicChanged: (value) => setState(() => _selectedAcademic = value),
        onTrackChanged: (value) => setState(() => _selectedTrack = value),
        onResetFilters: () => setState(() {
          _selectedCountry = null;
          _selectedAcademic = null;
          _selectedTrack = null;
          _resultController.clear();
        }),
        onApplyFilters: _applyFilters,
      ),
    );
  }

  UniversityData _toUniversityData(HomeUniversity university) {
    final location = [
      university.city,
      university.country,
    ].where((item) => item.trim().isNotEmpty).join(', ');
    return UniversityData(
      name: university.name,
      location: location.isEmpty ? 'N/A' : location,
      shortCode: _shortCode(university.name),
      color: _colorFromSeed(university.id),
      heroImage: university.logoUrl.isNotEmpty
          ? university.logoUrl
          : '${ApiConfig.baseUrl}/uploads/default-university-image.png',
    );
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        key: _scaffoldKey,
        drawerScrimColor: Colors.black.withOpacity(0.16),
        drawer: const CommonSideMenu(),
        body: AppBackground(
          child: AppPageEntrance(
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.40,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/img.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        Positioned(
                          top: MediaQuery.of(context).padding.top,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              _CircleIconButton(
                                icon: Icons.menu_rounded,
                                onTap: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                              ),
                              const Spacer(),
                              const AppLogo(compact: true, center: true),
                              const Spacer(),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    size: 26,
                                  ),
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.10,
                          left: 16,
                          right: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// Country
                              InkWell(
                                onTap: _openCountryDialog,
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Color(0xFFE4B88B),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedCountry ?? 'Select Country',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// Advance Search
                              InkWell(
                                onTap: _openAdvanceSearchDialog,
                                child: Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Color(0xFFE4B88B),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        color: AppColors.accent,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Advance Search',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              _DiscoverBanner(
                                banners: _banners,
                                isLoading: _isLoadingBanners,
                                pageController: _bannerPageController,
                                onPageChanged: (index) {
                                  if (!mounted) return;
                                  setState(() => _activeBannerIndex = index);
                                },
                              ),

                              const SizedBox(height: 8),

                              _BannerIndicator(
                                count: _banners.isEmpty ? 1 : _banners.length,
                                activeIndex: _activeBannerIndex,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshHomeData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionTitle(
                                context.l10n.text('popularUniversities'),
                              ),

                              const SizedBox(height: 12),

                              if (!_isLoadingUniversities &&
                                  _universities.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE6E6E6),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    context.l10n.text(
                                      'No education institute data available',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF616161),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              else
                                GridView.builder(
                                  itemCount: _isLoadingUniversities
                                      ? 4
                                      : _universities.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        childAspectRatio: 0.8,
                                      ),
                                  itemBuilder: (context, index) {
                                    if (_isLoadingUniversities) {
                                      return const _UniversityCardShimmer();
                                    }
                                    final item = _universities[index];
                                    return _UniversityCard(
                                      data: item,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UniversityDetailScreen(
                                                data: item,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  BottomTabBarCard(
                    activeIndex: _activeTab,
                    onTap: (index) {
                      setState(() => _activeTab = index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.text, size: 26),
      ),
    );
  }
}

class _DiscoverBanner extends StatelessWidget {
  const _DiscoverBanner({
    required this.banners,
    required this.isLoading,
    required this.pageController,
    required this.onPageChanged,
  });

  final List<BannerItem> banners;
  final bool isLoading;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _BannerShimmer();
    }
    if (banners.isEmpty) {
      return const _BannerShimmer();
    }
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: PageView.builder(
          controller: pageController,
          itemCount: banners.length,
          onPageChanged: onPageChanged,
          itemBuilder: (_, index) {
            final banner = banners[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _BannerShimmer(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const _BannerShimmer();
                  },
                ),
                if (banner.title.isNotEmpty)
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Text(
                      banner.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E3DB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_ShimmerBlock(height: 100, borderRadius: 8)],
      ),
    );
  }
}

class _BannerIndicator extends StatelessWidget {
  const _BannerIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF248B4B) : const Color(0xFFD4D4D4),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _CountrySelectionDialog extends StatefulWidget {
  const _CountrySelectionDialog({
    required this.countries,
    required this.selected,
  });

  final List<_CountryOption> countries;
  final String? selected;

  @override
  State<_CountrySelectionDialog> createState() =>
      _CountrySelectionDialogState();
}

class _CountrySelectionDialogState extends State<_CountrySelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<_CountryOption> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final normalized = query.trim().toLowerCase();
    setState(() {
      if (normalized.isEmpty) {
        _filteredCountries = widget.countries;
        return;
      }
      _filteredCountries = widget.countries
          .where((country) => country.name.toLowerCase().contains(normalized))
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 45,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Selection Country',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                    border: InputBorder.none,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredCountries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final country = _filteredCountries[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: _CountryFlag(country: country),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          fontWeight: widget.selected == country.name
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(country),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvanceSearchDialog extends StatefulWidget {
  const _AdvanceSearchDialog({
    required this.countryOptions,
    required this.academicOptions,
    required this.trackOptions,
    required this.currencyOptions,
    required this.selectedCountry,
    required this.selectedAcademic,
    required this.selectedTrack,
    required this.resultController,
    required this.onCountryChanged,
    required this.onAcademicChanged,
    required this.onTrackChanged,
    required this.onResetFilters,
    required this.onApplyFilters,
  });

  final List<String> countryOptions;
  final List<String> academicOptions;
  final List<String> trackOptions;
  final List<String> currencyOptions;
  final String? selectedCountry;
  final String? selectedAcademic;
  final String? selectedTrack;
  final TextEditingController resultController;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onAcademicChanged;
  final ValueChanged<String?> onTrackChanged;
  final VoidCallback onResetFilters;
  final Future<void> Function() onApplyFilters;

  @override
  State<_AdvanceSearchDialog> createState() => _AdvanceSearchDialogState();
}

class _AdvanceSearchDialogState extends State<_AdvanceSearchDialog> {
  String? _selectedCountry;
  String? _selectedAcademic;
  String? _selectedTrack;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
    _selectedAcademic = widget.selectedAcademic;
    _selectedTrack = widget.selectedTrack;
  }

  bool _isOnlyCountryAndAcademicAllowed(String? academicValue) {
    final normalized = academicValue?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) return false;
    return normalized.contains('master') ||
        normalized.contains('phd') ||
        normalized.contains('doctor') ||
        normalized.contains('teach');
  }

  @override
  Widget build(BuildContext context) {
    Widget dropdownTile({
      required String title,
      required List<String> options,
      required String? value,
      required ValueChanged<String?> onChanged,
      IconData icon = Icons.apartment_outlined,
      bool enabled = true,
    }) {
      final hasValue = value != null && options.contains(value);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD7D7D7)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: hasValue ? value : null,
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 250,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF757575),
                ),

                hint: Text(
                  options.isEmpty ? 'No options found' : 'Select $title',
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 14,
                  ),
                ),

                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Row(
                      children: [
                        Icon(icon, color: const Color(0xFF8A8A8A), size: 18),
                        const SizedBox(width: 8),

                        // 👇 FIX
                        Flexible(
                          child: Text(
                            option,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                onChanged: !enabled || options.isEmpty ? null : onChanged,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    final shouldDisableDetails = _isOnlyCountryAndAcademicAllowed(
      _selectedAcademic,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            dropdownTile(
              title: 'Country',
              options: widget.countryOptions,
              value: _selectedCountry,
              onChanged: (value) => setState(() => _selectedCountry = value),
              icon: Icons.flag_outlined,
            ),
            dropdownTile(
              title: 'Academic Qualification',
              options: widget.academicOptions,
              value: _selectedAcademic,
              onChanged: (value) => setState(() {
                _selectedAcademic = value;
                if (_isOnlyCountryAndAcademicAllowed(value)) {
                  _selectedTrack = null;
                  widget.resultController.clear();
                }
              }),
              icon: Icons.school_outlined,
            ),

            dropdownTile(
              title: 'Secondary School Certificate Program',
              options: widget.trackOptions,
              value: _selectedTrack,
              onChanged: (value) => setState(() => _selectedTrack = value),
              icon: Icons.menu_book_outlined,
              enabled: !shouldDisableDetails,
            ),
            Opacity(
              opacity: shouldDisableDetails ? 0.55 : 1,
              child: IgnorePointer(
                ignoring: shouldDisableDetails,
                child: AppTextField(
                  label: widget.currencyOptions.isNotEmpty
                      ? 'High school graduation rate (${widget.currencyOptions.first})'
                      : 'High school graduation rate',
                  hint: 'Enter high school graduation rate',
                  controller: widget.resultController,
                  keyboardType: TextInputType.number,
                  height: 48,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    label: context.l10n.text('Reset'),
                    onPressed: () async {
                      setState(() {
                        _selectedCountry = null;
                        _selectedAcademic = null;
                        _selectedTrack = null;
                      });
                      widget.resultController.clear();
                      widget.onResetFilters();
                      Navigator.of(context).pop();
                      await widget.onApplyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppPrimaryButton(
                    label: context.l10n.text('Continue'),
                    onPressed: () async {
                      widget.onCountryChanged(_selectedCountry);
                      widget.onAcademicChanged(_selectedAcademic);
                      widget.onTrackChanged(_selectedTrack);
                      Navigator.of(context).pop();
                      await widget.onApplyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryOption {
  const _CountryOption({
    required this.name,
    required this.flagEmoji,
    required this.flagImageUrl,
    required this.dialCode,
  });

  final String name;
  final String flagEmoji;
  final String flagImageUrl;
  final String dialCode;
}

class _CountryFlag extends StatelessWidget {
  const _CountryFlag({required this.country});

  final _CountryOption country;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        country.flagImageUrl.startsWith('http://') ||
        country.flagImageUrl.startsWith('https://');
    if (!hasImage) {
      return Text(country.flagEmoji, style: const TextStyle(fontSize: 18));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image.network(
        country.flagImageUrl,
        width: 22,
        height: 16,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.data, required this.onTap});

  final UniversityData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E3DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                Container(
                  height: 84,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data.heroImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          data.shortCode,
                          style: TextStyle(
                            color: data.color,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// NAME
                Text(
                  data.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                /// LOCATION + RATING
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14),
                      Expanded(
                        child: Text(
                          data.location,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const Icon(Icons.star, size: 14),
                      const Text("4.6"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: context.l10n.text('viewDetails'),
                    onPressed: onTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UniversityCardShimmer extends StatelessWidget {
  const _UniversityCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E3DB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(height: 84, borderRadius: 8),
          SizedBox(height: 10),
          _ShimmerBlock(height: 14, borderRadius: 4),
          SizedBox(height: 6),
          _ShimmerBlock(height: 12, width: 90, borderRadius: 4),
          Spacer(),
          _ShimmerBlock(height: 32, borderRadius: 8),
        ],
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
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
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final width = bounds.width == 0 ? 1 : bounds.width;
            final offset = (_controller.value * 2 * width) - width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE6E6E6),
                Color(0xFFF4F4F4),
                Color(0xFFE6E6E6),
              ],
              stops: const [0.1, 0.45, 0.9],
              transform: GradientTranslation(offset, 0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.height,
    this.width,
    this.borderRadius = 6,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
