import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static String uri = 'http://10.0.2.2:3000';

 static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('x-auth-token');
}
  
}