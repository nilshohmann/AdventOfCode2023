import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:aoc2023/riddle.dart';

typedef Point = ({int x, int y});
typedef Direction = ({int dx, int dy});

class Day16 extends Riddle {
  late final List<List<String>> field;

  final right = (dx: 1, dy: 0);
  final down = (dx: 0, dy: 1);
  final left = (dx: -1, dy: 0);
  final up = (dx: 0, dy: -1);

  Day16() : super(day: 16);

  @override
  Future prepare() async {
    final data = await readRiddleInput('16/input.txt');
    field = data.split('\n').map((e) => e.split('')).toList();
  }

  @override
  FutureOr solvePart1() {
    return _countEnergizedTiles(((x: 0, y: 0), right));
  }

  @override
  FutureOr solvePart2() async {
    const int threads = 10;

    final energies = await Future.wait(Iterable.generate(
      (field.length / threads).ceil(),
      (s) => Isolate.run(() {
        var maxEnergy = 0;

        for (var i = s; i < field.length; i += threads) {
          maxEnergy = [
            maxEnergy,
            _countEnergizedTiles(((x: i, y: 0), down)),
            _countEnergizedTiles(((x: i, y: field.length - 1), up)),
            _countEnergizedTiles(((x: 0, y: i), right)),
            _countEnergizedTiles(((x: field[0].length - 1, y: i), left)),
          ].reduce(max);
        }

        return maxEnergy;
      }),
    ));

    return energies.reduce(max);
  }

  int _countEnergizedTiles((Point, Direction) start) {
    // Caching to avoid loops
    final visited = <(Point, Direction)>[];

    final beams = [start];
    while (beams.isNotEmpty) {
      final beam = beams.removeLast();
      if (visited.contains(beam)) {
        continue;
      }
      visited.add(beam);

      final (pos, dir) = beam;
      for (final tdir in _nextDirections(pos, dir)) {
        final target = _move(pos, tdir);
        if (target != null) {
          beams.add((target, tdir));
        }
      }
    }

    return visited.map((e) => e.$1).toSet().length;
  }

  List<Direction> _nextDirections(Point pos, Direction dir) {
    final tile = field[pos.y][pos.x];

    if (dir == right) {
      return switch (tile) {
        '\\' => [down],
        '/' => [up],
        '|' => [down, up],
        _ => [dir],
      };
    }
    if (dir == down) {
      return switch (tile) {
        '\\' => [right],
        '/' => [left],
        '-' => [right, left],
        _ => [dir],
      };
    }
    if (dir == left) {
      return switch (tile) {
        '\\' => [up],
        '/' => [down],
        '|' => [down, up],
        _ => [dir],
      };
    }
    if (dir == up) {
      return switch (tile) {
        '\\' => [left],
        '/' => [right],
        '-' => [right, left],
        _ => [dir],
      };
    }

    throw 'Unknown tile at [${pos.x},${pos.y}]: $tile';
  }

  Point? _move(Point pos, Direction dir) {
    final target = (x: pos.x + dir.dx, y: pos.y + dir.dy);
    if (target.x < 0 ||
        target.x >= field[0].length ||
        target.y < 0 ||
        target.y >= field.length) {
      return null;
    }
    return target;
  }
}
