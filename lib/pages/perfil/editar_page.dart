import 'package:TallerGo/pages/perfil/editar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({Key? key}) : super(key: key);

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final EditarController _con = EditarController();
  FocusNode? myFocusNode;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, formKey);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ACTUALIZAR DATOS',style: TextStyle(fontSize: 20, fontFamily: 'NimbusSans', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  _imagen(),
                  const SizedBox(height: 20),
                  _emailText(),
                  const SizedBox(height: 20),
                  _dniText(),
                  const SizedBox(height: 20),
                  _nombreText(),
                  const SizedBox(height: 20),
                  _celularText(),
                  const SizedBox(height: 10),
                  _switch(),
                  const SizedBox(height: 10),
                  _contraText(),
                  const SizedBox(height: 20),
                  _contraConfText(),
                  const SizedBox(height: 20),
                  _actualizarBoton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _imagen(){
    return GestureDetector(
      onTap: !_con.switchValue ? _con.showAlertDialog : null,
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 70,
        child: ClipOval(
          child: _con.imagenfile != null
              ? Image.file(
            _con.imagenfile!,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          )
              : _con.user?.image != null && Uri.parse(_con.user!.image!).isAbsolute
              ? Image.network(
            _con.user!.image!,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          )
              : Image.asset(
            'assets/img/usuario_icon.png', // Puedes reemplazar esto con la ruta de tu imagen de marcador de posición
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  Widget _emailText() {
    return Container(
      padding: const EdgeInsets.only(left: 25,right: 25),
      child: TextFormField(
        enabled: false,
        controller: _con.emailController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined, color: Colors.amber),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          labelStyle: TextStyle(color: Colors.amber),

        ),
      ),
    );
  }
  Widget _dniText() {
    return Container(
      padding: const EdgeInsets.only(left: 25,right: 25),
      child: TextFormField(
        enabled: !_con.switchValue,
        keyboardType: TextInputType.phone,
        controller: _con.dniController,
        inputFormatters: [
          LengthLimitingTextInputFormatter(8),
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Dni',
          prefixIcon: Icon(Icons.credit_card_outlined, color: !_con.switchValue ? Colors.blue : Colors.amber),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          labelStyle: TextStyle(
            color: !_con.switchValue ? Colors.blue : Colors.amber, // Color del texto de la etiqueta
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'El campo está vacío';
          } else if (value.length < 8) {
            return 'Ingrese correctamente su dni';
          }
          return null;
        },
      ),
    );
  }

  Widget _celularText() {
    return Container(
      padding: const EdgeInsets.only(left: 25,right: 25),
      child: TextFormField(
        enabled: ! _con.switchValue,
        keyboardType: TextInputType.phone,
        controller: _con.celularController,
        inputFormatters: [
          LengthLimitingTextInputFormatter(9),
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), // Expresión regular para permitir solo letras.
        ],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Celular',
            prefixIcon: Icon(Icons.phone_android_outlined, color: !_con.switchValue ? Colors.blue : Colors.amber,
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1.5),
            ),
            labelStyle: TextStyle(
              color: !_con.switchValue ? Colors.blue : Colors.amber, // Color del texto de la etiqueta
            ),
          ),
          validator: (value) {
            String expresion = r'(9)(\d{8})';
            RegExp regExp = new RegExp(expresion);
            if(value!.isEmpty){
              return 'Por favor ingrese su celular';
            }else if(!(regExp.hasMatch(value))){
              return 'Por favor ingrese correctamente su celular';
            }
            return null;
          }
      ),
    );
  }

  Widget _nombreText() {
    return Container(
      padding: const EdgeInsets.only(left: 25,right: 25),
      child: TextFormField(
        enabled: ! _con.switchValue,
        controller: _con.nombreController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Nombre',
          prefixIcon: Icon(Icons.person_outline,
          color: !_con.switchValue ? Colors.blue : Colors.amber),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          labelStyle: TextStyle(
            color: !_con.switchValue ? Colors.blue : Colors.amber, // Color del texto de la etiqueta
          ),
        ),
        validator: (value){
          if(value!.isEmpty){
            return 'Ingrese su nombre';
          }
          return null;
        },
      ),
    );
  }

  Widget _actualizarBoton(){
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 0, 0, 255 )),
          padding: MaterialStatePropertyAll(EdgeInsets.only(right: 50, left: 50, top: 10,bottom: 10)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))))

        ),
          onPressed: () {
          _con.update();
          },
          child: const Text('Actualizar',style: TextStyle(fontSize: 20, color: Colors.white))),
    );
  }

  Widget _switch(){
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          const Text('Habilita para cambiar tu contraseña', style: TextStyle(
            fontSize: 16,
            fontFamily: 'NimbusSans',
            color: Colors.blue
          )),
          const SizedBox(width: 5),
          Switch(
              value: _con.switchValue,
              onChanged: (value) {
                setState(() {
                  _con.switchValue = value;
                  if (!value) {
                    _con.contraController.clear();
                    _con.contraConfController.clear();
                    _con.formKey.currentState?.reset();
                    _obscurePassword = true;
                  }
                });
              },
          ),
        ],
      ),
    );
  }

  Widget _contraText() {
    return Container(
      padding: const EdgeInsets.only(left: 25,right: 25),
      child: TextFormField(
        controller: _con.contraController,
        enabled: _con.switchValue,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: verContrase(),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1.5),
            ),
            labelStyle: TextStyle(
              color: !_con.switchValue ? Colors.blue : Colors.grey, // Color del texto de la etiqueta
            ),
          ),
        validator: (value) {
          if (_con.switchValue) {
            if (value!.length < 8) {
              return 'Las contraseñas tienen que tener más de 8 caracteres';
            }
          }
          return null;
        }
      ),
    );
  }
  Widget _contraConfText() {
    return Container(
      padding: const EdgeInsets.only(left: 25,right: 25),
      child: TextFormField(
        controller: _con.contraConfController,
        enabled: _con.switchValue,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Confirmar Contraseña',
          prefixIcon: Icon(Icons.lock_outline),
          suffixIcon: verContrase(),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          labelStyle: TextStyle(
            color: !_con.switchValue ? Colors.blue : Colors.grey, // Color del texto de la etiqueta
          ),
        ),
        validator: (value){
          if (_con.switchValue) {
            if (value != _con.contraController.text) {
              return 'Las contraseñas no coinciden';
            }
          }
          return null;
        },
      ),
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
  void refresh() {
    setState(() {});
  }
}
