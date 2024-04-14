import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/shared/common_markdown_body.dart';

class InstanceView extends StatelessWidget {
  final Site site;

  const InstanceView({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 48,
              child: site.icon == null
                  ? CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      maxRadius: 24,
                      child: Text(
                        site.name[0],
                        semanticsLabel: '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: site.icon!,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundColor: Colors.transparent,
                        foregroundImage: imageProvider,
                        maxRadius: 24,
                      ),
                    ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    site.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          site.description ?? '',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(),
        CommonMarkdownBody(
          body: site.sidebar ?? '',
        ),
      ],
    );
  }
}
