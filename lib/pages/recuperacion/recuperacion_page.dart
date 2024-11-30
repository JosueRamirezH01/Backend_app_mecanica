import 'package:TallerGo/pages/recuperacion/recuperacion_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RecuperacionPage extends StatefulWidget {
  const RecuperacionPage({Key? key}) : super(key: key);

  @override
  State<RecuperacionPage> createState() => _RecuperacionPageState();
}

class _RecuperacionPageState extends State<RecuperacionPage> {
  final RecuperacionController _con = RecuperacionController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 52, 73, 94),
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: const Text(
            'Recuperación de Contraseña ',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Roboto'
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ingresa tu correo electrónico para recuperar la contraseña.',
              style: TextStyle(fontSize: 20 , fontFamily: 'Pacifico' , color:Colors.lightBlue),
              textAlign: TextAlign.center,

            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _con.emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _con.forgotPassoword();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text(
                  'Enviar Solicitud',
                  style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Pacifico'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void refresh(){
    setState(() {});
  }
}
