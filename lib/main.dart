import 'package:app_mecanica/models/empresa.dart';
import 'package:app_mecanica/pages/home/home_page.dart';
import 'package:app_mecanica/pages/login/login.dart';
import 'package:app_mecanica/pages/perfil/editar_page.dart';
import 'package:app_mecanica/pages/recuperacion/confirmacion/confirmacion_page.dart';
import 'package:app_mecanica/pages/recuperacion/recuperacion_page.dart';
import 'package:app_mecanica/pages/registro/registro_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: 'login',
      routes: {
        'login': (_) => LoginPage(),
        'registro':(_)=>  RegistroPage(),
        'recuperacion':(_) => RecuperacionPage(),
        'home':(_) => HomePage(),
        'recuperacion/confirmacion': (_) => ConfirmacionPage(),
        'perfil':(_) => EditarPerfil(),
      },
    );
  }
}



