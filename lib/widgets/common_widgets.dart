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
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [AppColors.peach, AppColors.background, AppColors.peachSoft],
        ),
      ),
      child: child,
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.center = false});

  final bool center;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'جامعات\nالعرب',
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.logo,
                height: 0.9,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 34, height: 2, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              'ARAB\nUNIVERSITIES',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
            ),
          ],
        ),
      ],
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
          backgroundColor: Colors.white.withOpacity(0.9),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.text,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: Color(0xFFF1C7A2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  });

  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, color: AppColors.textMuted),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
        ),
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
        Text(
          prefix,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            link,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class AppScaffoldBody extends StatelessWidget {
  const AppScaffoldBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
