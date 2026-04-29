import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class UploadedDocumentsScreen extends StatelessWidget {
  const UploadedDocumentsScreen({super.key, this.activeTab = false});

  final bool activeTab;

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: 'Uploaded Documents',
      showBackButton: activeTab,
      child: UploadedDocumentsContent(),
    );
  }
}

class UploadedDocumentsContent extends StatelessWidget {
  const UploadedDocumentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    const docs = [
      ('Passport', '2.6 MB'),
      ('Academic Transcript', '2.2 MB'),
      ('Statement of Purpose (SOP)', '2.0 MB'),
      ('LOR', '1.8 MB'),
      ('CV', '2.4 MB'),
      ('Resume / CV', '2.1 MB'),
    ];

    return ListView.separated(
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final doc = docs[index];
        return SimpleTile(
          leading: Icons.picture_as_pdf_outlined,
          title: doc.$1,
          subtitle: doc.$2,
          trailing: const Icon(
            Icons.cancel_outlined,
            color: AppColors.textMuted,
          ),
        );
      },
    );
  }
}
