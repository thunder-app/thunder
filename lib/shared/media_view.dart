import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/link_preview_card.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy/lemmy.dart';

class MediaView extends StatefulWidget {
  final Post? post;
  final PostViewMedia? postView;

  const MediaView({super.key, this.post, this.postView});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  late SharedPreferences preferences;
  bool showFullHeightImages = true;

  void _initPreferences() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      showFullHeightImages = preferences.getBool('setting_general_show_full_height_images') ?? true;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  Future<void> _launchURL(url) async {
    Uri uri = Uri.parse(url);

    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (widget.postView == null || widget.postView!.media.isEmpty) return Container();

    if (widget.postView!.media.first.mediaType == MediaType.link) {
      return LinkPreviewCard(
        originURL: widget.postView!.media.first.originalUrl,
        mediaURL: widget.postView!.media.first.mediaUrl,
        mediaHeight: widget.postView!.media.first.height,
        mediaWidth: widget.postView!.media.first.width,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.postView!.media.first.mediaUrl!,
              height: showFullHeightImages ? widget.postView!.media.first.height : 150,
              width: widget.postView!.media.first.width,
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
                                    widget.post?.url ?? '',
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
                    onTap: () => _launchURL(widget.post?.url!),
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
