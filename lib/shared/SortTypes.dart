import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

class SortTypeItem {
  const SortTypeItem({required this.sortType, required this.icon, required this.label});

  final SortType sortType;
  final IconData icon;
  final String label;
}

class PostSortTypes {
  static get items => sortTypeItems;

  static const sortTypeItems = [
    SortTypeItem(
      sortType: SortType.hot,
      icon: Icons.local_fire_department_rounded,
      label: 'Hot',
    ),
    SortTypeItem(
      sortType: SortType.active,
      icon: Icons.rocket_launch_rounded,
      label: 'Active',
    ),
    SortTypeItem(
      sortType: SortType.new_,
      icon: Icons.auto_awesome_rounded,
      label: 'New',
    ),
    // SortTypeItem(
    //   sortType: SortType.,
    //   icon: Icons.history_toggle_off_rounded,
    //   label: 'Old',
    // ),
    SortTypeItem(
      sortType: SortType.mostComments,
      icon: Icons.comment_bank_rounded,
      label: 'Most Comments',
    ),
    SortTypeItem(
      sortType: SortType.newComments,
      icon: Icons.add_comment_rounded,
      label: 'New Comments',
    ),
  ];
}

class CommentSortTypes {
  static get items => sortTypeItems;

  static const sortTypeItems = [
    SortTypeItem(
      sortType: SortType.hot,
      icon: Icons.local_fire_department_rounded,
      label: 'Hot',
    ),
    SortTypeItem(
      sortType: SortType.topAll,
      icon: Icons.vertical_align_top,
      label: 'top',
    ),
    SortTypeItem(
      sortType: SortType.new_,
      icon: Icons.auto_awesome_rounded,
      label: 'New',
    ),
    // SortTypeItem(
    //   sortType: SortType.Old,
    //   icon: Icons.history_toggle_off_rounded,
    //   label: 'Old',
    // ),
  ];
}