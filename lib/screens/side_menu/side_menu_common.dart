import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../core/responsive_helper.dart';
import '../../core/app_theme.dart';
import '../login_screen.dart';
import '../../widgets/common_widgets.dart';

class SideMenuScaffold extends StatelessWidget {
  const SideMenuScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = true,
  });

  final String title;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double titleFontSize = isSmallMobile ? 16 : 18;

    return Material(
      child: SafeArea(
        child: AppBackground(
          child: Column(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (showBackButton)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isSmallMobile ? 12 : 16,
                          ),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF6F6F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallMobile ? 42 : 50,
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: titleFontSize),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Center(
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleTile extends StatelessWidget {
  const SimpleTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.onTap,
  });

  final IconData leading;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E1D9)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFE2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                leading,
                size: 16,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallMobile ? 11 : 12,
                    ),
                  ),
                  const SizedBox(height: 2),

                  subtitleWidget ??
                      Text(
                        subtitle ?? '',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 9 : 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                ],
              ),
            ),

            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.bullets});

  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 6),
          ...bullets.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 11 : 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showLogoutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black45,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEFE3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.text('logoutConfirmMessage'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2EDE7),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          context.l10n.text('cancel'),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (!context.mounted) return;

                          navigator.pop();
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDF0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          context.l10n.text('confirm'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
