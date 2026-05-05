import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/responsive_helper.dart';
import '../models/document_type.dart';
import '../services/application_api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_screen.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({
    super.key,
    this.universityName,
    this.universityHeroImage,
    this.courseTitle,
    this.applicationsPayload = const <Map<String, dynamic>>[],
  });

  final String? universityName;
  final String? universityHeroImage;
  final String? courseTitle;
  final List<Map<String, dynamic>> applicationsPayload;

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  late final Map<String, PlatformFile?> _selectedFiles = {};
  final ApplicationApiService _applicationApiService = const ApplicationApiService();
  bool _isUploading = false;
  List<({String type, String title, String subtitle})> _docs = const [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isUploading = true;
      _loadError = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId = prefs.getString('studentUserId')?.trim() ?? '';
      if (studentUserId.isEmpty) {
        throw Exception('studentUserId not found');
      }

      final List<DocumentTypeItem> types = await _applicationApiService.fetchDocumentTypes();
      final List<Map<String, dynamic>> uploaded = await _applicationApiService.fetchStudentDocuments(
        studentUserId: studentUserId,
      );
      final bool isArabic = (WidgetsBinding.instance.platformDispatcher.locale.languageCode) == 'ar';

      final docs = types
          .map(
            (item) => (
              type: item.value,
              title: isArabic ? item.labelAr : item.labelEn,
              subtitle: item.value,
            ),
          )
          .toList(growable: false);

      final Map<String, String> uploadedByType = <String, String>{};
      for (final item in uploaded) {
        final String type = item['type']?.toString() ?? '';
        final String fileName = item['fileName']?.toString() ?? '';
        if (type.isNotEmpty && fileName.isNotEmpty) {
          uploadedByType[type] = fileName;
        }
      }

      if (!mounted) return;
      setState(() {
        _docs = docs;
        _selectedFiles
          ..clear()
          ..addEntries(
            docs.map((doc) {
              final String? fileName = uploadedByType[doc.type];
              final PlatformFile? file = fileName == null ? null : PlatformFile(name: fileName, size: 0);
              return MapEntry<String, PlatformFile?>(doc.title, file);
            }),
          );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickDocument(({String type, String title, String subtitle}) doc) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    final filePath = file.path;
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    setState(() => _isUploading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId = prefs.getString('studentUserId')?.trim() ?? '';
      if (studentUserId.isEmpty) {
        throw Exception('studentUserId not found');
      }

      await _applicationApiService.uploadStudentDocument(
        studentUserId: studentUserId,
        type: doc.type,
        filePath: filePath,
        fileName: file.name,
      );

      setState(() {
        _selectedFiles[doc.title] = file;
      });
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.success,
        message: '${doc.title} uploaded successfully',
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  bool get _allDocumentsSelected => _selectedFiles.values.every((file) => file != null);

  void _onContinue() {
    if (!_allDocumentsSelected) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.text('uploadAllRequiredDocs'),
      );
      return;
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            universityName: widget.universityName,
            universityHeroImage: widget.universityHeroImage,
            courseTitle: widget.courseTitle,
            applicationsPayload: widget.applicationsPayload,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;
    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlowStepHeader(
                currentStep: 0,
                title: context.l10n.text('uploadDocuments'),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        if (_loadError != null) {
                          return Center(
                            child: Text(
                              _loadError!,
                              style: const TextStyle(color: AppColors.accent),
                            ),
                          );
                        }

                        if (_docs.isEmpty) {
                          return const Center(child: Text('No document types found'));
                        }

                        return ListView(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            isSmallMobile ? 14 : 20,
                            horizontalPadding,
                            20,
                          ),
                          children: [
                            Text(
                              context.l10n.text('requiredDocuments'),
                              style: TextStyle(
                                fontSize: isSmallMobile ? 16 : 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _UploadDropZone(
                              title: _docs.first.title,
                              subtitle: _docs.first.subtitle,
                              selectedFileName: _selectedFiles[_docs.first.title]?.name,
                              onTap: _isUploading ? () {} : () => _pickDocument(_docs.first),
                            ),
                            const SizedBox(height: 10),
                            ..._docs.skip(1).map(
                              (doc) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _UploadListTile(
                                  title: doc.title,
                                  subtitle: doc.subtitle,
                                  selectedFileName: _selectedFiles[doc.title]?.name,
                                  onTap: _isUploading ? () {} : () => _pickDocument(doc),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            AppPrimaryButton(
                              label: context.l10n.text('saveContinue'),
                              onPressed: _isUploading ? null : _onContinue,
                            ),
                          ],
                        );
                      },
                    ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
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
            Text.rich(
              TextSpan(
                text: context.l10n.text('tapToBrowse'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                children: [
                  TextSpan(
                    text: context.l10n.text('uploadFormats'),
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selectedFileName == null
                  ? '${context.l10n.text('supportedPrefix')}${context.l10n.text('uploadFormats')}'
                  : '${context.l10n.text('selectedPrefix')}$selectedFileName',
              style: TextStyle(
                color: selectedFileName == null ? AppColors.textMuted : AppColors.accent,
                fontWeight: selectedFileName == null ? FontWeight.w400 : FontWeight.w600,
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
                color: isUploaded ? const Color(0xFFA0E1BE) : const Color(0xFFECECEC),
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
