import 'package:flutter/material.dart';
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
      title: 'List of Payments',
      child: PaymentsContent(),
    );
  }
}

class PaymentsContent extends StatefulWidget {
  const PaymentsContent({super.key});

  @override
  State<PaymentsContent> createState() => _PaymentsContentState();
}

class _PaymentsContentState extends State<PaymentsContent> {
  final ApplicationApiService _api = const ApplicationApiService();
  bool _loading = true;
  List<Map<String, dynamic>> _payments = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId = prefs.getString('studentUserId')?.trim() ?? '';
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
            ? payments.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList()
            : <Map<String, dynamic>>[];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnackBar(context, type: AppSnackBarType.error, message: 'Failed to load payments.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildShimmerList();
    if (_payments.isEmpty) return _emptyState(context);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final Map<String, dynamic> item = _payments[index];
          final DateTime? createdAt = DateTime.tryParse(item['createdAt']?.toString() ?? '');
          final String date = createdAt == null
              ? '-'
              : '${_month(createdAt.month)} ${createdAt.day.toString().padLeft(2, '0')}, ${createdAt.year}';
          final num amount = (item['application'] is Map)
              ? ((item['application']['selectedApplicationFeeTotal'] as num?) ?? 0)
              : ((item['amount'] as num?) ?? 0);
          final String currency = item['currency']?.toString() ?? '';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6E0D8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(0)} ${currency.trim()}',
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _month(int m) {
    const List<String> names = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m - 1];
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.35, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        builder: (_, value, child) => Opacity(opacity: value, child: child),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
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
          const SizedBox(height: 120),
          Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE6E6E6)),
                color: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.payments_outlined, size: 52, color: Colors.grey),
                  SizedBox(height: 14),
                  Text('No payments available',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF616161), fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
