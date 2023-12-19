import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';
import 'package:collection/collection.dart';

typedef Point = ({int x, int y});
typedef Direction = ({int dx, int dy});

typedef State = ({Point pos, Direction dir, int loss, int steps});

class Day17 extends Riddle {
  final Map<Point, int> field = <Point, int>{};
  late final Point target;

  final right = (dx: 1, dy: 0);
  final down = (dx: 0, dy: 1);
  final left = (dx: -1, dy: 0);
  final up = (dx: 0, dy: -1);

  Day17() : super(day: 17);

  @override
  Future prepare() async {
    final data = await readRiddleInput('17/input.txt');

    for (final (y, line) in data.split('\n').enumerate()) {
      for (final (x, c) in line.split('').enumerate()) {
        field[(x: x, y: y)] = int.parse(c);
      }
    }

    target = field.keys.last;
  }

  @override
  FutureOr solvePart1() {
    return _calculateLossForBestPath(1, 3);
  }

  @override
  FutureOr solvePart2() {
    return _calculateLossForBestPath(4, 10);
  }

  int _calculateLossForBestPath(int minSteps, int maxSteps) {
    // Using a min heap for a kind of dijkstra algorithm where the heat loss
    // is the path cost
    final states = PriorityQueue<State>(
      (a, b) => a.loss < b.loss ? -1 : 1,
    );

    states.add((pos: (x: 0, y: 0), dir: right, loss: 0, steps: 0));
    states.add((pos: (x: 0, y: 0), dir: down, loss: 0, steps: 0));

    final visited = <(Point, Direction, int)>{};

    while (states.isNotEmpty) {
      final state = states.removeFirst();
      if (!visited.add((state.pos, state.dir, state.steps))) {
        // We've already been here
        continue;
      }

      if (state.pos == target) {
        if (state.steps >= minSteps) {
          return state.loss;
        }

        continue;
      }

      if (state.steps < maxSteps) {
        _tryAddNext(states, state, state.dir);
      }

      if (state.steps < minSteps) {
        continue;
      }

      for (final dir in state.dir.dx == 0 ? [right, left] : [down, up]) {
        _tryAddNext(states, state, dir);
      }
    }

    throw 'Something went wrong';
  }

  void _tryAddNext(PriorityQueue<State> states, State state, Direction dir) {
    final newPos = (x: state.pos.x + dir.dx, y: state.pos.y + dir.dy);

    if (field.containsKey(newPos)) {
      states.add((
        pos: newPos,
        dir: dir,
        loss: state.loss + field[newPos]!,
        steps: state.dir == dir ? state.steps + 1 : 1,
      ));
    }
  }
}
