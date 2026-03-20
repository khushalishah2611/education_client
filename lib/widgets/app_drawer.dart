import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';

class CommonSideMenu extends StatelessWidget {
  const CommonSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, context.l10n.text('dashboard'), false),
      (Icons.assignment_outlined, context.l10n.text('trackApplications'), false),
      (Icons.person_outline, context.l10n.text('myProfile'), false),
      (Icons.description_outlined, context.l10n.text('manageDocuments'), false),
      (Icons.payments_outlined, context.l10n.text('payments'), false),
      (Icons.notifications_none_rounded, context.l10n.text('notifications'), false),
      (Icons.verified_user_outlined, context.l10n.text('termsAndConditions'), false),
      (Icons.support_agent_outlined, context.l10n.text('emergencyContact'), false),
      (Icons.translate_outlined, context.l10n.text('changeLanguage'), false),
      (Icons.logout, context.l10n.text('logout'), true),
    ];

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 1.5),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ishan Sharma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Ishan01@gmail.com', style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.$1, size: 18, color: item.$3 ? Colors.red : AppColors.text),
                    ),
                    title: Text(
                      item.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: item.$3 ? Colors.red : AppColors.text,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).maybePop();
                      if (item.$1 == Icons.translate_outlined) {
                        context.toggleLanguage();
                      }
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemCount: items.length,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                context.l10n.text('versionLabel'),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
