import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final geosocialTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: GoogleFonts.roboto().fontFamily,
  textTheme: const TextTheme(
      headline1: TextStyle(
          fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
      headline2: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
      headline3: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
      bodyText2: TextStyle(
          fontSize: 9, fontWeight: FontWeight.w400, color: Colors.grey),
      bodyText1: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
);