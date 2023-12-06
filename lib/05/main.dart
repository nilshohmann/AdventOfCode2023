import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils.dart';

typedef Maps = Map<String, List<(int start, int end, int diff)>>;

class Day05 extends Riddle {
  late final String data;

  Day05() : super(day: 5);

  @override
  Future prepare() async {
    data = await readRiddleInput('05/input.txt');
  }

  @override
  FutureOr solvePart1() {
    final dataParts = data.split('\n\n');

    final seeds = dataParts[0].split(': ')[1].toInts(' ').toList();

    final maps = _buildMaps(dataParts.skip(1));
    return _findMinimumLocation(maps, seeds);
  }

  @override
  FutureOr solvePart2() async {
    final dataParts = data.split('\n\n');

    final seeds = dataParts[0].split(': ')[1].toInts(' ').toList();
    final maps = _buildMaps(dataParts.skip(1));

    final tasks = List.generate(
      seeds.length >> 1,
      (i) => Isolate.run(() {
        final start = seeds[i * 2];
        final range = seeds[i * 2 + 1];

        return _findMinimumLocation(
          maps,
          Iterable.generate(range, (i) => start + i),
        );
      }),
    );

    var minimumLocation = 10e30.toInt();
    for (final task in tasks) {
      final location = await task;
      if (location < minimumLocation) {
        minimumLocation = location;
      }
    }

    return minimumLocation;
  }

  Maps _buildMaps(Iterable<String> dataParts) {
    final Maps maps = {};

    for (final part in dataParts) {
      final mapData = part.split('\n');
      if (!mapData[0].endsWith(' map:')) {
        throw 'Invalid data: $part';
      }

      final name = mapData[0].substring(0, mapData[0].length - 5);
      final entries = <(int start, int end, int diff)>[];

      for (final map in mapData.skip(1).map((e) => e.toInts(' ').toList())) {
        final start = map[1];
        final end = start + map[2] - 1;
        final diff = map[0] - start;

        entries.add((start, end, diff));
      }

      maps[name] = entries;
    }

    return maps;
  }

  int _findMinimumLocation(Maps maps, Iterable<int> seeds) {
    return seeds.map((seed) {
      final soil = _convert(seed, maps['seed-to-soil']!);
      final fertilizer = _convert(soil, maps['soil-to-fertilizer']!);
      final water = _convert(fertilizer, maps['fertilizer-to-water']!);
      final light = _convert(water, maps['water-to-light']!);
      final temperature = _convert(light, maps['light-to-temperature']!);
      final humidity = _convert(temperature, maps['temperature-to-humidity']!);
      final location = _convert(humidity, maps['humidity-to-location']!);

      return location;
    }).reduce(min);
  }

  int _convert(int value, List<(int start, int end, int diff)> map) {
    for (final (start, end, diff) in map) {
      if (value >= start && value <= end) {
        return value + diff;
      }
    }

    return value;
  }
}
