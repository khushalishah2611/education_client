import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/student_session.dart';
import '../screens/side_menu_screens.dart';
import '../services/application_api_service.dart';

class CommonSideMenu extends StatefulWidget {
  const CommonSideMenu({super.key});

  @override
  State<CommonSideMenu> createState() => _CommonSideMenuState();
}

class _CommonSideMenuState extends State<CommonSideMenu> {
  final ApplicationApiService _api = const ApplicationApiService();

  String _displayName = '';
  String _displayEmail = '';
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final String userId = await StudentSession.currentStudentUserId();
      final List<Map<String, dynamic>> students = await _api.fetchStudents();

      final Map<String, dynamic>? current = students
          .cast<Map<String, dynamic>?>()
          .firstWhere(
            (item) => (item?['userId'] ?? '').toString() == userId,
            orElse: () => students.isNotEmpty ? students.first : null,
          );

      if (current == null || !mounted) return;

      final String firstName = (current['firstName'] ?? '').toString().trim();
      final String lastName = (current['lastName'] ?? '').toString().trim();
      final String fullName = '$firstName $lastName'.trim();
      final Map<String, dynamic> user =
          (current['user'] is Map<String, dynamic>)
              ? current['user'] as Map<String, dynamic>
              : <String, dynamic>{};

      setState(() {
        _displayName = fullName;
        _displayEmail = (user['email'] ?? '').toString().trim();
        _profileImageUrl = (current['profileImagePath'] ?? '').toString().trim();
      });
    } catch (_) {
      // Keep drawer usable even if profile lookup fails.
    }
  }

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
                      image: _profileImageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_profileImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImageUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: AppColors.textMuted,
                            size: 24,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName.isNotEmpty
                              ? _displayName
                              : context.l10n.text('myProfile'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _displayEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textMuted),
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
