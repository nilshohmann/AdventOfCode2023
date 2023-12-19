import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/iterable_extensions.dart';
import 'package:aoc2023/utils/string_extensions.dart';

typedef RuleEntry = ({String category, int comp, String next});

typedef Rule = ({
  String name,
  List<RuleEntry> entries,
  String fallback,
});

class Day19 extends Riddle {
  late final List<Rule> rules;
  late final Map<String, Rule> rulesMap;
  late final List<Map<String, int>> parts;

  Day19() : super(day: 19);

  @override
  Future prepare() async {
    final data = await readRiddleInput('19/input.txt');
    final (r, p) = data.splitIntoTwo('\n\n');
    rules = r.split('\n').map((l) {
      final (name, d) = l.substring(0, l.length - 1).splitIntoTwo('{');

      final t = d.split(',');
      final entries = t.take(t.length - 1).map((r) {
        final (d, n) = r.splitIntoTwo(':');
        return (
          category: d[0],
          comp: (d[1] == '>' ? 1 : -1) * int.parse(d.substring(2)),
          next: n,
        );
      }).toList();
      final fallback = t.last;

      // Eliminate additional rule with no value
      if (!entries.any((e) => e.next != fallback)) {
        entries.clear();
      }

      return (
        name: name,
        entries: entries,
        fallback: fallback,
      );
    }).toList();
    rulesMap = rules.toMap((r) => r.name, (r) => r);

    parts = p
        .split('\n')
        .map((l) => l
            .substring(1, l.length - 1)
            .split(',')
            .map((e) => e.splitIntoTwo('='))
            .toMap((e) => e.$1, (e) => int.parse(e.$2)))
        .toList();
  }

  @override
  FutureOr solvePart1() {
    return parts.map((part) {
      var currentRule = 'in';
      while (true) {
        currentRule = _nextRule(part, rulesMap[currentRule]!);
        if (currentRule == 'A') {
          return part.values.sum();
        }

        if (currentRule == 'R') {
          return 0;
        }
      }
    }).sum();
  }

  @override
  FutureOr solvePart2() {
    var result = 0;

    final states = [
      (
        rule: 'in',
        ranges: ['x', 'm', 'a', 's'].toMap((c) => c, (_) => (l: 1, u: 4000))
      )
    ];

    while (states.isNotEmpty) {
      var state = states.removeLast();
      if (state.rule == 'R') {
        continue;
      }

      if (state.rule == 'A') {
        var p = 1;
        for (final r in state.ranges.values) {
          p *= r.u - r.l + 1;
        }
        result += p;
        continue;
      }

      final ranges = state.ranges;
      final rule = rulesMap[state.rule]!;

      for (final entry in rule.entries) {
        final ranges2 = ['x', 'm', 'a', 's'].toMap(
          (c) => c,
          (c) => (l: ranges[c]!.l, u: ranges[c]!.u),
        );
        final b = ranges[entry.category]!;

        if (b.l < entry.comp.abs() && entry.comp.abs() < b.u) {
          ranges2[entry.category] = entry.comp < 0
              ? (l: b.l, u: -entry.comp - 1)
              : (l: entry.comp + 1, u: b.u);
          ranges[entry.category] = entry.comp < 0
              ? (l: -entry.comp, u: b.u)
              : (l: b.l, u: entry.comp);

          states.add((rule: entry.next, ranges: ranges2));
        }
      }

      states.add((rule: rule.fallback, ranges: ranges));
    }

    return result;
  }

  String _nextRule(Map<String, int> part, Rule rule) {
    for (final e in rule.entries) {
      if (e.comp > 0
          ? part[e.category]! > e.comp
          : part[e.category]! < -e.comp) {
        return e.next;
      }
    }

    return rule.fallback;
  }
}
