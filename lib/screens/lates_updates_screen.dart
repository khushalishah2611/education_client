import 'package:education/screens/side_menu/side_menu_common.dart'
    show SideMenuScaffold;
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/home_api_service.dart';

class LatestUpdatesScreen extends StatefulWidget {
  const LatestUpdatesScreen({super.key, this.activeTab = false});

  final bool activeTab;

  @override
  State<LatestUpdatesScreen> createState() => _LatestUpdatesScreenState();
}

class _LatestUpdatesScreenState extends State<LatestUpdatesScreen> {
  final HomeApiService _homeApiService = const HomeApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _updates = const <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _fetchUpdates();
  }

  Future<void> _fetchUpdates() async {
    setState(() => _isLoading = true);
    try {
      final response = await _homeApiService.fetchLatestUpdates(page: 1, limit: 10);
      final data = response['data'];
      setState(() {
        _updates = data is List
            ? data
                .whereType<Map>()
                .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
                .toList(growable: false)
            : const <Map<String, dynamic>>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: 'Lates Updates',
      showBackButton: widget.activeTab,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Recent Updates',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _updates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _updates[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            item['description']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
