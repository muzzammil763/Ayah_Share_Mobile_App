import 'package:ayahShare/services/quran_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const AyahShareApp());
}

class AyahShareApp extends StatelessWidget {
  const AyahShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AyahShare',
      // theme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.light,
      // ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.dark,
      //   scaffoldBackgroundColor: Colors.black,
      //   appBarTheme: const AppBarTheme(
      //     backgroundColor: Colors.black,
      //     foregroundColor: Colors.white,
      //     systemOverlayStyle: SystemUiOverlayStyle.light,
      //     elevation: 0,
      //     scrolledUnderElevation: 0,
      //   ),
      //   primaryColor: Colors.blue,
      // ),
      // themeMode: ThemeMode.system,
      // theme ke baare me dekhna he
      home: AyahShareScreen(),
    );
  }
}

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

  void changeGradientColors(List<Color> colors) {
    setState(() {
      gradientColors = colors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.blueAccent,
        title: const Text(
          'AyahShare',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Surah and Ayah selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: DropdownButton<int>(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 28,
                    ),
                    underline: const SizedBox(),
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
                ),
                const SizedBox(width: 20),
                Center(
                  child: DropdownButton<int>(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 28,
                    ),
                    underline: const SizedBox(),
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
                ),
              ],
            ),

            // Font Size and Color options
            const SizedBox(height: 12),
            const Text(
              'Ayah Font Size',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            const Text(
              'Translation Font Size',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            const Text(
              'Text Color',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick Text Color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
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
                'Select Text Color',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent.shade700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Gradient color picker
            OutlinedButton(
              onPressed: () {
                showDialog(
                  barrierColor: Colors.transparent,
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
              child: Text(
                'Select Gradient Colors',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent.shade700,
                ),
              ),
            ),

            const SizedBox(height: 20),

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
            ),

            const SizedBox(height: 20),
            // Share button
            OutlinedButton(
              onPressed: () {},
              child: const Text('Share Image'),
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
  MultipleChoiceGradientPickerState createState() =>
      MultipleChoiceGradientPickerState();
}

class MultipleChoiceGradientPickerState
    extends State<MultipleChoiceGradientPicker> {
  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    colors = widget.currentColors;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
      ),
    );
  }
}
