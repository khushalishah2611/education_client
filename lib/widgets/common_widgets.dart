import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../screens/help_screen.dart';

/// Backward-compatible gradient transform that translates by [dx]/[dy].
///
/// Some shimmer implementations reference `GradientTranslation` directly.
/// Defining it here keeps those widgets compiling across Flutter SDK versions.
class GradientTranslation extends GradientTransform {
  const GradientTranslation(this.dx, this.dy);

  final double dx;
  final double dy;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, dy, 0);
  }
}

enum AppSnackBarType { success, error }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackBarType type = AppSnackBarType.success,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: type == AppSnackBarType.success
            ? const Color(0xFF2E7D32)
            : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class AppPageEntrance extends StatefulWidget {
  const AppPageEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AppPageEntrance> createState() => _AppPageEntranceState();
}

class _AppPageEntranceState extends State<AppPageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        image: DecorationImage(
          image: AssetImage('assets/images/img.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          opacity: 0.15,
        ),
      ),
      child: child,
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.center = false, this.compact = false});

  final bool center;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/logo.webp',
      height: compact ? 42 : 72,
      fit: BoxFit.contain,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [logo],
    );

    return center ? Center(child: content) : content;
  }
}

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: TextButton.icon(
        onPressed: context.toggleLanguage,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.logo,
          backgroundColor: Colors.white.withOpacity(.92),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.language),
        label: Text(context.l10n.text('langLabel')),
      ),
    );
  }
}

class LanguageDropdownChip extends StatelessWidget {
  const LanguageDropdownChip({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;
    return InkWell(
      onTap: context.toggleLanguage,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.92),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8C8AE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(!isArabic ? "🇮🇳" : '🇵🇸', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              !isArabic ? 'English' : 'عربي',
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

class HelpPillButton extends StatelessWidget {
  const HelpPillButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Navigator.of(
      //   context,
      // ).push(MaterialPageRoute(builder: (_) => const HelpScreen())),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBD9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline_rounded, size: 18),
            const SizedBox(width: 6),
            Text(
              context.l10n.text('help').toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.bottomCardColor = Colors.white,
    this.isLoading = false,
  });

  final Widget child;
  final Color bottomCardColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontalPadding = size.width < 360 ? 14.0 : 16.0;
    final topPadding = size.height < 760 ? 32.0 : 52.0;
    final bottomPadding = size.height < 760 ? 32.0 : 52.0;

    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: const Color(0xFFF8EFE6),
              child: SafeArea(
                child: Stack(
                  children: [
                    /// 🔥 BACKGROUND IMAGE (FIXED)
                    Image.asset(
                      'assets/images/img.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    /// 🔥 MAIN CONTENT
                    Column(
                      children: [
                        /// 🔝 TOP BAR
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              HelpPillButton(),
                              LanguageDropdownChip(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ✅ CENTER LOGO (PERFECT POSITION)
                        Expanded(
                          child: Center(
                            child: Image.asset('assets/images/logo.webp'),
                          ),
                        ),

                        /// ⬇️ BOTTOM CARD (LOGIN AREA)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            topPadding,
                            horizontalPadding,
                            bottomPadding,
                          ),
                          decoration: BoxDecoration(
                            color: bottomCardColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: child,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallMobile = screenWidth <= 360;

    return SizedBox(
      width: double.infinity,
      height: isSmallMobile ? 42 : 45,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.text,
          disabledBackgroundColor: AppColors.primary.withOpacity(.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: isSmallMobile ? 15 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.text,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: Color(0xFFF1C7A2)),
          backgroundColor: const Color(0xFFFFFCF8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.suffixicon,
    this.controller,
    this.keyboardType,
    this.height = 45,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final Widget? suffixicon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, color: AppColors.textMuted, size: 20),

              /// ✅ DIRECT WIDGET USE
              suffixIcon: suffixicon,
            ),
          ),
        ),
      ],
    );
  }
}

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),

        /// FIXED HEIGHT CONTAINER
        Container(
          height: 45,
          alignment: Alignment.center,
          child: InputDecorator(
            decoration: InputDecoration(
              isDense: true, // important for compact height
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.prefix,
    required this.link,
    this.onTap,
  });

  final String prefix;
  final String link;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          prefix,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            link,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class AppScaffoldBody extends StatelessWidget {
  const AppScaffoldBody({
    super.key,
    required this.child,
    this.horizontalPadding = 10,
    this.topPadding = 12,
  });

  final Widget child;
  final double horizontalPadding;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(child: AppPageEntrance(child: child)),
        ),
      ),
    );
  }
}

class HeroIllustration extends StatelessWidget {
  const HeroIllustration({
    super.key,
    this.height = 320,
    this.showPattern = true,
  });

  final double height;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [Image.asset('assets/images/welcome.png')],
      ),
    );

    return content;
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}
