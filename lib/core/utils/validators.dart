String? validateDouble(String? value) {
  if (value == null) {
    return null;
  }
  if (value.isEmpty) {
    return null;
  }
  if (double.tryParse(value) == null) {
    return "Lütfen sayı giriniz";
  }
  return null;
}

String? validateStringNecessary(String? value) {
  if (value == null) {
    return null;
  }
  if (value.isEmpty) {
    return "Lütfen boş bırakmayınız";
  }
  return null;
}

String? validateDoubleNecessary(String? value) {
  if (value == null) {
    return "Lütfen sayı giriniz";
  }
  if (value.isEmpty) {
    return "Lütfen sayı giriniz";
  }
  if (double.tryParse(value) == null) {
    return "Lütfen sayı giriniz";
  }
  return null;
}

String? validateIntNecessary(String? value) {
  if (value == null) {
    return "Lütfen sayı girin";
  }
  if (value.isEmpty) {
    return "Lütfen sayı girin";
  }
  if (int.tryParse(value) == null) {
    return "Lütfen geçerli bir sayı girin";
  }
  return null;
}

String? validateInt(String? value) {
  if (value == null) {
    return null;
  }
  if (value.isEmpty) {
    return null;
  }
  if (int.tryParse(value) == null) {
    return "Lütfen geçerli bir sayı girin";
  }
  return null;
}

// create a number validator with form of xxx-xxx-xx-xx
String? validatePhoneNumber(String? value) {
  if (value == null) {
    return null;
  }
  if (value.isEmpty) {
    return null;
  }
  List<String> splitted = value.split(" ");
  if (splitted.length == 4 || splitted.length == 3) {
    bool done = true;
    for (var element in splitted) {
      if (int.tryParse(element) == null) {
        done = false;
      }
    }

    if (splitted.length == 4) {
      if (splitted[0].length != 3 ||
          splitted[1].length != 3 ||
          splitted[2].length != 2 ||
          splitted[3].length != 2) {
        done = false;
      }
    } else if (splitted.length == 3) {
      if (splitted[0].length != 3 ||
          splitted[1].length != 3 ||
          splitted[2].length != 4) {
        done = false;
      }
    }

    if (done) {
      return null;
    }
    return "Lütfen geçerli bir telefon numarası giriniz";
  } else {
    return "Lütfen geçerli bir telefon numarası giriniz";
  }
}
