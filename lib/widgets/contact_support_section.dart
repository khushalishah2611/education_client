import 'dart:ui';

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
    this.onOpenTikTok,
  });

  final Future<void> Function() onOpenWhatsApp;
  final Future<void> Function() onOpenInstagram;
  final Future<void> Function() onOpenSnapchat;
  final Future<void> Function() onOpenTwitter;
  final Future<void> Function() onOpenEmail;
  final Future<void> Function()? onOpenTikTok;

  @override
  Widget build(BuildContext context) {
    final items = <_SupportAction>[
      _SupportAction(
        label: 'Whatsapp',
        backgroundColor: const Color(0xFFE4F4E9),
        onTap: onOpenWhatsApp,
        icon: const _WhatsAppIcon(),
      ),
      _SupportAction(
        label: 'Instagram',
        backgroundColor: const Color(0xFFF4E7EF),
        onTap: onOpenInstagram,
        icon: const _InstagramIcon(),
      ),
      _SupportAction(
        label: 'Snapchat',
        backgroundColor: const Color(0xFFF7F2C8),
        onTap: onOpenSnapchat,
        icon: const _SnapchatIcon(),
      ),
      _SupportAction(
        label: 'Twitter',
        backgroundColor: Colors.white.withOpacity(.22),
        onTap: onOpenTwitter,
        icon: const _XIcon(),
      ),
      _SupportAction(
        label: 'Email',
        backgroundColor: const Color(0xFFF7F1E8),
        onTap: onOpenEmail,
        icon: const _GmailIcon(),
      ),
      _SupportAction(
        label: 'Tik Tok',
        backgroundColor: Colors.white.withOpacity(.42),
        onTap: onOpenTikTok ?? onOpenWhatsApp,
        icon: const _TikTokIcon(),
      ),
    ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SupportActionTile(item: item),
            ),
          ),
          const SizedBox(height: 30),
          _HelpHubButton(onTap: onOpenWhatsApp),
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

class _HelpHubButton extends StatelessWidget {
  const _HelpHubButton({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 110,
        height: 110,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.08),
          border: Border.all(color: Colors.white.withOpacity(.86)),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(.24),
            border: Border.all(color: Colors.white.withOpacity(.76)),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.text('helpHub'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    context.l10n.text('chatWithUs').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.chat_bubble_outline_rounded,
      color: Color(0xFF31B74A),
      size: 36,
    );
  }
}

class _InstagramIcon extends StatelessWidget {
  const _InstagramIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 33,
      height: 33,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF5B51D8), Color(0xFFC13584), Color(0xFFFCAF45)],
        ),
      ),
      child: const Icon(
        Icons.camera_alt_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _SnapchatIcon extends StatelessWidget {
  const _SnapchatIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFC00),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('👻', style: TextStyle(fontSize: 23, height: 1)),
      ),
    );
  }
}

class _XIcon extends StatelessWidget {
  const _XIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Center(
        child: Text(
          '𝕏',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            height: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _GmailIcon extends StatelessWidget {
  const _GmailIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(36, 28), painter: _GmailPainter());
  }
}

class _TikTokIcon extends StatelessWidget {
  const _TikTokIcon();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 7,
          top: 8,
          child: Text(
            '♪',
            style: TextStyle(
              color: Color(0xFF25F4EE),
              fontSize: 39,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 10,
          child: Text(
            '♪',
            style: TextStyle(
              color: Color(0xFFFE2C55),
              fontSize: 39,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '♪',
          style: TextStyle(
            color: Colors.black,
            fontSize: 39,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GmailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()
      ..color = const Color(0xFFE94235)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round;
    final grey = Paint()
      ..color = const Color(0xFFE8EAED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(2, 4)
      ..lineTo(2, size.height - 3)
      ..lineTo(size.width - 2, size.height - 3)
      ..lineTo(size.width - 2, 4);
    canvas.drawPath(body, grey);

    final flap = Path()
      ..moveTo(2, 4)
      ..lineTo(size.width / 2, size.height / 2 + 2)
      ..lineTo(size.width - 2, 4);
    canvas.drawPath(flap, red);

    canvas.drawLine(2, 4, 2, size.height - 3, red);
    canvas.drawLine(size.width - 2, 4, size.width - 2, size.height - 3, red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
