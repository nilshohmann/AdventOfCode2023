#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os

def path_for_day(day: int) -> str:
  return os.path.join('lib', f'0{day}'[-2:])

if __name__ == '__main__':
  day = 1
  while (True):
    if not os.path.isdir(path_for_day(day)):
      break
    day += 1

  print(f'Creating template for day {day}...')
  day_path = path_for_day(day)
  os.mkdir(day_path)
  open(os.path.join(day_path, 'input.txt'), 'a').close()
  open(os.path.join(day_path, 'readme.md'), 'a').close()

  with open(os.path.join(day_path, 'main.dart'), 'a') as file:
    padded_day = f'0{day}'[-2:]
    file.write(
f'''import 'dart:async';

import 'package:aoc2023/riddle.dart';

class Day{padded_day} extends Riddle {{
  late final String data;

  Day{padded_day}() : super(day: {day});

  @override
  Future prepare() async {{
    data = await readTaskInput('{padded_day}/input.txt');
  }}

  @override
  FutureOr solvePart1() {{
    return 0;
  }}

  @override
  FutureOr solvePart2() {{
    return 0;
  }}
}}
''')
