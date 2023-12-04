#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os, sys

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
    file.write(
f'''import \'package:aoc2023/utils.dart\';

Future main() async {{
  final data = await readTaskInput(\'{f'0{day}'[-2:]}/input.txt\');

  printResultsHeader();
  await runTask<int>('1', () async => _calculatePart1(data));
  await runTask<int>('2', () async => _calculatePart2(data));
}}

int _calculatePart1(String data) {{
  return 0;
}}

int _calculatePart2(String data) {{
    return 0;
}}
''')
