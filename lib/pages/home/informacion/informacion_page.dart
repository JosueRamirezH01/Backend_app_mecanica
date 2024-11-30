
import 'package:TallerGo/models/empresa.dart';
import 'package:TallerGo/pages/home/informacion/informacion_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../provider/FavoritosProvider.dart';



class InformacionPage extends StatefulWidget {
  final Empresa? empresa;
  InformacionPage({Key? key, this.empresa}) : super(key: key);

  @override
  State<InformacionPage> createState() => _InformacionPageState();
}


class _InformacionPageState extends State<InformacionPage> {
  final InformacionController _con = InformacionController();

  late final Empresa? empresaF;
  bool _isCalificacionExpanded = false;
  bool _isEmpresaInfoExpanded = false;
  bool _isTiendaVirtualExpanded = false;
  late String? direccion = '' ;
  late  FavoritosProvider favoritosProvider;
  @override
  void initState() {
    super.initState();
    empresaF = widget.empresa ?? Empresa();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      obtenerDireccion();
    });
  }

  Future<String?> obtenerDireccion() async {
    double? latitud = empresaF?.latitud;
    double? longitud = empresaF?.longitud;
    List<Placemark> placemarks = await placemarkFromCoordinates(
        latitud!, longitud!);
    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark lugar = placemarks[0];
      direccion = lugar.street ?? 'Dirección no encontrada';
      return direccion;
    }
  }
  @override
  Widget build(BuildContext context) {
    favoritosProvider = Provider.of<FavoritosProvider>(context, listen: false);
    final listaFavoritos = favoritosProvider.listaFavoritos;
    bool isPresent = listaFavoritos.any((empresa) => empresa.id_empresa == empresaF?.id_empresa);

    return Scaffold(
        appBar: AppBar(
          backgroundColor:  const Color.fromARGB(255, 0, 0, 255),
          elevation: 1,
          toolbarHeight: 150,
          leading: IconButton(
            padding:  const EdgeInsets.only(left: 10, bottom: 20),
            icon: Image.asset(
              'assets/img/atras.png',
              width: 50,
              height: 50,
              color: Colors.amber,
              fit: BoxFit.cover,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                     const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: const Text(
                        'Servicios Mecanicos',
                        style: TextStyle(fontSize: 24, fontFamily: 'NimbusSans', fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('Biker', style: TextStyle(fontSize: 22, fontFamily: 'NimbusSans', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // Accede a las propiedades de empresa a través de widget.empresa
                    Text(
                      empresaF?.razon_social ?? 'Sin empresa seleccionada',
                      style: const TextStyle(fontSize: 18, fontFamily: 'NimbusSans'),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor:  const Color.fromARGB(255, 253, 216, 53),
                child: ClipOval(
                  child: Image.asset(
                    'assets/img/icon_service.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    color:  const Color.fromARGB(255, 3, 155, 229),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen de fondo
                      Image.network(
                        empresaF?.imagen ?? '',
                        fit: BoxFit.cover,
                      ),
                      // Icono encima de la imagen
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isPresent = !isPresent;
                              if (isPresent) {
                                favoritosProvider.agregarFavorito(empresaF!);
                                print('isPresent $isPresent');
                              } else {
                                favoritosProvider.eliminarFavorito(empresaF!);
                              }
                            });
                          },
                          icon: isPresent
                              ? Image.asset('assets/img/corazon.png', width: 30, height: 30)
                              : Image.asset('assets/img/healt.png', width: 30, height: 30),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCalificacionExpansionPanel(),
                const SizedBox(height: 20),
                _buildEmpresaInfoExpansionPanel(),
                const SizedBox(height: 20),
                _buildTiendaVirtual(),
                FittedBox(
                    fit: BoxFit.fitWidth,
                    child: _linkFaccebook()),
                const SizedBox(height: 20),
              ],
            ),
          ),

             Positioned(
                bottom: 10,
                right: 20,
                child: _buildFloatingButtons(),
              ),

      ]
        ),

    );
  }

  Widget _buildFloatingButtons() {
    return SizedBox(
      child: Row(
        children: [
          SizedBox(
            width: 150, // Ancho del botón
            child: ElevatedButton(
              onPressed: _openMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255,0, 0, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Radio de los bordes
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions),
                  SizedBox(width: 5), // Espacio entre el icono y el texto
                  Text('Ir a Ruta',style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          SizedBox(width: 10), // Espacio entre botones
          SizedBox(
            width: 150, // Ancho del botón
            child: ElevatedButton(
              onPressed: () {
                _con.showMyDialog(context, empresaF?.id_empresa);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255,0, 0, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Radio de los bordes
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star),
                  SizedBox(width: 5), // Espacio entre el icono y el texto
                  Text('Calificar', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkFaccebook(){
    return Padding(
        padding: EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Text('FACCEBOOK', style: TextStyle(color: Color.fromARGB(255, 0, 0, 255), fontSize: 28, fontFamily: 'NimbusSans', fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: _launchURLFacce,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                  child: Image.asset('assets/img/facebook.png', color: Colors.grey,)
              ),
            )
          ],
        ),
    );
  }

  Widget _buildCalificacionExpansionPanel() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCalificacionExpanded = !_isCalificacionExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                leading: Image.asset('assets/img/estrella.png', width: 50, height: 50,color: Colors.amber),
                title: const Text(
                  'Calificaciónes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Revisa su calificacion',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NimbusSans'
                  ),
                ),
              );
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Center(
                      child: Text('Calificacion Total', style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 16
                      ),)
                  ),
                  subtitle: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Center(child: Text(
                             '${empresaF?.promedio}'
                         )
                        ),
                        Center(child: _calificacion())
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isExpanded: _isCalificacionExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildTiendaVirtual() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTiendaVirtualExpanded = !_isTiendaVirtualExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                leading: Image.asset('assets/img/tienda.png', width: 50, height: 50,color: Colors.amber),
                title: const Text(
                  'Tienda Virtual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Link Tienda Virtual',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NimbusSans'
                  ),
                ),
              );
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title:  Center(
                      child: Text('Bienvenido ${empresaF?.razon_social}', style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 16
                      ),)
                  ),
                  subtitle: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: Text('Tienda Virtual')),
                        Center(child: _linkTiendaVirtual())
                      ],
                    ),
                  ),
                ),
                // Agrega más información sobre la calificación si es necesario
              ],
            ),
            isExpanded: _isTiendaVirtualExpanded,
          ),
        ],
      ),
    );
  }

  Widget _linkTiendaVirtual(){
    return GestureDetector(
      onTap: _launchURLTienda,
        child: Text(empresaF?.url_tienda ?? 'No disponible', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 129, 212, 250)))
    );
  }
  Widget _buildEmpresaInfoExpansionPanel() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEmpresaInfoExpanded = !_isEmpresaInfoExpanded;
        });
      },
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                leading: Icon(Icons.info,size: 50, color: Colors.amber),
                title: Text(
                  'Información ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Conoce mas de la empresa',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NimbusSans'
                  ),
                )
              );
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                ListTile(
                  title: Text('Descripcion'),
                  leading: Icon(Icons.description, color: Colors.blueAccent,),
                  subtitle: Text(empresaF?.razon_social ?? '', style: TextStyle(fontFamily: 'NimbusSans')),
                ),
                ListTile(
                  title: Text('Cuenta con'),
                  leading: Icon(Icons.auto_awesome_mosaic, color: Colors.blueAccent,),
                  subtitle: Text('${empresaF?.taller_mecanico == true ? 'taller mecanico' : ''}'
                      '${empresaF?.taller_mecanico == true && empresaF?.tienda_fisica == true ? ' y ' : ''}'
                      '${empresaF?.tienda_fisica == true ? 'Tienda Fisica' : ''}',
                      style: TextStyle(fontFamily: 'NimbusSans')),
                ),
                ListTile(
                  title: Text('Horario de atención'),
                  leading: Icon(Icons.alarm, color: Colors.blueAccent,),
                  subtitle: Text('Lunes a Viernes: ${empresaF?.hora_atencion_lv}\nSábado: ${empresaF?.hora_atencion_s ?? 'No hay atencion'}\nDomingo: ${empresaF?.hora_atencion_d ?? 'No hay atencion'}', style: TextStyle(fontFamily: 'NimbusSans')),
                ),
                ListTile(
                  title: Text('Ubicación'),
                  leading: Icon(Icons.location_on, color: Colors.blueAccent,),
                  subtitle: Text( direccion!, style: TextStyle(fontFamily: 'NimbusSans')),
                ),
                ListTile(
                  title: Text('Telefono'),
                  leading: Icon(Icons.call, color: Colors.blueAccent,),
                  subtitle: Row(
                    children: [
                      Text('${empresaF?.celular}', style: TextStyle(fontFamily: 'NimbusSans')),
                      GestureDetector(
                        onTap: _makePhoneCall,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 45, bottom: 15),
                          child: Row(
                            children: [
                              Icon(Icons.call, color: Colors.green),
                              Text('LLAMAR', style: TextStyle(fontSize: 20, color: Colors.green)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            isExpanded: _isEmpresaInfoExpanded,
          ),
        ],
      ),
    );
  }

  Widget _calificacion(){
    double? promedio = empresaF?.promedio;
    return RatingBar.builder(
      initialRating: promedio!,
      itemCount: 5,
      itemSize: 15,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.blueAccent,
      ),
      ignoreGestures: true,
      onRatingUpdate: (double value) {  }, // Modo de solo lectura
    );
  }

  void refresh() {
    setState(() {});
  }
  Future<void> _launchURLTienda() async {
    String? url = empresaF?.url_tienda;
    if (await canLaunch(url!)) {
      print('Url $url');
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }
  Future<void> _launchURLFacce() async {
    String? url = empresaF?.url_faccebook;
    if (await canLaunch(url!)) {
      print('Url $url');
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }
  Future<void> _makePhoneCall() async {
    String? phoneNumber = empresaF?.celular;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
  Future<void> _openMaps() async {
    double? lat = empresaF?.latitud;
    double? lng = empresaF?.longitud;
    String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  }
}
