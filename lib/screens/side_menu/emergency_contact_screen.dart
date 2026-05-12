import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _makeCall(String number) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: number,
    );

    await launchUrl(uri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ContactInfoField(
            label: 'Guardian Name',
            value: 'Arab Education',
            icon: Icons.person_outline_rounded,
          ),

          const Divider(height: 1),

          const ContactInfoField(
            label: 'Relationship',
            value: 'Support Person',
            icon: Icons.person_outline_rounded,
          ),

          const Divider(height: 1),

          ContactInfoField(
            label: 'Mobile Number',
            value: '+968 7742 8887',
            icon: Icons.call_outlined,
            onTap: () => _makeCall(
              '+96877428887',
            ),
          ),

          const Divider(height: 1),

          ContactInfoField(
            label: 'Email Address',
            value: 'arabuapp@gmail.com',
            icon: Icons.mail_outline_rounded,
            onTap: () => _sendEmail(
              'arabuapp@gmail.com',
            ),
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
    this.onTap,
  });

  final String label;

  final String value;

  final IconData icon;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color:
                      AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                const Color(0xFFA7E7C5),
                borderRadius:
                BorderRadius.circular(
                  6,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color:
                const Color(0xFF0A3F27),
              ),
            ),
          ],
        ),
      ),
    );
  }
}