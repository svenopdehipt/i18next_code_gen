import 'package:example/i18n/localizations.i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18next/i18next.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    const locale = Locale('en', 'US');
    return MaterialApp(
      title: 'I18CodeGen Demo',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        I18NextLocalizationDelegate(
          locales: const [locale],
          dataSource: AssetBundleLocalizationDataSource(bundlePath: 'lib/i18n'),
        ),
      ],
      home: Builder(
        builder: (final context) {
          final localizations = Localization.of(context);
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  Text(localizations.example.test),
                  Text(localizations.example.testInterpolation(test: 'test')),
                  Text(localizations.example.testInterpolationNested(test: {'test': 'Test2', 'test2': 'Test3'})),
                  Text(localizations.example.testFormatted(test: 'test4')),
                  Text(localizations.example.testCount(count: 0)),
                  Text(localizations.example.testCount(count: 1)),
                  Text(localizations.example.testCount(count: 2)),
                  Text(localizations.example.testCountInterpolation(count: 0, test: 'test5')),
                  Text(localizations.example.testCountInterpolation(count: 1, test: 'test6')),
                  Text(localizations.example.testCountInterpolation(count: 2, test: 'test7')),
                  Text(localizations.example.testNestedOuter.testNestedInner),
                  Text(localizations.example.testNestedKeyInterpolation(test: 'test8')),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
      locale: locale,
    );
  }
}
