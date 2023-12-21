import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/iterable_extensions.dart';

typedef Point = ({int x, int y});

class Day21 extends Riddle {
  late final Map<Point, bool> field;
  late final Point start;
  late final ({int width, int height}) size;

  final directions = [
    (dx: 1, dy: 0),
    (dx: 0, dy: 1),
    (dx: -1, dy: 0),
    (dx: 0, dy: -1),
  ];

  Day21() : super(day: 21);

  @override
  Future prepare() async {
    final data = await readRiddleInput('21/input.txt');
    field = <Point, bool>{};

    for (final (y, l) in data.split('\n').enumerate()) {
      for (final (x, e) in l.split('').enumerate()) {
        if (e == 'S') {
          start = (x: x, y: y);
        }
        field[(x: x, y: y)] = e != '#';
      }
    }

    size = (width: field.keys.last.x + 1, height: field.keys.last.y + 1);
  }

  @override
  FutureOr solvePart1() {
    return _positionsAfterSteps(64, <Point>{start}).length;
  }

  @override
  FutureOr solvePart2() {
    // Notes:
    // The field is 131x131 with the start point exactly in the middle
    // So after 65 steps the edge of the field is reached
    // (26501365 - 65) % 131 is equal to 0

    // Start with the initial half cycle
    var positions = _positionsAfterSteps(size.width ~/ 2, <Point>{start});

    final cycleStates = [
      (steps: size.width ~/ 2, count: positions.length, diff: positions.length),
    ];

    // Store the latest accelerations in diff
    final diffs = [-1, 0];

    // Try to find the point at which the diffs grow in a predictable way
    while (diffs[0] != diffs[1]) {
      positions = _positionsAfterSteps(size.width, positions);
      cycleStates.add((
        steps: cycleStates[cycleStates.length - 1].steps + size.width,
        count: positions.length,
        diff: positions.length - cycleStates[cycleStates.length - 1].count,
      ));

      diffs[0] = diffs[1];
      diffs[1] = cycleStates[cycleStates.length - 1].diff -
          cycleStates[cycleStates.length - 2].diff;
    }

    final totalCycles = (26501365 / size.width).floor();

    var count = cycleStates[cycleStates.length - 1].count;
    var diff = cycleStates[cycleStates.length - 1].diff;

    // Now we know how the steps count is growing with each cycle and can
    // interpolate the result after the amount of full cycles
    for (var c = cycleStates.length - 1; c < totalCycles; c++) {
      diff += diffs[0];
      count += diff;
    }

    return count;
  }

  Set<Point> _positionsAfterSteps(int steps, Set<Point> positions) {
    for (final _ in Iterable.generate(steps)) {
      final nextPositions = <Point>{};
      for (final p in positions) {
        for (final d in directions) {
          final t = (x: p.x + d.dx, y: p.y + d.dy);
          if (field[(x: t.x % size.width, y: t.y % size.height)] ?? false) {
            nextPositions.add(t);
          }
        }
      }
      positions = nextPositions;
    }

    return positions;
  }
}
