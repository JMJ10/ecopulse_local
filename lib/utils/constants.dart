import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static String uri = 'https://ecopulselocal-production.up.railway.app';

 static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('x-auth-token');
}
  
}