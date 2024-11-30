

import 'package:TallerGo/provider/chat_provider.dart';
import 'package:flutter/cupertino.dart';

class ChatController {
  late BuildContext context;
  late Function refresh;
  ChatProvider _chatProvider = ChatProvider();
  Future init(BuildContext context, Function refresh) async{
      this.context = context;
      this.refresh = refresh;
      await _chatProvider.init(context);
    }


  void sendMessageToChatGPT(String message) async {
    try {
      String response = await _chatProvider.fetchResponseFromChatGPT(message);
      // Aquí puedes procesar la respuesta recibida, como mostrarla en la interfaz de usuario
    } catch (e) {
      // Manejar errores
      print('Error: $e');
    }
  }
}