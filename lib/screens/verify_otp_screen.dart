import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FakeStatusBar(),
          const SizedBox(height: 18),
          Text(context.l10n.text('verifyOtp'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Center(
            child: Text(
              context.l10n.text('otpHelp'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 28),
          const _OtpRow(),
          const SizedBox(height: 10),
          Center(
            child: Text(
              context.l10n.text('resendOtp'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 36),
          AppPrimaryButton(
            label: context.l10n.text('verifyAndLogin'),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  const _OtpRow();

  @override
  Widget build(BuildContext context) {
    final values = ['4', '7', '', '', '', ''];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values
          .map(
            (value) => Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          )
          .toList(),
    );
  }
}
