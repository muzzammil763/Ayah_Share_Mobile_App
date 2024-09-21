import 'package:ayah_share/picker.dart';
import 'package:ayah_share/services.dart';
import 'package:ayah_share/surahs.dart';
import 'package:ayah_share/translaters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screenshot/screenshot.dart';

class AyahShareScreen extends StatefulWidget {
  const AyahShareScreen({super.key});

  @override
  AyahShareScreenState createState() => AyahShareScreenState();
}

class AyahShareScreenState extends State<AyahShareScreen> {
  final QuranService _quranService = QuranService();
  ScreenshotController screenshotController = ScreenshotController();

  String arabicText = '';
  String translationText = '';
  int surah = 1;
  int ayah = 1;
  int totalAyahs = 7; // Start with the first surah's ayah count
  double fontSize = 20;
  double translationFontSize = 16;
  Color textColor = Colors.white;
  List<Color> gradientColors = [Colors.blue, Colors.purple];
  List<Translator> translations = translatorsList;
  String selectedTranslation = 'ur.jalandhry';

  @override
  void initState() {
    super.initState();
    fetchAyah();
    fetchSurahAyahCount();
  }

  void fetchAyah() async {
    try {
      final result =
          await _quranService.fetchAyah(surah, ayah, selectedTranslation);
      setState(() {
        arabicText = result['data'][0]['text'];
        translationText = result['data'][1]['text'];
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching ayah: $error');
      }
    }
  }

  void fetchSurahAyahCount() {
    setState(() {
      totalAyahs = surahList.firstWhere((s) => s.number == surah).numberOfAyahs;
    });
  }

  void changeGradientColors(List<Color> colors) {
    setState(() {
      gradientColors = List.from(colors);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'AyahShare',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DropdownButton<int>(
                isExpanded: true,
                menuWidth: MediaQuery.of(context).size.width * 0.8,
                iconSize: 30,
                alignment: Alignment.center,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down_sharp),
                value: surah,
                items: surahList.map((surah) {
                  return DropdownMenuItem<int>(
                    value: surah.number,
                    child: Text(
                        '${surah.number} - ${surah.englishName} ( ${surah.name} )'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    surah = value!;
                    ayah = 1;
                    fetchSurahAyahCount();
                    fetchAyah();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DropdownButton<int>(
                isExpanded: true,
                menuWidth: 150,
                iconSize: 30,
                alignment: Alignment.center,
                underline: const SizedBox(),
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.keyboard_arrow_down_sharp),
                ),
                value: ayah,
                items: List.generate(
                  totalAyahs,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('Ayah ${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    ayah = value!;
                    fetchAyah();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DropdownButton<String>(
                isExpanded: true,
                menuWidth: MediaQuery.of(context).size.width * 0.8,
                iconSize: 30,
                alignment: Alignment.center,
                underline: const SizedBox(),
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.keyboard_arrow_down_sharp),
                ),
                value: selectedTranslation,
                items: translations.map((translator) {
                  return DropdownMenuItem<String>(
                    value: translator.identifier,
                    child: Text(
                      '${translator.language.toUpperCase()} - ${translator.englishName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTranslation = value!;
                    fetchAyah();
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ayah Font Size',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              activeColor: Colors.blueAccent.shade700,
              value: fontSize,
              min: 10,
              max: 40,
              onChanged: (newValue) {
                setState(() {
                  fontSize = newValue;
                });
              },
            ),
            const Text(
              'Translation Font Size',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              activeColor: Colors.blueAccent.shade700,
              value: translationFontSize,
              min: 10,
              max: 30,
              onChanged: (newValue) {
                setState(() {
                  translationFontSize = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      barrierColor: Colors.transparent,
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            displayThumbColor: true,
                            enableAlpha: false,
                            showLabel: false,
                            pickerAreaHeightPercent: 0.5,
                            pickerColor: textColor,
                            onColorChanged: (color) {
                              setState(
                                () {
                                  textColor = color;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Text Color',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      useRootNavigator: true,
                      barrierColor: Colors.transparent,
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        content: MultipleChoiceGradientPicker(
                          currentColors: gradientColors,
                          onColorChanged: (colors) =>
                              changeGradientColors(colors),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Gradient Colors',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Screenshot area
            Screenshot(
              controller: screenshotController,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        arabicText,
                        style: TextStyle(
                          fontFamily: 'IndoPak',
                          fontSize: fontSize,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        translationText,
                        style: TextStyle(
                          fontFamily: 'Alvi',
                          fontSize: translationFontSize,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Share button
            OutlinedButton(
              onPressed: () {},
              child: Text(
                'Share Image',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
