import 'package:ayah_share/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AyahShareApp());
}

class AyahShareApp extends StatelessWidget {
  const AyahShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AyahShare',
        home: AyahShareScreen(),
      ),
    );
  }
}
