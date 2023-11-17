import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

Builder i18NextCodeGenFactory(final BuilderOptions options) =>
    I18NextCodeGen(
        localizations: options.config['localizations'],
        out: options.config['out'],
        flutter: options.config['flutter'],
    );

class I18NextCodeGen implements Builder {
  const I18NextCodeGen({required this.localizations, required this.out, required this.flutter});

  final String localizations;
  final String out;
  final bool flutter;

  @override
  Future build(final BuildStep buildStep) async {
    final allJsonFiles = await buildStep.findAssets(Glob(localizations)).toList();

    final file = LibraryBuilder();

    if (flutter) {
      file.directives.add(Directive.import('package:flutter/material.dart'));
    }
    else {
      file.directives.add(Directive.import('dart:ui'));
    }

    file.directives.add(Directive.import('package:i18next/i18next.dart'));

    final mainClass = _initClass(className: 'Localization', constructorName: '_')
      ..constructors.add(
        Constructor((final cb) {
          if (flutter) {
            cb.requiredParameters.add(
              Parameter((final pb) => pb
                ..type = const Reference('final BuildContext')
                ..name = 'context',
              ),
            );
          }
          else {
            cb.requiredParameters.addAll([
              Parameter((final pb) => pb
                ..type = const Reference('final Locale')
                ..name = 'locale',
              ),
              Parameter((final pb) => pb
                ..type = const Reference('final ResourceStore')
                ..name = 'resourceStore',
              ),
            ]);
          }
          cb
              ..factory = true
              ..name = 'of'
              ..optionalParameters.add(
                Parameter((final pb) => pb
                  ..type = const Reference('final String?')
                  ..name = 'localizationContext'
                  ..named = true,
                ),
              )
              ..lambda = true
              ..body = const Code('Localization._(I18Next.of(context)!, localizationContext)');

          if (flutter) {
            cb.body = const Code('Localization._(I18Next.of(context)!, localizationContext)');
          }
          else {
            cb.body = const Code('Localization._(I18Next(locale, resourceStore)!, localizationContext)');
          }
        }),
      );

    for (final jsonFile in allJsonFiles) {
      final Map<String, dynamic> content = jsonDecode(await buildStep.readAsString(jsonFile));

      final key = jsonFile.pathSegments.last.split('.').first;
      final className = _getClassName(key: key);
      _createClass(className, content, mainClass, file, '$key:');

      _addClassAttribute(class$: mainClass, key: key, className: className);
    }

    file.body.insert(0, mainClass.build());
    await File(out).writeAsString(DartFormatter().format(file.build().accept(DartEmitter()).toString()));
  }

  void _createClass(
    final String key,
    final Map<String, dynamic> content,
    final ClassBuilder superClass,
    final LibraryBuilder file,
    [final String prefix = '',]
  ) {
    final newClass = _initClass(className: key);
    content
      ..removeWhere((final key, final value) => key.contains('_plural') || key.contains('_male') || key.contains('_female'))
      ..forEach((final key, final value) {
        if (value is String) {
          _createAttribute(key, value, newClass, prefix);
        }
        if (value is Map<String, dynamic>) {
          final className = _getClassName(key: key, prevClass: newClass.name!);
          _createClass(className, value, newClass, file, '$prefix$key.');
          _addClassAttribute(class$: newClass, key: key, className: className);
        }
      });
    file.body.add(newClass.build());
  }

  void _createAttribute(final String key, final String value, final ClassBuilder superClass, [final String prefix = '']) {
    superClass.methods.add(Method((final fb) {
      var params = value.split('{{').sublist(1)
        .map((final e) => e.split('}}').first);
      
      final dateParams = params.where((final e) => !e.contains('.') && e.contains('datetime'))
        .map((final e) => e.split(',').first);

      params = params.where((final e) => !e.contains('datetime')).map((final e) => e.split(',').first);

      final stringParams = params.where((final e) => !e.contains('.') && e != 'count');
      final hasNumberParam = params.contains('count');
      final objectParams = params.where((final e) => e.contains('.')).map((final e) => e.split('.').first).toSet();

      var body = "i18next.t('$prefix$key'";

      fb
        ..returns = const Reference('String')
        ..name = key
        ..optionalParameters.addAll(
          stringParams.map((final e) => Parameter((final pb) =>
            pb
              ..name = e
              ..type = const Reference('final String')
              ..named = true
              ..required = true,
          ),),
        )
        ..optionalParameters.addAll(
          objectParams.map((final e) => Parameter((final pb) =>
            pb
              ..name = e
              ..type = const Reference('final Map<String, dynamic>')
              ..named = true
              ..required = true,
          ),),
        )
        ..optionalParameters.addAll(
          dateParams.map((final e) => Parameter((final pb) =>
            pb
              ..name = e
              ..type = const Reference('final DateTime')
              ..named = true
              ..required = true,
          ),),
        )
        ..type = params.isEmpty ? MethodType.getter : null
        ..lambda = true;

      if (hasNumberParam) {
        fb.optionalParameters.add(Parameter(
          (final pb) =>
            pb
              ..name = 'count'
              ..type = const Reference('final int')
              ..named = true
              ..required = true,
        ),);

        body += ', count: count';
      }

      final paramMap = <String, String>{};
      for (final param in stringParams.followedBy(objectParams).followedBy(dateParams)) {
        paramMap["'$param'"] = param;
      }

      if (paramMap.isNotEmpty) {
        body += ', variables: $paramMap';
      }

      fb.body = Code('$body, context: context)');
    }),);
  }

  String _getClassName({required final String key, final String prevClass = ' '}) =>
    '_${prevClass.substring(1)}${key.replaceRange(0, 1, key[0].toUpperCase())}';

  void _addClassAttribute({required final ClassBuilder class$, required final String key, required final String className}) {
    class$.methods.add(Method((final fb) {
        fb
          ..name = key
          ..type = MethodType.getter
          ..body = Code('$className(i18next, context)')
          ..returns = Reference(className)
          ..lambda = true;
      }),);
  }

  ClassBuilder _initClass({required final String className, final String? constructorName}) {
    final builder = ClassBuilder()
      ..name = className
      ..modifier = ClassModifier.final$
      ..fields.addAll([
        Field((final fb) =>
          fb
            ..name = 'i18next'
            ..modifier = FieldModifier.final$
            ..type = const Reference('I18Next'),
        ),
        Field((final fb) =>
          fb
            ..name = 'context'
            ..modifier = FieldModifier.final$
            ..type = const Reference('String?'),
        ),
      ])
      ..constructors.add(
        Constructor((final cb) =>
          cb
            ..constant = true
            ..name = constructorName
            ..requiredParameters.addAll([
              Parameter((final pb) => {
                pb.toThis = true,
                pb.name = 'i18next',
              },),
              Parameter((final pb) => {
                pb.toThis = true,
                pb.name = 'context',
              },),
            ]),
        ),
      );

    if (flutter) {
      builder.annotations.add(const CodeExpression(Code('immutable')));
    }

    return builder;
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'$lib$': ['g.dart'],
  };
}
