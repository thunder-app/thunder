import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thunder/shared/image_preview.dart';

class LinkPreviewCard extends StatefulWidget {
  const LinkPreviewCard({super.key, this.originURL, this.mediaURL, this.mediaHeight, this.mediaWidth});

  final String? originURL;
  final String? mediaURL;
  final double? mediaHeight;
  final double? mediaWidth;

  @override
  State<LinkPreviewCard> createState() => _LinkPreviewCardState();
}

class _LinkPreviewCardState extends State<LinkPreviewCard> {
  late SharedPreferences preferences;
  bool showLinkPreviews = true;

  void _initPreferences() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      showLinkPreviews = preferences.getBool('setting_general_show_link_previews') ?? true;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  Future<void> _launchURL(url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw Exception('Error: Could not launch $url');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.mediaURL != null && widget.mediaHeight != null && widget.mediaWidth != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(6), // Image border
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6), // Image border
            child: Stack(
              alignment: Alignment.bottomRight,
              fit: StackFit.passthrough,
              children: [
                if (showLinkPreviews) ImagePreview(url: widget.mediaURL!, height: widget.mediaHeight, width: widget.mediaWidth, isExpandable: false),
                Container(
                  color: Colors.grey.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.link,
                          color: Colors.white60,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.originURL!,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: () => _launchURL(widget.originURL),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: InkWell(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6), // Image border
            child: Stack(
              alignment: Alignment.bottomRight,
              fit: StackFit.passthrough,
              children: [
                Container(
                  color: Colors.grey.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.link,
                          color: Colors.white60,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.originURL ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: () => _launchURL(widget.originURL),
        ),
      );
    }
  }
}
