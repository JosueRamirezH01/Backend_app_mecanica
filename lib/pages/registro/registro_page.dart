import 'dart:async';

import 'package:app_mecanica/pages/registro/registro_controller.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  List listsexo = [{"titulo":"Masculino","value":"1"},{"titulo":"Femenino","value":"2"}];
  final RegistroController _con = RegistroController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Timer? _debounce;
  bool _emailError = false;

  bool _obscurePassword = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _debounce = Timer(Duration(seconds: 2), () {});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, formKey);
    });
  }

  void _onEmailTextChanged() {
    setState(() {
      String email = _con.correoController.text.trim();
      bool isEmailValid = EmailValidator.validate(email);

      // Verifica si el correo está vacío o no válido
      if (_con.correoController.text.isEmpty || !isEmailValid) {
        _con.mostrarCodigo = false;
        return;
      }

      // Cancela el temporizador existente (si existe)
      if (_debounce != null && _debounce!.isActive) {
        _debounce?.cancel();
      }

      // Realiza el trabajo asíncrono fuera de setState
      _debounce = Timer(Duration(seconds: 2), () {
        _con.buscar().then((buscarResult) {
          // Muestra el campo cuando el email es válido y la búsqueda es falsa
          _con.mostrarCodigo = !_emailError && !buscarResult;
          refresh();
        }).catchError((error) {
          // Manejar errores, por ejemplo, mostrar un mensaje de error
          print('Error: $error');
        });
      });
    });
  }
  void _onCodigoTextChanged() {
    setState(() {
      // Verifica si el correo está vacío o no válido
      if (_con.codigoController.text.isEmpty ) {
        _con.mostrarCodigo = false;
        return;
      }

      // Cancela el temporizador existente (si existe)
      if (_debounce != null && _debounce!.isActive) {
        _debounce?.cancel();
      }

      // Realiza el trabajo asíncrono fuera de setState
      _debounce = Timer(Duration(seconds: 2), () {
      _con.validarCodigo().then((codigoResult) {
          // Muestra el campo cuando el email es válido y la búsqueda es falsa
          _con.mostrarCodigo = !codigoResult;
          _con.mostrarBoton = codigoResult;
          refresh();
        }).catchError((error) {
          // Manejar errores, por ejemplo, mostrar un mensaje de error
          print('Error: $error');
        });
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 73, 94),
        title: const Text(
          'Registrate',
          style: TextStyle(
              fontSize: 24,
              fontFamily: 'Pacifico'
          ),
        ),
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _con.formKey, // Asigna el GlobalKey<FormState> al formulario
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/icono-registro.json', width: 200),
                textEmail(),
                const SizedBox(height: 16),
                if(_con.mostrarCodigo)
                _textCodigo(),
                const SizedBox(height: 16),
                textPassword(),
                const SizedBox(height: 16),
                textConfPassword(),
                const SizedBox(height: 16),
                _textNombre(),
                const SizedBox(height: 16),
                _textFieldSexo(),
                const SizedBox(height: 16),
                _textFieldni(),
                const SizedBox(height: 16),
                _textFielCelular(),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _con.mostrarBoton ? _con.registrar : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    primary: const Color.fromARGB(255, 153, 204, 102),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Text(
                      'Registrar',
                      style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'OneDay', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes una cuenta?',
                      style: TextStyle(fontSize: 16,fontFamily: 'NimbusSans'),
                    ),
                    TextButton(
                      onPressed: _con.goLogin,
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textCodigo(){
    return TextFormField(
    controller: _con.codigoController,
    style: TextStyle(
    fontFamily: 'OneDay'
    ),
    decoration: InputDecoration(
    contentPadding: const EdgeInsets.only(top: 15),
    labelText: 'Ingrese su codigo',
    hintText: 'Insertar el codigo enviado al correo ingresado',
      prefixIcon: Icon(Icons.lock)
    ),onChanged: (value) => {
    _onCodigoTextChanged()
    },
    validator: (value){
      if (value == null || value.isEmpty) {
        return 'Por favor ingrese su código';
      }
       return null;
      },
    );
  }


  Widget _textNombre(){
    return TextFormField(
      controller: _con.nombreController,
      decoration: const InputDecoration(
        labelText: 'Nombre Completo',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo requerido";
        }
        if (int.tryParse(value) != null) {
          return "Por favor ingrese solo letras";
        }
        return null;
      },
    );
  }

  Widget _textFielCelular(){
    return TextFormField(
      inputFormatters: [
        LengthLimitingTextInputFormatter(9)
      ],
      controller: _con.celularController,
      validator: (value){
        String expresion = r'(9)(\d{8})';
        RegExp regExp = new RegExp(expresion);
        if (value == null || value.isEmpty){
          return "Campo requerido";
        }if(!(regExp.hasMatch(value))){
          return "Por favor ingrese correctamente su celular";
        }
        return null;
      },
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
          label: Text('Celular'),
          prefixIcon: Icon(
            Icons.phone_iphone,
          )
      ),
    );
  }
  Widget _textFieldni(){
    return TextFormField(
      controller: _con.dniController,
      validator: (value){
        if (value == null || value.isEmpty){
          return "Campo requerido";
        }if(value.length < 8 ){
          return "Por favor ingrese correctamente su dni";
        }
        return null;
      },
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(8),
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: const InputDecoration(
          label: Text('Dni'),
          prefixIcon: Icon(
            Icons.article_outlined,
          )
      ),
    );
  }

  Widget _textFieldSexo(){
    return DropdownButtonFormField<String>(
      value:  _con.sexo,
      validator: (value){
        if (value == null|| value == ""){
          return "Campo requerido";
        }
        return null;
      },
      hint: const Text('Sexo'),
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(15),
          prefixIcon: Icon(
              Icons.interpreter_mode_rounded
          )

      ),
      items: [
        const DropdownMenuItem(
            value: "",
            child: Text("Seleccionar sexo"
            )
        ),
        ...listsexo.map<DropdownMenuItem<String>>((e) {
          return DropdownMenuItem(
              value: e['titulo'],
              child: Text(e['titulo'])
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _con.sexo = value;
        });

      },


    );
  }

  Widget textEmail(){
    return TextFormField(
      controller: _con.correoController,
      decoration: const InputDecoration(
        labelText: 'Correo Electrónico',
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value){
        _onEmailTextChanged();
      },
      validator: (value) {
        final bool isValid = EmailValidator.validate(_con.correoController.text.trim());
        if (value == null || value.isEmpty) {
          return "Campo requerido";
        }if (isValid == false){
          return "Por favor ingrese un email valido";
        }
        return null;
      },
    );
  }
  Widget textPassword(){
    return TextFormField(
      controller: _con.passwordController,
      decoration:  InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: verContrase(),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo requerido";
        }if(value.length < 8){
          return "la contraseña debe ser maximo de 8 caracteres";
        }if(!value.contains(RegExp(r'[0-9]'))){
          return "la contraseña debe contener al menos un numero";
        }if(!value.contains(RegExp(r'[a-z]'))){
          return "la contraseña debe contener al menos una letra minuscula";
        }if(!value.contains(RegExp(r'[A-Z]'))){
          return "la contraseña debe contener al menos una letra mayuscula";
        }
        return null;
      },
    );
  }
  Widget textConfPassword(){
    return TextFormField(
      controller: _con.confiPass,
      decoration:  InputDecoration(
        labelText: 'Confirmar Contraseña',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: verContrase(),
      ),
      obscureText: _obscurePassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Campo requerido";
          }if(value != _con.passwordController.text){
            return "La contraseña no coincide";
          }
          return null;
        }
    );
  }
  Widget verContrase(){
    return IconButton(onPressed: (){
      setState(() {
        _obscurePassword = !_obscurePassword;
      });
    },
      icon: _obscurePassword ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
      color: Colors.grey,
    );
  }

  void refresh(){
    setState(() {});
  }
}
