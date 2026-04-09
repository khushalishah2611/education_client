import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalLink(String link) async {
  final uri = Uri.tryParse(link);
  if (uri == null) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
