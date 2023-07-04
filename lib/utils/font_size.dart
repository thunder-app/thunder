import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/font_scale.dart';

Future<Map<String, double>> getTextScaleFactor() async {
  final prefs = await SharedPreferences.getInstance();

  String? titleFontSizeScaleString = prefs.getString("setting_theme_title_font_size_scale");
  String? contentFontSizeScaleString = prefs.getString("setting_theme_content_font_size_scale");

  double _titleFontSizeScaleFactor = FontScale.base.textScaleFactor;
  double _contentFontSizeScaleFactor = FontScale.base.textScaleFactor;

  if (titleFontSizeScaleString != null) {
    _titleFontSizeScaleFactor = FontScale.values.byName(titleFontSizeScaleString).textScaleFactor;
  }

  if (contentFontSizeScaleString != null) {
    _contentFontSizeScaleFactor = FontScale.values.byName(contentFontSizeScaleString).textScaleFactor;
  }

  Map<String, double> textScaleFactor = {"titleFontSizeScaleFactor": _titleFontSizeScaleFactor, "contentFontSizeScaleFactor": _contentFontSizeScaleFactor};

  return textScaleFactor;
}
