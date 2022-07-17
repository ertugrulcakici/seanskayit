extension DateTimeHelper on DateTime {
  String toH() {
    String nhour = hour.toString();
    if (nhour.length == 1) {
      nhour = "0$hour";
    }
    String nminute = minute.toString();
    if (nminute.length == 1) {
      nminute = "0$minute";
    }
    return "$hour:$minute";
  }

  String toD() {
    String nDay = day.toString();
    String nMonth = month.toString();
    return "$nDay/$nMonth/$year";
  }
}
