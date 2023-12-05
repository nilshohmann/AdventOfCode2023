import 'dart:io';
import 'dart:mirrors';

import 'package:aoc2023/riddle.dart';

void main(List<String> arguments) {
  final riddles = _findAllRiddles();

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

List<Riddle> _findAllRiddles() {
  final classes = currentMirrorSystem()
      .libraries
      .values
      .where((e) => e.simpleName == Symbol.empty)
      .map((e) => e.declarations.values.whereType<ClassMirror>().singleOrNull)
      .nonNulls;
  final riddleType =
      classes.singleWhere((e) => e.simpleName == Symbol('Riddle'));

  final riddles = classes
      .where((e) => !e.isAbstract && e.isAssignableTo(riddleType))
      .map((e) => e.newInstance(Symbol.empty, <dynamic>[]).reflectee as Riddle)
      .toList();

  riddles.sort((a, b) => a.day.compareTo(b.day));

  return riddles;
}
