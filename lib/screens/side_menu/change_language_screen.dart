import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/bloc/app_cubit.dart';
import '../../services/snackbar_service.dart';
import '../../services/student_api_service.dart';
import 'side_menu_common.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen>
    with CubitStateMixin<ChangeLanguageScreen> {
  final StudentApiService _api = const StudentApiService();

  bool _isUpdating = false;
  String? _updatingLanguageCode;

  Future<void> _changeLanguage(Locale locale) async {
    if (_isUpdating) return;

    final String languageCode = locale.languageCode;
    if (context.l10n.locale.languageCode == languageCode) return;

    updateView(() {
      _isUpdating = true;
      _updatingLanguageCode = languageCode;
    });

    try {
      final Map<String, dynamic> response = await _api.updateProfileLanguage(
        language: languageCode,
      );

      if (!mounted) return;

      await AppLocalizationScope.of(context).changeLanguage(locale);

      if (!mounted) return;

      snackBarService.showSuccess(
        message: response['message']?.toString().trim().isNotEmpty == true
            ? response['message'].toString()
            : context.l10n.text('languageUpdatedSuccessfully'),
      );
    } on StudentApiException catch (error) {
      if (!mounted) return;
      snackBarService.showError(
        message: error.message.isNotEmpty
            ? error.message
            : context.l10n.text('failedUpdateLanguage'),
      );
    } catch (_) {
      if (!mounted) return;
      snackBarService.showError(
        message: context.l10n.text('failedUpdateLanguage'),
      );
    } finally {
      if (mounted) {
        updateView(() {
          _isUpdating = false;
          _updatingLanguageCode = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('changeLanguage'),
      child: buildCubitView(
        (context) => Column(
          children: [
            LanguageTile(
              flag: '🇺🇸',
              label: 'English',
              selected: context.l10n.textDirection == TextDirection.ltr,
              isLoading: _isUpdating && _updatingLanguageCode == 'en',
              onTap: _isUpdating ? null : () => _changeLanguage(const Locale('en')),
            ),
            const SizedBox(height: 8),
            LanguageTile(
              flag: '🇴🇲',
              label: 'العربية',
              selected: context.l10n.textDirection == TextDirection.rtl,
              isLoading: _isUpdating && _updatingLanguageCode == 'ar',
              onTap: _isUpdating ? null : () => _changeLanguage(const Locale('ar')),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    super.key,
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isLoading = false,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE6DFD7)),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.2,
                    color: selected ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
                child: selected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
