import 'dart:async';
import 'dart:collection';

import '../command_runner.dart';

class ArgResults {
  Command? command;
  String? commandArg;
  Map<Option, Object?> options = {};

  // Returns true if the flag exists
  bool flag(String name) {
    // Only check flags, because we're sure that flags are booleans
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
      orElse: () {
        throw ArgumentException(
          'Input $name is not a known option',
          command?.name ?? '',
          name,
        );
      },
    );

    return (option: mapEntry.key, input: mapEntry.value);
  }

  bool hasOption(String name) {
    return options.keys.any((option) => option.name == name);
  }
}

sealed class Argument {
  // In the case of flags, the default value is a bool
  // In other options and commands, the default value is String
  // NB: flags are just Option objects that don't take arguments
  Object? get defaultValue;
  String? get help;

  String get name;
  String get usage;

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

  /// A flag is an [Option] that's treated as a boolean.
  /// All flags have a default value of false, and are
  /// considered true if the flag is passed into the
  /// command at all.
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

  FutureOr<String> run(ArgResults args);
}

class Option(
  this.name, {
  required this.type,
  this.help,
  this.abbr,
  this.defaultValue,
  this.valueHelp,
}) extends Argument {
  @override
  final String name;

  final OptionType type;

  @override
  final String? help;

  final String? abbr;

  @override
  final Object? defaultValue;

  @override
  final String? valueHelp;

  @override
  String get usage => switch (abbr) {
    final abbr? => '-$abbr,--$name: $help',
    null => '--$name: $help',
  };
}

enum OptionType { flag, option }
