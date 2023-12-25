import 'dart:async';
import 'dart:math';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

typedef Point = ({int x, int y, int z});
typedef Velocity = ({int dx, int dy, int dz});
typedef HailStone = ({Point p, Velocity v});
typedef Range = ({int start, int end});

class Day24 extends Riddle {
  late final List<HailStone> hailStones;
  late final Range velocities;

  Day24() : super(day: 24);

  @override
  Future prepare() async {
    final data = await readRiddleInput('24/input.txt');
    var (minV, maxV) = (0, 0);

    hailStones = data.split('\n').map((l) {
      final [p, v] = l.split(' @ ');
      final [x, y, z] = p.splitToInts(', ');
      final [dx, dy, dz] = v.splitToInts(', ');

      minV = [dx, dy, dz, minV].reduce(min);
      maxV = [dx, dy, dz, maxV].reduce(max);
      return (p: (x: x, y: y, z: z), v: (dx: dx, dy: dy, dz: dz));
    }).toList();

    velocities = (start: minV, end: maxV);
  }

  @override
  FutureOr solvePart1() {
    var collisions = 0;

    final area = (min: 200000000000000, max: 400000000000000);
    for (var i = 0; i < hailStones.length; i++) {
      for (var j = i + 1; j < hailStones.length; j++) {
        final c = _intersectionInTwoDimensions(hailStones[i], hailStones[j]);
        if (c != null &&
            c.x >= area.min &&
            c.x <= area.max &&
            c.y >= area.min &&
            c.y <= area.max) {
          collisions++;
        }
      }
    }

    return collisions;
  }

  @override
  FutureOr solvePart2() {
    final rock = _possibleRocks()
        .where((r) => hailStones.all((h) => r.collidesWith(h)))
        .firstOrNull;

    if (rock == null) {
      throw 'No possible rock found';
    }

    return rock.p.x + rock.p.y + rock.p.z;
  }

  ({double x, double y})? _intersectionInTwoDimensions(
      HailStone a, HailStone b) {
    // (a.px, a.py) + t1 * (a.vx, a.vy) = (b.px, b.py) + t2 * (b.vx, b.vy)
    // a.px + t1 * a.vx = b.px + t2 * b.vx
    // a.py + t1 * a.vy = b.py + t2 * b.vy
    //
    // t1 = (b.px - a.px + t2 * b.vx) / a.vx = (b.py - a.py + t2 * b.vy) / a.vy
    // px + t2 * b.vx / a.vx = py + t2 * b.vy / a.vy
    // t2 = (py - px) / (b.vx / a.vx - b.vy / a.vy)

    final p = (x: (b.p.x - a.p.x) / a.v.dx, y: (b.p.y - a.p.y) / a.v.dy);
    final d = b.v.dx / a.v.dx - b.v.dy / a.v.dy;
    if (d == 0) {
      return null;
    }

    final t1 = (p.y - p.x) / d;
    final c = (x: b.p.x + t1 * b.v.dx, y: b.p.y + t1 * b.v.dy);
    final t2 = p.x + t1 * b.v.dx / a.v.dx;

    return t1 >= 0 && t2 >= 0 ? c : null;
  }

  Iterable<HailStone> _possibleRocks() sync* {
    // Exclude some directions the stone can not possibly go to
    final invalidXRanges = <Range>[];
    final invalidYRanges = <Range>[];
    final invalidZRanges = <Range>[];

    for (var i = 0; i < hailStones.length; i++) {
      final h1 = hailStones[i];

      for (var j = i + 1; j < hailStones.length; j++) {
        final h2 = hailStones[j];

        if (h1.p.x > h2.p.x && h1.v.dx > h2.v.dx) {
          invalidXRanges.add((start: h2.v.dx, end: h1.v.dx));
        }
        if (h2.p.x > h1.p.x && h2.v.dx > h1.v.dx) {
          invalidXRanges.add((start: h1.v.dx, end: h2.v.dx));
        }

        if (h1.p.y > h2.p.y && h1.v.dy > h2.v.dy) {
          invalidYRanges.add((start: h2.v.dy, end: h1.v.dy));
        }
        if (h2.p.y > h1.p.y && h2.v.dy > h1.v.dy) {
          invalidYRanges.add((start: h1.v.dy, end: h2.v.dy));
        }

        if (h1.p.z > h2.p.z && h1.v.dz > h2.v.dz) {
          invalidZRanges.add((start: h2.v.dz, end: h1.v.dz));
        }
        if (h2.p.z > h1.p.z && h2.v.dz > h1.v.dz) {
          invalidZRanges.add((start: h1.v.dz, end: h2.v.dz));
        }
      }
    }

    // Just assume that the velocity is not too big
    // Try to reduce this factor if no solution is found
    final f = 3;
    final range = (start: velocities.start ~/ f, end: velocities.end ~/ f);

    for (final x in range.iter()) {
      if (invalidXRanges.any((e) => e.contains(x))) {
        continue;
      }

      for (final y in range.iter()) {
        if (invalidYRanges.any((e) => e.contains(y))) {
          continue;
        }

        for (final z in range.iter()) {
          if (invalidZRanges.any((e) => e.contains(z))) {
            continue;
          }

          final v = (dx: x, dy: y, dz: z);
          final p = _findRockPosition(v);
          if (p != null) {
            yield (p: p, v: v);
          }
        }
      }
    }
  }

  Point? _findRockPosition(Velocity v) {
    final h1 = hailStones[0];
    final h2 = hailStones[1];
    final d1 = h1.v - v;
    final d2 = h2.v - v;

    final diff = d1.dx * d2.dy - d1.dy * d2.dx;
    if (diff == 0) {
      return null;
    }

    final t = (d2.dy * (h2.p.x - h1.p.x) - d2.dx * (h2.p.y - h1.p.y)) ~/ diff;
    return t < 0 ? null : h1.p + d1 * t;
  }
}

extension on HailStone {
  bool collidesWith(HailStone other) {
    final diff = v - other.v;

    var t = -1;
    if (diff.dx != 0) {
      t = (other.p.x - p.x) ~/ diff.dx;
    } else if (diff.dy != 0) {
      t = (other.p.y - p.y) ~/ diff.dy;
    } else if (diff.dz != 0) {
      t = (other.p.z - p.z) ~/ diff.dz;
    }

    if (t < 0) {
      return false;
    }

    return (p + v * t) == (other.p + other.v * t);
  }
}

extension on Point {
  Point operator +(Velocity velocity) {
    return (x: x + velocity.dx, y: y + velocity.dy, z: z + velocity.dz);
  }
}

extension on Velocity {
  Velocity operator -(Velocity other) {
    return (dx: dx - other.dx, dy: dy - other.dy, dz: dz - other.dz);
  }

  Velocity operator *(int t) {
    return (dx: dx * t, dy: dy * t, dz: dz * t);
  }
}

extension on Range {
  Iterable<int> iter() sync* {
    for (var i = start; i <= end; i++) {
      yield i;
    }
  }

  bool contains(int i) {
    return i >= start && i <= end;
  }
}
