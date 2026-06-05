import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/contact_support_section.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const String whatsappNumber = '96877428887';
  static const String emailAddress = 'arabuapp@gmail.com';

  // Social usernames
  static const String instagramUrl = 'https://www.instagram.com/universities_arab?utm_source=qr&igsh=dHJydWx3Nm5taTNr';
  static const String facebookUrl = 'https://www.facebook.com/share/1C1iY7eHcN/';
  static const String snapchatUrl = 'https://www.snapchat.com/add/universitiesara?share_id=C2ct2Rm65l8&locale=ar-AE';
  static const String twitterUrl = 'https://x.com/universities_ar';
  static const String tiktokUrl = 'https://www.tiktok.com/@.universities_ara?_r=1&_t=ZS-96tgGchWj5w';

  Future<void> _launch(Uri uri) async {
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Launch Error: $e');
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri uri = Uri.parse(
      'https://wa.me/$whatsappNumber',
    );

    await _launch(uri);
  }

  Future<void> _openInstagram() async {
    final Uri uri = Uri.parse(instagramUrl);
    await _launch(uri);
  }

  Future<void> _openSnapchat() async {
    final Uri uri = Uri.parse(snapchatUrl);
    await _launch(uri);
  }

  Future<void> _openFacebook() async {
    final Uri uri = Uri.parse(facebookUrl);
    await _launch(uri);
  }

  Future<void> _openTwitter() async {
    final Uri uri = Uri.parse(twitterUrl);
    await _launch(uri);
  }

  Future<void> _openTikTok() async {
    final Uri uri = Uri.parse(tiktokUrl);
    await _launch(uri);
  }

  Future<void> _openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {
        'subject': 'Help Support',
      },
    );

    await _launch(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/img.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Container(color: const Color(0xFFFFF8EE).withOpacity(.46)),
            SafeArea(
              child: Column(
                children: [
                  const _HelpHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(33, 8, 33, 26),
                      children: [
                        Center(
                          child: Text(
                            context.l10n.text('help'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.logo,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(height: 24),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  const _HelpHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(20, 8, 18, 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: Colors.black,
              ),
            ),
          ),
          const Expanded(child: AppLogo(compact: true, center: true)),
          const _LanguageDropdownChip(),
        ],
      ),
    );
  }
}

class _LanguageDropdownChip extends StatelessWidget {
  const _LanguageDropdownChip();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;

    return InkWell(
      onTap: () {
        context.toggleLanguage();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.96),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE8C8AE),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? '🇴🇲' : '🇬🇧',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              isArabic ? 'العربية' : 'English',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 1),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 17,
              color: AppColors.text,
            ),
          ],
        ),
      ),
    );
  }
}
