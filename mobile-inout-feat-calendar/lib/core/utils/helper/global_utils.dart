import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class GlobalUtils {
  
  // download file for cache
  static Future<File> downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final filename = p.basename(url);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    return file.writeAsBytes(response.bodyBytes);
  }

}