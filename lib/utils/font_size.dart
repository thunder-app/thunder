import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';

Future<Map<String, double>> getTextScaleFactor() async {
  final prefs = (await UserPreferences.instance).sharedPreferences;

  String? titleFontSizeScaleString = prefs.getString(LocalSettings.titleFontSizeScale.name);
  String? contentFontSizeScaleString = prefs.getString(LocalSettings.contentFontSizeScale.name);

  double titleFontSizeScaleFactor = FontScale.base.textScaleFactor;
  double contentFontSizeScaleFactor = FontScale.base.textScaleFactor;

  if (titleFontSizeScaleString != null) {
    titleFontSizeScaleFactor = FontScale.values.byName(titleFontSizeScaleString).textScaleFactor;
  }

  if (contentFontSizeScaleString != null) {
    contentFontSizeScaleFactor = FontScale.values.byName(contentFontSizeScaleString).textScaleFactor;
  }

  Map<String, double> textScaleFactor = {"titleFontSizeScaleFactor": titleFontSizeScaleFactor, "contentFontSizeScaleFactor": contentFontSizeScaleFactor};

  return textScaleFactor;
}
