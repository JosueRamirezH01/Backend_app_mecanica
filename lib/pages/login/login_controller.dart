
import 'package:TallerGo/models/response_api.dart';
import 'package:TallerGo/models/user.dart';
import 'package:TallerGo/provider/user_provider.dart';
import 'package:TallerGo/utils/my_snackbar.dart';
import 'package:TallerGo/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';

class LoginController{

  final SharedPref _sharedPref = SharedPref();
  late BuildContext  context;
  late Function refresh;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserProvider _userProvider = UserProvider();
  Future init(BuildContext context, Function refresh) async{
    this.context = context;
    this.refresh = refresh;
    await _userProvider.init(context);
    User users = User.fromJson(await _sharedPref.read('user') ?? {});
    if(users.verificador_token != null){
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    }
    refresh();
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    ResponseApi? responseApi = await _userProvider.login(email, password);
    print(responseApi?.toJson());
    if(responseApi!.success){
      User users = User.fromJson(responseApi.data);
      _sharedPref.save('user', users.toJson());
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    }else {
        MySnackbarError.show(context, responseApi.message);
    }
  }

  void goRegistro(){
    Navigator.pushNamed(context, 'registro');
  }

  void goRecuperacion(){
    Navigator.pushNamed(context, 'recuperacion');
  }



}