import 'package:education/models/admin_university.dart';
import 'package:education/models/banner_item.dart';
import 'package:education/screens/lates_updates_screen.dart';
import 'package:education/screens/side_menu/track_my_applications_screen.dart';
import 'package:education/screens/side_menu/uploaded_documents_screen.dart';
import 'package:flutter/material.dart';
import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/image_url_helper.dart';
import '../core/responsive_helper.dart';
import '../controllers/home_controller.dart';
import '../models/country_option.dart';
import '../services/home_api_service.dart';
import '../widgets/app_drawer.dart';
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
  late final HomeController _controller;
  int _activeTab = 0;
  final PageController _bannerPageController = PageController(
    viewportFraction: 1,
  );
  int _activeBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      homeApiService: const HomeApiService(),
      initialCountry: widget.initialCountry,
      initialDialCode: widget.initialDialCode,
    )..addListener(_onControllerChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _bannerPageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_activeBannerIndex >= _controller.banners.length &&
        _controller.banners.isNotEmpty) {
      _activeBannerIndex = 0;
    }
    setState(() {});
  }

  Future<void> _openCountryDialog() async {
    final selected = await showDialog<CountryOption>(
      context: context,
      builder: (_) => _CountrySelectionDialog(
        countries: _controller.countryOptions,
        selected: _controller.selectedCountry,
      ),
    );
    if (selected == null || !mounted) return;
    _controller.updateCountry(selected.name);
    await _controller.applyFilters();
  }

  Future<void> _openAdvanceSearchDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AdvanceSearchDialog(
        countryOptions: _controller.countryOptions
            .map((item) => item.name)
            .toList(growable: false),
        academicOptions: _controller.academicOptions,
        trackOptions: _controller.trackOptions,
        currencyOptions: _controller.currencyOptions,
        selectedCountry: _controller.selectedCountry,
        selectedAcademic: _controller.selectedAcademic,
        selectedTrack: _controller.selectedTrack,
        resultController: _controller.resultController,
        onCountryChanged: _controller.updateCountry,
        onAcademicChanged: _controller.updateAcademic,
        onTrackChanged: _controller.updateTrack,
        onResetFilters: _controller.resetFilters,
        onApplyFilters: _controller.applyFilters,
      ),
    );
  }

  Future<void> _refreshHomeData() => _controller.refreshHomeData();

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = context.responsiveHorizontalPadding;
    final int gridColumns = context.responsiveGridColumns;
    final double gridAspectRatio = context.isSmallMobile ? 0.92 : 0.8;

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
                  if (_activeTab == 0) ...[
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
                            left: horizontalPadding,
                            right: horizontalPadding,
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                            left: horizontalPadding,
                            right: horizontalPadding,
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
                                            _controller.selectedCountry ??
                                                'Select Country',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  banners: _controller.banners,
                                  isLoading: _controller.isLoadingBanners,
                                  pageController: _bannerPageController,
                                  onPageChanged: (index) {
                                    if (!mounted) return;
                                    setState(() => _activeBannerIndex = index);
                                  },
                                ),

                                const SizedBox(height: 8),

                                _BannerIndicator(
                                  count: _controller.banners.isEmpty
                                      ? 1
                                      : _controller.banners.length,
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

                                if (!_controller.isLoadingUniversities &&
                                    _controller.universities.isEmpty)
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
                                    itemCount: _controller.isLoadingUniversities
                                        ? 4
                                        : _controller.universities.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: gridColumns,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                          childAspectRatio: gridAspectRatio,
                                        ),
                                    itemBuilder: (context, index) {
                                      if (_controller.isLoadingUniversities) {
                                        return const _UniversityCardShimmer();
                                      }
                                      final item =
                                          _controller.universities[index];
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
                  ] else if (_activeTab == 1) ...[
                    Expanded(child: TrackMyApplicationsScreen(_activeTab : true)),
                  ] else if (_activeTab == 2) ...[
                    Expanded(child: UploadedDocumentsScreen(_activeTab : true)),
                  ] else ...[
                    Expanded(child: LatestUpdatesScreen(_activeTab : true)),
                  ],

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

  final List<CountryOption> countries;
  final String? selected;

  @override
  State<_CountrySelectionDialog> createState() =>
      _CountrySelectionDialogState();
}

class _CountrySelectionDialogState extends State<_CountrySelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<CountryOption> _filteredCountries;

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

            Opacity(
              opacity: shouldDisableDetails ? 0.55 : 1,
              child: dropdownTile(
                title: 'Secondary School Certificate Program',
                options: widget.trackOptions,
                value: _selectedTrack,
                onChanged: (value) => setState(() => _selectedTrack = value),
                icon: Icons.menu_book_outlined,
                enabled: !shouldDisableDetails,
              ),
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
                        widget.resultController.clear();
                      });
                      widget.onResetFilters();
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

class _CountryFlag extends StatelessWidget {
  const _CountryFlag({required this.country});

  final CountryOption country;

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

  final AdminUniversity data;
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
                      ImageUrlHelper.resolveUploadUrl(data.logoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Center(child: Image.asset('assets/images/logo.webp')),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// NAME
                Text(
                  data.name ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                /// LOCATION + RATING
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// LEFT SIDE (Location)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data.country ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT SIDE (Rating)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFB300),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (data.rating ?? 0).toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
