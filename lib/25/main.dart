import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:collection/collection.dart';

class Day25 extends Riddle {
  late final String data;
  final Map<String, Set<String>> components = <String, Set<String>>{};

  Day25() : super(day: 25);

  @override
  Future prepare() async {
    final data = await readRiddleInput('25/input.txt');
    for (var element in data.split('\n')) {
      final [n, o] = element.split(': ');
      components[n] = o.split(' ').toSet();
    }

    final keys = [...components.keys];
    for (final key in keys) {
      for (final c in components[key]!) {
        if (!components.containsKey(c)) {
          components[c] = {key};
        } else {
          components[c]!.add(key);
        }
      }
    }
  }

  @override
  FutureOr solvePart1() {
    final result = _findConnectionsToCut();
    return result.$2.$1 * result.$2.$2;
  }

  @override
  FutureOr solvePart2() {
    // Just push the red button
    return 0;
  }

  (List<(String, String)>, (int, int)) _findConnectionsToCut() {
    // Find 10 possible connections to cut
    final possibleConnections = _findPossibleConnectionsToCut();

    // Go through all combinations and find the correct one
    for (var i = 0; i < possibleConnections.length; i++) {
      for (var j = i + 1; j < possibleConnections.length; j++) {
        for (var k = j + 1; k < possibleConnections.length; k++) {
          final connectionsToCut = [
            possibleConnections[i],
            possibleConnections[j],
            possibleConnections[k],
          ];

          final sizes = connectionsToCut[0].map(
            (c) => _determineNetworkSize(c, connectionsToCut),
          );
          if (sizes.$1 + sizes.$2 == components.length) {
            return (connectionsToCut, (sizes));
          }
        }
      }
    }

    throw 'No connections found';
  }

  List<(String, String)> _findPossibleConnectionsToCut() {
    // We count the traffic going through the network of components and try to
    // find the three most used connections
    final traffic = <(String, String), int>{};

    // To speed things up we only look at a random fraction of the connections
    final keys = components.keys.toList()..shuffle();
    for (var component in keys.take(50)) {
      final visited = <String>[];
      final states = PriorityQueue<({String p, String c, int l})>(
        (a, b) => a.l < b.l ? -1 : 1,
      );
      states.add((p: '', c: component, l: 0));

      while (states.isNotEmpty) {
        final (:p, :c, :l) = states.removeFirst();
        if (visited.contains(c)) {
          continue;
        }

        visited.add(c);
        final links = components[c]!;
        for (final link in links) {
          if (p.isNotEmpty) {
            final route = (p, c).sorted();
            traffic[route] = (traffic[route] ?? 0) + 1;
          }

          states.add((p: c, c: link, l: l + 1));
        }
      }
    }

    return traffic.entries
        .sortedBy<num>((e) => -e.value)
        .take(10)
        .map((e) => e.key)
        .toList();
  }

  int _determineNetworkSize(
      String component, List<(String, String)> connectionsToCut) {
    final visited = <String>[];
    final states = [component];

    while (states.isNotEmpty) {
      final c = states.removeLast();
      if (visited.contains(c)) {
        continue;
      }

      visited.add(c);
      states.addAll(components[c]!
          .where((e) => !connectionsToCut.contains((c, e).sorted())));
    }

    return visited.length;
  }
}

extension on (String, String) {
  (String, String) sorted() {
    if ($1.compareTo($2) > 0) {
      return ($2, $1);
    }
    return this;
  }

  (T, T) map<T>(T Function(String) mapper) {
    return (mapper($1), mapper($2));
  }
}
