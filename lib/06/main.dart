import 'dart:async';
import 'dart:math';

import 'package:aoc2023/riddle.dart';

class Day06 extends Riddle {
  late final String data;

  Day06() : super(day: 6);

  @override
  Future prepare() async {
    data = await readRiddleInput('06/input.txt');
  }

  @override
  FutureOr solvePart1() {
    final lines = data
        .split('\n')
        .map((l) => l
            .split(':')[1]
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map(int.parse)
            .toList())
        .toList();

    var result = 1;
    for (var i = 0; i < lines[0].length; i++) {
      result *= _countWaysToBeatRecord(lines[0][i], lines[1][i]);
    }
    return result;
  }

  @override
  FutureOr solvePart2() {
    final lines = data
        .split('\n')
        .map((l) => int.parse(l.split(':')[1].replaceAll(' ', '')))
        .toList();

    return _countWaysToBeatRecord(lines[0], lines[1]);
  }

  int _countWaysToBeatRecord(int duration, int record) {
    // Total distance travelled:
    // distance = chargeTime * (duration - chargeTime)
    //
    // We want to find the possible changeTimes for the record:
    // record = duration * chargeTime - chargeTime ^ 2
    // 0 = chargeTime ^ 2 - duration * chargeTime + record
    //
    // The pq formula helps us to find two solutions for the record:
    // chargeTime = duration / 2 +- sqrt((-duration / 2) ^ 2 - record)
    final minRecordChargeTime =
        duration / 2 - sqrt((duration * duration / 4) - record);
    final maxRecordChargeTime =
        duration / 2 + sqrt((duration * duration / 4) - record);

    return maxRecordChargeTime.ceil() - minRecordChargeTime.floor() - 1;
  }
}
