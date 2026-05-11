import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../../services/application_api_service.dart';
import 'side_menu_common.dart';

class TrackMyApplicationsScreen extends StatelessWidget {
  const TrackMyApplicationsScreen({super.key, this.activeTab = false});
  final bool activeTab;
  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(title: 'Track My Applications', showBackButton: activeTab, child: const TrackMyApplicationsContent());
  }
}

class TrackMyApplicationsContent extends StatefulWidget { const TrackMyApplicationsContent({super.key}); @override State<TrackMyApplicationsContent> createState()=>_T(); }
class _T extends State<TrackMyApplicationsContent> {
  final _api = const ApplicationApiService();
  List<Map<String,dynamic>> _apps = const [];
  bool _loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';
    final data = await _api.fetchStudentOverview(studentUserId: studentUserId);
    final apps = data['applications'];
    if(mounted){setState((){_apps = apps is List ? apps.whereType<Map>().map((e)=>e.map((k,v)=>MapEntry(k.toString(), v))).toList() : const []; _loading=false;});}
  }
  @override Widget build(BuildContext context){
    if(_loading){return const Center(child:CircularProgressIndicator(color: AppColors.primary));}
    return ListView.separated(itemCount:_apps.length,separatorBuilder:(_,__)=>const SizedBox(height:8),itemBuilder:(context,index){
      final item=_apps[index];
      final uni=item['university'] is Map ? (item['university']['name']?.toString() ?? '-') : '-';
      final prog=item['program'] is Map ? (item['program']['name']?.toString() ?? '-') : '-';
      final id=item['id']?.toString() ?? '';
      return Container(padding: const EdgeInsets.all(12),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(8),border: Border.all(color: const Color(0xFFE0DDD8))),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[
        Text('Application ID : #${id.length>8?id.substring(0,8):id}',style: const TextStyle(fontSize:14,fontWeight: FontWeight.w500)),
        const SizedBox(height:8),
        Text(uni,style: const TextStyle(fontSize:16,fontWeight: FontWeight.w700)),
        const SizedBox(height:2),
        Text(prog,style: const TextStyle(fontSize:14,color: AppColors.textMuted)),
      ]));
    });
  }
}
