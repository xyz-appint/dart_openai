import 'dart:io';

import 'package:http/http.dart';
import 'package:openai/src/core/builder/base_api_url.dart';
import 'package:openai/src/core/models/image.dart';
import 'package:openai/src/core/networking/client.dart';

import '../../core/base/images/base.dart';
import '../../core/models/image_edit.dart';

import 'package:http/http.dart' as http;

import '../../core/models/variation.dart';
import '../../core/utils/logger.dart';

class OpenAIImages implements OpenAIImagesBase {
  @override
  String get endpoint => "/images";

  @override
  Future<OpenAIImageModel> create({
    required String prompt,
    int? n,
    String? size,
    String? responseFormat,
    String? user,
  }) async {
    final String generations = "/generations";
    return await OpenAINetworkingClient.post(
      to: BaseApiUrlBuilder.build(endpoint + generations),
      onSuccess: (json) => OpenAIImageModel.fromJson(json),
      body: {
        "prompt": prompt,
        if (n != null) "n": n,
        if (size != null) "size": size,
        if (responseFormat != null) "response_format": responseFormat,
        if (user != null) "user": user,
      },
    );
  }

  @override
  Future<OpenAiImageEditModel> edit({
    required File image,
    File? mask,
    required String prompt,
    int? n,
    String? size,
    String? responseFormat,
    String? user,
  }) async {
    final String edit = "/edits";
    return await OpenAINetworkingClient.imageEditForm<OpenAiImageEditModel>(
      image: image,
      mask: mask,
      body: {
        "prompt": prompt,
        if (n != null) "n": n.toString(),
        if (size != null) "size": size,
        if (responseFormat != null) "response_format": responseFormat,
        if (user != null) "user": user,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAiImageEditModel.fromJson(response);
      },
      to: BaseApiUrlBuilder.build(endpoint + edit),
    );
  }

  Future<OpenAIVariationModel> variation({
    required File image,
    int? n,
    String? size,
    String? responseFormat,
    String? user,
  }) async {
    final String variations = "/variations";
    return await OpenAINetworkingClient.imageVariationForm<
        OpenAIVariationModel>(
      image: image,
      body: {
        if (n != null) "n": n.toString(),
        if (size != null) "size": size,
        if (responseFormat != null) "response_format": responseFormat,
        if (user != null) "user": user,
      },
      onSuccess: (Map<String, dynamic> response) {
        return OpenAIVariationModel.fromJson(response);
      },
      to: BaseApiUrlBuilder.build(endpoint + variations),
    );
  }

  OpenAIImages() {
    OpenAILogger.logEndpoint(endpoint);
  }
}