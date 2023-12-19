import 'dart:async';

import 'package:aoc2023/riddle.dart';
import 'package:aoc2023/utils/utils.dart';

class Day07 extends Riddle {
  late final String data;

  Day07() : super(day: 7);

  @override
  Future prepare() async {
    data = await readRiddleInput('07/input.txt');
  }

  @override
  FutureOr solvePart1() {
    return _solve('23456789TJQKA', false);
  }

  @override
  FutureOr solvePart2() {
    return _solve('J23456789TQKA', true);
  }

  int _solve(String cardValues, bool withJoker) {
    return data
        .split('\n')
        .map((e) {
          final (h, bid) = e.splitIntoTwo(' ');
          final hand = h.split('').map(cardValues.indexOf).toList();

          final joker = withJoker ? _determineJoker(hand) : 0;
          return (
            value: _determineValue(hand, joker: joker),
            bid: int.parse(bid),
          );
        })
        .sortdBy((e) => e.value)
        .mapEnumerated((e, i) => e.bid * (i + 1))
        .sum();
  }

  int _determineJoker(List<int> hand) {
    final baseHand = hand.where((c) => c != 0).sorted();
    return baseHand.isEmpty
        // If we have only jokers we take the highest valued card
        ? 12
        // Otherwise find the card with the highest amount and value
        : _determinAmounts(baseHand)[0].card;
  }

  int _determineValue(List<int> hand, {int joker = 0}) {
    final amounts = _determinAmounts(hand.map((c) => c == 0 ? joker : c));

    var value = switch (amounts.length) {
      // Five of a kind
      1 => 6,
      // Four of a kind
      2 when amounts[0].amount == 4 => 5,
      // Full house
      2 => 4,
      // Three of a kind
      3 when amounts[0].amount == 3 => 3,
      // Two pairs
      3 => 2,
      // One pair
      4 => 1,
      // Highest card
      _ => 0,
    };

    // Append the values of the other cards to make sorting easier
    for (var c in hand) {
      value = (value << 4) + c;
    }

    return value;
  }

  List<({int card, int amount})> _determinAmounts(Iterable<int> hand) {
    final amounts = <int, int>{};
    for (var c in hand) {
      amounts[c] = amounts.containsKey(c) ? amounts[c]! + 1 : 1;
    }

    return amounts.entries
        .map((e) => (card: e.key, amount: e.value))
        .sortdBy((e) => -e.amount);
  }
}
