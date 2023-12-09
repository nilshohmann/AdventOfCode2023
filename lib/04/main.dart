import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

class Day04 extends Riddle {
  late final String data;

  Day04() : super(day: 4);

  @override
  Future prepare() async {
    data = await readRiddleInput('04/input.txt');
  }

  @override
  FutureOr solvePart1() {
    var result = 0;

    final lines = data.split('\n');
    for (final line in lines) {
      final (_, content) = line.splitIntoTwo(': ');
      final (left, right) =
          content.trimLeft().replaceAll('  ', ' ').splitIntoTwo(' | ');

      final winningNumbers = left.splitToInts(' ').toList();
      final myNumbers = right.splitToInts(' ').toList();

      var matches = 0;
      for (final num in myNumbers) {
        if (winningNumbers.contains(num)) {
          matches++;
        }
      }

      if (matches > 0) {
        result += 1 << (matches - 1);
      }
    }

    return result;
  }

  @override
  FutureOr solvePart2() {
    final lines = data.split('\n');
    final copies = List.generate(lines.length, (_) => 1);

    var currentLine = 0;
    for (final line in lines) {
      final (_, content) = line.splitIntoTwo(': ');
      final (left, right) =
          content.trimLeft().replaceAll('  ', ' ').splitIntoTwo(' | ');

      final winningNumbers = left.splitToInts(' ').toList();
      final myNumbers = right.splitToInts(' ').toList();

      var matches = 0;
      for (final num in myNumbers) {
        if (winningNumbers.contains(num)) {
          matches++;
        }
      }

      for (var i = 0; i < matches && i < lines.length; i++) {
        copies[currentLine + 1 + i] += copies[currentLine];
      }

      currentLine++;
    }

    return copies.sum();
  }
}
