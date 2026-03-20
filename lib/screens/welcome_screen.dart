import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBody(
      horizontalPadding: 0,
      topPadding: 8,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: FakeStatusBar(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: HeroIllustration(height: 420),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.l10n.text('welcomeTitle'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.15),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.l10n.text('welcomeSubtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 17, height: 1.45, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 28),
                          AppPrimaryButton(
                            label: context.l10n.text('login'),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppOutlinedButton(
                            label: context.l10n.text('createAccount'),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                            ),
                          ),
                        ],
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
