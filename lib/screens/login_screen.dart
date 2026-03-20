import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FakeStatusBar(),
          const SizedBox(height: 18),
          Text(context.l10n.text('loginWithOtp'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          AppTextField(
            label: context.l10n.text('email'),
            hint: context.l10n.text('email'),
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 30),
          AppPrimaryButton(
            label: context.l10n.text('sendOtp'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VerifyOtpScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
