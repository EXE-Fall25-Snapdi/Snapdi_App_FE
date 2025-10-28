import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm:ss';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';

  /// Format DateTime to string with given pattern
  static String formatDateTime(DateTime dateTime, String pattern) {
    final formatter = DateFormat(pattern);
    return formatter.format(dateTime);
  }

  /// Format DateTime to display date string
  static String formatDate(DateTime dateTime) {
    return formatDateTime(dateTime, displayDateFormat);
  }

  /// Format DateTime to display time string
  static String formatTime(DateTime dateTime) {
    return formatDateTime(dateTime, displayTimeFormat);
  }

  /// Format DateTime to display date and time string
  static String formatDateTimeDisplay(DateTime dateTime) {
    return formatDateTime(dateTime, displayDateTimeFormat);
  }

  /// Parse string to DateTime
  static DateTime? parseDateTime(String dateTimeStr, String pattern) {
    try {
      final formatter = DateFormat(pattern);
      return formatter.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  /// Get time ago string (e.g., "2 hours ago", "1 day ago")
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 năm trước' : '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 tháng trước' : '$months tháng trước';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 ngày trước'
          : '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 giờ trước'
          : '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 phút trước'
          : '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      23,
      59,
      59,
      999,
    );
  }
}

class ValidationUtils {
  /// Validate email format
  static bool isValidEmail(String email) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  /// Validate phone number format (basic validation)
  static bool isValidPhoneNumber(String phoneNumber) {
    const pattern = r'^\+?[\d\s\-\(\)]{10,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(phoneNumber);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, containing uppercase, lowercase, digit, and special character
    const pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  /// Check if string is not null and not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Check if string has minimum length
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }

  /// Check if string has maximum length
  static bool hasMaxLength(String? value, int maxLength) {
    return value == null || value.length <= maxLength;
  }
}

class StringUtils {
  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Capitalize first letter only
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  /// Remove all whitespace characters
  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  /// Format currency with custom symbol
  static String formatCurrency(
    double amount, {
    String symbol = '\$',
    int decimals = 2,
  }) {
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  /// Format price for VND (Vietnamese Dong) with comma separators
  /// Example: 500000 -> "500,000"
  static String formatVND(double amount, {bool showSymbol = false}) {
    final formatter = NumberFormat('#,###', 'en_US');
    final formatted = formatter.format(amount);
    return showSymbol ? '$formatted VNĐ' : formatted;
  }

  /// Format price for VND from int
  /// Example: 500000 -> "500,000 VNĐ"
  static String formatVNDFromInt(int amount, {bool showSymbol = true}) {
    return formatVND(amount.toDouble(), showSymbol: showSymbol);
  }

  /// Parse formatted VND string back to double
  /// Example: "500,000" -> 500000.0
  /// Example: "500,000 VNĐ" -> 500000.0
  static double parseVND(String formattedAmount) {
    // Remove all non-digit characters (commas, spaces, currency symbols)
    final cleaned = formattedAmount.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Parse formatted VND string back to int
  /// Example: "500,000" -> 500000
  static int parseVNDToInt(String formattedAmount) {
    return parseVND(formattedAmount).toInt();
  }

  /// Format price with abbreviated notation (K, M, B)
  /// Example: 1500000 -> "1.5M"
  static String formatPriceAbbreviated(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  /// Format price range for VND
  /// Example: formatPriceRange(500000, 1000000) -> "500,000 - 1,000,000 VNĐ"
  static String formatPriceRange(double minPrice, double maxPrice) {
    return '${formatVND(minPrice)} - ${formatVND(maxPrice, showSymbol: true)}';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Generate random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      length,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }
}

/// Currency Input Formatter for VND
/// Formats numbers with comma separators as user types
/// Example: User types "500000" -> displays "500,000"
/// The actual value stored remains 500000 (use parseVND to extract)
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If empty, return as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters to get the actual value
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // If no digits, return empty
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse the numeric value
    int value = int.parse(digitsOnly);

    // Format with commas
    String formatted = _formatter.format(value);

    // Return formatted text with cursor at the end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
