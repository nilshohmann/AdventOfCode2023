import 'dart:io';

import 'package:aoc2023/01/main.dart' as day01;
import 'package:aoc2023/02/main.dart' as day02;
import 'package:aoc2023/03/main.dart' as day03;
import 'package:aoc2023/04/main.dart' as day04;

final tasksForDay = <int, void Function()>{
  1: day01.main,
  2: day02.main,
  3: day03.main,
  4: day04.main,
};

void main(List<String> arguments) {
  int? day = arguments.isEmpty ? null : int.tryParse(arguments[0]);

  while (day == null || !tasksForDay.containsKey(day)) {
    stdout.writeln('Available days:');
    for (var d in tasksForDay.keys) {
      stdout.writeln('Day $d');
    }

    stdout.write('Which day do want to execute? ');
    day = int.tryParse(stdin.readLineSync() ?? '');
  }

  stdout.writeln('Executing tasks for day $day...');
  tasksForDay[day]!();
}
