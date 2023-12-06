import 'dart:io';

import 'package:path/path.dart' as path;

void main() {
  var day = 1;

  while (true) {
    final dayPath = path.join('lib', day.toString().padLeft(2, '0'));
    if (!Directory(dayPath).existsSync()) {
      break;
    }

    day++;
  }

  final paddedDay = day.toString().padLeft(2, '0');
  final dayPath = path.join('lib', paddedDay);
  Directory(dayPath).createSync();
  File(path.join(dayPath, 'input.txt')).createSync();
  File(path.join(dayPath, 'readme.md')).createSync();

  File(path.join(dayPath, 'main.dart'))
      .writeAsStringSync("""import 'dart:async';

import 'package:aoc2023/riddle.dart';

class Day$paddedDay extends Riddle {
  late final String data;

  Day$paddedDay() : super(day: $day);

  @override
  Future prepare() async {
    data = await readRiddleInput('$paddedDay/input.txt');
  }

  @override
  FutureOr solvePart1() {
    return 0;
  }

  @override
  FutureOr solvePart2() {
    return 0;
  }
}
""");
}
