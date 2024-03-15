part 'request.g.dart';
//
// class ClaudeRequest {
//   String? model;
//   int? maxTokens;
//   List<ClaudeMessage>? messages;
//
//   ClaudeRequest({
//     this.model,
//     this.maxTokens,
//     this.messages,
//   });
//
//   factory ClaudeRequest.fromJson(Map<String, dynamic> json) =>
//       _$RequestFromJson(json);
//
//   Map<String, dynamic> toJson() => _$RequestToJson(this);
// }

class ClaudeMessage {
  String? role;
  String? content;

  ClaudeMessage({required this.role, required this.content});

  factory ClaudeMessage.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
