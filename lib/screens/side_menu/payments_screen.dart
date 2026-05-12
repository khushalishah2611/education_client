import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/application_api_service.dart';
import 'side_menu_common.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SideMenuScaffold(
      title: 'Payments History',
      child: PaymentsContent(),
    );
  }
}

class PaymentsContent extends StatefulWidget {
  const PaymentsContent({super.key});

  @override
  State<PaymentsContent> createState() => _PaymentsContentState();
}

class _PaymentsContentState extends State<PaymentsContent>
    with SingleTickerProviderStateMixin {
  final ApplicationApiService _api = const ApplicationApiService();

  bool _loading = true;

  List<Map<String, dynamic>> _payments = <Map<String, dynamic>>[];

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _load();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';

      if (studentUserId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _payments = <Map<String, dynamic>>[];
          _loading = false;
        });

        return;
      }

      final Map<String, dynamic> overview = await _api.fetchStudentOverview(
        studentUserId: studentUserId,
      );

      final Object? payments = overview['payments'];

      if (!mounted) return;

      setState(() {
        _payments = payments is List
            ? payments
                .whereType<Map>()
                .map(
                  (e) => e.map(
                    (k, v) => MapEntry(
                      k.toString(),
                      v,
                    ),
                  ),
                )
                .toList()
            : <Map<String, dynamic>>[];

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: 'Failed to load payments.',
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat(
      'MMM dd, yyyy',
    ).format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat(
      'hh:mm a',
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildShimmerList();
    }

    if (_payments.isEmpty) {
      return _emptyState(context);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final Map<String, dynamic> item = _payments[index];

          final DateTime? createdAt = DateTime.tryParse(
            item['createdAt']?.toString() ?? '',
          );

          final String date = createdAt == null ? '-' : _formatDate(createdAt);

          final String time = createdAt == null ? '-' : _formatTime(createdAt);

          final num amount = (item['application'] is Map)
              ? ((item['application']['selectedApplicationFeeTotal'] as num?) ??
                  0)
              : ((item['amount'] as num?) ?? 0);

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE6E0D8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$date  $time',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(0)} Omani Rial',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: 10,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, __) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE6E0D8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerLine(
                          width: 180,
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _shimmerLine(
                    width: 120,
                    height: 18,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _shimmerLine({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment(
            -1 + (_shimmerController.value * 2),
            0,
          ),
          end: Alignment(
            1 + (_shimmerController.value * 2),
            0,
          ),
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE6E6E6),
                ),
                color: Colors.white,
              ),
              child: Text(
                'No payments available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF616161),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
