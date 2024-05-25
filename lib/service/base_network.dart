import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseNetwork {
  static final String baseUrl = "https://fake-coffee-api.vercel.app";

  static Future<dynamic> get(String partUrl) async {
    final String fullUrl = baseUrl + partUrl;
    debugPrint("BaseNetwork - fullUrl: $fullUrl");
    final response = await http.get(Uri.parse(fullUrl));
    debugPrint("BaseNetwork - response: ${response.body}");

    if (response.statusCode == 200) {
      return _processResponse(response);
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
    }
  }

  static dynamic _processResponse(http.Response response) {
    final body = response.body;
    if (body.isNotEmpty) {
      return json.decode(body);
    } else {
      print("processResponse error: empty body");
      return {"error": true};
    }
  }

  static void debugPrint(String value) {
    print("[BASE_NETWORK] - $value");
  }
}
