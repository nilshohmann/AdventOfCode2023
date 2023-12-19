import 'dart:async';
import 'dart:math';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

typedef Point = ({int x, int y});
typedef Direction = ({int dx, int dy});

class Day18 extends Riddle {
  late final List<String> lines;

  final right = (dx: 1, dy: 0);
  final down = (dx: 0, dy: 1);
  final left = (dx: -1, dy: 0);
  final up = (dx: 0, dy: -1);

  Day18() : super(day: 18);

  @override
  Future prepare() async {
    final data = await readRiddleInput('18/input.txt');
    lines = data.split('\n');
  }

  @override
  FutureOr solvePart1() {
    final instructions = lines.map((l) {
      final e = l.split(' ');
      final count = int.parse(e[1]);

      return switch (e[0]) {
        'R' => (dx: count, dy: 0),
        'D' => (dx: 0, dy: count),
        'L' => (dx: -count, dy: 0),
        'U' => (dx: 0, dy: -count),
        _ => throw 'Invalid line: $l',
      };
    });

    return _determineHoleArea(instructions);
  }

  @override
  FutureOr solvePart2() {
    final instructions = lines.map((l) {
      final hex = l.split(' ')[2];
      final count = int.parse(hex.substring(2, 7), radix: 16);

      return switch (hex[7]) {
        '0' => (dx: count, dy: 0),
        '1' => (dx: 0, dy: count),
        '2' => (dx: -count, dy: 0),
        '3' => (dx: 0, dy: -count),
        _ => throw 'Invalid line: $l',
      };
    });

    return _determineHoleArea(instructions);
  }

  int _determineHoleArea(Iterable<Direction> instructions) {
    var current = (x: 0, y: 0);

    // Calculate the inner area of the polygon using shoelace algorithm
    final innerArea = 0.5 *
        instructions.map((i) {
          final next = (x: current.x + i.dx, y: current.y + i.dy);
          final value = current.x * next.y - next.x * current.y;
          current = next;
          return value;
        }).sum();

    // As we're only counting the inner area (the points are at the center of
    // our 1m^2 holes) we need to also add the half meter around the inner area
    final outerArea = 0.5 * instructions.map((i) => (i.dx + i.dy).abs()).sum();

    // Now only the remaining area in the edges is missing (1 m^2)
    return (innerArea + outerArea + 1).toInt();
  }
}
