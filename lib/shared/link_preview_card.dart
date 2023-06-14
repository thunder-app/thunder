import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thunder/shared/image_preview.dart';

class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({super.key, this.originURL, this.mediaURL, this.mediaHeight, this.mediaWidth});

  final String? originURL;
  final String? mediaURL;
  final double? mediaHeight;
  final double? mediaWidth;

  Future<void> _launchURL(url) async {
    Uri url0 = Uri.parse(url);

    if (!await launchUrl(url0)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (mediaURL != null && mediaHeight != null && mediaWidth != null) {
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
                ImagePreview(url: mediaURL!, height: mediaHeight, width: mediaWidth, isExpandable: false),
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
                          originURL!,
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
          onTap: () => _launchURL(originURL),
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
                          originURL ?? '',
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
          onTap: () => _launchURL(originURL),
        ),
      );
    }
  }
}
