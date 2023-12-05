extension StringExtensions on String {
  (String, String) splitIntoTwo(String separator) {
    final index = indexOf(separator);
    if (index < 0) {
      throw 'Separator "$separator" not found in "$this"';
    }

    return (substring(0, index), substring(index + separator.length));
  }

  Iterable<int> toInts(String separator) {
    return split(separator).map(int.parse);
  }
}
