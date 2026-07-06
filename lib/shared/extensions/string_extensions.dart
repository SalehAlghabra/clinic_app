extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get toTitleCase {
    if (isEmpty) return this;
    return split(' ').map((str) => str.capitalize).join(' ');
  }
}
