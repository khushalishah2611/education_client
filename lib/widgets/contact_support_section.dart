import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';

class ContactSupportSection extends StatelessWidget {
  const ContactSupportSection({
    super.key,
    required this.onOpenWhatsApp,
    required this.onOpenInstagram,
    required this.onOpenFacebook,
    required this.onOpenSnapchat,
    required this.onOpenTwitter,
    required this.onOpenEmail,
    required this.onOpenTikTok,
  });

  final Future<void> Function() onOpenWhatsApp;
  final Future<void> Function() onOpenInstagram;
  final Future<void> Function() onOpenFacebook;
  final Future<void> Function() onOpenSnapchat;
  final Future<void> Function() onOpenTwitter;
  final Future<void> Function() onOpenEmail;
  final Future<void> Function() onOpenTikTok;

  @override
  Widget build(BuildContext context) {
    final items = <_SupportAction>[
      _SupportAction(
        label: context.l10n.text('WhatsApp'),
        backgroundColor: const Color(0xFFE4F4E9),
        onTap: onOpenWhatsApp,
        icon: Image.asset(
          'assets/images/whatsapp.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      _SupportAction(
        label: context.l10n.text('Instagram'),
        backgroundColor: const Color(0xFFF4E7EF),
        onTap: onOpenInstagram,
        icon: Image.asset(
          'assets/images/instagram.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      _SupportAction(
        label: context.l10n.text('facebook'),
        backgroundColor: const Color(0xFFF7F2C8),
        onTap: onOpenFacebook,
        icon: Image.asset(
          'assets/images/facebook.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      _SupportAction(
        label: context.l10n.text('Snapchat'),
        backgroundColor: const Color(0xFFF7F2C8),
        onTap: onOpenSnapchat,
        icon: Image.asset(
          'assets/images/snapchat.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      _SupportAction(
        label: context.l10n.text('Twitter'),
        backgroundColor: Colors.white.withOpacity(.22),
        onTap: onOpenTwitter,
        icon: Image.asset(
          'assets/images/twitter.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      _SupportAction(
        label: context.l10n.text('email'),
        backgroundColor: const Color(0xFFF7F1E8),
        onTap: onOpenEmail,
        icon:Image.asset(
          'assets/images/gmail.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      _SupportAction(
        label: context.l10n.text('TikTok'),
        backgroundColor: Colors.white.withOpacity(.42),
        onTap: onOpenTikTok,
        icon: Image.asset(
          'assets/images/tiktok.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
    ];

    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SupportActionTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportAction {
  const _SupportAction({
    required this.label,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Widget icon;
  final Future<void> Function() onTap;
}

class _SupportActionTile extends StatelessWidget {
  const _SupportActionTile({required this.item});

  final _SupportAction item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: item.backgroundColor.withOpacity(.82),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white.withOpacity(.82), width: 1.2),
          ),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(child: item.icon),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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


