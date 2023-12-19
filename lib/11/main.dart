import 'dart:async';
import 'dart:math';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

typedef Point = ({int x, int y});

class Day11 extends Riddle {
  late final List<String> map;

  Day11() : super(day: 11);

  @override
  Future prepare() async {
    final data = await readRiddleInput('11/input.txt');

    map = data.split('\n');
  }

  @override
  FutureOr solvePart1() {
    return _solve(emptySpaceSize: 2);
  }

  @override
  FutureOr solvePart2() {
    return _solve(emptySpaceSize: 1000000);
  }

  int _solve({required int emptySpaceSize}) {
    // We already count them once "normally"
    emptySpaceSize--;

    final galaxies = <Point>[];
    for (var y = 0; y < map.length; y++) {
      for (var x = 0; x < map[y].length; x++) {
        if (map[y][x] == '#') {
          galaxies.add((x: x, y: y));
        }
      }
    }

    final emptyRows = Iterable.generate(map.length)
        .where((y) => Iterable.generate(map[0].length, (x) => (x: x, y: y))
            .where((p) => map[p.y][p.x] == '#')
            .isEmpty)
        .toList();

    final emptyColumns = Iterable.generate(map[0].length)
        .where((x) => Iterable.generate(map[0].length, (y) => (x: x, y: y))
            .where((p) => map[p.y][p.x] == '#')
            .isEmpty)
        .toList();

    var distances = 0;
    while (galaxies.isNotEmpty) {
      final galaxy = galaxies.removeAt(0);

      for (var g in galaxies) {
        final sx = min(galaxy.x, g.x);
        final sy = min(galaxy.y, g.y);

        final dx = (galaxy.x - g.x).abs();
        final dy = (galaxy.y - g.y).abs();
        distances += dx + dy;

        if (dx > 0) {
          distances += emptySpaceSize *
              Iterable.generate(
                  dx, (x) => emptyColumns.contains(sx + x) ? 1 : 0).sum();
        }

        if (dy > 0) {
          distances += emptySpaceSize *
              Iterable.generate(dy, (y) => emptyRows.contains(sy + y) ? 1 : 0)
                  .sum();
        }
      }
    }

    return distances;
  }
}
