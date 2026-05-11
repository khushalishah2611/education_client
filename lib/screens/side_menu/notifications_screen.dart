import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../services/application_api_service.dart';
import 'side_menu_common.dart';

class NotificationsScreen extends StatefulWidget { const NotificationsScreen({super.key}); @override State<NotificationsScreen> createState()=>_N(); }
class _N extends State<NotificationsScreen>{
  final _api = const ApplicationApiService();
  List<Map<String,dynamic>> _items = const [];
  bool _loading = true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';
    final data = await _api.fetchStudentOverview(studentUserId: studentUserId);
    final items = data['notifications'];
    if(mounted){setState((){_items=items is List? items.whereType<Map>().map((e)=>e.map((k,v)=>MapEntry(k.toString(), v))).toList():const []; _loading=false;});}
  }
  @override Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('notifications'),
      child: _loading ? const Center(child:CircularProgressIndicator(color: AppColors.primary)) : ListView(
        children: _items.map((e)=>NotificationCard(title:e['title']?.toString()??'-', description:e['message']?.toString()??'', date:e['createdAt']?.toString()??'')).toList(),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.title, required this.description, required this.date});
  final String title; final String description; final String date;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(6),border: Border.all(color: const Color(0xFFD7D4D0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }
}
