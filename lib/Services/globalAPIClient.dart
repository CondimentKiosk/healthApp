import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ApiClient {
  static final Dio dio = Dio();           
  static final CookieJar cookieJar = CookieJar();

  static int currentUserId = 0;    
  static int currentPatientId = 0;  


  static void init() {
    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.baseUrl = 'http://192.168.0.28:4000';
    dio.options.headers['Content-Type'] = 'application/json';
  }

  static String patientRoute(String route) {
    return '/$currentUserId/$currentPatientId$route';
  }

}
