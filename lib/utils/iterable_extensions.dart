extension SumExtension<E extends num> on Iterable<E> {
  E sum() {
    return reduce((v, e) => (v + e) as E);
  }

  E max() {
    final i = iterator;
    i.moveNext();

    var m = i.current;
    while (i.moveNext()) {
      if (i.current > m) {
        m = i.current;
      }
    }

    return m;
  }
}

extension IterableExtensions<E> on Iterable<E> {
  Map<K, V> toMap<K, V>(K Function(E) keyFunc, V Function(E) valueFunc) {
    final result = <K, V>{};
    for (final element in this) {
      result[keyFunc(element)] = valueFunc(element);
    }
    return result;
  }

  Iterable<T> mapEnumerated<T>(T Function(E e, int index) toElement) sync* {
    var index = 0;
    for (final element in this) {
      yield toElement(element, index);
      index++;
    }
  }

  Iterable<(int, E)> enumerate() sync* {
    var index = 0;
    for (var element in this) {
      yield (index, element);
      index++;
    }
  }

  List<E> sortdBy(dynamic Function(E element) selector) {
    return sorted((a, b) => selector(a).compareTo(selector(b)));
  }

  List<E> sorted([int Function(E a, E b)? compare]) {
    return [...this]..sort(compare);
  }

  bool eq(Iterable<E> other) {
    final i = other.iterator;
    for (final e in this) {
      if (!i.moveNext()) {
        return false;
      }

      if (e != i.current) {
        return false;
      }
    }

    return true;
  }

  bool all(bool Function(E) check) {
    if (isEmpty) {
      return false;
    }

    for (final e in this) {
      if (!check(e)) {
        return false;
      }
    }

    return true;
  }
}
