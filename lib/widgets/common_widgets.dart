import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDE3CF), Color(0xFFFFFBF7), Color(0xFFFCE1CB)],
          stops: [0, .42, 1],
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
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.language),
        label: Text(context.l10n.text('langLabel')),
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
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.text,
          disabledBackgroundColor: AppColors.primary.withOpacity(.7),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.text),
              )
            : Text(label),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({super.key, required this.label, required this.onPressed});

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    this.controller,
    this.keyboardType,
    this.height = 45,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text)),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              prefixIcon: icon == null ? null : Icon(icon, color: AppColors.textMuted, size: 20),
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
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text)),
        const SizedBox(height: 10),
        InputDecorator(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          ),
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted)),
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
        Text(prefix, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
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
  const AppScaffoldBody({super.key, required this.child, this.horizontalPadding = 10, this.topPadding = 12});

  final Widget child;
  final double horizontalPadding;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: child,
          ),
        ),
      ),
    );
  }
}

class HeroIllustration extends StatelessWidget {
  const HeroIllustration({super.key, this.height = 320, this.showPattern = true});

  final double height;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children:  [
          Image.asset(
              'assets/images/welcome.png'
          ),
        ],
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
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
    );
  }
}

