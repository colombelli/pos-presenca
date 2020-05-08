import 'package:flutter/material.dart';
import 'package:pg_check/screens/wrapper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      supportedLocales: [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
      ],

      // Propertie to load the correct file for each localization
      localizationsDelegates: [

          // A class that loads the translations
          AppLocalizations.delegate,

          //Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          //Similarly for other widgets
          GlobalWidgetsLocalizations.delegate,
      ],

      localeResolutionCallback: (locale, supportedLocales) {

        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode){
                return supportedLocale;
              }
        }

        // if locale not supported, return english
        return supportedLocales.first;
      },

      home: Wrapper(),
    );
  }
}