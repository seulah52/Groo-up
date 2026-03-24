extension StringExtensions on String {
  bool   get isNullOrEmpty => trim().isEmpty;
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
