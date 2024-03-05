import 'package:app_mecanica/models/response_api.dart';
import 'package:app_mecanica/models/user.dart';
import 'package:app_mecanica/provider/user_provider.dart';
import 'package:app_mecanica/utils/my_snackbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class RegistroController {
  TextEditingController nombreController = TextEditingController();
  TextEditingController codigoController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confiPass = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController dniController = TextEditingController();
  String? sexo;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late BuildContext context;
  late Function refresh;
  final UserProvider _userProvider = UserProvider();
  late ProgressDialog _progressDialog;
  bool isEnable = true;
  bool mostrarCodigo = false;
  bool mostrarBoton = false;


  Future init(BuildContext context, Function refresh, GlobalKey<FormState> formKey) async {
    this.context = context;
    this.refresh = refresh;
    this.formKey = formKey;
    _progressDialog = ProgressDialog(context: context);
  }

  void goLogin() {
    Navigator.pushNamed(context, 'login');
  }

  Future<bool> buscar() async {
    String email = correoController.text.trim();
    bool isValid = EmailValidator.validate(correoController.text.trim());
    ResponseApi? responseApi = await _userProvider.validarEmail(email);
    if (responseApi == null) {
      // Manejar el caso cuando responseApi es nulo
      MySnackbarError.show(context, 'Error al validar el email');
      return false;
    } else if (responseApi.success) {
      MySnackbarError.show(context, responseApi.message);
      return true;
    } else if (isValid) {
      ResponseApi? responseApiCodigo = await _userProvider.codeRegister(email);
      if (responseApiCodigo == null) {
        // Manejar el caso cuando responseApiCodigo es nulo
        MySnackbarError.show(context, 'Error al obtener el código de registro');
        return false;
      } else if (responseApiCodigo.success) {
        _showAlertDialog(responseApiCodigo.message);
        return false;
      }
    }
    // Devolver false como valor predeterminado si no se cumplen las condiciones anteriores
    return false;
  }

  Future<bool> validarCodigo() async {
    String codigo = codigoController.text;
    ResponseApi? responseApi = await _userProvider.validateTokenRegistro(
        codigo);
    if (responseApi == null) {
      MySnackbarError.show(context, 'Error al validar el codigo');
      return false;
    } else if (responseApi.success) {
      MySnackbarPositivo.show(context, responseApi.message);

      codigoController.clear();
      return true;
    }
    MySnackbarError.show(context, responseApi.message);
    return false;
}

  Future<void> registrar() async {

      String correo = correoController.text.trim();
      String password = passwordController.text;
      String nombre = nombreController.text;
      String dni = dniController.text;
      String celular = celularController.text;
      if (formKey.currentState?.validate() ?? false) {
      _progressDialog.show(max: 300,msg: "Espere un momento...");
      isEnable = false;
      User user = User(
          email: correo, password: password, nombre: nombre, dni: dni, sexo: sexo ?? '', celular: celular
      );
      ResponseApi? responseApi = await _userProvider.create(user);
      _progressDialog.close();
      MySnackbarPositivo.show(context, responseApi!.message);

      if (responseApi.success) {
        Future.delayed(Duration(seconds: 3),(){
          Navigator.pushReplacementNamed(context, 'login');
        });
      }else {
        isEnable = true;
      }
      }else{
        MySnackbarError.show(context, 'Por favor, corrija los errores antes de registrarse.');
      }
  }

  void _showAlertDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SE ENVIO CORRECTAMENTE'),
          icon: Icon(Icons.check_circle,color: Colors.green,size: 40),
          content: Text(errorMessage,style: TextStyle(fontFamily: 'OneDay')),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }
}