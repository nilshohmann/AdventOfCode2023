import 'dart:async';
import 'dart:isolate';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

typedef Point = ({int x, int y, int z});
typedef Brick = ({int id, Point start, Point end});

class Day22 extends Riddle {
  late final List<Brick> allBricks;

  Day22() : super(day: 22);

  @override
  Future prepare() async {
    final data = await readRiddleInput('22/input.txt');

    var id = 0;
    allBricks = data.split('\n').map((l) {
      final (s, e) = l.splitIntoTwo('~');
      final sc = s.splitToInts(',');
      final ec = e.splitToInts(',');

      final start = (x: sc[0], y: sc[1], z: sc[2]);
      final end = (x: ec[0], y: ec[1], z: ec[2]);
      final swap = (start.x > end.x || start.y > start.y || start.z > end.z);

      return (
        id: id++,
        start: swap ? end : start,
        end: swap ? start : end,
      );
    }).sortdBy((b) => b.start.z);
  }

  @override
  FutureOr solvePart1() {
    // Let all the bricks fall down
    final (:brickMap, :field, dropped: _) = _dropBricks(allBricks);

    var disintegratableBricks = 0;

    for (var brick in brickMap.values.sortdBy((b) => b.start.z)) {
      // Remove brick
      for (final p in _getPointsFor(brick)) {
        field.remove(p);
      }

      // Check if bricks directly above can fall down
      final bricksAbove = _getBricksAbove(brick, field);
      if (!bricksAbove.any((id) => _canMoveDown(brickMap[id]!, field))) {
        disintegratableBricks++;
      }

      // Add brick again
      for (final p in _getPointsFor(brick)) {
        field[p] = brick.id;
      }
    }

    return disintegratableBricks;
  }

  @override
  FutureOr solvePart2() async {
    // Let all the bricks fall down
    final (:brickMap, dropped: _, field: _) = _dropBricks(allBricks);

    final bricks = brickMap.values.sortdBy((b) => b.start.z);

    var droppedBricks = await Future.wait(bricks.map((brick) {
      return Isolate.run(() {
        final r = _dropBricks(bricks.where((b) => b.id != brick.id));
        return r.dropped;
      });
    }));

    return droppedBricks.sum();
  }

  ({int dropped, Map<int, Brick> brickMap, Map<Point, int> field}) _dropBricks(
      Iterable<Brick> bricks) {
    final brickMap = <int, Brick>{};

    final field = <Point, int>{};
    for (final brick in bricks) {
      brickMap[brick.id] = brick;

      for (final p in _getPointsFor(brick)) {
        field[p] = brick.id;
      }
    }

    final dropped = <int>{};

    for (var brick in bricks) {
      while (_canMoveDown(brick, field)) {
        brick = _moveDown(brick, field);
        brickMap[brick.id] = brick;
        dropped.add(brick.id);
      }
    }

    return (dropped: dropped.length, brickMap: brickMap, field: field);
  }

  List<Point> _getPointsFor(Brick brick) {
    if (brick.start.x != brick.end.x) {
      return List.generate(brick.end.x - brick.start.x + 1,
          (i) => (x: brick.start.x + i, y: brick.start.y, z: brick.start.z));
    }

    if (brick.start.y != brick.end.y) {
      return List.generate(brick.end.y - brick.start.y + 1,
          (i) => (x: brick.start.x, y: brick.start.y + i, z: brick.start.z));
    }

    if (brick.start.z != brick.end.z) {
      return List.generate(brick.end.z - brick.start.z + 1,
          (i) => (x: brick.start.x, y: brick.start.y, z: brick.start.z + i));
    }

    if (brick.start == brick.end) {
      return [brick.start];
    }

    throw 'Invalid brick: $brick';
  }

  bool _canMoveDown(Brick brick, Map<Point, int> field) {
    if (brick.start.z == 1) {
      return false;
    }

    return brick.start.z != brick.end.z
        // Vertical brick
        ? field[_oneDown(brick.start)] == null
        // Horizontal brick
        : _getPointsFor(brick).all((p) => field[_oneDown(p)] == null);
  }

  Brick _moveDown(Brick brick, Map<Point, int> field) {
    if (brick.start.z != brick.end.z) {
      // Vertical brick
      field.remove(brick.end);
      field[_oneDown(brick.start)] = brick.id;
    } else {
      // Horizontal brick
      for (final p in _getPointsFor(brick)) {
        field.remove(p);
        field[_oneDown(p)] = brick.id;
      }
    }

    return (
      id: brick.id,
      start: _oneDown(brick.start),
      end: _oneDown(brick.end),
    );
  }

  List<int> _getBricksAbove(Brick brick, Map<Point, int> field) {
    var ids = <int?>{};

    // Vertical brick
    if (brick.start.z != brick.end.z) {
      ids.add(field[_oneUp(brick.end)]);
    } else {
      for (final p in _getPointsFor(brick)) {
        ids.add(field[_oneUp(p)]);
      }
    }

    return ids.nonNulls.toList();
  }

  Point _oneDown(Point point) {
    return (x: point.x, y: point.y, z: point.z - 1);
  }

  Point _oneUp(Point point) {
    return (x: point.x, y: point.y, z: point.z + 1);
  }
}
