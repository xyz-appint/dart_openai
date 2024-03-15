part 'response.g.dart';

class ClaudeResponse {
  final String? id;
  final String? type;
  final String? role, model;
  final List<ClaudeContent>? content;
  final String? stopReason;
  final dynamic stopSequence;
  final ClaudeUsage? usage;

  const ClaudeResponse({
    this.id,
    this.type,
    this.model,
    this.role,
    this.content,
    this.stopReason,
    this.stopSequence,
    this.usage,
  });

  factory ClaudeResponse.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

class ClaudeContent {
  final String? type;
  final String? text;

  const ClaudeContent({
    this.type,
    this.text,
  });

  factory ClaudeContent.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);
}

class ClaudeUsage {
  final int? inputTokens;
  final int? outputTokens;

  const ClaudeUsage({
    this.inputTokens,
    this.outputTokens,
  });

  factory ClaudeUsage.fromJson(Map<String, dynamic> json) =>
      _$UsageFromJson(json);

  Map<String, dynamic> toJson() => _$UsageToJson(this);
}
