extension SumExtension<E extends num> on Iterable<E> {
  E sum() {
    return reduce((v, e) => (v + e) as E);
  }
}

extension IterableExtensions<E> on Iterable<E> {
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
}
