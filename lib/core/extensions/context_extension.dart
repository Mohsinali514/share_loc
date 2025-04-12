import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension ContextExt on BuildContext {
  ThemeData get theme {
    return Theme.of(this);
  }

  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }

  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;

  UserProvider get userProvider => read<UserProvider>();

  LocalUser? get currentUser => userProvider.user;
}
