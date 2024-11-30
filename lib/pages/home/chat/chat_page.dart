import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );
  final carga = ".....";
  final apikey = "AIzaSyBj1su2QlNV3Het4QPaqSMNSycwhy1tOlA";


  @override
  void initState() {
    super.initState();
    _addGreetingMessage();
  }

  void _addGreetingMessage() {
    // Crear un mensaje de saludo
    final greetingMessage = types.TextMessage(
      author: const types.User(id: 'bikerbot'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: '¡Hola! Soy tu amigo BikerBot. ¿En qué puedo ayudarte hoy?',
    );

    // Agregar el mensaje de saludo a la lista de mensajes
    _addMessage(greetingMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  // void _handleAttachmentPressed() {
  //   showModalBottomSheet<void>(
  //     context: context,
  //     builder: (BuildContext context) => SafeArea(
  //       child: SizedBox(
  //         height: 144,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 _handleImageSelection();
  //               },
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('Photo'),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('File'),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('Cancel'),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }


  // void _handleImageSelection() async {
  //   final result = await ImagePicker().pickImage(
  //     imageQuality: 70,
  //     maxWidth: 1440,
  //     source: ImageSource.gallery,
  //   );
  //
  //   if (result != null) {
  //     final bytes = await result.readAsBytes();
  //     final image = await decodeImageFromList(bytes);
  //
  //     final message = types.ImageMessage(
  //       author: _user,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       height: image.height.toDouble(),
  //       id: const Uuid().v4(),
  //       name: result.name ?? '',
  //       size: bytes.length,
  //       uri: result.path,
  //       width: image.width.toDouble(),
  //     );
  //
  //     _addMessage(message);
  //   }
  // }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir =
              (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      // await OpenFile.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    // Agregar el mensaje enviado por el usuario al chat
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    _addMessage(textMessage);

    // Mostrar la animación de cargo mientras se está generando la respuesta
    final cargaAnimacion = types.TextMessage(
        author: const types.User(id: 'gemini'),
        id:  Uuid().v4(),
        text: ". . . . . . . . . .",
    );
    _addMessage(cargaAnimacion);

    // Generar la respuesta del modelo Gemini
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apikey);
    final prompt = textMessage.text;
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);


    // Introducir un retraso antes de agregar la respuesta y eliminar la animación de carga
    await Future.delayed(Duration(seconds: 1));

    // Eliminar la animación de carga y agregar la respuesta
    _messages.removeWhere((msg) => msg.id == cargaAnimacion.id);
    final geminiResponseMessage = types.TextMessage(
      author: const types.User(id: 'gemini'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: response.text!,
    );
    _addMessage(geminiResponseMessage);
  }




  // void _loadMessages() async {
  //   final response = await rootBundle.loadString('assets/json/message.json');
  //   final messages = (jsonDecode(response) as List)
  //       .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
  //       .toList();
  //
  //   setState(() {
  //     _messages = messages;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff343541),
        appBar: AppBar(
          centerTitle: true,
      
          automaticallyImplyLeading: false,
          title: Text(
            'Soy tu amigo BikerBot',
            style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
          ),
          backgroundColor: Colors.lime,
        ),
        body: Stack(
          children: [
            Chat(
              messages: _messages,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              showUserAvatars: true,
              showUserNames: true,
              user: _user,
              theme: const DefaultChatTheme(
                seenIcon: Text(
                  'read',
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
              ),
            ),
      
          ],
        ),

    );
  }
}
