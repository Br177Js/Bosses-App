import 'dart:convert';
import 'package:http/http.dart' as http;
import 'boss_repository.dart';

class BossApiService {
  static const String baseUrl = "https://eldenring.fanapis.com";
  static Future<List<Boss>> fetchBosses() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/bosses"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List enemies = data["data"];
      return enemies.map((enemy) {
        return Boss(
            id: enemy["id"],
            name: enemy["name"],
            image: enemy["image"],
            description: enemy["description"],
            location: enemy["location"],
            drops: enemy["drops"],
            defeated: enemy["defeated"],
        );
      }).toList();
    } else {
      throw Exception("Błąd pobierania danych");
    }
  }
}
