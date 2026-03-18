class FormValidation {
  static String? passwordValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your password';
    } else if (text.length < 5) {
      return 'Password must be at least 5 characters long';
    }
    return null;
  }

  static String? otpValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your OTP';
    } else if (text.length != 4 || int.tryParse(text) == null) {
      return 'OTP must be a 4-digit number';
    }
    return null;
  }
static String? nameValidation(String? text) {
  if (text == null || text.isEmpty) {
    return 'Please enter your name';
  } else if (text.length <= 2) {
    return 'Name must contain at least 3 characters';
  } else if (text.length > 16) {
    return 'Name must contain less than 17 characters';
  }
  // No character restrictions
  return null;
}

static String? emailValidation(String? text) {
  final trimmedText = text?.trim() ?? '';
  if (trimmedText.isEmpty) {
    return 'Please enter your email';
  } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(trimmedText)) {
    return 'Please enter a valid email address';
  }
  return null;
}


  static String? ageValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your age';
    } else if (text.length > 2) {
      return 'Age must be less than 100';
    }
    return null;
  }

  static String? phoneValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your phone number';
    }
    try {
      int phoneNumber = int.parse(text);
      if (phoneNumber.toString().length != 10) {
        return 'Phone number must be 10 digits';
      }
    } catch (e) {
      return 'Phone number must contain only numeric digits';
    }
    return null;
  }

  static String? genderValidation(String? selectedGender) {
    if (selectedGender == null || selectedGender.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  static String? nationalityValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your nationality';
    }
    return null;
  }

  static String? addressValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  static String? cityValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your city';
    }
    return null;
  }

  static String? stateValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your state';
    }
    return null;
  }

  static String? countryValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your country';
    }
    return null;
  }

  static String? pinCodeValidation(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter your pin code';
    } else if (text.length != 6) {
      return 'Pin code must be 6 digits';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
      return 'Pin code must contain only numeric digits';
    }
    return null;
  }
}
