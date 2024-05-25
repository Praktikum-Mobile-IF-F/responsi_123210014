import 'package:responsi/model/kopi_model.dart';
import 'base_network.dart';

class ApiDataSource {
  static final ApiDataSource _instance = ApiDataSource._internal();

  factory ApiDataSource() {
    return _instance;
  }

  ApiDataSource._internal();

  Future<List<JenisKopi>> loadJenisKopi() async {
    final response = await BaseNetwork.get("/api");
    print("ApiDataSource - response: $response");

    if (response is List) {
      return response.map((json) => JenisKopi.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}
