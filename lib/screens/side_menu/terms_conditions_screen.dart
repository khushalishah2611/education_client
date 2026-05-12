import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../services/application_api_service.dart';
import '../../widgets/common_widgets.dart';
import 'side_menu_common.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  final ApplicationApiService _api = const ApplicationApiService();
  bool _loading = true;
  List<Map<String, dynamic>> _agreements = <Map<String, dynamic>>[];

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
      final Map<String, dynamic> overview = await _api.fetchStudentOverview(
        studentUserId: studentUserId,
      );
      final Object? templates = overview['agreementTemplates'];
      if (!mounted) return;
      setState(() {
        _agreements = templates is List
            ? templates
                .whereType<Map>()
                .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
                .toList()
            : <Map<String, dynamic>>[];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: 'Failed to load terms & conditions.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('termsAndConditions'),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: _agreements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final Map<String, dynamic> item = _agreements[index];
                  final String title = item['title']?.toString().trim().isNotEmpty == true
                      ? item['title'].toString()
                      : 'Terms';
                  final String content = item['content']?.toString().trim() ?? '';
                  final List<String> bullets = content
                      .split(RegExp(r'[\n\r]+|(?<=\.)\s+'))
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  return SectionCard(
                    title: title,
                    bullets:
                        bullets.isEmpty ? <String>['No details available.'] : bullets,
                  );
                },
              ),
            ),
    );
  }
}
