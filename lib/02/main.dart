import 'dart:async';
import 'dart:math';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

typedef Game = ({int id, List<({int red, int green, int blue})> rounds});

class Day02 extends Riddle {
  late final List<Game> games;

  Day02() : super(day: 2);

  @override
  Future prepare() async {
    final data = await readRiddleInput('02/input.txt');

    games = data.split('\n').map(_parseGame).toList();
  }

  @override
  FutureOr solvePart1() {
    var result = 0;
    for (final game in games) {
      if (!game.rounds.any((r) => r.red > 12 || r.green > 13 || r.blue > 14)) {
        result += game.id;
      }
    }

    return result;
  }

  @override
  FutureOr solvePart2() {
    var result = 0;
    for (final game in games) {
      var red = 0;
      var green = 0;
      var blue = 0;

      for (final round in game.rounds) {
        red = max(red, round.red);
        green = max(green, round.green);
        blue = max(blue, round.blue);
      }

      result += red * green * blue;
    }

    return result;
  }

  Game _parseGame(String line) {
    final index = line.indexOf(': ');
    if (!line.startsWith('Game ') || index <= 0) {
      throw 'Invalid line: $line';
    }

    final id = int.parse(line.substring(5, index));
    final rounds = line.substring(index + 2).split('; ').map((round) {
      var red = 0;
      var green = 0;
      var blue = 0;

      for (var c in round.split(', ')) {
        final (amount, color) = c.splitIntoTwo(' ');
        switch (color) {
          case 'red':
            red = int.parse(amount);
          case 'green':
            green = int.parse(amount);
          case 'blue':
            blue = int.parse(amount);
          default:
            throw 'Unknown color: $color';
        }
      }

      return (red: red, green: green, blue: blue);
    }).toList();

    return (id: id, rounds: rounds);
  }
}
