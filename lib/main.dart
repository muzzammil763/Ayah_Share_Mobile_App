import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:myappp/services/quran_services.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const AyahSaverApp());
}

class AyahSaverApp extends StatelessWidget {
  const AyahSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayah Saver',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AyahSaverScreen(),
    );
  }
}

class AyahSaverScreen extends StatefulWidget {
  const AyahSaverScreen({super.key});

  @override
  _AyahSaverScreenState createState() => _AyahSaverScreenState();
}

class _AyahSaverScreenState extends State<AyahSaverScreen> {
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

  @override
  void initState() {
    super.initState();
    fetchAyah();
    fetchSurahAyahCount();
  }

  void fetchAyah() async {
    try {
      final result = await _quranService.fetchAyah(surah, ayah);
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

  void fetchSurahAyahCount() async {
    try {
      final count = await _quranService.fetchSurahAyahCount(surah);
      setState(() {
        totalAyahs = count;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching surah details: $error');
      }
    }
  }

  void captureAndSaveScreenshot() async {
    final Uint8List? image = await screenshotController.capture();
    if (image != null) {
      final result = await ImageGallerySaver.saveImage(image,
          quality: 80, name: "ayah_screenshot");
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    }
  }

  void changeGradientColors(List<Color> colors) {
    setState(() {
      gradientColors = colors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayah Saver')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Surah and Ayah selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: surah,
                  items: List.generate(
                    114,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Surah ${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      surah = value!;
                      ayah = 1; // Reset ayah when surah changes
                      fetchSurahAyahCount(); // Fetch total ayahs in the new surah
                      fetchAyah();
                    });
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: ayah,
                  items: List.generate(
                    totalAyahs,
                    (index) => DropdownMenuItem(
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
              ],
            ),

            // Font Size and Color options
            const SizedBox(height: 10),
            const Text('Font Size',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: fontSize,
              min: 10,
              max: 40,
              onChanged: (newValue) {
                setState(() {
                  fontSize = newValue;
                });
              },
            ),
            const Text('Translation Font Size',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: translationFontSize,
              min: 10,
              max: 30,
              onChanged: (newValue) {
                setState(() {
                  translationFontSize = newValue;
                });
              },
            ),
            const Text('Text Color',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick Text Color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: textColor,
                        onColorChanged: (color) {
                          setState(() {
                            textColor = color;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Select Text Color'),
            ),
            const SizedBox(height: 10),

            // Gradient color picker
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick Gradient Colors'),
                    content: MultipleChoiceGradientPicker(
                      currentColors: gradientColors,
                      onConfirm: (colors) => changeGradientColors(colors),
                    ),
                  ),
                );
              },
              child: const Text('Select Gradient Colors'),
            ),

            const SizedBox(height: 20),

            // Screenshot area
            Screenshot(
              controller: screenshotController,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      arabicText,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      translationText,
                      style: TextStyle(
                        fontSize: translationFontSize,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Download button
            ElevatedButton(
              onPressed: captureAndSaveScreenshot,
              child: const Text('Download Image'),
            ),
          ],
        ),
      ),
    );
  }
}

class MultipleChoiceGradientPicker extends StatefulWidget {
  final List<Color> currentColors;
  final ValueChanged<List<Color>> onConfirm;

  const MultipleChoiceGradientPicker(
      {super.key, required this.currentColors, required this.onConfirm});

  @override
  _MultipleChoiceGradientPickerState createState() =>
      _MultipleChoiceGradientPickerState();
}

class _MultipleChoiceGradientPickerState
    extends State<MultipleChoiceGradientPicker> {
  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    colors = widget.currentColors;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Pick First Gradient Color'),
        ColorPicker(
          pickerColor: colors[0],
          onColorChanged: (color) {
            setState(() {
              colors[0] = color;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text('Pick Second Gradient Color'),
        ColorPicker(
          pickerColor: colors[1],
          onColorChanged: (color) {
            setState(() {
              colors[1] = color;
            });
          },
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(colors);
            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
