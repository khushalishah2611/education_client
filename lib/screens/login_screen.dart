import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.text('loginWithOtp'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          Text(context.l10n.text('mobileNumber'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Text('🇵🇸 +1'),
                const SizedBox(width: 10),
                Container(width: 1, height: 30, color: AppColors.border),
                const SizedBox(width: 12),
                Text(
                  '70235 68911',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          AppPrimaryButton(
            label: context.l10n.text('sendOtp'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VerifyOtpScreen()),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.check_box_outline_blank_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.text('termsPrivacy'),
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
