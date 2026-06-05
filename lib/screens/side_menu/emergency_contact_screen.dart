import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../widgets/contact_support_section.dart';
import 'side_menu_common.dart';

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('help'),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: const EmergencyContactCard(),
        ),
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({super.key});

  static const String whatsappNumber = '96877428887';
  static const String emailAddress = 'arabuapp@gmail.com';
  static const String instagramUrl = 'https://www.instagram.com/universities_arab?utm_source=qr&igsh=dHJydWx3Nm5taTNr';
  static const String facebookUrl = 'https://www.facebook.com/share/1C1iY7eHcN/';
  static const String snapchatUrl = 'https://www.snapchat.com/add/universitiesara?share_id=C2ct2Rm65l8&locale=ar-AE';
  static const String twitterUrl = 'https://x.com/universities_ar';
  static const String tiktokUrl = 'https://www.tiktok.com/@.universities_ara?_r=1&_t=ZS-96tgGchWj5w';

  Future<void> _makeCall(String number) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: number,
    );

    await launchUrl(uri);
  }
  Future<void> _openTikTok() async {
    await launchUrl(Uri.parse(instagramUrl));
  }
  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    await launchUrl(uri);
  }

  Future<void> _openWhatsApp() async {
    await launchUrl(Uri.parse('https://wa.me/$whatsappNumber'));
  }

  Future<void> _openInstagram() async {
    await launchUrl(Uri.parse(instagramUrl));
  }

  Future<void> _openFacebook() async {
    await launchUrl(Uri.parse(facebookUrl));
  }

  Future<void> _openSnapchat() async {
    await launchUrl(Uri.parse(snapchatUrl));
  }

  Future<void> _openTwitter() async {
    await launchUrl(Uri.parse(twitterUrl));
  }

  Future<void> _openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {'subject': 'Help Support'},
    );
    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //   Container(
          // width: double.infinity,
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(12),
          //   border: Border.all(
          //     color: Colors.grey.shade300,
          //   ),
          // ),
          // child: Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     ContactInfoField(
          //       label: context.l10n.text('guardianName'),
          //       value: 'Arab Education',
          //       icon: Icons.person_outline_rounded,
          //     ),
          //
          //     const Divider(height: 1),
          //
          //     ContactInfoField(
          //       label: context.l10n.text('relationship'),
          //       value: 'Support Person',
          //       icon: Icons.person_outline_rounded,
          //     ),
          //
          //     const Divider(height: 1),
          //
          //     ContactInfoField(
          //       label: context.l10n.text('mobileNumber'),
          //       value: '+968 7742 8887',
          //       icon: Icons.call_outlined,
          //       onTap: () => _makeCall(
          //         '+96877428887',
          //       ),
          //     ),
          //
          //     const Divider(height: 1),
          //
          //     ContactInfoField(
          //       label: context.l10n.text('emailAddress'),
          //       value: 'arabuapp@gmail.com',
          //       icon: Icons.mail_outline_rounded,
          //       onTap: () => _sendEmail(
          //         'arabuapp@gmail.com',
          //       ),
          //     ),
          //   ],
          // ),
          //   ),
          //   const SizedBox(height: 16),
          ContactSupportSection(
            onOpenWhatsApp: _openWhatsApp,
            onOpenInstagram: _openInstagram,
            onOpenFacebook: _openFacebook,
            onOpenSnapchat: _openSnapchat,
            onOpenTwitter: _openTwitter,
            onOpenEmail: _openEmail,
            onOpenTikTok: _openTikTok,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFA7E7C5),
                borderRadius: BorderRadius.circular(
                  6,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: const Color(0xFF0A3F27),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
