import 'package:flutter/material.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool isValidEmail() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }
}

extension BuildContextExtensions on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void navigateTo(Widget page) {
    Navigator.of(this).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void pop() {
    Navigator.of(this).pop();
  }
}