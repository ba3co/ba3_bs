mixin AppValidator {
  String? isFieldValid(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required!';
    }
    return null;
  }

  String? isFirstNameValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required!';
    }
    if (value.trim().length < 3) {
      return 'Please enter at least 3 characters!';
    }
    return null;
  }

  String? isLastNameValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required!';
    }
    if (value.trim().length < 3) {
      return 'Please enter at least 3 characters!';
    }
    return null;
  }

  String? isEmailValid(String? email) {
    final emailRegex = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');
    if (email == null || email.trim().isEmpty) {
      return 'Email is required!';
    } else if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email!';
    }
    return null;
  }

  String? isPhoneValid(String? value, int? phoneLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone is required!';
    }
    if (value.trim().length != phoneLength) {
      return 'Your phone number should be $phoneLength digits!';
    }
    if (int.tryParse(value.trim()) == null) {
      return '$value can only be numbers';
    }
    return null;
  }

  String? isVerificationCodeValid(String? code) {
    if (code == null || code.isEmpty) {
      return 'Code is required';
    } else if (code.length < 6) {
      return 'Please enter 6 digits';
    }
    return null;
  }

  String? isDescriptionValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe the damage';
    }
    return null;
  }

  // Validation for the amount field
  String? isAmountValid(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    final amount = int.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount < 1 || amount > 1000) {
      return 'Amount must be between 1 and 1000';
    }

    return null; // No validation error
  }

  static bool isUrlValid(url) => RegExp(
        r'^(http(s)?:\/\/)?(www\.)?[a-zA-Z0-9-_\.]+\.[a-zA-Z]{2,4}\/?([\w\/\-?=%.&=]+)?$',
      ).hasMatch(url);

  static bool isDurationValid(url) => RegExp(
        r'^\d{1,2}:\d{1,2}$',
      ).hasMatch(url);

  static bool isValidTextNumber(
    String textNumber,
    double minValue,
    double maxValue,
  ) {
    try {
      final clearedTextNum = textNumber.trim();
      final number = clearedTextNum.isNotEmpty ? double.parse(clearedTextNum) : 0;
      final isValid = number >= minValue && number <= maxValue;
      return isValid;
    } catch (_) {
      return false;
    }
  }

  static bool isValidName(String name) => name.trim().isNotEmpty;

  static bool isPasswordValid(String password) {
    final RegExp passwordPattern = RegExp(r'^(?=.*[0-9])(?=.*[A-Z])(?=.*[^a-zA-Z0-9]).{8,}$');

    return passwordPattern.hasMatch(password);
  }

  static bool isValidVerificationCode(String code) {
    final RegExp sixNumbersPattern = RegExp(r'^\d{6}$');
    return sixNumbersPattern.hasMatch(code);
  }

  static bool isValidUuid(String uuid) {
    final uuidRegExp =
        RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegExp.hasMatch(uuid);
  }
}
