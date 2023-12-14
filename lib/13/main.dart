import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

class Day13 extends Riddle {
  late final List<String> notes;

  Day13() : super(day: 13);

  @override
  Future prepare() async {
    final data = await readRiddleInput('13/input.txt');
    notes = data.split('\n\n');
  }

  @override
  FutureOr solvePart1() {
    return notes.map((n) => _findMirror(n, false)).sum();
  }

  @override
  FutureOr solvePart2() {
    return notes.map((n) => _findMirror(n, true)).sum();
  }

  int _findMirror(String note, bool partTwo) {
    final rows = note.split('\n');
    final row = _findMirrorIndex(rows, partTwo ? 1 : 0);
    if (row > 0) {
      return row * 100;
    }

    final columns = _flip(rows);
    final column = _findMirrorIndex(columns, partTwo ? 1 : 0);
    return column;
  }

  int _findMirrorIndex(List<String> lines, int maxDiff) {
    final potentialMirrors = Iterable.generate(lines.length - 1).where((i) {
      var diff = 0;

      for (var l1 = i, l2 = i + 1;
          l1 >= 0 && l2 < lines.length && diff <= maxDiff;
          l1--, l2++) {
        diff += _countDiffs(lines[l1], lines[l2]);
      }

      return diff == maxDiff;
    }).toList();

    return potentialMirrors.isEmpty ? 0 : potentialMirrors.single + 1;
  }

  List<String> _flip(List<String> lines) {
    return List.generate(lines[0].length,
        (y) => Iterable.generate(lines.length, (x) => lines[x][y]).join(''));
  }

  int _countDiffs(String a, String b) {
    return Iterable.generate(a.length, (i) => a[i] == b[i] ? 0 : 1).sum();
  }
}
