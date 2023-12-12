import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

class Day12 extends Riddle {
  late final List<({String springs, List<int> groups})> onsen;

  Day12() : super(day: 12);

  @override
  Future prepare() async {
    final data = await readRiddleInput('12/input.txt');

    onsen = data.split('\n').map((l) {
      final (springs, groups) = l.splitIntoTwo(' ');
      return (springs: springs, groups: groups.splitToInts(','));
    }).toList();
  }

  @override
  FutureOr solvePart1() {
    return onsen
        .map((line) => _findArrangements(line.springs, line.groups))
        .sum();
  }

  @override
  FutureOr solvePart2() async {
    return onsen
        .map((line) => _findArrangements(
              List.generate(5, (_) => line.springs).join('?'),
              Iterable.generate(5, (_) => line.groups).reduce((v, e) => v + e),
            ))
        .sum();
  }

  int _findArrangements(String springs, List<int> groups) {
    // Make things easier because we don't have an open group at the end
    springs = '$springs.';

    // Cache states with found subsolutions to speed things up
    final cache = <(int, int, int), int>{};

    // state: (position in springs, position in groups, current group length)
    int solve((int, int, int) state) {
      if (cache.containsKey(state)) {
        return cache[state]!;
      }

      final (i, g, groupLength) = state;

      // We're at the end
      if (i == springs.length) {
        // Check if we found all groups
        return g == groups.length ? 1 : 0;
      }

      // Count all the possible arrangements in substates
      var result = 0;

      if (springs[i] == '#' || springs[i] == '?') {
        // Check if it makes sense to continue the current group
        if (g < groups.length && groups[g] > groupLength) {
          result += solve((i + 1, g, groupLength + 1));
        }
      }

      if (springs[i] == '.' || springs[i] == '?') {
        if (groupLength == 0) {
          result += solve((i + 1, g, 0));
        } else if (g < groups.length && groups[g] == groupLength) {
          result += solve((i + 1, g + 1, 0));
        }
      }

      cache[state] = result;
      return result;
    }

    return solve((0, 0, 0));
  }
}
