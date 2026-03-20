import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class AcademicInfoScreen extends StatelessWidget {
  const AcademicInfoScreen({super.key, required this.flowLabel});

  final String flowLabel;

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBody(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const AppLogo(center: true),
            const SizedBox(height: 34),
            AppDropdownField(
              label: context.l10n.text('country'),
              value: context.l10n.text('arab'),
              icon: Icons.public,
            ),
            const SizedBox(height: 18),
            AppDropdownField(
              label: context.l10n.text('latestAcademic'),
              value: context.l10n.text('latestAcademic'),
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: context.l10n.text('inputResult'),
              hint: context.l10n.text('inputResult'),
              icon: Icons.insert_chart_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            AppDropdownField(
              label: context.l10n.text('courseOrProgram'),
              value: context.l10n.text('bachelorCs'),
              icon: Icons.menu_book_outlined,
            ),
            const SizedBox(height: 32),
            AppPrimaryButton(
              label: flowLabel == 'Register'
                  ? context.l10n.text('createAccount')
                  : context.l10n.text('continue'),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
