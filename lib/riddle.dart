import 'dart:async';

import 'package:resource_portable/resource_portable.dart';

typedef TaskFunction<T> = FutureOr<T> Function();

abstract class Riddle {
  final int day;

  Riddle({required this.day});

  Future prepare() async {}

  Future solve() async {
    await prepare();

    _printResultsHeader();
    await _runTask('1', () => solvePart1());
    await _runTask('2', () => solvePart2());
  }

  FutureOr<dynamic> solvePart1() {
    return 0;
  }

  FutureOr<dynamic> solvePart2() {
    return 0;
  }
}

void _printResultsHeader() {
  print('# Results');
  print('');
  print('| Part | Result | Time |');
  print('| --- | --- | --- |');
}

Future<String> readTaskInput(String filename) async {
  final content = await Resource('package:aoc2023/$filename').readAsString();

  return content.trim();
}

FutureOr<dynamic> _runTask(
  String description,
  TaskFunction taskFunction,
) async {
  final stopwatch = Stopwatch()..start();

  final result = await taskFunction();

  stopwatch.stop();
  final duration = stopwatch.elapsed;
  print('| $description | $result | ~${_formatDuration(duration)} |');

  return result;
}

String _formatDuration(Duration duration) {
  if (duration < Duration(seconds: 1)) {
    final milliseconds = (duration * 2000).inSeconds / 2;
    return '${milliseconds}ms';
  }

  if (duration < Duration(minutes: 1)) {
    final seconds = (duration * 100).inSeconds / 100;
    return '${seconds}s';
  }

  if (duration < Duration(hours: 1)) {
    final minutes = (duration * 100).inMinutes / 100;
    return '${minutes}min';
  }

  return duration.toString();
}
