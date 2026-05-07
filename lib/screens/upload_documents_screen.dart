import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_localizations.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../core/responsive_helper.dart';
import '../models/document_type.dart';
import '../services/application_api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_screen.dart';

typedef _DocumentDefinition = ({String type, String title, String subtitle});

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
  static const int _maxUploadBytes = 5 * 1024 * 1024;
  late final Map<String, PlatformFile?> _selectedFiles = {};
  final Map<String, _UploadedDocumentInfo> _uploadedDocuments =
      <String, _UploadedDocumentInfo>{};
  final ApplicationApiService _applicationApiService =
      const ApplicationApiService();
  bool _isUploading = false;
  List<_DocumentDefinition> _docs = const [];
  Map<String, String> _documentTypeAliases = const <String, String>{};

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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';
      final List<DocumentTypeItem> types =
          await _applicationApiService.fetchDocumentTypes();
      final List<Map<String, dynamic>> uploaded =
          await _applicationApiService.fetchStudentDocuments(
        studentUserId: studentUserId,
      );
      final bool isArabic =
          (WidgetsBinding.instance.platformDispatcher.locale.languageCode) ==
              'ar';

      final List<_DocumentDefinition> docs =
          _documentDefinitionsFromTypes(types, isArabic: isArabic);
      final Map<String, String> documentTypeAliases =
          _documentTypeAliasesFromTypes(types);
      final Map<String, _UploadedDocumentInfo> uploadedDocs =
          _uploadedDocumentsFromApiItems(
        uploaded,
        documentTypeAliases: documentTypeAliases,
      );

      if (!mounted) return;
      setState(() {
        _docs = docs;
        _documentTypeAliases = documentTypeAliases;
        _uploadedDocuments
          ..clear()
          ..addAll(uploadedDocs);
      });
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickDocument(
    _DocumentDefinition doc,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
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

    if (file.size > _maxUploadBytes) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: 'File too large. Maximum allowed size is 5 MB.',
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';
      if (studentUserId.isEmpty) {
        throw Exception('studentUserId not found');
      }

      final Map<String, dynamic> response =
          await _applicationApiService.uploadStudentDocument(
        studentUserId: studentUserId,
        type: doc.type,
        filePath: filePath,
        fileName: file.name,
      );
      final _UploadedDocumentInfo uploadedDocument =
          _uploadedDocumentFromUploadResponse(
        response,
        fallbackType: doc.type,
        fallbackFileName: file.name,
        fallbackFilePath: filePath,
      );

      final String documentKey = _resolveDocumentKey(doc.type);
      setState(() {
        _selectedFiles[documentKey] = file;
        _uploadedDocuments[documentKey] = uploadedDocument;
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

  bool get _hasAllRequiredDocuments =>
      _docs.isNotEmpty &&
      _docs.every(
        (doc) {
          final String documentKey = _resolveDocumentKey(doc.type);
          return _selectedFiles[documentKey] != null ||
              _hasUploadedDocumentForKey(documentKey);
        },
      );

  Future<bool> _refreshUploadedDocuments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String studentUserId = prefs.getString('studentUserId')?.trim() ?? '';
    final List<Map<String, dynamic>> uploaded =
        await _applicationApiService.fetchStudentDocuments(
      studentUserId: studentUserId,
    );
    final Map<String, _UploadedDocumentInfo> uploadedDocs =
        _uploadedDocumentsFromApiItems(
      uploaded,
      documentTypeAliases: _documentTypeAliases,
    );

    if (mounted) {
      setState(() {
        _uploadedDocuments
          ..clear()
          ..addAll(uploadedDocs);
      });
    }

    return _docs.every(
      (doc) {
        final String documentKey = _resolveDocumentKey(doc.type);
        return _selectedFiles[documentKey] != null ||
            _hasUploadedDocumentForKey(
              documentKey,
              uploadedDocuments: uploadedDocs,
            );
      },
    );
  }

  Future<void> _onContinue() async {
    setState(() => _isUploading = true);
    try {
      final bool hasAllRequiredFromApi =
          _hasAllRequiredDocuments || await _refreshUploadedDocuments();

      if (!hasAllRequiredFromApi) {
        if (!mounted) return;
        showAppSnackBar(
          context,
          type: AppSnackBarType.error,
          message: context.l10n.text('uploadAllRequiredDocs'),
        );
        return;
      }

      if (!mounted) return;
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

  _UploadedDocumentInfo? _uploadedDocument(String type) {
    final String documentKey = _resolveDocumentKey(type);
    final PlatformFile? selectedFile = _selectedFiles[documentKey];
    if (selectedFile != null) {
      return _UploadedDocumentInfo(
        type: type,
        fileName: selectedFile.name,
        openUri: _uriFromFilePath(selectedFile.path),
      );
    }
    return _uploadedDocuments[_uploadedDocumentKeyFor(documentKey)];
  }

  String? _selectedFileLabel(String type) {
    final _UploadedDocumentInfo? uploadedDocument = _uploadedDocument(type);
    return uploadedDocument?.displayName ??
        (uploadedDocument != null
            ? context.l10n.text('alreadyUploaded')
            : null);
  }

  Future<void> _handleDocumentTap(
    _DocumentDefinition doc,
  ) async {
    final _UploadedDocumentInfo? uploadedDocument = _uploadedDocument(doc.type);
    if (uploadedDocument == null) {
      await _pickDocument(doc);
      return;
    }
  }

  Map<String, _UploadedDocumentInfo> _uploadedDocumentsFromApiItems(
    List<Map<String, dynamic>> items, {
    Map<String, String>? documentTypeAliases,
  }) {
    final Map<String, _UploadedDocumentInfo> uploadedDocs =
        <String, _UploadedDocumentInfo>{};
    for (int i = 0; i < items.length; i++) {
      final _UploadedDocumentInfo? uploadedDocument =
          _uploadedDocumentInfoFromApiItem(items[i]);
      if (uploadedDocument == null) {
        debugPrint('Skipped null document at index => $i');
        continue;
      }

      String documentKey = _resolveDocumentKey(
        uploadedDocument.type,
        aliases: documentTypeAliases,
      );
      if (documentKey.isEmpty) {
        documentKey = 'document_$i';
      }

      if (uploadedDocs.containsKey(documentKey)) {
        documentKey = '${documentKey}_$i';
      }

      uploadedDocs[documentKey] = uploadedDocument;
      debugPrint(
        'Added Document => $documentKey => ${uploadedDocument.fileName}',
      );
    }

    debugPrint('API Count => ${items.length}');
    debugPrint('Uploaded Count => ${uploadedDocs.length}');

    return uploadedDocs;
  }

  _UploadedDocumentInfo _uploadedDocumentFromUploadResponse(
    Map<String, dynamic> response, {
    required String fallbackType,
    required String fallbackFileName,
    required String fallbackFilePath,
  }) {
    final _UploadedDocumentInfo? uploadedDocument =
        _uploadedDocumentInfoFromApiItem(response, fallbackType: fallbackType);
    if (uploadedDocument != null) {
      return uploadedDocument.copyWith(
        type: uploadedDocument.type.isEmpty
            ? fallbackType
            : uploadedDocument.type,
        fileName: uploadedDocument.fileName ?? fallbackFileName,
        openUri: uploadedDocument.openUri ?? _uriFromFilePath(fallbackFilePath),
      );
    }

    return _UploadedDocumentInfo(
      type: fallbackType,
      fileName: fallbackFileName,
      openUri: _uriFromFilePath(fallbackFilePath),
    );
  }

  _UploadedDocumentInfo? _uploadedDocumentInfoFromApiItem(
    Map<String, dynamic> item, {
    String? fallbackType,
  }) {
    final String type = _documentTypeFromApiItem(item).ifEmpty(fallbackType);
    if (type.isEmpty) return null;

    return _UploadedDocumentInfo(
      type: type,
      fileName: _firstDocumentString(item, _fileNameKeys),
      openUri: _uriFromApiValue(_firstDocumentString(item, _fileUrlKeys)),
    );
  }

  List<_DocumentDefinition> _documentDefinitionsFromTypes(
    List<DocumentTypeItem> types, {
    required bool isArabic,
  }) {
    final Set<String> seenDocumentKeys = <String>{};
    final List<_DocumentDefinition> docs = <_DocumentDefinition>[];

    for (final DocumentTypeItem item in types) {
      final String type = item.value.trim();
      final String documentKey = _documentKey(type);
      if (documentKey.isEmpty || !seenDocumentKeys.add(documentKey)) {
        continue;
      }

      final String localizedTitle =
          (isArabic ? item.labelAr : item.labelEn).trim();
      final String fallbackTitle =
          item.labelEn.trim().ifEmpty(item.labelAr.trim());
      docs.add(
        (
          type: type,
          title: localizedTitle.ifEmpty(fallbackTitle).ifEmpty(type),
          subtitle: type,
        ),
      );
    }

    return docs;
  }

  Map<String, String> _documentTypeAliasesFromTypes(
    List<DocumentTypeItem> types,
  ) {
    final Map<String, String> aliases = <String, String>{};
    for (final DocumentTypeItem item in types) {
      final String canonicalKey = _documentKey(item.value);
      if (canonicalKey.isEmpty) continue;

      for (final String alias in <String>[
        item.value,
        item.id,
        item.labelEn,
        item.labelAr,
      ]) {
        final String aliasKey = _documentKey(alias);
        if (aliasKey.isNotEmpty) {
          aliases[aliasKey] = canonicalKey;
        }
      }
    }
    return aliases;
  }

  String _resolveDocumentKey(
    String type, {
    Map<String, String>? aliases,
  }) {
    final String key = _documentKey(type);
    return aliases?[key] ?? _documentTypeAliases[key] ?? key;
  }

  bool _hasUploadedDocumentForKey(
    String documentKey, {
    Map<String, _UploadedDocumentInfo>? uploadedDocuments,
  }) =>
      _uploadedDocumentKeyFor(
        documentKey,
        uploadedDocuments: uploadedDocuments,
      ) !=
      null;

  String? _uploadedDocumentKeyFor(
    String documentKey, {
    Map<String, _UploadedDocumentInfo>? uploadedDocuments,
  }) {
    final Map<String, _UploadedDocumentInfo> documents =
        uploadedDocuments ?? _uploadedDocuments;
    if (documents.containsKey(documentKey)) {
      return documentKey;
    }

    for (final String key in documents.keys) {
      if (key.startsWith('${documentKey}_')) {
        return key;
      }
    }

    return null;
  }

  String _documentKey(String type) {
    return type
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-/]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String _documentTypeFromApiItem(Map<String, dynamic> item) {
    final Object? documentType = item['documentType'];
    if (documentType is Map) {
      final Object? value = documentType['value'] ??
          documentType['type'] ??
          documentType['documentTypeValue'] ??
          documentType['document_type_value'] ??
          documentType['id'] ??
          documentType['documentTypeId'] ??
          documentType['document_type_id'] ??
          documentType['labelEn'] ??
          documentType['labelAr'] ??
          documentType['name'];
      if (value != null) return value.toString().trim();
    }

    final Object? type = item['type'] ??
        item['documentTypeValue'] ??
        item['document_type_value'] ??
        item['document_type'] ??
        item['documentTypeId'] ??
        item['document_type_id'] ??
        item['documentType'];
    return type?.toString().trim() ?? '';
  }

  String? _firstDocumentString(
    Map<String, dynamic> item,
    Set<String> keys, [
    Set<Object?> visited = const <Object?>{},
  ]) {
    if (visited.contains(item)) return null;
    final Set<Object?> nextVisited = <Object?>{...visited, item};

    for (final MapEntry<String, dynamic> entry in item.entries) {
      if (keys.contains(entry.key) && entry.value != null) {
        final String value = entry.value.toString().trim();
        if (value.isNotEmpty) return value;
      }
    }

    for (final Object? value in item.values) {
      if (value is Map) {
        final Map<String, dynamic> nested = value.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        final String? nestedValue =
            _firstDocumentString(nested, keys, nextVisited);
        if (nestedValue != null) return nestedValue;
      }
      if (value is List) {
        for (final Object? listItem in value) {
          if (listItem is Map) {
            final Map<String, dynamic> nested = listItem.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            final String? nestedValue =
                _firstDocumentString(nested, keys, nextVisited);
            if (nestedValue != null) return nestedValue;
          }
        }
      }
    }

    return null;
  }

  Uri? _uriFromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    final Uri? uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.hasScheme) return uri;
    if (value.startsWith('/')) {
      return Uri.tryParse('${ApiConfig.baseUrl}$value');
    }
    return Uri.tryParse('${ApiConfig.baseUrl}/$value');
  }

  Uri? _uriFromFilePath(String? filePath) {
    if (filePath == null || filePath.isEmpty) return null;
    return Uri.file(filePath);
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
                        if (_docs.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE6E6E6),
                                ),
                                color: Colors.white,
                              ),
                              child: Text(
                                context.l10n.text(
                                  'No document types found',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
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
                              selectedFileName:
                                  _selectedFileLabel(_docs.first.type),
                              onTap: _isUploading
                                  ? () {}
                                  : () => _handleDocumentTap(_docs.first),
                            ),
                            const SizedBox(height: 10),
                            ..._docs.skip(1).map(
                                  (doc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _UploadListTile(
                                      title: doc.title,
                                      subtitle: doc.subtitle,
                                      selectedFileName:
                                          _selectedFileLabel(doc.type),
                                      onTap: _isUploading
                                          ? () {}
                                          : () => _handleDocumentTap(doc),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 18),
                            AppPrimaryButton(
                              label: context.l10n.text('saveContinue'),
                              onPressed:
                                  _isUploading ? null : () => _onContinue(),
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
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
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

const Set<String> _fileNameKeys = <String>{
  'fileName',
  'filename',
  'file_name',
  'originalName',
  'originalname',
  'original_file_name',
  'name',
  'title',
};

const Set<String> _fileUrlKeys = <String>{
  'url',
  'fileUrl',
  'file_url',
  'documentUrl',
  'document_url',
  'downloadUrl',
  'download_url',
  'secureUrl',
  'secure_url',
  'location',
  'path',
  'filePath',
  'file_path',
};

class _UploadedDocumentInfo {
  const _UploadedDocumentInfo({
    required this.type,
    this.fileName,
    this.openUri,
  });

  final String type;
  final String? fileName;
  final Uri? openUri;

  String? get displayName {
    final String? trimmed = fileName?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  _UploadedDocumentInfo copyWith({
    String? type,
    String? fileName,
    Uri? openUri,
  }) {
    return _UploadedDocumentInfo(
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      openUri: openUri ?? this.openUri,
    );
  }
}

extension _StringFallback on String {
  String ifEmpty(String? fallback) => isEmpty ? (fallback ?? '') : this;
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
            Icon(
              isUploaded
                  ? Icons.check_circle_outline
                  : Icons.cloud_upload_outlined,
              size: 54,
              color: isUploaded ? AppColors.accent : const Color(0xFFB8B8B8),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: isUploaded
                    ? context.l10n.text('openDocument')
                    : context.l10n.text('tapToBrowse'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                children: [
                  if (!isUploaded)
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
                  : selectedFileName!,
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
                      color:
                          isUploaded ? AppColors.accent : AppColors.textMuted,
                      fontWeight:
                          isUploaded ? FontWeight.w600 : FontWeight.w400,
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
                isUploaded ? Icons.open_in_new : Icons.upload_outlined,
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
