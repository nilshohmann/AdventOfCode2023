import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

typedef Point = ({int x, int y});

class Day10 extends Riddle {
  late final List<List<String>> map;
  late final Point start;

  late final List<List<bool>> visited;

  final validMoves = <(int x, int y), List<String>>{
    (1, 0): ['┛', '━', '┓'], // target right
    (-1, 0): ['┗', '━', '┏'], // target left
    (0, 1): ['┗', '┃', '┛'], // target down
    (0, -1): ['┏', '┃', '┓'], // target up
  };

  Day10() : super(day: 10);

  @override
  Future prepare() async {
    final data = await readRiddleInput('10/input.txt');

    // Replacements are not necessary but makes it possible to print the map
    map = _addEmptyBorder(data
            .replaceAll('-', '━')
            .replaceAll('|', '┃')
            .replaceAll('F', '┏')
            .replaceAll('7', '┓')
            .replaceAll('L', '┗')
            .replaceAll('J', '┛')
            .split('\n')
            .map((l) => l.split(''))
            .toList())
        .toList();

    visited = List.generate(
        map.length, (i) => List.generate(map[i].length, (_) => false));

    for (var y = 0; y < map.length; y++) {
      final x = map[y].indexOf('S');
      if (x >= 0) {
        start = (x: x, y: y);
      }
    }

    _replaceStartPipe();
  }

  @override
  FutureOr solvePart1() {
    var i = 0;
    var upcoming = <Point>{start};
    while (upcoming.isNotEmpty) {
      final next = upcoming;
      upcoming = <Point>{};
      i++;

      for (final p in next) {
        visited[p.y][p.x] = true;

        for (final d in validMoves.keys) {
          if (_canMove(p, d)) {
            upcoming.add(_add(p, d));
          }
        }
      }
    }

    return i - 1;
  }

  @override
  FutureOr solvePart2() {
    for (var y = 0; y < map.length; y++) {
      for (var x = 0; x < map[y].length; x++) {
        if (!visited[y][x]) {
          map[y][x] = '.';
        }
      }
    }

    // Expand the map so each pipe takes 3x3 tiles and we have spacings between
    final expandedMap = _expandMap();

    // Start from the top left corner and remove all empty fields
    final next = <Point>[(x: 0, y: 0)];
    while (next.isNotEmpty) {
      final n = next.removeAt(0);
      if (expandedMap[n.y][n.x] != '.') {
        continue;
      }
      expandedMap[n.y][n.x] = ' ';

      for (final d in validMoves.keys) {
        final t = _add(n, d);
        if (t.y >= 0 &&
            t.y < expandedMap.length &&
            t.x >= 0 &&
            t.x < expandedMap[0].length &&
            expandedMap[t.y][t.x] == '.') {
          next.add(t);
        }
      }
    }

    // Count all remaining 3x3 tiles that have a '.' in the middle
    var result = 0;
    for (var y = 0; y < map.length; y++) {
      for (var x = 0; x < map[y].length; x++) {
        if (expandedMap[y * 3 + 1][x * 3 + 1] == '.') {
          result++;
        }
      }
    }

    return result;
  }

  Point _add(Point p, (int, int) d) {
    return (x: p.x + d.$1, y: p.y + d.$2);
  }

  bool _canMove(Point p, (int, int) d) {
    final t = _add(p, d);

    // With the border around we don't need any out of bounds checks
    if (!visited[t.y][t.x] &&
        validMoves[d]!.contains(map[t.y][t.x]) &&
        validMoves[(-d.$1, -d.$2)]!.contains(map[p.y][p.x])) {
      return true;
    }

    return false;
  }

  Iterable<List<String>> _addEmptyBorder(List<List<String>> map) sync* {
    final emptyLine = List.generate(map[0].length + 2, (_) => '.');
    yield emptyLine;

    for (final line in map) {
      yield line
        ..insert(0, '.')
        ..add('.');
    }

    yield emptyLine;
  }

  void _replaceStartPipe() {
    final s = validMoves.keys.mapEnumerated((d, i) {
      final t = _add(start, d);
      return validMoves[d]!.contains(map[t.y][t.x]) ? 1 << i : 0;
    }).sum();

    map[start.y][start.x] = switch (s) {
      3 => '━', // right + left
      5 => '┏', // right + down
      6 => '┓', // left + down
      9 => '┗', // right + up
      10 => '┛', // left + up
      12 => '┃', // down + up
      _ => throw 'Invalid start point: $start',
    };
  }

  List<List<String>> _expandMap() {
    final newMap = List.generate(
      map.length * 3,
      (i) => List.generate(map[0].length * 3, (_) => '.'),
    );

    final fillings = <String, List<(int, int)>>{
      '.': [],
      '━': [(0, 1), (1, 1), (2, 1)],
      '┃': [(1, 0), (1, 1), (1, 2)],
      '┏': [(1, 1), (2, 1), (1, 2)],
      '┓': [(0, 1), (1, 1), (1, 2)],
      '┗': [(1, 0), (1, 1), (2, 1)],
      '┛': [(1, 0), (1, 1), (0, 1)],
    };

    for (var y = 0; y < map.length; y++) {
      for (var x = 0; x < map[y].length; x++) {
        for (final t in fillings[map[y][x]]!) {
          newMap[y * 3 + t.$2][x * 3 + t.$1] = '█';
        }
      }
    }

    return newMap;
  }
}
