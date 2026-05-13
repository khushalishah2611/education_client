import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../core/responsive_helper.dart';
import '../core/student_session.dart';
import '../models/document_type.dart';
import '../services/application_api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_screen.dart';

typedef _DocumentDefinition = ({
String type,
String title,
String subtitle,
});

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
  State<UploadDocumentsScreen> createState() =>
      _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState
    extends State<UploadDocumentsScreen> {
  static const int _maxUploadBytes = 5 * 1024 * 1024;

  final Map<String, PlatformFile?> _selectedFiles =
  <String, PlatformFile?>{};

  final ApplicationApiService _applicationApiService =
  const ApplicationApiService();

  bool _isUploading = false;

  List<_DocumentDefinition> _docs =
  const <_DocumentDefinition>[];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final List<DocumentTypeItem> types =
      await _applicationApiService.fetchDocumentTypes();

      final bool isArabic =
          WidgetsBinding
              .instance
              .platformDispatcher
              .locale
              .languageCode ==
              'ar';

      final List<_DocumentDefinition> docs =
      _documentDefinitionsFromTypes(
        types,
        isArabic: isArabic,
      );

      if (!mounted) return;

      setState(() {
        _docs = docs;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _pickDocument(
      _DocumentDefinition doc,
      ) async {
    final result =
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final PlatformFile file =
        result.files.first;

    final String? filePath = file.path;

    if (filePath == null ||
        filePath.isEmpty) {
      return;
    }

    if (file.size > _maxUploadBytes) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message:
        'File too large. Maximum allowed size is 5 MB.',
      );

      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final String studentUserId =
      await _resolveStudentUserId();

      if (studentUserId.isEmpty) {
        throw Exception(
          'studentUserId not found',
        );
      }

      await _applicationApiService
          .uploadStudentDocument(
        studentUserId: studentUserId,
        type: doc.type,
        filePath: filePath,
        fileName: file.name,
      );

      final String documentKey =
      _documentKey(doc.type);

      setState(() {
        _selectedFiles[documentKey] = file;
      });

      if (!mounted) return;

      showAppSnackBar(
        context,
        type: AppSnackBarType.success,
        message:
        '${doc.title} uploaded successfully',
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
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  bool get _hasAllRequiredDocuments =>
      _docs.isNotEmpty &&
          _docs.every(
                (doc) {
              final String documentKey =
              _documentKey(doc.type);

              return _selectedFiles[
              documentKey] !=
                  null;
            },
          );

  Future<void> _onContinue() async {
    if (!_hasAllRequiredDocuments) {
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.text(
          'uploadAllRequiredDocs',
        ),
      );

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          universityName:
          widget.universityName,
          universityHeroImage:
          widget.universityHeroImage,
          courseTitle:
          widget.courseTitle,
          applicationsPayload:
          widget.applicationsPayload,
        ),
      ),
    );
  }

  Future<String>
  _resolveStudentUserId() async {
    final String fromSession =
    await StudentSession
        .currentStudentUserId();

    if (fromSession.isNotEmpty) {
      return fromSession;
    }

    for (final Map<String, dynamic>
    item in widget
        .applicationsPayload) {
      final String fromTopLevel =
      (item['studentUserId'] ?? '')
          .toString()
          .trim();

      if (fromTopLevel.isNotEmpty) {
        return fromTopLevel;
      }

      final String fromStudentId =
      (item['studentId'] ?? '')
          .toString()
          .trim();

      if (fromStudentId.isNotEmpty) {
        return fromStudentId;
      }

      final Object? student =
      item['student'];

      if (student is Map) {
        final String
        fromStudentObject =
        (student['id'] ?? '')
            .toString()
            .trim();

        if (fromStudentObject
            .isNotEmpty) {
          return fromStudentObject;
        }
      }

      final Object? application =
      item['application'];

      if (application is Map) {
        final String fromApplication =
        (application[
        'studentUserId'] ??
            '')
            .toString()
            .trim();

        if (fromApplication
            .isNotEmpty) {
          return fromApplication;
        }

        final String
        fromApplicationStudentId =
        (application['studentId'] ??
            '')
            .toString()
            .trim();

        if (fromApplicationStudentId
            .isNotEmpty) {
          return fromApplicationStudentId;
        }
      }
    }

    return '';
  }

  String? _selectedFileLabel(
      String type,
      ) {
    final String documentKey =
    _documentKey(type);

    final PlatformFile? file =
    _selectedFiles[documentKey];

    return file?.name;
  }

  Future<void> _handleDocumentTap(
      _DocumentDefinition doc,
      ) async {
    await _pickDocument(doc);
  }

  List<_DocumentDefinition>
  _documentDefinitionsFromTypes(
      List<DocumentTypeItem> types, {
        required bool isArabic,
      }) {
    final Set<String> seenKeys =
    <String>{};

    final List<_DocumentDefinition>
    docs =
    <_DocumentDefinition>[];

    for (final DocumentTypeItem
    item in types) {
      final String type =
      item.value.trim();

      final String key =
      _documentKey(type);

      if (key.isEmpty ||
          !seenKeys.add(key)) {
        continue;
      }

      final String localizedTitle =
      (isArabic
          ? item.labelAr
          : item.labelEn)
          .trim();

      final String fallbackTitle =
      item.labelEn
          .trim()
          .ifEmpty(
        item.labelAr.trim(),
      );

      docs.add(
        (
        type: type,
        title: localizedTitle
            .ifEmpty(fallbackTitle)
            .ifEmpty(type),
        subtitle: type,
        ),
      );
    }

    return docs;
  }

  String _documentKey(String type) {
    return type
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'[\s\-/]+'),
      '_',
    )
        .replaceAll(
      RegExp(r'_+'),
      '_',
    )
        .replaceAll(
      RegExp(r'^_|_$'),
      '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile =
        context.isSmallMobile;

    final double horizontalPadding =
        context
            .responsiveHorizontalPadding;

    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              FlowStepHeader(
                currentStep: 0,
                title: context.l10n.text(
                  'uploadDocuments',
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        if (_docs.isEmpty) {
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            child: Container(
                              width:
                              double.infinity,
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 12,
                              ),
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  10,
                                ),
                                border:
                                Border.all(
                                  color:
                                  const Color(
                                    0xFFE6E6E6,
                                  ),
                                ),
                                color:
                                Colors.white,
                              ),
                              child: Text(
                                context.l10n
                                    .text(
                                  'No document types found',
                                ),
                                textAlign:
                                TextAlign
                                    .center,
                                style:
                                const TextStyle(
                                  color: Color(
                                    0xFF616161,
                                  ),
                                  fontWeight:
                                  FontWeight
                                      .w500,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView(
                          padding:
                          EdgeInsets.fromLTRB(
                            horizontalPadding,
                            isSmallMobile
                                ? 14
                                : 20,
                            horizontalPadding,
                            20,
                          ),
                          children: [
                            Text(
                              context.l10n.text(
                                'requiredDocuments',
                              ),
                              style:
                              TextStyle(
                                fontSize:
                                isSmallMobile
                                    ? 16
                                    : 18,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            _UploadDropZone(
                              title: _docs
                                  .first.title,
                              subtitle: _docs
                                  .first.subtitle,
                              selectedFileName:
                              _selectedFileLabel(
                                _docs.first.type,
                              ),
                              onTap:
                              _isUploading
                                  ? () {}
                                  : () => _handleDocumentTap(
                                _docs.first,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ..._docs
                                .skip(1)
                                .map(
                                  (doc) =>
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(
                                      bottom:
                                      10,
                                    ),
                                    child:
                                    _UploadListTile(
                                      title:
                                      doc.title,
                                      subtitle:
                                      doc.subtitle,
                                      selectedFileName:
                                      _selectedFileLabel(
                                        doc.type,
                                      ),
                                      onTap:
                                      _isUploading
                                          ? () {}
                                          : () => _handleDocumentTap(
                                        doc,
                                      ),
                                    ),
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: ColoredBox(
                          color:
                          Color.fromRGBO(
                            0,
                            0,
                            0,
                            0.25,
                          ),
                          child: Center(
                            child:
                            CircularProgressIndicator(
                              color:
                              AppColors
                                  .primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  child:
                  AppPrimaryButton(
                    label: context.l10n
                        .text(
                      'saveContinue',
                    ),
                    onPressed:
                    _isUploading
                        ? null
                        : () =>
                        _onContinue(),
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

extension _StringFallback on String {
  String ifEmpty(String? fallback) {
    return isEmpty
        ? (fallback ?? '')
        : this;
  }
}

class _UploadDropZone
    extends StatelessWidget {
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
    final bool isUploaded =
        selectedFileName != null;

    return InkWell(
      borderRadius:
      BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          border: Border.all(
            color:
            const Color(0xFFE8E2D9),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const _DocIcon(),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        title,
                        style:
                        const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style:
                        const TextStyle(
                          color: AppColors
                              .textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 26,
            ),
            Icon(
              isUploaded
                  ? Icons
                  .check_circle_outline
                  : Icons
                  .cloud_upload_outlined,
              size: 54,
              color: isUploaded
                  ? AppColors.accent
                  : const Color(
                0xFFB8B8B8,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text.rich(
              TextSpan(
                text: isUploaded
                    ? context.l10n.text(
                  'uploaded',
                )
                    : context.l10n.text(
                  'tapToBrowse',
                ),
                style:
                const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  AppColors.text,
                ),
                children: [
                  if (!isUploaded)
                    TextSpan(
                      text: context
                          .l10n
                          .text(
                        'uploadFormats',
                      ),
                      style:
                      const TextStyle(
                        color:
                        AppColors
                            .accent,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              selectedFileName ??
                  '${context.l10n.text('supportedPrefix')}${context.l10n.text('uploadFormats')}',
              style: TextStyle(
                color:
                selectedFileName ==
                    null
                    ? AppColors
                    .textMuted
                    : AppColors
                    .accent,
                fontWeight:
                selectedFileName ==
                    null
                    ? FontWeight
                    .w400
                    : FontWeight
                    .w600,
              ),
              textAlign:
              TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadListTile
    extends StatelessWidget {
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
    final bool isUploaded =
        selectedFileName != null;

    return InkWell(
      borderRadius:
      BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          border: Border.all(
            color:
            const Color(0xFFE8E2D9),
          ),
        ),
        child: Row(
          children: [
            const _DocIcon(),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    isUploaded
                        ? selectedFileName!
                        : subtitle,
                    style: TextStyle(
                      color: isUploaded
                          ? AppColors
                          .accent
                          : AppColors
                          .textMuted,
                      fontWeight:
                      isUploaded
                          ? FontWeight
                          .w600
                          : FontWeight
                          .w400,
                    ),
                    overflow:
                    TextOverflow
                        .ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration:
              BoxDecoration(
                color: isUploaded
                    ? const Color(
                  0xFFA0E1BE,
                )
                    : const Color(
                  0xFFECECEC,
                ),
                borderRadius:
                BorderRadius
                    .circular(8),
              ),
              child: Icon(
                isUploaded
                    ? Icons.check
                    : Icons
                    .upload_outlined,
                size: 18,
                color:
                Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocIcon
    extends StatelessWidget {
  const _DocIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
        const Color(0xFFF4F4F4),
        borderRadius:
        BorderRadius.circular(
          8,
        ),
      ),
      child: const Icon(
        Icons.description_outlined,
        color: AppColors.accent,
      ),
    );
  }
}
