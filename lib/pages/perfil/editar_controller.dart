

import 'dart:convert';
import 'dart:io';

import 'package:TallerGo/models/response_api.dart';
import 'package:TallerGo/models/user.dart';
import 'package:TallerGo/provider/user_provider.dart';
import 'package:TallerGo/utils/my_snackbar.dart';
import 'package:TallerGo/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class EditarController{
  TextEditingController emailController = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController dniController = TextEditingController();
  TextEditingController contraController = TextEditingController();
  TextEditingController contraConfController = TextEditingController();

  ProgressDialog? _progressDialog;
  bool isEnable = true;
  late BuildContext context;
  late Function refresh;
  User? user;
  late GlobalKey<FormState> formKey;
  final UserProvider _userProvider = UserProvider();
  final SharedPref _sharedPref = SharedPref();
  File? imagenfile;
  XFile? pickedFile;
  late  bool switchValue = false;

  Future init(BuildContext context, Function refresh, GlobalKey<FormState> formKey) async {
    this.context = context;
    this.refresh = refresh;
    this.formKey = formKey;
    await _userProvider.init(context);
    user = User.fromJson(await _sharedPref.read('user'));
    emailController.text = user?.email ?? 'No Disponible';
    celularController.text = user?.celular ?? 'No Disponible';
    nombreController.text = user?.nombre ?? 'No Disponible';
    dniController.text = user?.dni ?? 'No Disponible';
    _progressDialog = ProgressDialog(context: context);
    refresh();
  }

  Future<void> update() async {
    String nombre = nombreController.text;
    String dni = dniController.text;
    String celular = celularController.text;
    String password = contraController.text;
    if (formKey.currentState?.validate() ?? false) {
      _progressDialog?.show(max: 300, msg: 'Espere un momento...');
      isEnable = false;
      if (switchValue) {
        String? idUsuario = user?.id_usuario;
        print('CODIGO $idUsuario');
        print('PASSWORD $password');
        ResponseApi? responseApi = await _userProvider.updatePassword(
            idUsuario, password);
        MySnackbarPositivo.show(context, responseApi!.message);
        _progressDialog?.close();
        if(responseApi.success){
          Future.delayed(const Duration(seconds: 3), () {
            logout();
          });
        }else {
          isEnable = true;
        }
      } else {
        User registro = User(
            usuario_id: user?.usuario_id,
            nombre: nombre,
            dni: dni,
            celular: celular,
            image: user?.image
        );
        Stream? stream = await _userProvider.update(registro, imagenfile);
        stream?.listen((res) async {
          _progressDialog?.close();
          ResponseApi response = ResponseApi.fromJson(json.decode(res));
          print('RESPUESTA: ${response.toJson()}');
          MySnackbarPositivo.show(context, response.message);

          if (response.success) {
            user = await _userProvider.getById(user?.id_usuario);
            _sharedPref.save('user', user?.toJson());
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.pushReplacementNamed(context, 'home');
            });
          }
          else {
            isEnable = true;
          }
        });
      }
    }else {
      MySnackbarError.show(context, 'Por favor, corrija los errores antes de registrarse.');
    }
  }

  logout(){
    _sharedPref.logout(context, user?.id_usuario ?? '');
  }


  Future selectImage(ImageSource imageSource) async {
    final picker = ImagePicker();
    pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      imagenfile = File(pickedFile!.path);
    }
    Navigator.pop(context);
    refresh();
  }
  void showAlertDialog() {
    Widget galleryButton = ElevatedButton(
      onPressed: () {
        selectImage(ImageSource.gallery);
      },
      child: const Text('GALERIA'),
    );

    Widget cameraButton = ElevatedButton(
      onPressed: () {
        selectImage(ImageSource.camera);
      },
      child: const Text('CAMARA'),
    );

    AlertDialog alertDialog = AlertDialog(
      title: const Text('Selecciona tu imagen'),
      actions: [
        galleryButton,
        cameraButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

}