import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import 'side_menu_common.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('termsAndConditions'),
      child: const ListView(
        children: [
          SectionCard(
            title: 'Use of the App',
            bullets: [
              'This app provides admissions-related data, forms, and notifications.',
              'Users must share authentic details only while applying.',
              'Misuse may lead to account restriction.',
            ],
          ),
          SizedBox(height: 10),
          SectionCard(
            title: 'User Account',
            bullets: [
              'You are responsible for maintaining the confidentiality of your account.',
              'Notify support if any suspicious activity appears.',
            ],
          ),
          SizedBox(height: 10),
          SectionCard(
            title: 'Privacy',
            bullets: [
              'Personal information is handled according to our privacy policy.',
              'Data may be used to improve app functionality and experience.',
            ],
          ),
        ],
      ),
    );
  }
}
