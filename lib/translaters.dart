class Translator {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final String direction;

  Translator({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    required this.direction,
  });
}

final List<Translator> translatorsList = [
  Translator(
    identifier: "en.sahih",
    language: "en",
    name: "Saheeh International",
    englishName: "Saheeh International",
    format: "text",
    type: "translation",
    direction: "ltr",
  ),
  Translator(
    identifier: "ur.jalandhry",
    language: "ur",
    name: "جالندہری",
    englishName: "Fateh Muhammad Jalandhry",
    format: "text",
    type: "translation",
    direction: "rtl",
  ),
  // Add more translators here...
];
