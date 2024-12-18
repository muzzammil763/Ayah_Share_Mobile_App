import 'dart:io';

import 'package:ayah_share/about.dart';
import 'package:ayah_share/picker.dart';
import 'package:ayah_share/services.dart';
import 'package:ayah_share/surahs.dart';
import 'package:ayah_share/translaters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AyahShareScreen extends StatefulWidget {
  const AyahShareScreen({super.key});

  @override
  AyahShareScreenState createState() => AyahShareScreenState();
}

class AyahShareScreenState extends State<AyahShareScreen> {
  final QuranService _quranService = QuranService();
  ScreenshotController screenshotController = ScreenshotController();

  String arabicText = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';
  String translationText =
      'شروع الله کا نام لے کر جو بڑا مہربان نہایت رحم والا ہے';
  int surah = 1;
  int ayah = 1;
  int totalAyahs = 7;
  double fontSize = 34;
  double translationFontSize = 17;
  Color textColor = Colors.white;
  List<Color> gradientColors = [Colors.blue, Colors.purple.shade900];
  List<Translator> translations = translatorsList;
  String selectedTranslation = 'ur.jalandhry';
  double aspectRatio = 1;

  @override
  void initState() {
    super.initState();
    loadCachedAyah();
    fetchSurahAyahCount();
  }

  void loadCachedAyah() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedArabicText = prefs.getString('arabicText');
    String? cachedTranslationText = prefs.getString('translationText');

    if (cachedArabicText != null && cachedTranslationText != null) {
      setState(() {
        arabicText = cachedArabicText;
        translationText = cachedTranslationText;
      });
    } else {
      fetchAyah();
    }
  }

  void fetchAyah() async {
    try {
      final result =
          await _quranService.fetchAyah(surah, ayah, selectedTranslation);
      setState(() {
        arabicText = result['data'][0]['text'];
        translationText = result['data'][1]['text'];
      });

      // Cache the first ayah
      if (surah == 1 && ayah == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('arabicText', arabicText);
        prefs.setString('translationText', translationText);
      }
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

  void shareScreenshot() async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = File('${directory.path}/screenshot.png');
        await imagePath.writeAsBytes(image);

        await Share.shareXFiles([XFile(imagePath.path)],
            text: 'Check out this Ayah!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing screenshot: $e');
      }
    }
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
        actions: [
          PopupMenuButton(
            color: Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  height: 40,
                  child: const Text('About'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const About(),
                      ),
                    );
                  },
                ),
              ];
            },
            onSelected: (value) {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DropdownButton<int>(
                isExpanded: true,
                menuWidth: MediaQuery.of(context).size.width * 0.7,
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
                menuWidth: MediaQuery.of(context).size.width * 0.7,
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
                menuWidth: MediaQuery.of(context).size.width * 0.7,
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
              min: 20,
              max: 45,
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
              min: 15,
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
            const SizedBox(height: 12),
            ToggleButtons(
              color: Colors.blueAccent.shade700,
              borderRadius: BorderRadius.circular(8),
              fillColor: Colors.white,
              selectedBorderColor: Colors.blueAccent.shade700,
              borderWidth: 1.5,
              onPressed: (int index) {
                setState(() {
                  aspectRatio = index == 0 ? 1 : 9 / 16;
                });
              },
              isSelected: [aspectRatio == 1, aspectRatio == 9 / 16],
              children: const <Widget>[
                Icon(Icons.crop_square),
                Icon(Icons.crop_16_9),
              ],
            ),
            const SizedBox(height: 16),
            Screenshot(
              controller: screenshotController,
              child: AspectRatio(
                aspectRatio: aspectRatio,
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
                      const SizedBox(height: 12),
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
              onPressed: shareScreenshot, // Call the shareScreenshot method
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
