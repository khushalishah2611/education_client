import 'package:flutter/material.dart';

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
  final ApplicationApiService _applicationApiService = const ApplicationApiService();
  final Set<String> _uploadedDocumentTypeIds = <String>{};

  bool _isLoading = true;
  bool _isSubmitting = false;
  List<DocumentTypeItem> _documentTypes = const <DocumentTypeItem>[];

  @override
  void initState() {
    super.initState();
    _loadDocumentTypes();
  }

  Future<void> _loadDocumentTypes() async {
    setState(() => _isLoading = true);
    try {
      final items = await _applicationApiService.fetchDocumentTypes();
      if (!mounted) return;
      setState(() => _documentTypes = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _documentTypes = const <DocumentTypeItem>[]);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _hasMinimumOneDocument => _uploadedDocumentTypeIds.isNotEmpty;

  void _toggleUploaded(String id) {
    setState(() {
      if (_uploadedDocumentTypeIds.contains(id)) {
        _uploadedDocumentTypeIds.remove(id);
      } else {
        _uploadedDocumentTypeIds.add(id);
      }
    });
  }

  void _onContinue() {
    if (!_hasMinimumOneDocument) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: 'Please upload at least one document.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              universityName: widget.universityName,
              universityHeroImage: widget.universityHeroImage,
              courseTitle: widget.courseTitle,
              applicationsPayload: widget.applicationsPayload,
            ),
          ),
        )
        .whenComplete(() {
          if (mounted) {
            setState(() => _isSubmitting = false);
          }
        });
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isSmallMobile ? 14 : 20,
                          horizontalPadding,
                          20,
                        ),
                        children: [
                          Text(
                            'Document Types',
                            style: TextStyle(
                              fontSize: isSmallMobile ? 16 : 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Minimum one document upload required.',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 12),
                          if (_documentTypes.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE8E2D9)),
                              ),
                              child: const Text('No document types available.'),
                            )
                          else
                            ..._documentTypes.map((type) {
                              final bool isUploaded = _uploadedDocumentTypeIds.contains(type.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () => _toggleUploaded(type.id),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE8E2D9)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                context.l10n.isArabic && type.labelAr.isNotEmpty
                                                    ? type.labelAr
                                                    : type.labelEn,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(type.value, style: const TextStyle(color: AppColors.textMuted)),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          value: isUploaded,
                                          onChanged: (_) => _toggleUploaded(type.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 14),
                          AppPrimaryButton(
                            label: context.l10n.text('saveContinue'),
                            onPressed: _isSubmitting ? null : _onContinue,
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
