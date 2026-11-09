import 'dart:math';

/// Generates the random ids that key charts on the JavaScript side.
abstract final class UID {
  static const _chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final _secureRandom = Random.secure();

  /// A random alphanumeric id of [length] characters.
  static String generate([int length = 10]) => List.generate(
    length,
    (_) => _chars[_secureRandom.nextInt(_chars.length)],
  ).join();
}
