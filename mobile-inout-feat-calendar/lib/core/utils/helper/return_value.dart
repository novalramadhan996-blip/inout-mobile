class ReturnValue {
  static String string(
    dynamic value, {
    dynamic otherValue,
    String? defaultValue,
  }) {
    if (value.runtimeType == int) {
      return value.toString();
    }
    return (value as String?) ?? (otherValue as String?) ?? defaultValue ?? '';
  }

  static int integer(dynamic value, {int? defaultValue}) {
    if (value.runtimeType == String) {
      return 0;
    }
    return (value as num?)?.toInt() ?? (defaultValue ?? 0);
  }

  static double doubleValue(dynamic value, {double? defaultValue}) {
    return (value as num?)?.toDouble() ?? (defaultValue ?? 0.0);
  }

  static num number(dynamic value, {num? defaultValue}) {
    return (value as num?) ?? (defaultValue ?? 0);
  }

  static bool boolean(dynamic value, {bool? defaultValue}) {
    return (value as bool?) ?? (defaultValue ?? false);
  }

  static DateTime? dateTime(dynamic value) {
    return DateTime.tryParse((value as String?) ?? '');
  }

  static List<T> list<T>(dynamic value) {
    return List<T>.from((value as List<dynamic>?)?.cast<T>() ?? <T>[]);
  }

  static List<T> listObject<T>({
    required dynamic value,
    required dynamic Function(Map<String, dynamic>) fromMap,
  }) {
    if (value is List) {
      if (value.isEmpty) {
        return <T>[];
      }
    }

    return List<T>.from(
      (value as List<dynamic>?)?.map<dynamic>(
            (dynamic element) => fromMap(element as Map<String, dynamic>),
          ) ??
          <T>[],
    );
  }

  static Map<String, dynamic> map(dynamic value) {
    return (value as Map<String, dynamic>?) ?? <String, dynamic>{};
  }
}
