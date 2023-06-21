import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'package:lemmy/lemmy.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/core/theme/bloc/theme_bloc.dart';
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  // General settings
  bool showLinkPreviews = true;
  bool showVoteActions = true;
  bool showSaveAction = true;
  bool showFullHeightImages = false;

  String defaultInstance = 'lemmy.world';
<<<<<<< HEAD
<<<<<<< HEAD
=======
  String themeType = 'dark';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
  String themeType = 'dark';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  TextEditingController instanceController = TextEditingController();

  // Loading
  bool isLoading = true;

  void setPreferences(attribute, value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (attribute) {
      case 'setting_general_show_link_previews':
        await prefs.setBool('setting_general_show_link_previews', value);
        setState(() => showLinkPreviews = value);
        break;
      case 'setting_general_show_vote_actions':
        await prefs.setBool('setting_general_show_vote_actions', value);
        setState(() => showVoteActions = value);
        break;
      case 'setting_general_show_save_action':
        await prefs.setBool('setting_general_show_save_action', value);
        setState(() => showSaveAction = value);
        break;
      case 'setting_general_show_full_height_images':
        await prefs.setBool('setting_general_show_full_height_images', value);
        setState(() => showFullHeightImages = value);
        break;
      case 'setting_instance_default_instance':
        await prefs.setString('setting_instance_default_instance', value);
        setState(() => defaultInstance = value);
        break;
<<<<<<< HEAD
<<<<<<< HEAD
    }

    if (context.mounted) context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      case 'setting_theme_type':
        await prefs.setString('setting_theme_type', value);
        setState(() => themeType = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      showLinkPreviews = prefs.getBool('setting_general_show_link_previews') ?? true;
      showVoteActions = prefs.getBool('setting_general_show_vote_actions') ?? true;
      showSaveAction = prefs.getBool('setting_general_show_save_action') ?? true;
      showFullHeightImages = prefs.getBool('setting_general_show_full_height_images') ?? false;
<<<<<<< HEAD
<<<<<<< HEAD
=======
      themeType = prefs.getString('setting_theme_type') ?? 'dark';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
      themeType = prefs.getString('setting_theme_type') ?? 'dark';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      isLoading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('General'), centerTitle: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Posts',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Show link previews',
                          value: showLinkPreviews,
                          iconEnabled: Icons.photo_size_select_actual_rounded,
                          iconDisabled: Icons.photo_size_select_actual_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_link_previews', value),
                        ),
                        ToggleOption(
                          description: 'Show voting on posts',
                          value: showVoteActions,
                          iconEnabled: Icons.import_export_rounded,
                          iconDisabled: Icons.import_export_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_vote_actions', value),
                        ),
                        ToggleOption(
                          description: 'Show save action on post',
                          value: showSaveAction,
                          iconEnabled: Icons.star_rounded,
                          iconDisabled: Icons.star_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_save_action', value),
                        ),
                        ToggleOption(
                          description: 'View full height images',
                          value: showFullHeightImages,
                          iconEnabled: Icons.view_compact_rounded,
                          iconDisabled: Icons.view_compact_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_full_height_images', value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
<<<<<<< HEAD
<<<<<<< HEAD
                            'Instances',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                            'Theme',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Use dark theme',
                          value: themeType == 'dark',
                          iconEnabled: Icons.dark_mode_rounded,
                          iconDisabled: Icons.dark_mode_outlined,
                          onToggle: (bool value) => setPreferences('setting_theme_type', value == true ? 'dark' : 'light'),
                        ),
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                        // TextFormField(
                        //   // initialValue: defaultInstance ?? '',

                        //   controller: instanceController,
                        //   decoration: const InputDecoration(
                        //     prefix: Text('https://'),
                        //     isDense: true,
                        //     hintText: 'lemmy.ml',
                        //   ),
                        // ),
                        // const SizedBox(height: 16.0),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     setPreferences('setting_instance_default_instance', 'https://${instanceController.text}');

                        //     LemmyClient lemmyClient = LemmyClient.instance;
                        //     lemmyClient.changeBaseUrl('https://${instanceController.text}');
                        //     SnackBar snackBar = SnackBar(
                        //       content: Text('Default instance changed to ${instanceController.text}'),
                        //       behavior: SnackBarBehavior.floating,
                        //     );
                        //     ScaffoldMessenger.of(context).clearSnackBars();
                        //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        //   },
                        //   child: const Text('Change default instance'),
                        // ),
                        // ToggleOption(
                        //   description: 'Change default instance',
                        //   value: defaultInstance,
                        //   iconEnabled: Icons.computer_rounded,
                        //   iconDisabled: Icons.photo_size_select_actual_rounded,
                        //   onToggle: (bool value) => setPreferences('setting_general_show_link_previews', value),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
