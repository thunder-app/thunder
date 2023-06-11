import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/communities/bloc/communities_bloc.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/communities/pages/communities_page.dart';

class Thunder extends StatelessWidget {
  const Thunder({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThunderBloc>(create: (context) => ThunderBloc()),
        BlocProvider<CommunitiesBloc>(create: (context) => CommunitiesBloc()),
      ],
      child: const CommunityPage(),
    );
  }
}
