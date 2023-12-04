import 'package:aoc2023/utils.dart';

Future main() async {
  final data = await readTaskInput('01/input.txt');

  printResultsHeader();
  await runTask<int>('1', () async => _calculatePart1(data));
  await runTask<int>('2', () async => _calculatePart2(data));
}

int _calculatePart1(String data) {
  final lines = data.split('\n');
  return _getCalibrationValue(lines);
}

int _calculatePart2(String data) {
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
