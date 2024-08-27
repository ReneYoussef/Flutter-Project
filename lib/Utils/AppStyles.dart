import 'dart:ui';
import 'package:flutter/material.dart';
Color primary = const Color(0xFF687daf);

class Styles{

  static Color primaryColor = primary;
  static Color textColor = const Color(0xff000000);
  static Color bgcolor = const Color(0xFFeeedf2);
  static Color orange = const Color(0xFFF37B67);
  static Color registerLineText = const Color.fromARGB(255, 230, 224, 224);
  static Color texttheme = const Color(0xFF526799);
  static Color HomeTitle = Colors.white;
  static Color HomeContainerbgColor = const Color(0xD4878383);
  static Color primaryBackground = const Color(0xFF3b3b3b);
  static Color primary = const Color(0xFF000000);
  static Color secondaryBackground = const Color(0xFFFFFFFF);
  static Color primaryText = const Color(0xFF526799);


  static TextStyle textStyle =
  TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500);
  static TextStyle headlinestyle =
  TextStyle(fontSize: 26, color: textColor, fontWeight: FontWeight.bold);
  static TextStyle headlinestyle2 =
  TextStyle(fontSize: 21, color: textColor, fontWeight: FontWeight.bold);
  static TextStyle headlinestyle3 =
  TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.w500);
  static TextStyle headlinestyle4 = TextStyle(
      fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500);
  static TextStyle registerLine = TextStyle(
      fontSize: 18, color: registerLineText, fontWeight: FontWeight.w500);
  static TextStyle text_Theme =
  TextStyle(fontSize: 18, color: texttheme, fontWeight: FontWeight.w500);
  static TextStyle LoginTxt =
  TextStyle(fontSize: 20, color: HomeTitle, fontWeight: FontWeight.w800);
  static TextStyle HomeContainer =
  TextStyle(fontSize: 20, color: HomeTitle, fontWeight: FontWeight.w800);
  static TextStyle ButtonText =
  TextStyle(fontSize: 20, color: HomeTitle, fontWeight: FontWeight.w700);


  static TextStyle titleLarge =
  TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  // Text styles
  static TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    color: primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: 18,
    color: primary,
    fontWeight: FontWeight.w600,
  ); static TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    color: primary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleSmall = TextStyle(
    fontSize: 18,
    color: primary,
    fontWeight: FontWeight.w300,
  );
}

class FlutterFlowTheme {
  static Color primaryBackground = const Color(0xFF3b3b3b);
  static Color primary = const Color(0xFF000000);
  static Color secondaryBackground = const Color(0xFFFFFFFF);
  static Color primaryText = const Color(0xFF526799);

  static TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    color: Styles.primaryText,
    fontWeight: FontWeight.w500,
  );
  static TextStyle labelMedium = TextStyle(
    fontSize: 18,
    color: Styles.primaryText,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleLarge = TextStyle(
    fontSize: 18,
    color: Styles.primaryText,
    fontWeight: FontWeight.w900,
  );
  static TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    color: Styles.primaryText,
    fontWeight: FontWeight.w600,
  );
  static TextStyle titleSmall = TextStyle(
    fontSize: 18,
    color: Styles.primaryText,
    fontWeight: FontWeight.w300,
  );
  static TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static FlutterFlowThemeData of(BuildContext context) {
    return FlutterFlowThemeData(context);
  }
}

class FlutterFlowThemeData {
  final BuildContext context;

  const FlutterFlowThemeData(this.context);

  TextStyle get headlineSmall => FlutterFlowTheme.headlineSmall;
  TextStyle get labelMedium => FlutterFlowTheme.labelMedium;
  TextStyle get bodyMedium => FlutterFlowTheme.bodyMedium;
  TextStyle get titleSmall => FlutterFlowTheme.titleSmall;
  TextStyle get titleMedium => FlutterFlowTheme.titleMedium;

  Color get primaryBackground => FlutterFlowTheme.primaryBackground;
  Color get primary => FlutterFlowTheme.primary;
  Color get secondaryBackground => FlutterFlowTheme.secondaryBackground;
  Color get primaryText => FlutterFlowTheme.primaryText;
}