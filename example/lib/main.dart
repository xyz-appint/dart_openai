import 'package:dart_openai/dart_openai.dart';

import 'env/env.dart';

Future<void> main() async {
  // Set the OpenAI API key from the .env file.
  OpenAI.apiKey = Env.apiKey;
  OpenAI.isAzure = true;

  Claude.apiKey = '';
  Claude.baseUrl = 'https://api.anthropic.com/v1';

  Claude.createMessageStream(
    model: 'claude-3-opus-20240229',
    messages: [ClaudeMessage(role: 'user', content: 'HI')],
    maxTokens: 1024,
  ).listen((event) {
    onData(ClaudeResponse event) {}
    onError() {
      print('error');
    }

    onDone() {}
  });
  //
  //
  // // Start using!
  // final completion = await OpenAI.instance.completion.create(
  //   model: "text-davinci-003",
  //   prompt: "Dart is",
  // );
  //
  // // Printing the output to the console
  // print(completion.choices[0].text);
  //
  // // Generate an image from a prompt.
  // final image = await OpenAI.instance.image.create(
  //   prompt: "dog",
  //   n: 1,
  // );
  //
  // // Printing the output to the console.
  // for (int index = 0; index < image.data.length; index++) {
  //   final currentItem = image.data[index];
  //   print(currentItem.url);
  // }
  //
  // // create a moderation
  // final moderation = await OpenAI.instance.moderation.create(
  //   input: "I will cut your head off",
  // );
  //
  // // Printing moderation
  // print(moderation.results.first.categories.violence);
}
