
import 'package:flutter/cupertino.dart';

class ConfirmacionController {

  late BuildContext context;
  late Function refresh;
  late String email;
  Future init(BuildContext context, Function refresh)async{
    this.context = context;
    this.refresh = refresh;
    final Map<String, dynamic> datos = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    email = datos['email'];
    refresh();
  }
}