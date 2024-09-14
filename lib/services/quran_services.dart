import 'dart:convert';

import 'package:http/http.dart' as http;

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1/';

  Future<Map<String, dynamic>> fetchAyah(int surah, int ayah) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ayah/$surah:$ayah/editions/quran-simple,en.sahih'),
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
}
