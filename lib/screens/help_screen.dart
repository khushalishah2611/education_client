import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';
import '../widgets/contact_support_section.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const String whatsappNumber = '96877428887';
  static const String emailAddress = 'arabuapp@gmail.com';

  // Social usernames
  static const String instagramUsername = 'instagram';
  static const String snapchatUsername = 'snapchat';
  static const String twitterUsername = 'twitter';

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
    final Uri uri = Uri.parse(
      'https://instagram.com/$instagramUsername',
    );

    await _launch(uri);
  }

  Future<void> _openSnapchat() async {
    final Uri uri = Uri.parse(
      'https://snapchat.com/add/$snapchatUsername',
    );

    await _launch(uri);
  }

  Future<void> _openTwitter() async {
    final Uri uri = Uri.parse(
      'https://twitter.com/$twitterUsername',
    );

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
    final double horizontalPadding =
        context.responsiveHorizontalPadding;

    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        body: Container(
          color: const Color(0xFFF8F4EE),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: ListView(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE7E7E7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.l10n.text('help'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const _LanguageDropdownChip(),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    context.l10n.text('needHelp'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  ContactSupportSection(
                    onOpenWhatsApp: _openWhatsApp,
                    onOpenInstagram: _openInstagram,
                    onOpenSnapchat: _openSnapchat,
                    onOpenTwitter: _openTwitter,
                    onOpenEmail: _openEmail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdownChip
    extends StatelessWidget {
  const _LanguageDropdownChip();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;

    return InkWell(
      onTap: context.toggleLanguage,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.92),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE8C8AE),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🇵🇸',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 5),
            Text(
              isArabic ? 'English' : 'عربي',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
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