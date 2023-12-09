extension StringExtensions on String {
  (String, String) splitIntoTwo(String separator) {
    final index = indexOf(separator);
    if (index < 0) {
      throw 'Separator "$separator" not found in "$this"';
    }

    return (substring(0, index), substring(index + separator.length));
  }

  Iterable<int> splitToInts(String separator) {
    return split(separator).map(int.parse);
  }
}

extension SumExtension on Iterable<int> {
  int sum() {
    return reduce((v, e) => v + e);
  }
}

extension ListExtension<E> on Iterable<E> {
  Iterable<T> mapEnumerated<T>(T Function(E e, int index) toElement) sync* {
    var index = 0;
    for (var element in this) {
      yield toElement(element, index);
      index++;
    }
  }

  List<E> sortdBy(dynamic Function(E element) selector) {
    return sorted((a, b) => selector(a).compareTo(selector(b)));
  }

  List<E> sorted([int Function(E a, E b)? compare]) {
    return [...this]..sort(compare);
  }
}
