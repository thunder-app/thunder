import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/shared/common_markdown_body.dart';

class InstanceView extends StatelessWidget {
  final Site site;
  final String? alternateSiteName;

  const InstanceView({super.key, required this.site, this.alternateSiteName});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: site.icon != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
              foregroundImage: site.icon != null ? CachedNetworkImageProvider(site.icon!) : null,
              maxRadius: 24,
              child: site.icon == null && alternateSiteName != null
                  ? Text(
                      alternateSiteName!,
                      semanticsLabel: '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  : null,
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
        CommonMarkdownBody(body: site.sidebar ?? ''),
      ],
    );
  }
}
