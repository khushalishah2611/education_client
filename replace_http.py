import os

def process_file(path):
    with open(path, 'r') as f:
        content = f.read()

    # Add import if not present
    if "import '../core/http_client.dart';" not in content and "import '../../core/http_client.dart';" not in content:
        # Check depth
        if 'application_api_service.dart' in path or 'auth_api_service.dart' in path or 'home_api_service.dart' in path or 'student_api_service.dart' in path:
            content = content.replace("import 'package:http/http.dart' as http;\n", "import 'package:http/http.dart' as http;\nimport '../core/http_client.dart';\n")
    
    content = content.replace('await http.get(', 'await AppHttpClient.client.get(')
    content = content.replace('await http.post(', 'await AppHttpClient.client.post(')
    content = content.replace('await http.put(', 'await AppHttpClient.client.put(')
    content = content.replace('await http.delete(', 'await AppHttpClient.client.delete(')
    content = content.replace('await http.patch(', 'await AppHttpClient.client.patch(')
    content = content.replace('await request.send()', 'await AppHttpClient.client.send(request)')

    with open(path, 'w') as f:
        f.write(content)

process_file('lib/services/application_api_service.dart')
process_file('lib/services/auth_api_service.dart')
process_file('lib/services/home_api_service.dart')
process_file('lib/services/student_api_service.dart')

print("Replacement complete.")
