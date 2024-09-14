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
          ColorPicker(
            displayThumbColor: true,
            enableAlpha: false,
            showLabel: false,
            pickerAreaHeightPercent: 0.5,
            pickerColor: colors[0],
            onColorChanged: (color) {
              setState(() {
                colors[0] = color;
              });
              widget.onColorChanged(colors);
            },
          ),
          ColorPicker(
            displayThumbColor: true,
            enableAlpha: false,
            showLabel: false,
            pickerAreaHeightPercent: 0.5,
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
