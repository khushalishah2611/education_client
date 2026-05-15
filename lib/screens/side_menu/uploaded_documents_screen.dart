import 'package:education/core/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/student_session.dart';
import '../../widgets/common_widgets.dart';
import '../../services/application_api_service.dart';
import 'side_menu_common.dart';

class UploadedDocumentsScreen extends StatelessWidget {
  const UploadedDocumentsScreen({
    super.key,
    this.activeTab = false,
  });

  final bool activeTab;

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('uploadedDocuments'),
      showBackButton: activeTab,
      child: const UploadedDocumentsContent(),
    );
  }
}

class UploadedDocumentsContent extends StatefulWidget {
  const UploadedDocumentsContent({super.key});

  @override
  State<UploadedDocumentsContent> createState() =>
      _UploadedDocumentsContentState();
}

class _UploadedDocumentsContentState extends State<UploadedDocumentsContent> {
  final ApplicationApiService _api = const ApplicationApiService();

  List<Map<String, dynamic>> _documents = [];

  bool _loading = true;
  String? _openingDocumentId;

  String _normalizedType(Map<String, dynamic> document) {
    return (document['type']?.toString() ?? '').trim().toLowerCase();
  }

  DateTime? _documentTimestamp(Map<String, dynamic> document) {
    final timestamp = document['updatedAt'] ??
        document['updated_at'] ??
        document['createdAt'] ??
        document['created_at'];

    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp.toString());
  }

  int _documentIdAsInt(Map<String, dynamic> document) {
    return int.tryParse(document['id']?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> _mergeDocumentsByType(List<dynamic> docs) {
    final parsedDocs = docs
        .whereType<Map>()
        .map(
          (e) => e.map(
            (k, v) => MapEntry(k.toString(), v),
          ),
        )
        .toList();

    final docsByType = <String, Map<String, dynamic>>{};

    for (final doc in parsedDocs) {
      final typeKey = _normalizedType(doc);

      if (typeKey.isEmpty) {
        docsByType['__unknown_${_documentIdAsInt(doc)}'] = doc;
        continue;
      }

      final existing = docsByType[typeKey];
      if (existing == null) {
        docsByType[typeKey] = doc;
        continue;
      }

      final existingTime = _documentTimestamp(existing);
      final incomingTime = _documentTimestamp(doc);

      final shouldReplace = incomingTime != null && existingTime != null
          ? incomingTime.isAfter(existingTime)
          : _documentIdAsInt(doc) > _documentIdAsInt(existing);

      if (shouldReplace) {
        docsByType[typeKey] = doc;
      }
    }

    final mergedDocs = docsByType.values.toList();

    mergedDocs.sort((a, b) {
      final bTime = _documentTimestamp(b);
      final aTime = _documentTimestamp(a);

      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime);
      }

      return _documentIdAsInt(b).compareTo(_documentIdAsInt(a));
    });

    return mergedDocs;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final studentUserId = await StudentSession.currentStudentUserId();

      final overview = await _api.fetchStudentOverview(
        studentUserId: studentUserId,
      );

      final docs = overview['documents'];

      if (!mounted) return;

      setState(() {
        _documents = docs is List ? _mergeDocumentsByType(docs) : [];

        _loading = false;
      });
    } catch (e) {
      debugPrint('Load documents error: $e');

      if (!mounted) return;

      setState(() => _loading = false);

      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.text('failedLoadDocuments'),
      );
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    try {
      final studentUserId = await StudentSession.currentStudentUserId();

      await _api.deleteStudentDocument(
        documentId: item['id']?.toString() ?? '',
        studentUserId: studentUserId,
      );

      if (!mounted) return;

      showAppSnackBar(
        context,
        type: AppSnackBarType.success,
        message: context.l10n.text('documentDeletedSuccessfully'),
      );

      await _load();
    } catch (e) {
      debugPrint('Delete document error: $e');

      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: context.l10n.text('failedDeleteDocument'),
      );
    }
  }

  Future<void> _openDocument(Map<String, dynamic> doc) async {
    try {
      final filePath = doc['filePath']?.toString() ?? '';
      final documentId = doc['id']?.toString() ?? '';

      if (filePath.isEmpty) {
        showAppSnackBar(
          context,
          type: AppSnackBarType.error,
          message: context.l10n.text('documentPathNotFound'),
        );
        return;
      }

      setState(() {
        _openingDocumentId = documentId;
      });

      final url = ImageUrlHelper.resolveUploadUrl(filePath);

      debugPrint('Resolved Document URL: $url');

      final uri = Uri.parse(url);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        showAppSnackBar(
          context,
          type: AppSnackBarType.error,
          message: context.l10n.text('unableOpenDocument'),
        );
      }
    } catch (e) {
      debugPrint('Open document error: $e');

      if (mounted) {
        showAppSnackBar(
          context,
          type: AppSnackBarType.error,
          message: context.l10n.text('failedOpenDocument'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _openingDocumentId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildShimmerList();
    }

    if (_documents.isEmpty) {
      return _emptyState(context);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: _documents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final doc = _documents[index];

          final documentId = doc['id']?.toString() ?? '';
          final isOpening = _openingDocumentId == documentId;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFEAEAEA),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                doc['type']?.toString() ?? 'Document',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  onTap: isOpening ? null : () => _openDocument(doc),
                  child: Text(
                    doc['fileName']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isOpening ? Colors.grey : Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              trailing: isOpening
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : IconButton(
                      onPressed: () => _delete(doc),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
              onTap: isOpening ? null : () => _openDocument(doc),
            ),
          );
        },
      ),
    );
  }
  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PDF ICON BOX
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                const SizedBox(width: 14),

                // TEXT AREA
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        height: 12,
                        width:
                        MediaQuery.of(context)
                            .size
                            .width *
                            0.45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // DELETE BUTTON
                Container(
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 16,
            ),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE6E6E6),
              ),
              color: Colors.white,
            ),
            child:   Text(
              'No uploaded documents available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF616161),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
