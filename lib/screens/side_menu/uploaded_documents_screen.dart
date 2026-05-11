import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/application_api_service.dart';
import 'side_menu_common.dart';

class UploadedDocumentsScreen extends StatelessWidget {
  const UploadedDocumentsScreen({super.key, this.activeTab = false});

  final bool activeTab;

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: 'Uploaded Documents',
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

    final overview =
    await _api.fetchStudentOverview(studentUserId: studentUserId);

    final docs = overview['documents'];

    if (mounted) {
      setState(() {
        _documents = docs is List
            ? docs
            .whereType<Map>()
            .map((e) => e.map(
              (k, v) => MapEntry(k.toString(), v),
        ))
            .toList()
            : [];
        _loading = false;
      });
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

    await _api.deleteStudentDocument(
      documentId: item['id']?.toString() ?? '',
      studentUserId: studentUserId,
    );

    if (!mounted) return;

    showAppSnackBar(
      context,
      type: AppSnackBarType.success,
      message: 'Document deleted.',
    );

    await _load();
  }

  Future<void> _openDocument(Map<String, dynamic> doc) async {
    final fileName = doc['fileName']?.toString();

    if (fileName == null || fileName.isEmpty) return;

    final encodedFileName = Uri.encodeComponent(fileName);

    final url = 'https://arab.vedx.cloud/uploads/$encodedFileName';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final doc = _documents[index];

          return SimpleTile(
            leading: Icons.picture_as_pdf_outlined,
            title: doc['type']?.toString() ?? '-',
            subtitleWidget: GestureDetector(
              onTap: () => _openDocument(doc), // 👈 FILE NAME CLICK
              child: Text(
                doc['fileName']?.toString() ?? '',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () => _openDocument(doc), // optional full tile tap
            trailing: IconButton(
              onPressed: () => _delete(doc),
              icon: const Icon(
                Icons.cancel_outlined,
                color: AppColors.textMuted,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE6E6E6)),
                color: Colors.white,
              ),
              child: const Text(
                'No uploaded documents available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}