import 'package:flutter/services.dart';
import 'package:fraction/fraction.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static String convertToReadableCookTime(Duration tod) {
    if (tod.inMinutes == 0) {
      return 'N/A';
    }
    return '${tod.inHours}:${(tod.inMinutes - (60 * tod.inHours)).toString().padLeft(2, '0')}';
  }

  static String capitalize(String s) {
    if (s.isNotEmpty) {
      return s[0].toUpperCase() + s.substring(1);
    } else {
      return '';
    }
  }

  static loadUnitList() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(AppText.unitShared) == null) {
      prefs.setStringList(AppText.unitShared, AppText.units);
    }
  }

  static Future<List<String>> getUnits(String pattern) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> units = prefs.getStringList(AppText.unitShared) ?? AppText.units;

    if (pattern.isEmpty) {
      return units;
    }

    return units.where((e) => e.toLowerCase().startsWith(pattern.toLowerCase())).toList();
  }

  //added by zhen, do some conversion for ingredient amount field
  static double? ingreDouble(String s) {
    if (s.isEmpty) {
      return null;
    }
    if (s.contains("/")) {
      int index = s.indexOf("/");
      double nominator = double.parse(s.substring(0, index));
      double denominator = double.parse(s.substring(index + 1, s.length));
      double result = nominator / denominator;
      return roundTo3(result);
    } else {
      return roundTo3(double.parse(s));
    }
  }

  //round a double to 3 digits after period like 2.989, 14.333
  static double roundTo3(double s) {
    String inString = s.toStringAsFixed(3);
    return double.parse(inString);
  }

  static List<TextInputFormatter> fractionFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r"[0-9./]")),
    TextInputFormatter.withFunction((oldValue, newValue) {
      try {
        final text = newValue.text;
        if (text.contains("/")) {
          if ('/'.allMatches(text.toString()).length > 1) {
            // number of slashes can't be more than 1
            return oldValue;
          }
        } else if (text.isNotEmpty) {
          double.parse(text);
        }
        return newValue;
      } catch (e) {
        //error
      }
      return oldValue;
    }),
  ];

  static String forceReduce(String large) {
    List<String> fractionParts = large.split('/');
    if (fractionParts.length > 1 && double.parse(fractionParts[1]) == 1000) {
      double num = double.parse(fractionParts[0]);
      double den = double.parse(fractionParts[1]);

      if (num / den < 0.5) {
        den /= num;
        return '1/${den.round()}';
      } else {
        den /= num;
        Fraction small = Fraction.fromDouble(1 / double.parse(den.toStringAsFixed(1)));

        return small.toString();
      }
    } else {
      return large;
    }
  }

  static String forceEmpty(String s) {
    if (s[0] == '-') {
      return '';
    } else {
      return s;
    }
  }

  static String removeControlCharacters(String s) {
    return s.replaceAll('"', '\\"').replaceAll('\n', '\\n').replaceAll('\t', '\\t').replaceAll('\b', '\\b').replaceAll('\f', '\\f').replaceAll('\r', '\\r');
  }
}
