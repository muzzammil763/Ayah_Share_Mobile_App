import 'package:ayahShare/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AyahShareApp());
}

class AyahShareApp extends StatelessWidget {
  const AyahShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AyahShare',
      home: AyahShareScreen(),
    );
  }
}
