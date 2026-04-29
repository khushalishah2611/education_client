import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: 'Help',
      child: Align(
        alignment: Alignment.topCenter,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: EmergencyContactCard(),
        ),
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ContactInfoField(
            label: 'Guardian Name',
            value: 'Abhishek Verma',
            icon: Icons.person_outline_rounded,
          ),
          Divider(height: 1),

          ContactInfoField(
            label: 'Relationship',
            value: 'Brother',
            icon: Icons.person_outline_rounded,
          ),
          Divider(height: 1),

          ContactInfoField(
            label: 'Mobile Number',
            value: '+91 89788 54588',
            icon: Icons.call_outlined,
          ),
          Divider(height: 1),

          ContactInfoField(
            label: 'Email Address',
            value: 'theabc@gmail.com',
            icon: Icons.mail_outline_rounded,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          /// ICON BOX
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFA7E7C5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF0A3F27)),
          ),
        ],
      ),
    );
  }
}
