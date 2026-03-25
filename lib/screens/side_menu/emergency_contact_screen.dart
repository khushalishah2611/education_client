import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SideMenuScaffold(
      title: 'جهة اتصال الطوارئ',
      child: EmergencyContactCard(),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1DFDC)),
      ),
      child: const Column(
        children: [
          ContactInfoField(label: 'اسم ولي الأمر', value: 'Abhishek Verma', icon: Icons.person_outline_rounded),
          Divider(height: 1, color: Color(0xFFE4E2E0)),
          ContactInfoField(label: 'صلة القرابة', value: 'الأخ', icon: Icons.person_outline_rounded),
          Divider(height: 1, color: Color(0xFFE4E2E0)),
          ContactInfoField(label: 'رقم الموبايل', value: '+91 89788 54588', icon: Icons.call_outlined),
          Divider(height: 1, color: Color(0xFFE4E2E0)),
          ContactInfoField(label: 'البريد الإلكتروني', value: 'theabc@gmail.com', icon: Icons.mail_outline_rounded),
        ],
      ),
    );
  }
}

class ContactInfoField extends StatelessWidget {
  const ContactInfoField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted, height: 1.1),
                ),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFA7E7C5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF0A3F27)),
          ),
        ],
      ),
    );
  }
}
