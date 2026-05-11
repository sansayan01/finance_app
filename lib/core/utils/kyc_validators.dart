class KYCValidators {
  KYCValidators._();

  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final RegExp _aadharRegex = RegExp(r'^\d{12}$');
  static final RegExp _phoneRegex = RegExp(r'^[6-9]\d{9}$');

  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN is required';
    }
    final upperValue = value.toUpperCase();
    if (!_panRegex.hasMatch(upperValue)) {
      return 'Invalid PAN format (e.g., ABCDE1234F)';
    }
    return null;
  }

  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhar is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 12) {
      return 'Aadhar must be 12 digits';
    }
    if (!_aadharRegex.hasMatch(digitsOnly)) {
      return 'Invalid Aadhar format';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) {
      return 'Phone must be 10 digits';
    }
    if (!_phoneRegex.hasMatch(digitsOnly)) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String formatPhoneForDisplay(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 10) {
      return '+91 ${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5)}';
    }
    return phone;
  }

  static String maskAadhar(String aadhar) {
    if (aadhar.length != 12) return aadhar;
    return '${aadhar.substring(0, 4)} **** **** ${aadhar.substring(8)}';
  }

  static String maskPAN(String pan) {
    if (pan.length != 10) return pan;
    return '${pan.substring(0, 3)}****${pan.substring(7)}';
  }
}
