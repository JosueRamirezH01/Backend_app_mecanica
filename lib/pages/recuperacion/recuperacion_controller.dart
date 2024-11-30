
import 'package:TallerGo/models/response_api.dart';
import 'package:TallerGo/models/user.dart';
import 'package:TallerGo/provider/user_provider.dart';
import 'package:TallerGo/utils/my_snackbar.dart';
import 'package:flutter/cupertino.dart';

class RecuperacionController {
  late BuildContext context;
  late Function  refresh;
  TextEditingController emailController = TextEditingController();
  final UserProvider _userProvider = UserProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
  }

  void forgotPassoword() async{
    String email = emailController.text.trim();
    ResponseApi? responseApi = await _userProvider.forgotPassword(email);
    if(responseApi?.success == true){
      MySnackbarPositivo.show(context, responseApi!.message);
      Navigator.pushReplacementNamed(context, 'recuperacion/confirmacion', arguments:{
        'email': emailController.text
      });
    }else{
      MySnackbarError.show(context, responseApi!.message);
    }
  }
}