import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

class Day15 extends Riddle {
  late final List<String> sequences;

  Day15() : super(day: 15);

  @override
  Future prepare() async {
    final data = await readRiddleInput('15/input.txt');
    sequences = data.split(',');
  }

  @override
  FutureOr solvePart1() {
    return sequences.map(_hash).sum();
  }

  @override
  FutureOr solvePart2() {
    final boxes = List.generate(256, (_) => <({String l, int f})>[]);
    for (final s in sequences) {
      if (s.endsWith('-')) {
        final l = s.substring(0, s.length - 1);
        final b = _hash(l);
        boxes[b].removeWhere((e) => e.l == l);
      } else {
        final (l, f) = s.splitIntoTwo('=');
        final b = _hash(l);

        final i = boxes[b].indexWhere((e) => e.l == l);
        if (i < 0) {
          boxes[b].add((l: l, f: int.parse(f)));
        } else {
          boxes[b][i] = (l: l, f: int.parse(f));
        }
      }
    }

    final focusPower = boxes
        .mapEnumerated((e, b) => e.isEmpty
            ? 0
            : e.mapEnumerated((l, s) => (b + 1) * (s + 1) * l.f).sum())
        .sum();
    return focusPower;
  }

  int _hash(String s) {
    var value = 0;
    for (final c in s.codeUnits) {
      value = ((value + c) * 17) % 256;
    }
    return value;
  }
}
