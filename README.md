# i18next_code_gen

[![pub package](https://img.shields.io/pub/v/i18next_code_gen.svg)](https://pub.dev/packages/i18next_code_gen)

---

A plugin which supports code generation for [i18next](https://pub.dev/packages/i18next).

## Getting Started

Add the config to the `build.yaml`:

```yaml
targets:
  $default:
    builders:
      i18next_code_gen:
        options:
          localizations: lib/i18n/en-US/*.json
```

Replace en-US with the main language. It is also possible to
add an `out`-option to change the output file. The default file is
`lib/i18n/localizations.i18n.dart`. Another option is to add
`flutter: false` to support dart only environments.

## Code generation

Run the code generator once with `dart run build_runner build` or
add a listener with `dart run build_runner watch`.

## Usage

Get the localization by importing `/i18n/localizations.i18n.dart`
and calling `Localization.of(context)`. This returns a variable which
contains sub-variables and sub-sub-variables to get the localization.

## Supported systems

Supports all Dart and Flutter environments.
