import 'package:aoc2023/utils.dart';

Future main() async {
  final data = await readTaskInput('04/input.txt');

  printResultsHeader();
  await runTask<int>('1', () async => _calculateCardsValue(data));
  await runTask<int>('2', () async => _calculateActualCardsValue(data));
}

int _calculateCardsValue(String data) {
  var result = 0;

  final lines = data.split('\n');
  for (final line in lines) {
    final (_, content) = line.splitIntoTwo(': ');
    final (left, right) =
        content.trimLeft().replaceAll('  ', ' ').splitIntoTwo(' | ');

    final winningNumbers = left.split(' ').map((p) => int.parse(p)).toList();
    final myNumbers = right.split(' ').map((p) => int.parse(p)).toList();

    var matches = 0;
    for (final num in myNumbers) {
      if (winningNumbers.contains(num)) {
        matches++;
      }
    }

    if (matches > 0) {
      result += 1 << (matches - 1);
    }
  }

  return result;
}

int _calculateActualCardsValue(String data) {
  final lines = data.split('\n');
  final copies = List.generate(lines.length, (_) => 1);

  var currentLine = 0;
  for (final line in lines) {
    final (_, content) = line.splitIntoTwo(': ');
    final (left, right) =
        content.trimLeft().replaceAll('  ', ' ').splitIntoTwo(' | ');

    final winningNumbers = left.split(' ').map((p) => int.parse(p)).toList();
    final myNumbers = right.split(' ').map((p) => int.parse(p)).toList();

    var matches = 0;
    for (final num in myNumbers) {
      if (winningNumbers.contains(num)) {
        matches++;
      }
    }

    for (var i = 0; i < matches && i < lines.length; i++) {
      copies[currentLine + 1 + i] += copies[currentLine];
    }

    currentLine++;
  }

  return copies.reduce((value, element) => value + element);
}
