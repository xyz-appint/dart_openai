import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../dart_openai.dart';
import '../core/base/openai_client/base.dart';
import '../core/constants/config.dart';
import '../core/constants/strings.dart';
import '../core/networking/client.dart';
import '../core/utils/logger.dart';

/// The main class of the package. It is a singleton class, so you can only have one instance of it.
/// You can also access the instance by calling the [OpenAI.instance] getter.
/// ```dart
/// final openai = OpenAI.instance;
/// ```
@immutable
final class Claude extends OpenAIClientBase {
  /// The singleton instance of [OpenAI].
  static final Claude _instance = Claude._();

  static String? _internalApiKey;
  static String? _internalBaseUrl;

  static Claude get instance {
    if (_internalApiKey == null) {
      throw MissingApiKeyException("""
      You must set the api key before accessing the instance of this class.
      Example:
      OpenAI.apiKey = "Your API Key";
      """);
    }

    return _instance;
  }

  /// {@macro openai_config_requests_timeOut}
  static Duration get requestsTimeOut => OpenAIConfig.requestsTimeOut;

  /// {@macro openai_config_requests_timeOut}
  static set requestsTimeOut(Duration requestsTimeOut) {
    OpenAILogger.requestsTimeoutChanged(requestsTimeOut);
  }

  static set apiKey(String apiKey) {
    _internalApiKey = apiKey;
  }

  static set baseUrl(String baseUrl) {
    _internalBaseUrl = baseUrl;
  }

  static set showLogs(bool newValue) {
    OpenAILogger.isActive = newValue;
  }

  static set showResponsesLogs(bool showResponsesLogs) {
    OpenAILogger.showResponsesLogs = showResponsesLogs;
  }

  Claude._();

  static Stream<ClaudeResponse> createMessageStream({
    required String model,
    required List<ClaudeMessage> messages,
    required int maxTokens,
    double? temperature,
    http.Client? client,
  }) {
    return _postClaudeStream<ClaudeResponse>(
      to: _buildClaude('/messages'),
      body: {
        "model": model,
        "stream": true,
        "messages": messages.map((message) => message.toJson()).toList(),
        "max_tokens": maxTokens,
        if (temperature != null) "temperature": temperature,
      },
      onSuccess: (Map<String, dynamic> response) {
        return ClaudeResponse.fromJson(response);
      },
      client: client,
    );
  }

  static String _buildClaude(String endpoint, [String? id, String? query]) {
    final baseUrl = _internalBaseUrl;
    final usedEndpoint = _handleEndpointsStarting(endpoint);
    String apiLink = "$baseUrl";
    apiLink += "$usedEndpoint";
    if (id != null) {
      apiLink += "/$id";
    } else if (query != null) {
      apiLink += "?$query";
    }

    return apiLink;
  }

  static Map<String, String> _buildHeader() {
    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'anthropic-beta': 'messages-2023-12-15',
      'anthropic-version': '2023-06-01',
    };
    assert(
      _internalApiKey != null,
      """
      You must set the API key before making building any headers for a request.""",
    );
    headers = {
      ...headers,
      "x-api-key": "$_internalApiKey",
    };
    OpenAILogger.log(jsonEncode(headers));

    return headers;
  }

  // This is used to handle the endpoints that don't start with a slash.
  static String _handleEndpointsStarting(String endpoint) {
    return endpoint.startsWith("/") ? endpoint : "/$endpoint";
  }

  static Map<String, dynamic> _decodeToMap(String responseBody) {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to decode JSON: $e');
    }
  }

  static Stream<T> _postClaudeStream<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, dynamic> body,
    http.Client? client,
  }) async* {
    try {
      final clientForUse = client ?? _streamingHttpClient();
      final uri = Uri.parse(to);
      final headers = _buildHeader();
      final httpMethod = 'POST';
      final request = http.Request(httpMethod, uri);
      request.headers.addAll(headers);
      request.body = jsonEncode(body);

      OpenAILogger.logStartRequest(to);
      try {
        final respond = await clientForUse.send(request);
        try {
          OpenAILogger.startReadStreamResponse();
          final stream = respond.stream
              .transform(utf8.decoder)
              .transform(openAIChatStreamLineSplitter);

          try {
            String respondData = "";
            await for (final value
                in stream.where((event) => event.isNotEmpty)) {
              final data = value;
              print(data);
              respondData += data;

              final dataLines = data
                  .split("\n")
                  .where((element) => element.isNotEmpty)
                  .toList();

              for (String line in dataLines) {
                if (line.startsWith(OpenAIStrings.streamResponseStart)) {
                  final String data = line.substring(6);
                  if (data.contains(OpenAIStrings.streamResponseEnd)) {
                    OpenAILogger.streamResponseDone();
                    break;
                  }
                  final decoded = jsonDecode(data) as Map<String, dynamic>;
                  yield onSuccess(decoded);
                  continue;
                }

                Map<String, dynamic> decodedData = {};
                try {
                  decodedData = _decodeToMap(respondData);
                } catch (error) {
                  /** ignore, data has not been received */
                }

                if (_doesErrorExists(decodedData)) {
                  final error = decodedData[OpenAIStrings.errorFieldKey]
                      as Map<String, dynamic>;
                  var message = error[OpenAIStrings.messageFieldKey] as String;
                  message = message.isEmpty ? jsonEncode(error) : message;
                  final statusCode = respond.statusCode;
                  final exception = RequestFailedException(message, statusCode);

                  yield* Stream<T>.error(
                    exception,
                  ); // Error cases sent from openai
                }
              }
            } // end of await for
          } catch (error, stackTrace) {
            yield* Stream<T>.error(
              error,
              stackTrace,
            ); // Error cases in handling stream
          }
        } catch (error, stackTrace) {
          yield* Stream<T>.error(
            error,
            stackTrace,
          ); // Error cases in decoding stream from response
        }
      } catch (e) {
        yield* Stream<T>.error(e); // Error cases in getting response
      }
    } catch (e) {
      yield* Stream<T>.error(e); //Error cases in making request
    }
  }

  static bool _doesErrorExists(Map<String, dynamic> decodedResponseBody) {
    return decodedResponseBody[OpenAIStrings.errorFieldKey] != null;
  }

  static http.Client _streamingHttpClient() {
    return http.Client();
  }
}
