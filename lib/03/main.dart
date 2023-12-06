import 'dart:async';
import 'dart:math';

import 'package:aoc2023/riddle.dart';

typedef Digit = (int x, int y, int length);

const String _nonMachineParts = '.0123456789';

class Day03 extends Riddle {
  late final String data;

  Day03() : super(day: 3);

  @override
  Future prepare() async {
    data = await readRiddleInput('03/input.txt');
  }

  @override
  FutureOr solvePart1() {
    final lines = data.split('\n');
    final digits = _findDigits(lines);

    var result = 0;

    for (final (x, y, length) in digits) {
      if (_isPartInRange(lines, x, y, length)) {
        result += int.parse(lines[y].substring(x, x + length));
      }
    }

    return result;
  }

  @override
  FutureOr solvePart2() {
    final lines = data.split('\n');
    final digits = _findDigits(lines);

    var gears = <(int x, int y), List<Digit>>{};

    for (final (x, y, length) in digits) {
      var gear = _findAdjacentGear(lines, y, x, length);
      if (gear != null) {
        if (gears.containsKey(gear)) {
          gears[gear]!.add((x, y, length));
        } else {
          gears[gear] = <Digit>[(x, y, length)];
        }
      }
    }

    var result = 0;

    for (final entry in gears.entries) {
      if (entry.value.length != 2) {
        continue;
      }

      final numbers = entry.value
          .map((e) => int.parse(lines[e.$2].substring(e.$1, e.$1 + e.$3)))
          .toList();
      result += numbers[0] * numbers[1];
    }

    return result;
  }

  List<Digit> _findDigits(List<String> lines) {
    var results = <Digit>[];

    for (var y = 0; y < lines.length; y++) {
      var start = -1;
      var digits = <String>[];

      for (var x = 0; x < lines[y].length; x++) {
        if (int.tryParse(lines[y][x]) != null) {
          digits.add(lines[y][x]);
          if (start < 0) {
            start = x;
          }
        } else {
          if (start >= 0) {
            results.add((start, y, digits.length));
          }

          start = -1;
          digits = <String>[];
        }
      }

      if (start >= 0) {
        results.add((start, y, digits.length));
      }
    }

    return results;
  }

  bool _isPartInRange(List<String> lines, int x, int y, int length) {
    final y1 = max(y - 1, 0);
    final y2 = min(y + 1, lines.length - 1);

    final x1 = max(x - 1, 0);
    final x2 = min(x + length, lines[0].length - 1);

    for (var ay = y1; ay <= y2; ay++) {
      for (var ax = x1; ax <= x2; ax++) {
        if (!_nonMachineParts.contains(lines[ay][ax])) {
          return true;
        }
      }
    }

    return false;
  }

  (int, int)? _findAdjacentGear(List<String> lines, int y, int x, int length) {
    // print('($x, $y) - $length');

    final y1 = max(y - 1, 0);
    final y2 = min(y + 1, lines.length - 1);

    final x1 = max(x - 1, 0);
    final x2 = min(x + length, lines[0].length - 1);

    // print('($x1, $y1) -> ($x2, $y2)');

    for (var ay = y1; ay <= y2; ay++) {
      for (var ax = x1; ax <= x2; ax++) {
        if (lines[ay][ax] == '*') {
          // print(lines[ay][ax]);
          return (ax, ay);
        }
      }
    }

    return null;
  }
}
