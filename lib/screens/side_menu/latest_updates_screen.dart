import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/home_api_service.dart';

class LatestUpdatesScreen extends StatefulWidget {
  const LatestUpdatesScreen({super.key});

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
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_updates.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE6E6E6),
          ),
        ),
        child: const Text(
          'No updates available',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF616161),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchUpdates,
      child: ListView(
        padding:
        const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          const SizedBox(height: 50),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Recent Updates',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          ..._updates.map(
                (item) => Container(
              padding:
              const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFDAD6D1),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']?.toString() ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item['description']
                        ?.toString() ??
                        '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
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
      padding:
      const EdgeInsets.fromLTRB(16, 70, 16, 16),
      itemCount: 6,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return const _ShimmerUpdateCard();
      },
    );
  }
}

class _ShimmerUpdateCard extends StatefulWidget {
  const _ShimmerUpdateCard();

  @override
  State<_ShimmerUpdateCard> createState() =>
      _ShimmerUpdateCardState();
}

class _ShimmerUpdateCardState
    extends State<_ShimmerUpdateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFEAEAEA),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _shimmerBox(
                width: 180,
                height: 16,
              ),

              const SizedBox(height: 10),

              _shimmerBox(
                width: double.infinity,
                height: 12,
              ),

              const SizedBox(height: 8),

              _shimmerBox(
                width: 220,
                height: 12,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius:
              BorderRadius.circular(6),
            ),
          ),
        );
      },
    );
  }
}