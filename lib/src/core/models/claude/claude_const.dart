import 'package:meta/meta.dart';

/// {@template openai_strings}
/// This class is responsible for storing general [String] constants.
/// {@endtemplate}
@internal
@immutable
abstract class ClaudeConst {
  /// The identifier and initial value to exclude for stream responses (SSE).
  static const streamResponseStart = "data";

  static const streamResponseEvent = "event";

  /// The identifier and final value to exclude for stream responses (SSE).
  static const streamResponseEnd = "message_stop";

  /// The name of the error field a failed response will have.
  static const errorFieldKey = 'error';

  /// The name of the message field a failed response will have.
  static const messageFieldKey = 'message';
}
