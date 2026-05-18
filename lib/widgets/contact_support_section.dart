import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';

class ContactSupportSection extends StatelessWidget {
  const ContactSupportSection({
    super.key,
    required this.onOpenWhatsApp,
    required this.onOpenInstagram,
    required this.onOpenSnapchat,
    required this.onOpenTwitter,
    required this.onOpenEmail,
  });

  final Future<void> Function() onOpenWhatsApp;
  final Future<void> Function() onOpenInstagram;
  final Future<void> Function() onOpenSnapchat;
  final Future<void> Function() onOpenTwitter;
  final Future<void> Function() onOpenEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 14,
            spacing: 14,
            children: [
              _SocialItem(
                icon: Icons.chat,
                label: 'Whatsapp',
                color: const Color(0xFF31B74A),
                onTap: onOpenWhatsApp,
              ),
              _SocialItem(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                color: const Color(0xFFDD2A7B),
                onTap: onOpenInstagram,
              ),
              _SocialItem(
                icon: Icons.tag_faces_rounded,
                label: 'Snapchat',
                color: const Color(0xFFFFD728),
                onTap: onOpenSnapchat,
              ),
              _SocialItem(
                icon: Icons.alternate_email,
                label: 'Twitter',
                color: const Color(0xFF1DA1F2),
                onTap: onOpenTwitter,
              ),
              _SocialItem(
                icon: Icons.email,
                label: 'Email',
                color: AppColors.text,
                onTap: onOpenEmail,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.text('needHelp'),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.text('tapButtonBelow'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onOpenWhatsApp,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF95D7B8),
                    foregroundColor: AppColors.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(context.l10n.text('chatWithUs')),
                ),
              ),
            ],
          ),
        ),
      ],
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
              border: Border.all(color: color, width: 1.4),
            ),
            child: Icon(icon, color: color, size: 22),
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
