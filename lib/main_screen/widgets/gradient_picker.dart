import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MultipleChoiceGradientPicker extends StatefulWidget {
  final List<Color> currentColors;
  final ValueChanged<List<Color>> onColorChanged;

  const MultipleChoiceGradientPicker({
    super.key,
    required this.currentColors,
    required this.onColorChanged,
  });

  @override
  MultipleChoiceGradientPickerState createState() =>
      MultipleChoiceGradientPickerState();
}

class MultipleChoiceGradientPickerState
    extends State<MultipleChoiceGradientPicker> {
  late List<Color> colors;

  @override
  void initState() {
    super.initState();
    colors = List.from(widget.currentColors);
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
              widget.onColorChanged(colors);
            },
          ),
          const SizedBox(height: 20),
          const Text('Pick Second Gradient Color'),
          ColorPicker(
            pickerColor: colors[1],
            onColorChanged: (color) {
              setState(
                () {
                  colors[1] = color;
                },
              );
              widget.onColorChanged(colors);
            },
          ),
        ],
      ),
    );
  }
}
