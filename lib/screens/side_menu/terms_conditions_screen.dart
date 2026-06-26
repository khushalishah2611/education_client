import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/bloc/app_cubit.dart';
import '../../models/agreement_template.dart';
import '../../services/application_api_service.dart';
import '../../services/snackbar_service.dart';
import '../../utils/auth_utils.dart';
import 'side_menu_common.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen>
    with
        SingleTickerProviderStateMixin,
        CubitStateMixin<TermsConditionsScreen> {
  final ApplicationApiService _api = const ApplicationApiService();

  bool _loading = true;

  List<Map<String, dynamic>> _agreements = <Map<String, dynamic>>[];

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
    updateView(() => _loading = true);

    try {
      final List<AgreementTemplate> templates =
          await _api.fetchAgreementTemplates();

      if (!mounted) return;

      updateView(() {
        _agreements = templates
            .map<Map<String, dynamic>>((template) => {
                  'titleEn': template.titleEn,
                  'titleAr': template.titleAr,
                  'contentEn': template.contentEn,
                  'contentAr': template.contentAr,
                })
            .toList();

        _loading = false;
      });
    } on ApplicationApiException catch (e) {
      // Auto-logout if student user not found (404)
      if (isStudentNotFoundError(e)) {
        await performLogout(context);
        return;
      }

      updateView(() => _loading = false);

      snackBarService.showError(
        message: context.l10n.text('failedLoadTermsConditions'),
      );
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
        title: context.l10n.text(
          'termsAndConditions',
        ),
        child: _loading
            ? _buildShimmerList()
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

                    final String title = _localizedAgreementField(
                      context,
                      item,
                      englishKeys: const <String>['titleEn', 'title'],
                      arabicKeys: const <String>['titleAr'],
                    );

                    final String content = _localizedAgreementField(
                      context,
                      item,
                      englishKeys: const <String>['contentEn', 'content'],
                      arabicKeys: const <String>['contentAr'],
                    );

                    final String displayTitle = title.isNotEmpty
                        ? title
                        : context.l10n.text('terms');

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
                          ? <String>['No details available.']
                          : bullets,
                    );
                  },
                ),
              ),
      ),
    );
  }

  String _localizedAgreementField(
    BuildContext context,
    Map<String, dynamic> item, {
    required List<String> englishKeys,
    required List<String> arabicKeys,
  }) {
    final languageCode = Localizations.localeOf(context)
        .languageCode
        .toLowerCase();
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE6E6E6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerLine(
                    width: 180,
                    height: 18,
                  ),
                  const SizedBox(height: 16),
                  _shimmerBullet(),
                  const SizedBox(height: 10),
                  _shimmerBullet(),
                  const SizedBox(height: 10),
                  _shimmerBullet(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _shimmerBullet() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _shimmerLine(
                width: double.infinity,
                height: 12,
              ),
              const SizedBox(height: 6),
              _shimmerLine(
                width: 220,
                height: 12,
              ),
            ],
          ),
        ),
      ],
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
}
