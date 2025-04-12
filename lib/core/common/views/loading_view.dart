import 'dart:io';
import 'package:share_loc/core/extensions/context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: _buildLoader(context),
      ),
    );
  }

  Widget _buildLoader(BuildContext context) {
    final color = context.theme.colorScheme.secondary;

    return Platform.isIOS
        ? CupertinoActivityIndicator(color: color, radius: 15)
        : CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          );
  }
}
