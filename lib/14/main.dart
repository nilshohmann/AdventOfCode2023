import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

typedef Point = ({int x, int y});

class Day14 extends Riddle {
  late final List<List<bool>> cubes;
  late final List<List<bool>> stones;

  // ri: row indexes, ci: column indexes, r: reversed
  late final Map<String, ({List<int> ri, List<int> ci, bool r})> directions;

  Day14() : super(day: 14);

  @override
  Future prepare() async {
    final data = await readRiddleInput('14/input.txt');

    stones = [];
    cubes = data.split('\n').mapEnumerated((l, y) {
      final s = List.generate(l.length, (_) => false);

      final c = List.generate(l.length, (x) {
        if (l[x] == 'O') {
          s[x] = true;
        }

        return l[x] == '#';
      });

      stones.add(s);
      return c;
    }).toList();

    directions = {
      'n': (
        ri: [],
        ci: List.generate(cubes.length, (i) => i),
        r: false,
      ),
      'w': (
        ri: List.generate(cubes[0].length, (i) => i),
        ci: [],
        r: false,
      ),
      's': (
        ri: [],
        ci: List.generate(cubes.length, (i) => i),
        r: true,
      ),
      'e': (
        ri: List.generate(cubes[0].length, (i) => i),
        ci: [],
        r: true,
      ),
    };
  }

  @override
  FutureOr solvePart1() {
    _tilt('n');
    return _findStones().map((e) => stones.length - e.y).sum();
  }

  @override
  FutureOr solvePart2() {
    var index = -1;
    var start = -1;

    // Start by searching for repeating patterns
    final rounds = <List<Point>>[];
    for (; start < 0; index++) {
      for (final d in ['n', 'w', 's', 'e']) {
        _tilt(d);
      }

      final s = _findStones();
      start = rounds.indexWhere((r) => r.eq(s));
      rounds.add(s);
    }

    final finalIndex = start + (1000000000 - index) % (index - start) - 1;
    return rounds[finalIndex].map((e) => stones.length - e.y).sum();
  }

  List<Point> _findStones() {
    final result = <({int x, int y})>[];

    for (final y in Iterable<int>.generate(stones.length)) {
      for (final x in Iterable<int>.generate(stones[0].length)) {
        if (stones[y][x]) {
          result.add((x: x, y: y));
        }
      }
    }

    return result;
  }

  void _print() {
    print(Iterable.generate(cubes.length, (y) {
      return Iterable.generate(cubes[0].length, (x) {
        if (cubes[y][x]) {
          return '#';
        }
        if (stones[y][x]) {
          return 'O';
        }
        return '.';
      }).join('');
    }).join('\n'));
  }

  void _tilt(String direction) {
    final d = directions[direction]!;

    if (d.ri.isNotEmpty) {
      for (final y in Iterable.generate(stones.length)) {
        var free = -1;

        for (final x in d.r ? d.ri.reversed : d.ri) {
          if (cubes[y][x]) {
            free = -1;
            continue;
          }

          if (stones[y][x]) {
            if (free >= 0) {
              stones[y][x] = false;
              stones[y][free] = true;

              free += d.r ? -1 : 1;
            }

            continue;
          }

          if (free < 0) {
            free = x;
          }
        }
      }
    }

    if (d.ci.isNotEmpty) {
      for (final x in Iterable.generate(stones[0].length)) {
        var free = -1;

        for (final y in d.r ? d.ci.reversed : d.ci) {
          if (cubes[y][x]) {
            free = -1;
            continue;
          }

          if (stones[y][x]) {
            if (free >= 0) {
              stones[y][x] = false;
              stones[free][x] = true;

              free += d.r ? -1 : 1;
            }

            continue;
          }

          if (free < 0) {
            free = y;
          }
        }
      }
    }
  }
}
