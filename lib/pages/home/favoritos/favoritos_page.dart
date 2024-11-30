import 'package:TallerGo/models/empresa.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:TallerGo/provider/FavoritosProvider.dart';

import '../informacion/informacion_page.dart';



class FavoritosPage extends StatefulWidget {
  const FavoritosPage({Key? key}) : super(key: key);

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}


class _FavoritosPageState extends State<FavoritosPage> {
  late  FavoritosProvider favoritosProvider;

  @override
  Widget build(BuildContext context) {
    // Obtener la instancia de FavoritosProvider
    final favoritosProvider = Provider.of<FavoritosProvider>(context);

    // Obtener la lista de favoritos
    final listaFavoritos = favoritosProvider.listaFavoritos;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Favoritos', style: TextStyle(color: Colors.white)),
        backgroundColor:  const Color.fromARGB(255, 0, 0, 255),
        elevation: 1,
      ),
      body: listaFavoritos.isEmpty
          ? Center(
        child: Text('No hay favoritos'),
      )
          : ListView.builder(
        itemCount: listaFavoritos.length,
        itemBuilder: (context, index) {
          final empresa = listaFavoritos[index];
          return _card(empresa);
        },
      ),
    );
  }

  Widget _card(Empresa empresa) {
    favoritosProvider = Provider.of<FavoritosProvider>(context, listen: false);
    double? promedio = empresa.promedio;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundImage: CachedNetworkImageProvider(empresa.imagen ?? ''),
          ),
        ),
        title: Text(
          empresa.razon_social ?? 'Nombre no disponible',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  _calificacion(promedio!),
                  const SizedBox(height: 3),
                  Text(
                    'Auxilio Mecanico: ${empresa.auxilio_mecanico == true ? 'SI' : 'NO'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Teléfono: ${empresa.celular ?? 'No disponible'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      favoritosProvider.eliminarFavorito(empresa);

                      print('Eliminar');
                    },
                    child:  Image.asset(
                      'assets/img/basura.png'
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
        onTap: () {

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => InformacionPage(empresa: empresa),
          ));
          print('DIRECCIONANDO AL MAPA');
          },
      ),
    );
  }
  Widget _calificacion(double promedio){
    return RatingBar.builder(
      initialRating: promedio,
      itemCount: 5,
      itemSize: 15,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      ignoreGestures: true,
      onRatingUpdate: (double value) {  }, // Modo de solo lectura
    );
  }

  void refresh(){
    setState(() {});
  }
}



