import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_screen.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({
    super.key,
    required this.university,
    required this.course,
  });

  final UniversityData university;
  final CourseData course;

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final List<({String title, String subtitle})> _docs = const [
    (title: 'Passport', subtitle: 'Valid for at least 6 months'),
    (title: 'Statement of Purpose (SOP)', subtitle: 'Words about your goals'),
    (title: 'LOR', subtitle: 'From 2 different academic reference'),
    (title: 'Resume / CV', subtitle: 'Latest professional experience'),
  ];

  late final Map<String, PlatformFile?> _selectedFiles = {
    for (final doc in _docs) doc.title: null,
  };

  Future<void> _pickDocument(String docTitle) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _selectedFiles[docTitle] = result.files.first;
    });
  }

  bool get _allDocumentsSelected => _selectedFiles.values.every((file) => file != null);

  void _onContinue() {
    if (!_allDocumentsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          university: widget.university,
          course: widget.course,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FlowStepHeader(currentStep: 0, title: 'Upload Documents'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  children: [
                    const Text(
                      'Required Documents',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    _UploadDropZone(
                      title: _docs.first.title,
                      subtitle: _docs.first.subtitle,
                      selectedFileName: _selectedFiles[_docs.first.title]?.name,
                      onTap: () => _pickDocument(_docs.first.title),
                    ),
                    const SizedBox(height: 10),
                    ..._docs.skip(1).map(
                      (doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UploadListTile(
                          title: doc.title,
                          subtitle: doc.subtitle,
                          selectedFileName: _selectedFiles[doc.title]?.name,
                          onTap: () => _pickDocument(doc.title),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPrimaryButton(
                      label: 'Save & Continue',
                      onPressed: _onContinue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  const _UploadDropZone({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selectedFileName,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E2D9)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const _DocIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 26),
            const Icon(
              Icons.cloud_upload_outlined,
              size: 54,
              color: Color(0xFFB8B8B8),
            ),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                text: 'Tap to Browse ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                children: [
                  TextSpan(
                    text: 'PDF / JPG / PNG',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selectedFileName == null
                  ? 'Supported: PDF, JPG, PNG'
                  : 'Selected: $selectedFileName',
              style: TextStyle(
                color: selectedFileName == null
                    ? AppColors.textMuted
                    : AppColors.accent,
                fontWeight: selectedFileName == null
                    ? FontWeight.w400
                    : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadListTile extends StatelessWidget {
  const _UploadListTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selectedFileName,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    final bool isUploaded = selectedFileName != null;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E2D9)),
        ),
        child: Row(
          children: [
            const _DocIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded ? selectedFileName! : subtitle,
                    style: TextStyle(
                      color: isUploaded ? AppColors.accent : AppColors.textMuted,
                      fontWeight: isUploaded ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFFA0E1BE)
                    : const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isUploaded ? Icons.check : Icons.upload_outlined,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocIcon extends StatelessWidget {
  const _DocIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.description_outlined, color: AppColors.accent),
    );
  }
}
