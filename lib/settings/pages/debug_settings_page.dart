import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.data_object_rounded),
                  const SizedBox(width: 8.0),
                  Text(
                    'Delete Local Preferences',
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              ),
              onPressed: () => {
                SharedPreferences.getInstance().then((prefs) async {
                  await prefs.clear();

                  SnackBar snackBar = const SnackBar(
                    content: Text('Cleared all user preferences'),
                    behavior: SnackBarBehavior.floating,
                  );

                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                })
              },
            ),
            const SizedBox(height: 16.0),
            TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: theme.colorScheme.primaryContainer.harmonizeWith(theme.colorScheme.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.data_object_rounded),
                  const SizedBox(width: 8.0),
                  Text(
                    'Delete Local Database',
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
              onPressed: () async {
                String path = join(await getDatabasesPath(), 'thunder.db');
                await databaseFactory.deleteDatabase(path);

                SnackBar snackBar = const SnackBar(
                  content: Text('Cleared local database. Restart Thunder for changes to take effect.'),
                  behavior: SnackBarBehavior.floating,
                );

                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
