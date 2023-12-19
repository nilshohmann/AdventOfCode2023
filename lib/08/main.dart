import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

class Day08 extends Riddle {
  late final List<int> instructions;
  late final Map<String, List<String>> map = <String, List<String>>{};

  Day08() : super(day: 8);

  @override
  Future prepare() async {
    final data = await readRiddleInput('08/input.txt');
    final (rawInstructions, rawMap) = data.splitIntoTwo('\n\n');
    instructions = rawInstructions.split('').map('LR'.indexOf).toList();

    for (final l in rawMap.split('\n')) {
      final (name, targets) = l.splitIntoTwo(' = ');

      map[name] = targets.substring(1, targets.length - 1).split(', ');
    }
  }

  @override
  FutureOr solvePart1() {
    var position = 'AAA';

    var i = 0;
    for (; position != 'ZZZ'; i++) {
      position = map[position]![instructions[i % instructions.length]];
    }

    return i;
  }

  @override
  FutureOr solvePart2() {
    final positions = map.keys.where((e) => e.endsWith('A')).toList();

    final singleFinishes = positions.map((position) {
      String nextPosition(String p, int i) {
        return map[p]![instructions[i % instructions.length]];
      }

      var i = 0;
      var start = (count: 0, position: nextPosition(position, 0));

      while (true) {
        position = nextPosition(position, i++);

        // Try to find a solution for each ghost that
        if (position.endsWith('Z') &&
            // ... is a multiple of the  instructions length
            i % instructions.length == 0) {
          // ... and repeats itself
          if (nextPosition(position, 0) == start.position) {
            break;
          } else {
            start = (count: i, position: nextPosition(position, 0));
          }
        }
      }

      return start.count - i;
    }).toList();

    // Finally find the least common multiple of all these runs
    return singleFinishes.reduce(_leastCommonMultiple);
  }

  int _leastCommonMultiple(int a, int b) {
    if ((a == 0) || (b == 0)) {
      return 0;
    }

    return ((a ~/ a.gcd(b)) * b).abs();
  }
}
