class ResponseModel {
  late List<Choice> choices;

  ResponseModel({required this.choices});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['choices'] != null) {
      choices = <Choice>[];
      json['choices'].forEach((v) {
        choices.add(Choice.fromJson(v));
      });
    }
  }
}

class Choice {
  late String text;
  late double temperature;
  late double logprobs;
  late List<double> finishReason;

  Choice({
    required this.text,
    required this.temperature,
    required this.logprobs,
    required this.finishReason,
  });

   Choice.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    temperature = json['temperature'];
    logprobs = json['logprobs'];
    finishReason = List<double>.from(json['finish_reason']);
  }
}
