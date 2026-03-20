import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'academic_info_screen.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBody(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const AppLogo(center: true),
              const SizedBox(height: 34),
              Text(
                context.l10n.text('createYourAccount'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: context.l10n.text('fullName'),
                hint: context.l10n.text('fullName'),
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: context.l10n.text('email'),
                hint: context.l10n.text('email'),
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: context.l10n.text('mobileNumber'),
                hint: context.l10n.text('mobileNumber'),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              AppDropdownField(
                label: context.l10n.text('country'),
                value: context.l10n.text('arab'),
                icon: Icons.public,
              ),
              const SizedBox(height: 30),
              AppPrimaryButton(
                label: context.l10n.text('createAccount'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AcademicInfoScreen(flowLabel: 'Register'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: AppTextLink(
                  prefix: context.l10n.text('termsPrefix'),
                  link: context.l10n.text('termsLink'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: AppTextLink(
                  prefix: context.l10n.text('alreadyHaveAccount'),
                  link: context.l10n.text('login'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
