import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

typedef Module = ({String type, String name, List<String> targets});

class Day20 extends Riddle {
  late final Map<String, Module> modules;

  Day20() : super(day: 20);

  @override
  Future prepare() async {
    final data = await readRiddleInput('20/input.txt');
    modules = data.split('\n').map((l) {
      final (left, right) = l.splitIntoTwo(' -> ');
      final type = ['&', '%'].contains(left[0]) ? left[0] : '';
      final name = type.isEmpty ? left : left.substring(1);
      return (name: name, type: type, targets: right.split(', '));
    }).toMap((m) => m.name, (m) => m);
  }

  @override
  FutureOr solvePart1() {
    final result = _findHighsAndLows(iterations: 1000);
    return result.lows * result.highs;
  }

  @override
  FutureOr solvePart2() {
    return _findMinButtonCount();
  }

  ({int lows, int highs}) _findHighsAndLows({required int iterations}) {
    var lows = 0;
    var highs = 0;

    var moduleStates = _buildInitialModuleStates();

    for (final _ in Iterable.generate(iterations)) {
      // Start by sending the 'low' from the button to the broadcaster
      final states = [(module: 'broadcaster', from: '', signal: false)];

      while (states.isNotEmpty) {
        final state = states.removeAt(0);
        if (state.signal) {
          highs++;
        } else {
          lows++;
        }

        if (state.module == 'rx') {
          continue;
        }

        final module = modules[state.module]!;
        switch (module.type) {
          // Broadcaster
          case '':
            for (final t in module.targets) {
              states.add((module: t, from: state.module, signal: state.signal));
            }
            break;

          // Flip flop
          case '%':
            // Ignore high signals
            if (state.signal == true) {
              break;
            }

            final newSignal = !moduleStates.flipFlops[state.module]!;
            moduleStates.flipFlops[state.module] = newSignal;
            for (final t in module.targets) {
              states.add((module: t, from: state.module, signal: newSignal));
            }

            break;

          // Conjunction
          case '&':
            final c = moduleStates.conjunctions[state.module]!;
            c[state.from] = state.signal;

            final newSignal = c.values.any((e) => !e) ? true : false;
            for (final t in module.targets) {
              states.add((module: t, from: state.module, signal: newSignal));
            }

            break;
        }
      }
    }

    return (lows: lows, highs: highs);
  }

  int _findMinButtonCount() {
    var moduleStates = _buildInitialModuleStates();

    // rx is only filled by qn which is a conjunction of these modules:
    final relevantModules = moduleStates.conjunctions['qn']!.keys;
    // So we want to find how many button taps in takes to get a high for each
    final receivedHighs = relevantModules.toMap((m) => m, (_) => <int>[]);

    var count = 0;

    while (true) {
      count++;

      // Start by sending the 'low' from the button to the broadcaster
      final states = [(module: 'broadcaster', from: '', signal: false)];

      while (states.isNotEmpty) {
        final state = states.removeAt(0);

        if (state.module == 'rx') {
          // Will probably never happen in reasonable time
          if (state.signal == false) {
            return count;
          }

          continue;
        }

        // Find the high signals sent to 'qn'
        if (state.signal && state.module == 'qn') {
          receivedHighs[state.from]!.add(count);

          // We can also take more the 2 measurements for each input and check
          // for repeating patterns, but it's actually always the same diff
          if (receivedHighs.values.all((l) => l.length >= 2)) {
            /*for (final l in receivedHighs.values) {
              print(Iterable.generate(l.length - 1, (i) => l[i + 1] - l[i]));
            }*/

            // Now again we only need to find the least common multiple here
            final result = receivedHighs.values
                .map((l) => l[1] - l[0])
                .reduce(_leastCommonMultiple);

            return result;
          }
        }

        final module = modules[state.module]!;
        switch (module.type) {
          // Broadcaster
          case '':
            for (final t in module.targets) {
              states.add((module: t, from: state.module, signal: state.signal));
            }
            break;

          // Flip flop
          case '%':
            // Ignore high signals
            if (state.signal == true) {
              break;
            }

            final newSignal = !moduleStates.flipFlops[state.module]!;
            moduleStates.flipFlops[state.module] = newSignal;
            for (final t in module.targets) {
              states.add((module: t, from: state.module, signal: newSignal));
            }

            break;

          // Conjunction
          case '&':
            final c = moduleStates.conjunctions[state.module]!;
            c[state.from] = state.signal;

            final newSignal = c.values.any((e) => !e) ? true : false;
            for (final t in module.targets) {
              states.add((module: t, from: state.module, signal: newSignal));
            }

            break;
        }
      }
    }
  }

  ({Map<String, bool> flipFlops, Map<String, Map<String, bool>> conjunctions})
      _buildInitialModuleStates() {
    final flipFlops = <String>[];
    final conjunctions = <String>[];

    // maps inputs for each module
    final map = <String, List<String>>{};

    for (final module in modules.values) {
      for (final t in module.targets) {
        if (map.containsKey(t)) {
          map[t]!.add(module.name);
        } else {
          map[t] = [module.name];
        }
      }

      if (module.type == '%') {
        flipFlops.add(module.name);
      }
      if (module.type == '&') {
        conjunctions.add(module.name);
      }
    }

    return (
      flipFlops: flipFlops.toMap((x) => x, (_) => false),
      conjunctions: conjunctions.toMap(
        (x) => x,
        (x) => map[x]!.toMap((i) => i, (_) => false),
      ),
    );
  }

  int _leastCommonMultiple(int a, int b) {
    if ((a == 0) || (b == 0)) {
      return 0;
    }

    return ((a ~/ a.gcd(b)) * b).abs();
  }
}
