import 'package:flutter/material.dart';

enum UserType {
  moderator,
  admin,
  self,
  bot,
  op,
  birthday;

  get color {
    switch (this) {
      case UserType.moderator:
        return Colors.orange;
      case UserType.admin:
        return Colors.red;
      case UserType.self:
        return Colors.green;
      case UserType.bot:
        return Colors.purple;
      case UserType.op:
        return Colors.blue;
      case UserType.birthday:
        return Colors.pink;
    }
  }
}
