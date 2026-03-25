import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';

class UploadedDocumentsScreen extends StatelessWidget {
  const UploadedDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const docs = [
      ('Passport', '2.6 MB'),
      ('Academic Transcript', '2.2 MB'),
      ('Statement of Purpose (SOP)', '2.0 MB'),
      ('LOR', '1.8 MB'),
      ('CV', '2.4 MB'),
      ('Resume / CV', '2.1 MB'),
    ];

    return _SideMenuScaffold(
      title: 'Uploaded Documents',
      child: ListView.separated(
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final doc = docs[index];
          return _SimpleTile(
            leading: Icons.picture_as_pdf_outlined,
            title: doc.$1,
            subtitle: doc.$2,
            trailing: const Icon(
              Icons.cancel_outlined,
              color: AppColors.textMuted,
            ),
          );
        },
      ),
    );
  }
}

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const payments = [
      ('March 03, 2026', '11:00 AM', '₹1,500.00'),
      ('August 13, 2025', '11:00 AM', '₹1,100.00'),
      ('March 03, 2025', '11:00 AM', '₹950.00'),
    ];

    return _SideMenuScaffold(
      title: 'List of Payments',
      child: ListView.separated(
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = payments[index];
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
                    '${item.$1}   •   ${item.$2}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  item.$3,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const notifications = [
      (
        'Document Approved',
        'Your document is approved and ready for the next process.',
        'March 13, 2026',
      ),
      (
        'Application Deadline Reminder',
        'Your last date to submit this form is next week.',
        'March 11, 2026',
      ),
      (
        'Application Deadline Extended',
        'Your application deadline has been extended.',
        'March 10, 2026',
      ),
      (
        'Document Approved',
        'Your document is approved and ready for the next process.',
        'March 09, 2026',
      ),
    ];

    return _SideMenuScaffold(
      title: 'Notification',
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE9E2D9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    item.$3,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SideMenuScaffold(
      title: 'Emergency Contact',
      child: Column(
        children: const [
          _InfoField(label: 'Guardian Name', value: 'Ishan Sharma'),
          SizedBox(height: 10),
          _InfoField(label: 'Relationship', value: 'Father'),
          SizedBox(height: 10),
          _InfoField(label: 'Mobile Number', value: '+91 98765 43120'),
          SizedBox(height: 10),
          _InfoField(label: 'Email ID', value: 'shanwar@gmail.com'),
        ],
      ),
    );
  }
}

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SideMenuScaffold(
      title: context.l10n.text('changeLanguage'),
      child: Column(
        children: [
          _LanguageTile(
            label: 'English',
            selected: context.l10n.textDirection == TextDirection.ltr,
            onTap: () => AppLocalizationScope.of(
              context,
            ).changeLanguage(const Locale('en')),
          ),
          const SizedBox(height: 8),
          _LanguageTile(
            label: 'العربية',
            selected: context.l10n.textDirection == TextDirection.rtl,
            onTap: () => AppLocalizationScope.of(
              context,
            ).changeLanguage(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SideMenuScaffold(
      title: context.l10n.text('termsAndConditions'),
      child: ListView(
        children: const [
          _SectionCard(
            title: 'Use of the App',
            bullets: [
              'This app provides admissions-related data, forms, and notifications.',
              'Users must share authentic details only while applying.',
              'Misuse may lead to account restriction.',
            ],
          ),
          SizedBox(height: 10),
          _SectionCard(
            title: 'User Account',
            bullets: [
              'You are responsible for maintaining the confidentiality of your account.',
              'Notify support if any suspicious activity appears.',
            ],
          ),
          SizedBox(height: 10),
          _SectionCard(
            title: 'Privacy',
            bullets: [
              'Personal information is handled according to our privacy policy.',
              'Data may be used to improve app functionality and experience.',
            ],
          ),
        ],
      ),
    );
  }
}


class TrackMyApplicationsScreen extends StatelessWidget {
  const TrackMyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applications = [
      const _ApplicationCardData(
        universityName: 'Harvard University',
        courseName: 'Bachelor of Computer Science',
        shortCode: 'HAR',
        appId: '#12345',
      ),
      const _ApplicationCardData(
        universityName: 'Al-Ahliyya Amman University',
        courseName: 'Bachelor of Computer Science',
        shortCode: 'AAU',
        appId: '#12346',
      ),
      const _ApplicationCardData(
        universityName: 'Beirut Arab University',
        courseName: 'Bachelor of Computer Science',
        shortCode: 'BAU',
        appId: '#12347',
      ),
    ];

    return _SideMenuScaffold(
      title: 'Track My Applications',
      child: ListView.separated(
        itemCount: applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = applications[index];

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0DDD8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application ID : ${item.appId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.shortCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.universityName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.courseName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE0DDD8)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text(
                      'Application Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F1F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCardData {
  const _ApplicationCardData({
    required this.universityName,
    required this.courseName,
    required this.shortCode,
    required this.appId,
  });

  final String universityName;
  final String courseName;
  final String shortCode;
  final String appId;
}

class _SideMenuScaffold extends StatelessWidget {
  const _SideMenuScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                /// BACK BUTTON (LEFT)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: InkWell(
                      onTap:  () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6F6F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
            
                /// TITLE (PERFECT CENTER)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: child)
          ],
        ),
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData leading;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E1D9)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFE2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(leading, size: 16, color: Colors.redAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DFD7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_square, size: 16, color: Colors.green),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6DFD7)),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.accent : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.bullets});

  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...bullets.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showLogoutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}
