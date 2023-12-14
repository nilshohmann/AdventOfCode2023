import 'dart:io';

import 'package:aoc2023/01/main.dart';
import 'package:aoc2023/02/main.dart';
import 'package:aoc2023/03/main.dart';
import 'package:aoc2023/04/main.dart';
import 'package:aoc2023/05/main.dart';
import 'package:aoc2023/06/main.dart';
import 'package:aoc2023/07/main.dart';
import 'package:aoc2023/08/main.dart';
import 'package:aoc2023/09/main.dart';
import 'package:aoc2023/10/main.dart';
import 'package:aoc2023/11/main.dart';
import 'package:aoc2023/12/main.dart';
import 'package:aoc2023/13/main.dart';
import 'package:aoc2023/14/main.dart';
import 'package:aoc2023/riddle.dart';

void main(List<String> arguments) {
  final riddles = _allRiddles();

  int? day = arguments.isEmpty ? null : int.tryParse(arguments[0]);

  while (day == null || !riddles.any((r) => r.day == day)) {
    stdout.writeln('Available days:');
    for (var riddle in riddles) {
      stdout.writeln('Day ${riddle.day}');
    }

    stdout.write('Which day do want to execute? ');
    day = int.tryParse(stdin.readLineSync() ?? '');
  }

  stdout.writeln('Executing tasks for day $day...');
  riddles.singleWhere((r) => r.day == day).solve();
}

List<Riddle> _allRiddles() {
  return <Riddle>[
    Day01(),
    Day02(),
    Day03(),
    Day04(),
    Day05(),
    Day06(),
    Day07(),
    Day08(),
    Day09(),
    Day10(),
    Day11(),
    Day12(),
    Day13(),
    Day14(),
  ];
}
