import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thunder/shared/image_preview.dart';

class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({super.key, this.originURL, this.mediaURL, this.mediaHeight, this.mediaWidth, this.showLinkPreviews = true});

  final String? originURL;
  final String? mediaURL;
  final double? mediaHeight;
  final double? mediaWidth;
  final bool showLinkPreviews;

  Future<void> _launchURL(url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw Exception('Error: Could not launch $url');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

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
                if (showLinkPreviews) ImagePreview(url: mediaURL!, height: mediaHeight, width: mediaWidth, isExpandable: false),
                Container(
                  color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade700,
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
                              // color: Colors.white60,
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
                  color: useDarkTheme ? Colors.grey.shade900 : theme.colorScheme.primary.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.link,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          originURL ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
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
