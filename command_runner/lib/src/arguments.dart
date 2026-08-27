import 'dart:async';
import 'dart:collection';

import '../command_runner.dart';

class ArgResults {
  Command? command;
  String? commandArg;
  Map<Option, Object?> options = {};

  // Returns true if the flag exists.
  bool flag(String name) {
    // Only check flags, because we're sure that flags are booleans.
    for (var option in options.keys.where(
      (opt) => opt.type == OptionType.flag,
    )) {
      if (option.name == name) {
        return options[option] as bool;
      }
    }
    return false;
  }

  ({Option option, Object? input}) getOption(String name) {
    var mapEntry = options.entries.firstWhere(
      (entry) => entry.key.name == name || entry.key.abbr == name,
    );

    return (option: mapEntry.key, input: mapEntry.value);
  }

  bool hasOption(String name) {
    return options.keys.any((option) => option.name == name);
  }
}

abstract class Argument {
  /// In the case of flags, the default value is a bool.
  /// In other options and commands, the default value is a String.
  ///
  /// NB: flags are just Option objects that don't take arguments
  Object? get defaultValue;

  /// an optional `String` that provides a description.
  String? get help;

  /// a `String` that uniquely identifies the argument.
  String get name;

  /// a getter that provides a `String` showing how to use the argument.
  String get usage;

  /// an optional `String` to give a hint about the expected value.
  String? get valueHelp;
}

abstract class Command extends Argument {
  late CommandRunner runner;

  @override
  String? help;

  @override
  String? defaultValue;

  @override
  String? valueHelp;

  final List<Option> _options = [];

  String get description;

  @override
  String get name;

  UnmodifiableSetView<Option> get options =>
      UnmodifiableSetView(_options.toSet());

  bool get requiresArgument => false;

  @override
  String get usage {
    return '$name:  $description';
  }

  /// A flag is an `[Option]` that's treated as a boolean.
  void addFlag(String name, {String? help, String? abbr, String? valueHelp}) {
    _options.add(
      .new(
        name,
        help: help,
        abbr: abbr,
        defaultValue: false,
        valueHelp: valueHelp,
        type: OptionType.flag,
      ),
    );
  }

  /// An option is an `[Option]` that takes a value.
  void addOption(
    String name, {
    String? help,
    String? abbr,
    String? defaultValue,
    String? valueHelp,
  }) {
    _options.add(
      .new(
        name,
        help: help,
        abbr: abbr,
        defaultValue: defaultValue,
        valueHelp: valueHelp,
        type: OptionType.option,
      ),
    );
  }

  FutureOr<Object?> run(ArgResults args);
}

final class Option(
  @override final String name, {
  required final OptionType type,
  @override final String? help,
  final String? abbr,
  @override final Object? defaultValue,
  @override final String? valueHelp,
}) extends Argument {
  @override
  String get usage => switch (abbr) {
    final abbr? => '-$abbr,--$name: $help',
    null => '--$name: $help',
  };
}

enum OptionType { flag, option }
