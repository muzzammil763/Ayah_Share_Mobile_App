import 'dart:convert';

import 'package:http/http.dart' as http;

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1/';

  Future<Map<String, dynamic>> fetchAyah(
      int surah, int ayah, String translation) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/ayah/$surah:$ayah/editions/quran-simple,$translation'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load ayah');
    }
  }

  Future<int> fetchSurahAyahCount(int surah) async {
    final response = await http.get(Uri.parse('$baseUrl/surah/$surah'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['ayahs'].length;
    } else {
      throw Exception('Failed to load surah details');
    }
  }

  Future<List<Translation>> fetchTranslations() async {
    final response = await http
        .get(Uri.parse('$baseUrl/edition?format=text&type=translation'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Translation.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load translations');
    }
  }
}

class Translation {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String direction;

  Translation({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    required this.direction,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      identifier: json['identifier'],
      language: json['language'],
      name: json['name'],
      englishName: json['englishName'],
      format: json['format'],
      type: json['type'],
      direction: json['direction'],
    );
  }
}
