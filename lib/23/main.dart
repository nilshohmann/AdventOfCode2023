import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/iterable_extensions.dart';

typedef Point = ({int x, int y});

class Day23 extends Riddle {
  final Map<Point, String> field = <Point, String>{};
  late final Point start;
  late final Point end;

  final directions = [
    (dx: 1, dy: 0),
    (dx: 0, dy: 1),
    (dx: -1, dy: 0),
    (dx: 0, dy: -1),
  ];

  Day23() : super(day: 23);

  @override
  Future prepare() async {
    final data = await readRiddleInput('23/input.txt');
    final lines = data.split('\n');

    for (final (y, l) in lines.indexed) {
      for (final (x, t) in l.split('').indexed) {
        if (t != '#') {
          field[(x: x, y: y)] = t;
        }
      }
    }

    start = (x: lines[0].indexOf('.'), y: 0);
    end = (x: lines[lines.length - 1].indexOf('.'), y: lines.length - 1);
  }

  @override
  FutureOr solvePart1() {
    // First build a graph with all junctions or end points as nodes
    final graph = _buildGraph(false);
    return _findLongestPath(graph, start);
  }

  @override
  FutureOr solvePart2() {
    // First build a graph with all junctions or end points as nodes
    final graph = _buildGraph(true);
    return _findLongestPath(graph, start);
  }

  // Iteratively go through all nodes and find the longest path to the end
  int _findLongestPath(Map<Point, Map<Point, int>> graph, Point pos,
      [int count = 0, List<Point> visited = const <Point>[]]) {
    if (pos == end) {
      return count;
    }

    visited = [...visited, pos];

    return graph[pos]!
        .entries
        .where((e) => !visited.contains(e.key))
        .map((e) => _findLongestPath(graph, e.key, count + e.value, visited))
        .followedBy([0]).max();
  }

  Map<Point, Map<Point, int>> _buildGraph(bool ignoreSlopes) {
    final graph = <Point, Map<Point, int>>{};
    final states = [
      (pos: start, directions: [(x: start.x, y: start.y + 1)])
    ];

    while (states.isNotEmpty) {
      var (:pos, :directions) = states.removeAt(0);
      if (graph.containsKey(pos)) {
        continue;
      }

      final r = graph[pos] = <Point, int>{};

      for (final next in directions) {
        final (pos: nextPos, :length, :targets) =
            _findNextJunction(next, pos, ignoreSlopes);

        // If we have not found a way to the next position or if the previous
        // way is shorter than the current one (multiple ways from a to b)
        if (r[nextPos] == null || r[nextPos]! < length) {
          r[nextPos] = length;
        }

        if (targets.isNotEmpty) {
          states.add((pos: nextPos, directions: targets));
        }
      }
    }

    return graph;
  }

  ({Point pos, int length, List<Point> targets}) _findNextJunction(
      Point pos, Point prev, bool ignoreSlopes) {
    var length = 0;

    while (true) {
      length++;

      final nextPositions = directions
          .map((dir) {
            final target = (x: pos.x + dir.dx, y: pos.y + dir.dy);
            return target != prev && _canMoveTo(target, dir, ignoreSlopes)
                ? target
                : null;
          })
          .nonNulls
          .toList();

      // - If there is no possible next step we have either reached a dead end
      //   or the end position
      // - If there is only one way to continue follow the path further
      // - If there is more than one direction to go we found a junction
      if (nextPositions.length != 1) {
        nextPositions.add(prev);
        return (pos: pos, length: length, targets: nextPositions);
      }

      prev = pos;
      pos = nextPositions[0];
    }
  }

  bool _canMoveTo(Point target, ({int dx, int dy}) dir, bool ignoreSlopes) {
    if (ignoreSlopes) {
      return field[target] != null;
    }

    return switch (field[target]) {
      '.' => true,
      '>' => dir.dx == 1,
      'v' => dir.dy == 1,
      '<' => dir.dx == -1,
      '^' => dir.dy == -1,
      _ => false,
    };
  }
}
