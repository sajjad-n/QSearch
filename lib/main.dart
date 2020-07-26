import 'package:flutter/material.dart';
import 'package:qsearch/screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'IranYekan',
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'IranYekan'
          ),
          backgroundColor: Colors.white
        ),
      ),
      home: SplashScreen(),
    );
  }
}
