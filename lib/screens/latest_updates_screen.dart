import 'package:education/screens/side_menu/side_menu_common.dart';
import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../services/home_api_service.dart';

class LatestUpdatesScreen extends StatefulWidget {
  const LatestUpdatesScreen({
    super.key,
    this.activeTab = false,
  });

  final bool activeTab;

  @override
  State<LatestUpdatesScreen> createState() =>
      _LatestUpdatesScreenState();
}

class _LatestUpdatesScreenState
    extends State<LatestUpdatesScreen> {
  final HomeApiService _homeApiService =
  const HomeApiService();

  bool _isLoading = true;

  List<Map<String, dynamic>> _updates =
  const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchUpdates();
  }

  Future<void> _fetchUpdates() async {
    setState(() => _isLoading = true);

    try {
      final response =
      await _homeApiService.fetchLatestUpdates(
        page: 1,
        limit: 10,
      );

      final data = response['data'];

      setState(() {
        _updates = data is List
            ? data
            .whereType<Map>()
            .map(
              (e) => e.map(
                (k, v) =>
                MapEntry(k.toString(), v),
          ),
        )
            .toList()
            : const <Map<String, dynamic>>[];
      });
    } catch (e) {
      _updates = const <Map<String, dynamic>>[];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('latestUpdates'),
      showBackButton: widget.activeTab,
      child: _buildBody(),
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
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color:
              const Color(0xFFE6E6E6),
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
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16,
        ),
        children: [
          GestureDetector(
            onTap: _fetchUpdates,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  8,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    context.l10n.text('recentUpdates'),
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          ..._updates.map(
                (item) => Container(
              margin:
              const EdgeInsets.only(
                bottom: 10,
              ),
              padding:
              const EdgeInsets.all(
                14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFE7E2DC,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    item['title']
                        ?.toString() ??
                        '-',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight
                          .w700,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    item['description']
                        ?.toString() ??
                        '',
                    style:
                    const TextStyle(
                      color:
                      AppColors.text,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16,
      ),
      itemCount: 10,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return const _ShimmerUpdateCard();
      },
    );
  }
}

class _ShimmerUpdateCard
    extends StatefulWidget {
  const _ShimmerUpdateCard();

  @override
  State<_ShimmerUpdateCard>
  createState() =>
      _ShimmerUpdateCardState();
}

class _ShimmerUpdateCardState
    extends State<_ShimmerUpdateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
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
          opacity:
          0.4 +
              (_controller.value *
                  0.6),
          child: Container(
            padding:
            const EdgeInsets.all(
              14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: const Color(
                  0xFFEAEAEA,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                _shimmerBox(
                  width: 180,
                  height: 16,
                ),

                const SizedBox(
                  height: 10,
                ),

                _shimmerBox(
                  width:
                  double.infinity,
                  height: 12,
                ),

                const SizedBox(
                  height: 8,
                ),

                _shimmerBox(
                  width: 220,
                  height: 12,
                ),
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
        color:
        const Color(0xFFE5E5E5),
        borderRadius:
        BorderRadius.circular(
          6,
        ),
      ),
    );
  }
}