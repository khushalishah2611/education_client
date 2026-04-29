import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../screens/side_menu_screens.dart';

class CommonSideMenu extends StatelessWidget {
  const CommonSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final items =
        <({IconData icon, String label, bool danger, Widget? screen})>[
          (
            icon: Icons.home_outlined,
            label: context.l10n.text('dashboard'),
            danger: false,
            screen: null,
          ),
          (
            icon: Icons.assignment_outlined,
            label: context.l10n.text('trackApplications'),
            danger: false,
            screen: const TrackMyApplicationsScreen(activeTab: true),
          ),
          (
            icon: Icons.person_outline,
            label: context.l10n.text('myProfile'),
            danger: false,
            screen: const ProfileScreen(),
          ),
          (
            icon: Icons.description_outlined,
            label: context.l10n.text('manageDocuments'),
            danger: false,
            screen: const UploadedDocumentsScreen(activeTab: true),
          ),
          (
            icon: Icons.payments_outlined,
            label: context.l10n.text('payments'),
            danger: false,
            screen: const PaymentsScreen(),
          ),
          (
            icon: Icons.notifications_none_rounded,
            label: context.l10n.text('notifications'),
            danger: false,
            screen: const NotificationsScreen(),
          ),
          (
            icon: Icons.verified_user_outlined,
            label: context.l10n.text('termsAndConditions'),
            danger: false,
            screen: const TermsConditionsScreen(),
          ),
          (
            icon: Icons.support_agent_outlined,
            label: context.l10n.text('help'),
            danger: false,
            screen: const EmergencyContactScreen(),
          ),
          (
            icon: Icons.translate_outlined,
            label: context.l10n.text('changeLanguage'),
            danger: false,
            screen: const ChangeLanguageScreen(),
          ),
          (
            icon: Icons.logout,
            label: context.l10n.text('logout'),
            danger: true,
            screen: null,
          ),
        ];

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.96),
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
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ishan Sharma',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ishan01@gmail.com',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                      child: Icon(
                        item.icon,
                        size: 18,
                        color: item.danger ? Colors.red : AppColors.text,
                      ),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: item.danger ? Colors.red : AppColors.text,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).maybePop();
                      if (item.icon == Icons.logout) {
                        showLogoutDialog(context);
                        return;
                      }
                      if (item.screen != null) {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => item.screen!));
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
