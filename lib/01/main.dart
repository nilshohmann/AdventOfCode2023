import 'dart:async';

import 'package:aoc2023/riddle.dart';

class Day01 extends Riddle {
  late final String data;

  Day01() : super(day: 1);

  @override
  Future prepare() async {
    data = await readRiddleInput('01/input.txt');
  }

  @override
  FutureOr solvePart1() {
    final lines = data.split('\n');
    return _getCalibrationValue(lines);
  }

  @override
  FutureOr solvePart2() {
    // Since the first or last letter of the written digit could be part of
    // the previous or next written digit we have to keep them intact
    final lines = data
        .replaceAll('one', 'o1e')
        .replaceAll('two', 't2o')
        .replaceAll('three', 't3e')
        .replaceAll('four', 'f4r')
        .replaceAll('five', 'f5e')
        .replaceAll('six', 's6x')
        .replaceAll('seven', 's7n')
        .replaceAll('eight', 'e8t')
        .replaceAll('nine', 'n9e')
        .split('\n');

    return _getCalibrationValue(lines);
  }

  int _getCalibrationValue(List<String> lines) {
    int result = 0;

    for (var line in lines) {
      var digits = line
          .split('')
          .map((c) => int.tryParse(c) ?? -1)
          .where((d) => d >= 0)
          .toList();
      result += digits.first * 10 + digits.last;
    }

    return result;
  }
}
