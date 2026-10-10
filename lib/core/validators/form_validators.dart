abstract final class FormValidators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = double.tryParse(value);
    if (n == null || n < 0) return 'Enter a valid amount';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final requiredError = required(value, field: 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }
}
