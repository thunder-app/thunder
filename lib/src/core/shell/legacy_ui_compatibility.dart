import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/cupertino.dart' as legacy_cupertino; // ignore: deprecated_member_use, migrate_design_widgets
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as legacy_material; // ignore: deprecated_member_use, migrate_design_widgets
import 'package:flutter_localizations/flutter_localizations.dart' as legacy_localizations;
import 'package:material_ui/material_ui.dart';

/// Bridges packages that still use Flutter's legacy Material and Cupertino APIs.
class LegacyUiCompatibility extends StatelessWidget {
  const LegacyUiCompatibility({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return MaterialUiCompatibilityBridge(
      delegates: const [
        _LegacyEsperantoMaterialDelegate(),
        _LegacyEsperantoCupertinoDelegate(),
        // The bridge needs delegates for the legacy widget types.
        // ignore: deprecated_member_use
        legacy_localizations.GlobalMaterialLocalizations.delegate,
        // ignore: deprecated_member_use
        legacy_localizations.GlobalCupertinoLocalizations.delegate,
        legacy_localizations.GlobalWidgetsLocalizations.delegate,
      ],
      // ignore: deprecated_member_use
      child: CupertinoUiCompatibilityBridge(
        delegates: const [
          _LegacyEsperantoCupertinoDelegate(),
          // ignore: deprecated_member_use
          legacy_localizations.GlobalCupertinoLocalizations.delegate,
          legacy_localizations.GlobalWidgetsLocalizations.delegate,
        ],
        child: child,
      ),
    );
  }
}

// Legacy Flutter localizations have no Esperanto delegate; use English for
// legacy widgets while the migrated app continues to use Esperanto.
class _LegacyEsperantoMaterialDelegate extends LocalizationsDelegate<legacy_material.MaterialLocalizations> {
  const _LegacyEsperantoMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'eo';

  @override
  Future<legacy_material.MaterialLocalizations> load(Locale locale) => SynchronousFuture(const legacy_material.DefaultMaterialLocalizations());

  @override
  bool shouldReload(_LegacyEsperantoMaterialDelegate old) => false;
}

class _LegacyEsperantoCupertinoDelegate extends LocalizationsDelegate<legacy_cupertino.CupertinoLocalizations> {
  const _LegacyEsperantoCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'eo';

  @override
  Future<legacy_cupertino.CupertinoLocalizations> load(Locale locale) => SynchronousFuture(const legacy_cupertino.DefaultCupertinoLocalizations());

  @override
  bool shouldReload(_LegacyEsperantoCupertinoDelegate old) => false;
}
