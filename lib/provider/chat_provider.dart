import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatProvider {
  late BuildContext context;

  Future init(BuildContext context) async {
    this.context = context;
  }

  Future<String> fetchResponseFromChatGPT(String message) async {
    final String apiKey = dotenv.env['APIKEY'] ?? ''; // Obtener la clave de API desde el archivo .env
    final String endpoint = 'https://api.openai.com/v1/completions'; // URL del endpoint de OpenAI

    final Map<String, String> headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'model': 'gpt-3.5-turbo', // Modelo de lenguaje ChatGPT a utilizar
      'max_tokens': 150, // Número máximo de tokens para generar en la respuesta
      'prompt': message, // El mensaje que envías al modelo para obtener una respuesta
      'temperature': 0.7, // Controla la creatividad de las respuestas generadas (0.0 - 1.0)
    };

    await Future.delayed(Duration(seconds: 5));

    final http.Response response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String chatResponse = data['choices'][0]['text'];
      print('Respuesta de ChatGPT: $chatResponse');
      return chatResponse;
    } else {
      print('Error al enviar la solicitud: ${response.statusCode}');
      throw Exception('Error al enviar la solicitud a ChatGPT');
    }
  }
}

