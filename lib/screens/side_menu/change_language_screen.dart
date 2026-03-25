import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('changeLanguage'),
      child: Column(
        children: [
          LanguageTile(
            flag: '🇺🇸',
            label: 'English',
            selected: context.l10n.textDirection == TextDirection.ltr,
            onTap: () => AppLocalizationScope.of(context).changeLanguage(const Locale('en')),
          ),
          const SizedBox(height: 8),
          LanguageTile(
            flag: '🇴🇲',
            label: 'العربية',
            selected: context.l10n.textDirection == TextDirection.rtl,
            onTap: () => AppLocalizationScope.of(context).changeLanguage(const Locale('ar')),
          ),
        ],
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
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

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
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1.2, color: selected ? AppColors.accent : AppColors.textMuted),
              ),
              child: selected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
