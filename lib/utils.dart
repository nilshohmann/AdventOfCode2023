import 'dart:async';

import 'package:resource_portable/resource.dart' show Resource;

typedef TaskFunction<T> = Future<T> Function();

Future<String> readTaskInput(String filename) async {
  final content = await Resource('package:aoc2023/$filename').readAsString();

  return content.trim();
}

void printResultsHeader() {
  print('# Results');
  print('');
  print('| Part | Result | Time |');
  print('| --- | --- | --- |');
}

Future<T> runTask<T>(String description, TaskFunction taskFunction) async {
  final stopwatch = Stopwatch()..start();

  final result = await taskFunction();

  stopwatch.stop();
  print('| $description | $result | ~${formatDuration(stopwatch.elapsed)} |');

  return result;
}

String formatDuration(Duration duration) {
  if (duration < Duration(seconds: 1)) {
    final ms = (duration * 2000).inSeconds;
    return '${ms / 2}ms';
  }

  return duration.toString();
}

extension StringExtensions on String {
  (String, String) splitIntoTwo(String separator) {
    final index = indexOf(separator);
    if (index < 0) {
      throw 'Separator "$separator" not found in "$this"';
    }

    return (substring(0, index), substring(index + separator.length));
  }
}
