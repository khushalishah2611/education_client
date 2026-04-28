import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SideMenuScaffold(
      title: 'Emergency Contact',
      child: EmergencyContactContent(),
    );
  }
}

class EmergencyContactContent extends StatelessWidget {
  const EmergencyContactContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ContactInfoField(
          label: 'Guardian Name',
          value: 'Abhishek Verma',
          icon: Icons.person_outline_rounded,
        ),
        Divider(height: 1, color: Color(0xFFE4E2E0)),
        ContactInfoField(
          label: 'Relationship',
          value: 'Brother',
          icon: Icons.person_outline_rounded,
        ),
        Divider(height: 1, color: Color(0xFFE4E2E0)),
        ContactInfoField(
          label: 'Mobile Number',
          value: '+91 89788 54588',
          icon: Icons.call_outlined,
        ),
        Divider(height: 1, color: Color(0xFFE4E2E0)),
        ContactInfoField(
          label: 'Email ID',
          value: 'theabc@gmail.com',
          icon: Icons.mail_outline_rounded,
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFA7E7C5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF0A3F27)),
          ),
        ],
      ),
    );
  }
}
