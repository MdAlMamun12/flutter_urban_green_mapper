import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Parse various Firestore/JSON date shapes into a Dart [DateTime].
///
/// Accepts:
/// - `DateTime` (returned as-is)
/// - `Timestamp` (Firestore) -> converted via `.toDate()`
/// - `int` (seconds or milliseconds since epoch) -> heuristics applied
/// - `String` -> parsed with `DateTime.tryParse`
/// - `Map` with `seconds`/`nanoseconds` or `_seconds`/`_nanoseconds`
DateTime? parseFirestoreDateTime(dynamic value, {DateTime? fallback}) {
  if (value == null) return fallback;

  try {
    if (value is DateTime) return value;

    if (value is Timestamp) return value.toDate();

    if (value is int) {
      // Heuristic: treat ints > 1e12 as milliseconds, else as seconds
      if (value.abs() > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;

      // Try parsing numeric string
      final asInt = int.tryParse(value);
      if (asInt != null) {
        if (asInt.abs() > 1000000000000) return DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
      }
    }

    if (value is Map) {
      // Firestore JSON shape
      final seconds = value['seconds'] ?? value['_seconds'];
      final nanosRaw = value['nanoseconds'] ?? value['_nanoseconds'] ?? 0;
      final nanos = nanosRaw is int ? nanosRaw : int.tryParse('$nanosRaw') ?? 0;
      if (seconds != null) {
        final s = seconds is int ? seconds : int.tryParse('$seconds');
        if (s != null) return DateTime.fromMillisecondsSinceEpoch(s * 1000 + (nanos ~/ 1000000));
      }
    }
  } catch (_) {
    // ignore and return fallback
  }

  return fallback;
}
