import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy/lemmy.dart';

class MediaView extends StatelessWidget {
  final Post post;

  const MediaView({super.key, required this.post});

  Future<void> _launchURL(url) async {
    Uri url0 = Uri.parse(url);

    if (!await launchUrl(url0)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (post.url == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: post.url!,
              fit: BoxFit.fitWidth,
              progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                color: Colors.grey.shade900,
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(value: downloadProgress.progress),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade900,
                child: Padding(
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
                                    post.url ?? '',
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
                    onTap: () => _launchURL(post.url!),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
