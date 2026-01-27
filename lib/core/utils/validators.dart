import 'package:flutter/services.dart';

class Validators {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    if (value.trim().length < 8) {
      return 'Account number must be at least 8 characters';
    }
    return null;
  }

  static String? validateAccountName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account name is required';
    }
    if (value.trim().length < 2) {
      return 'Account name must be at least 2 characters';
    }
    return null;
  }

  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category name is required';
    }
    if (value.trim().length < 2) {
      return 'Category name must be at least 2 characters';
    }
    return null;
  }

  static String? validateTagName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tag name is required';
    }
    if (value.trim().length < 2) {
      return 'Tag name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePatternName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pattern name is required';
    }
    if (value.trim().length < 2) {
      return 'Pattern name must be at least 2 characters';
    }
    return null;
  }

  static TextInputFormatter numericInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  static TextInputFormatter amountInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));
}
