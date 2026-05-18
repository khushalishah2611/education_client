import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';

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

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Wrap(
                      alignment:
                      WrapAlignment.spaceBetween,
                      runSpacing: 14,
                      spacing: 14,
                      children: [
                        _SocialItem(
                          icon: Icons.chat,
                          label: 'Whatsapp',
                          color:
                          const Color(0xFF31B74A),
                          onTap: () async {
                            await _openWhatsApp();
                          },
                        ),

                        _SocialItem(
                          icon:
                          Icons.camera_alt_outlined,
                          label: 'Instagram',
                          color:
                          const Color(0xFFDD2A7B),
                          onTap: () async {
                            await _openInstagram();
                          },
                        ),

                        _SocialItem(
                          icon:
                          Icons.tag_faces_rounded,
                          label: 'Snapchat',
                          color:
                          const Color(0xFFFFD728),
                          onTap: () async {
                            await _openSnapchat();
                          },
                        ),

                        _SocialItem(
                          icon:
                          Icons.alternate_email,
                          label: 'Twitter',
                          color:
                          const Color(0xFF1DA1F2),
                          onTap: () async {
                            await _openTwitter();
                          },
                        ),

                        _SocialItem(
                          icon: Icons.email,
                          label: 'Email',
                          color: AppColors.text,
                          onTap: () async {
                            await _openEmail();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n
                              .text('needHelp'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          context.l10n
                              .text('tapButtonBelow'),
                          style: const TextStyle(
                            color:
                            AppColors.textMuted,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 42,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              await _openWhatsApp();
                            },
                            style:
                            FilledButton.styleFrom(
                              backgroundColor:
                              const Color(
                                0xFF95D7B8,
                              ),
                              foregroundColor:
                              AppColors.text,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  8,
                                ),
                              ),
                            ),
                            child: Text(
                              context.l10n.text(
                                'chatWithUs',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _SocialItem extends StatelessWidget {
  const _SocialItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 1.4,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
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