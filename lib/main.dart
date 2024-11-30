import 'package:TallerGo/pages/home/favoritos/favoritos_page.dart';
import 'package:TallerGo/pages/home/home_page.dart';
import 'package:TallerGo/pages/login/login.dart';
import 'package:TallerGo/pages/perfil/editar_page.dart';
import 'package:TallerGo/pages/recuperacion/confirmacion/confirmacion_page.dart';
import 'package:TallerGo/pages/recuperacion/recuperacion_page.dart';
import 'package:TallerGo/pages/registro/registro_page.dart';
import 'package:TallerGo/provider/FavoritosProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => FavoritosProvider()),

    ],
    child: MyApp(),
  ),
  );
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
          'favoritos':(_)=>FavoritosPage(),
        },
    );
  }
}



