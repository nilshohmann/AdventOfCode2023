import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

class Day09 extends Riddle {
  late final List<List<int>> sensorValues;

  Day09() : super(day: 9);

  @override
  Future prepare() async {
    final data = await readRiddleInput('09/input.txt');
    sensorValues = data.split('\n').map((l) => l.splitToInts()).toList();
  }

  @override
  FutureOr solvePart1() {
    return sensorValues.map(_interpolateNextValue).sum();
  }

  @override
  FutureOr solvePart2() {
    return sensorValues
        .map((e) => e.reversed.toList())
        .map(_interpolateNextValue)
        .sum();
  }

  int _interpolateNextValue(List<int> values) {
    var result = values.last;

    while (values.any((e) => e != 0)) {
      values = List.generate(
        values.length - 1,
        (i) => values[i + 1] - values[i],
      );

      result += values.last;
    }

    return result;
  }
}
