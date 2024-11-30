import 'package:TallerGo/pages/recuperacion/confirmacion/confirmacion_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ConfirmacionPage extends StatefulWidget {
  const ConfirmacionPage({Key? key}) : super(key: key);

  @override
  State<ConfirmacionPage> createState() => _ConfirmacionPageState();
}

class _ConfirmacionPageState extends State<ConfirmacionPage> {
  final ConfirmacionController _con = ConfirmacionController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 73, 94),
        title: Text(
          'Servicios Mecanicos Biker',
          style: TextStyle(fontSize: 24, fontFamily: 'NimbusSans'),
        ),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _con.email != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'CONFIRMAMOS TU CAMBIO DE CONTRASEÑA',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'NimbusSans',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Si ${_con.email} es un correo válido creado para estar asociado con SERVICE BIKER, le habrá llegado a su correo electrónico una contraseña para iniciar sesión.',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'NimbusSans',
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
            : Text(
          'Email no inicializado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
