import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';

/// Displays search results for instances.
class SearchInstancesResults extends StatelessWidget {
  /// The scroll controller for infinite scrolling.
  final ScrollController scrollController;

  const SearchInstancesResults({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, List<ThunderInstanceInfo>?>(
      selector: (state) => state.instances,
      builder: (context, instances) {
        if (instances == null) return const SizedBox.shrink();

        return ListView.builder(
          controller: scrollController,
          itemCount: instances.length,
          itemBuilder: (context, index) {
            final instanceInfo = instances[index];
            return AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              firstChild: InstanceListEntry(
                instance: ThunderInstanceInfo(
                  id: instanceInfo.id,
                  domain: instanceInfo.domain,
                  name: fetchInstanceNameFromUrl(instanceInfo.domain)!,
                  success: instanceInfo.success,
                ),
              ),
              secondChild: InstanceListEntry(instance: instanceInfo),
              crossFadeState: instanceInfo.isMetadataPopulated() ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            );
          },
        );
      },
    );
  }
}
