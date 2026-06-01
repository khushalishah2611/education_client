import 'package:education/screens/side_menu/side_menu_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/bloc/app_cubit.dart';
import '../core/api_config.dart';
import '../models/latest_update.dart';
import '../services/home_api_service.dart';

class LatestUpdatesScreen extends StatefulWidget {
  const LatestUpdatesScreen({
    super.key,
    this.activeTab = false,
  });

  final bool activeTab;

  @override
  State<LatestUpdatesScreen> createState() => _LatestUpdatesScreenState();
}

class _LatestUpdatesScreenState extends State<LatestUpdatesScreen>
    with CubitStateMixin<LatestUpdatesScreen> {
  static const int _pageLimit = 10;

  final HomeApiService _homeApiService = const HomeApiService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreUpdates = true;
  int _currentPage = 1;
  List<LatestUpdate> _updates = const <LatestUpdate>[];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreWhenNeeded);
    _fetchUpdates();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreWhenNeeded)
      ..dispose();
    super.dispose();
  }

  Future<void> _fetchUpdates() async {
    updateView(() {
      _isLoading = true;
      _isLoadingMore = false;
    });

    try {
      final response = await _homeApiService.fetchLatestUpdatesPage(
        page: 1,
        limit: _pageLimit,
      );

      if (!mounted) return;

      updateView(() {
        _updates = response.data;
        _currentPage = response.pagination.page;
        _hasMoreUpdates = response.pagination.hasNextPage;
      });
    } catch (_) {
      if (!mounted) return;

      updateView(() {
        _updates = const <LatestUpdate>[];
        _currentPage = 1;
        _hasMoreUpdates = false;
      });
    } finally {
      if (mounted) {
        updateView(() => _isLoading = false);
      }
    }
  }

  void _loadMoreWhenNeeded() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMoreUpdates) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _fetchMoreUpdates();
    }
  }

  Future<void> _fetchMoreUpdates() async {
    if (_isLoadingMore || !_hasMoreUpdates) return;

    updateView(() => _isLoadingMore = true);

    try {
      final response = await _homeApiService.fetchLatestUpdatesPage(
        page: _currentPage + 1,
        limit: _pageLimit,
      );

      if (!mounted) return;

      updateView(() {
        _updates = <LatestUpdate>[..._updates, ...response.data];
        _currentPage = response.pagination.page;
        _hasMoreUpdates = response.pagination.hasNextPage;
      });
    } catch (_) {
      if (!mounted) return;

      updateView(() => _hasMoreUpdates = false);
    } finally {
      if (mounted) {
        updateView(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _openAttachment(String imagePath) async {
    final url = _resolveLatestUpdateUrl(imagePath);
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _resolveLatestUpdateUrl(String imagePath) {
    final value = imagePath.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return Uri.encodeFull(value);

    final normalized = value.replaceFirst(RegExp(r'^/+'), '');
    return Uri.encodeFull('${ApiConfig.baseUrl}/$normalized');
  }

  @override
  Widget build(BuildContext context) {
    return buildCubitView(
      (context) => SideMenuScaffold(
        title: context.l10n.text('latestUpdates'),
        showBackButton: widget.activeTab,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_updates.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE6E6E6),
            ),
          ),
          child: Text(
            context.l10n.text('noUpdatesAvailable'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF616161),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchUpdates,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          GestureDetector(
            onTap: _fetchUpdates,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    context.l10n.text('recentUpdates'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._updates.map(
            (item) => _LatestUpdateCard(
              item: item,
              onOpenAttachment: _openAttachment,
            ),
          ),
          if (_isLoadingMore) ...[
            const SizedBox(height: 6),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return const _ShimmerUpdateCard();
      },
    );
  }
}

class _LatestUpdateCard extends StatelessWidget {
  const _LatestUpdateCard({
    required this.item,
    required this.onOpenAttachment,
  });

  final LatestUpdate item;
  final ValueChanged<String> onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final imagePath = item.imagePath.trim();
    final hasAttachment = imagePath.isNotEmpty;
    final title = _localizedValue(
      context: context,
      englishValue: item.title,
      arabicValue: item.titleAr,
    );
    final description = _localizedValue(
      context: context,
      englishValue: item.description,
      arabicValue: item.descriptionAr,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE7E2DC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? '-' : title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (hasAttachment) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onOpenAttachment(imagePath),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FB),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _isPdf(imagePath)
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      color: _isPdf(imagePath)
                          ? const Color(0xFFD32F2F)
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (item.createdAt.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              _formatCreatedAt(item.createdAt),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  static String _localizedValue({
    required BuildContext context,
    required String englishValue,
    required String arabicValue,
  }) {
    final languageCode = Localizations.localeOf(context)
        .languageCode
        .toLowerCase();
    final english = englishValue.trim();
    final arabic = arabicValue.trim();

    if (languageCode == 'ar') {
      return arabic.isNotEmpty ? arabic : english;
    }

    return english.isNotEmpty ? english : arabic;
  }

  static bool _isPdf(String path) {
    final normalized = path.split('?').first.toLowerCase();
    return normalized.endsWith('.pdf');
  }

  static String _formatCreatedAt(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return DateFormat('dd MMMM yyyy hh:mm a').format(date.toLocal());
  }
}

class _ShimmerUpdateCard extends StatefulWidget {
  const _ShimmerUpdateCard();

  @override
  State<_ShimmerUpdateCard> createState() => _ShimmerUpdateCardState();
}

class _ShimmerUpdateCardState extends State<_ShimmerUpdateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
        return Opacity(
          opacity: 0.4 + (_controller.value * 0.6),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEAEAEA),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 180, height: 16),
                const SizedBox(height: 10),
                _shimmerBox(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                _shimmerBox(width: 220, height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
