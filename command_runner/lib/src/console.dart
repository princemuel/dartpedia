/*
 * // Copyright 2025 The Dart and Flutter teams. All rights reserved.
 * // Use of this source code is governed by a BSD-style license that can be
 * // found in the LICENSE file.
 */

import 'dart:io';

const String ansiEscapeLiteral = '\x1B';

/// Splits strings on `\n` characters, then writes each line to the
/// console. [duration] defines how many milliseconds there will be
/// between each line print.
Future<void> write(String text, {int duration = 50}) async {
  final List<String> lines = text.split('\n');
  for (final String line in lines) {
    await _delayedPrint('$line \n', duration: duration);
  }
}

Future<void> _delayedPrint(String text, {int duration = 0}) async {
  return Future<void>.delayed(
    Duration(milliseconds: duration),
    () => stdout.write(text),
  );
}

/// RGB formatted colors that are used to style input
///
/// All colors from Dart's brand styleguide
///
/// As a demo, only includes colors this program cares about.
/// If you want to use more colors, add them here.
enum ConsoleColor {
  /// Sky blue - #b8eafe
  lightBlue(184, 234, 254),

  /// Accent colors from Dart's brand guidelines
  /// Warm red - #F25D50
  red(242, 93, 80),

  /// Light yellow - #F9F8C4
  yellow(249, 248, 196),

  /// Light grey, good for text, #F8F9FA
  grey(240, 240, 240),

  ///
  white(255, 255, 255);

  /// Reset text and background color to terminal defaults
  static String get reset => '$ansiEscapeLiteral[0m';

  final int r;
  final int g;
  final int b;

  const ConsoleColor(this.r, this.g, this.b);

  /// Change text color for all future output (until reset)
  /// ```dart
  /// print('hello'); // prints in terminal default color
  /// print('AnsiColor.red.enableForeground');
  /// print('hello'); // prints in red color
  /// ```
  String get enableBackground => '$ansiEscapeLiteral[48;2;$r;$g;${b}m';

  /// Change text color for all future output (until reset)
  /// ```dart
  /// print('hello'); // prints in terminal default color
  /// print('AnsiColor.red.enableForeground');
  /// print('hello'); // prints in red color
  /// ```
  String get enableForeground => '$ansiEscapeLiteral[38;2;$r;$g;${b}m';

  /// Sets background color and then resets the color change
  String applyBackground(String text) {
    return '$ansiEscapeLiteral[48;2;$r;$g;${b}m$text$ansiEscapeLiteral[0m';
  }

  /// Sets text color for the input
  String applyForeground(String text) {
    return '$ansiEscapeLiteral[38;2;$r;$g;${b}m$text$reset';
  }
}

extension TextRenderUtils on String {
  String get errorText => ConsoleColor.red.applyForeground(this);
  String get instructionText => ConsoleColor.yellow.applyForeground(this);
  String get titleText => ConsoleColor.lightBlue.applyForeground(this);

  List<String> splitLinesByLength(int length) {
    final List<String> words = split(' ');
    final List<String> output = <String>[];
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      final String word = words[i];
      if (buffer.length + word.length <= length) {
        buffer.write(word.trim());
        if (buffer.length + 1 <= length) {
          buffer.write(' ');
        }
      }
      // If the next word surpasses length, start the next line
      if (i + 1 < words.length &&
          words[i + 1].length + buffer.length + 1 > length) {
        output.add(buffer.toString().trim());
        buffer.clear();
      }
    }

    // Add left overs
    output.add(buffer.toString().trim());
    return output;
  }
}
