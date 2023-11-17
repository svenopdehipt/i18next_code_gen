import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';

@immutable
final class Localization {
  const Localization._(
    this.i18next,
    this.context,
  );

  factory Localization.of(
    final BuildContext context, {
    final String? localizationContext,
  }) =>
      Localization._(I18Next.of(context)!, localizationContext);

  final I18Next i18next;

  final String? context;

  _Example get example => _Example(i18next, context);
}

@immutable
final class _ExampleTestNestedOuter {
  const _ExampleTestNestedOuter(
    this.i18next,
    this.context,
  );

  final I18Next i18next;

  final String? context;

  String get testNestedInner =>
      i18next.t('example:testNestedOuter.testNestedInner', context: context);
}

@immutable
final class _Example {
  const _Example(
    this.i18next,
    this.context,
  );

  final I18Next i18next;

  final String? context;

  String get test => i18next.t('example:test', context: context);

  String testInterpolation({required final String test}) =>
      i18next.t('example:testInterpolation',
          variables: {'test': test}, context: context);

  String testInterpolationNested({required final Map<String, dynamic> test}) =>
      i18next.t('example:testInterpolationNested',
          variables: {'test': test}, context: context);

  String testFormatted({required final String test}) => i18next
      .t('example:testFormatted', variables: {'test': test}, context: context);

  String get testNestedKey =>
      i18next.t('example:testNestedKey', context: context);

  String testCount({required final int count}) =>
      i18next.t('example:testCount', count: count, context: context);

  String testCountInterpolation({
    required final String test,
    required final int count,
  }) =>
      i18next.t('example:testCountInterpolation',
          count: count, variables: {'test': test}, context: context);

  _ExampleTestNestedOuter get testNestedOuter =>
      _ExampleTestNestedOuter(i18next, context);

  String testNestedKeyInterpolation({required final String test}) =>
      i18next.t('example:testNestedKeyInterpolation',
          variables: {'test': test}, context: context);
}
