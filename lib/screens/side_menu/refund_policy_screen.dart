import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../core/bloc/app_cubit.dart';
import '../../services/application_api_service.dart';
import '../../services/snackbar_service.dart';
import 'side_menu_common.dart';

class RefundPolicyScreen extends StatefulWidget {
  const RefundPolicyScreen({super.key});

  @override
  State<RefundPolicyScreen> createState() => _RefundPolicyScreenState();
}

class _RefundPolicyScreenState extends State<RefundPolicyScreen>
    with CubitStateMixin<RefundPolicyScreen> {
  final ApplicationApiService _api = const ApplicationApiService();

  bool _loading = true;

  List<Map<String, dynamic>> _policies = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    updateView(() => _loading = true);

    try {
      final policies = await _api.fetchRefundPolicy();
      if (!mounted) return;

      updateView(() {
        _policies = policies;
        _loading = false;
      });
    } catch (_) {
      updateView(() => _loading = false);

      snackBarService.showError(
        message: context.l10n.text('failedLoadTermsConditions'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildCubitView(
      (context) => SideMenuScaffold(
        title: context.l10n.text('refundPolicy'),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: Colors.white,
                onRefresh: _load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: _policies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final Map<String, dynamic> item = _policies[index];

                    final String title = _localizedPolicyField(
                      context,
                      item,
                      englishKeys: const <String>['titleEn', 'title'],
                      arabicKeys: const <String>['titleAr'],
                    );

                    final String content = _localizedPolicyField(
                      context,
                      item,
                      englishKeys: const <String>['descriptionEn', 'description'],
                      arabicKeys: const <String>['descriptionAr'],
                    );

                    final String displayTitle = title.isNotEmpty
                        ? title
                        : context.l10n.text('refundPolicy');

                    final List<String> bullets = content
                        .split(
                          RegExp(
                            r'[\r\n]+|(?<=\.)\s+',
                          ),
                        )
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    return SectionCard(
                      title: displayTitle,
                      bullets: bullets.isEmpty
                          ? <String>[context.l10n.text('no data available')]
                          : bullets,
                    );
                  },
                ),
              ),
      ),
    );
  }

  String _localizedPolicyField(
    BuildContext context,
    Map<String, dynamic> item, {
    required List<String> englishKeys,
    required List<String> arabicKeys,
  }) {
    final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final english = _firstNonEmptyValue(item, englishKeys);
    final arabic = _firstNonEmptyValue(item, arabicKeys);

    if (languageCode == 'ar') {
      return arabic.isNotEmpty ? arabic : english;
    }

    return english.isNotEmpty ? english : arabic;
  }

  String _firstNonEmptyValue(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}