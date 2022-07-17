// ignore_for_file: non_constant_identifier_names

extension DateTimeExtentions on DateTime {
  String get D => "$day/$month/$year";

  String get H => "$hour:$minute";

  String get full => "$D $H";

  DateTime onlyDate() {
    return DateTime(year, month, day);
  }
}
