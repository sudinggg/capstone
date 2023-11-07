import 'dart:convert';
import 'package:capston1/tokenManager.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  static ApiManager apiManager = new ApiManager();
  TokenManager tokenManager = TokenManager().getTokenManager();
  ApiManager getApiManager(){
    return apiManager;
  }
  final String baseUrl = "http://34.64.78.183:8080";
  // 정보 받아올 때
  Future<Map<String, dynamic>> Get(String endpoint) async {

    String accessToken = tokenManager.getAccessToken();

    final response = await http.get(Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken', // 요청 헤더 설정
      },
    );

    if (response.statusCode == 200) { // 통신 성공 시
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  //정보 보낼 때
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {

    String accessToken = tokenManager.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // 요청 헤더 설정
        'Authorization': 'Bearer $accessToken',

      },
      body: jsonEncode(data), // 요청 데이터를 JSON 형식으로 변환
    );

    if (response.statusCode == 200) { // 성공적인 응답
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from the API');
    }
  }


  // 카카오 토큰을 이용해서 서버 토큰을 받기 위한 함수
  Future<Map<String, dynamic>> getServerToken (String kakaoAccessToken) async {
    String endpoint = "/user/auth/kakao";

    final response = await http.get(Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'kakaoAccessToken': 'Bearer $kakaoAccessToken', // 요청 헤더 설정
      },
    );

    if (response.statusCode == 200) { // 통신 성공 시
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from the API');
    }
  }


}
