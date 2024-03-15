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

class ClaudeMessageContent {
  String type = 'text';
  String? text;

  ClaudeMessageContent({required this.type, this.text});

  Map<String, dynamic> toJson() => {
        'type': type,
        'text': text,
      };

  ClaudeMessageContent fromJson(Map<String, dynamic> json) =>
      ClaudeMessageContent(
        type: json['type'] as String,
        text: json['text'] ?? '',
      );
}

class ClaudeMessage {
  String? role;

  // String? content;
  List<ClaudeMessageContent> content;

  ClaudeMessage({required this.role, required this.content});

  factory ClaudeMessage.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
