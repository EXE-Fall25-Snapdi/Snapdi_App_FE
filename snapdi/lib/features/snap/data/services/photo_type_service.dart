import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/environment.dart';
import '../models/photo_type.dart';

class PhotoTypeService {
  http.Client _createClient() {
    return http.Client();
  }

  Future<List<PhotoType>> getPhotoTypes() async {
    // Bypass SSL certificate verification for development
    HttpOverrides.global = _DevHttpOverrides();
    
    final client = _createClient();
    
    try {
      final response = await client.get(
        Uri.parse('${Environment.apiBaseUrl}/api/PhotoTypes'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'text/plain',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => PhotoType.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    } finally {
      client.close();
    }
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
