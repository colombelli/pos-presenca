import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        AppLocalizations.of(context).translate('example_string_1'),
      ),
    );
  }
}