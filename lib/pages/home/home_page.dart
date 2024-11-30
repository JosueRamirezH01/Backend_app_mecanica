
import 'package:TallerGo/models/empresa.dart';
import 'package:TallerGo/pages/home/chat/chat_page.dart';
import 'package:TallerGo/pages/home/home_controller.dart';
import 'package:TallerGo/pages/home/informacion/informacion_page.dart';
import 'package:TallerGo/pages/home/lista/list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;



class HomePage extends StatefulWidget {
  final Empresa? empresa;
  HomePage({Key? key, this.empresa}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _con = HomeController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _gopagina = false;
  late Widget _currentBody;
  @override
  void initState() {
    super.initState();
    _currentBody = _googleMaps();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      // if (widget.empresa != null) {
      //   _con.centrarMapaEnEmpresa(widget.empresa?.razon_social);
      //   print('EMPRESA DIRECCIONADA ${widget.empresa?.id_empresa}');
      // }
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 255),
        elevation: 1,
        toolbarHeight: 150,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 10, bottom: 20),
          icon: Image.asset(
            'assets/img/usuario_icon.png',
            width: 50, // Ajusta el tamaño del icono de usuario
            height: 50,
            fit: BoxFit.cover,
            color: const Color.fromARGB(255, 153, 163, 164 ), // Color del icono de usuario
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      'Servicios Mecanicos',
                      style: TextStyle(fontSize: 24, fontFamily: 'NimbusSans', fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Text('Biker', style: TextStyle(fontSize: 22, fontFamily: 'NimbusSans', fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 10),
                  Text(
                    'Talleres Mecanicos',
                    style: TextStyle(fontSize: 18, fontFamily: 'NinbusSans', color: Colors.white),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color.fromARGB(255, 253, 216, 53),
              child: ClipOval(
                child: Image.asset(
                  'assets/img/icon_service.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  color: const Color.fromARGB(255, 3, 155, 229),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: _drawer(),
      body:  Stack(
        children: [
          _googleMaps(),
          if(_gopagina)
            _currentBody,
          _buildBottomWidget(),

        ],
      ),
      floatingActionButton: _buildBottomButtonWidget(), // Aquí es donde debes llamar a _buildBottomButtonWidget
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.only(top: 5, left: 10), // Ajuste de espaciado
            decoration: BoxDecoration(

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _con.users?.nombre ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                Text(
                  '${_con.users?.email ?? ''} ',
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                Text(
                  '${_con.users?.celular ?? ''} ',
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                const SizedBox(height: 8), // Ajuste de espacio
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: _con.users?.image != null
                          ? Image.network(
                        _con.users!.image!, // Asumiendo que _con.users?.image es una URL de imagen remota
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        'assets/img/usuario_icon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Editar perfil', style: TextStyle(fontSize: 16, fontFamily: 'NimbusSans')),
            trailing: const Icon(Icons.edit, size: 30),
            onTap: _con.goToEditar,
          ),
          ListTile(
            title: const Text('Mis Favoritos',style: TextStyle(fontSize: 16, fontFamily: 'NimbusSans')),
            trailing: Image.asset('assets/img/icon_heart.png',height: 30,width: 30,),
            onTap: _con.goFavoritos,
          ),
          ListTile(
            title: const Text('Cerrar sesion', style: TextStyle(fontFamily: 'NimbusSans', fontSize: 16)),
            trailing: const Icon(Icons.power_settings_new, size: 30),
            onTap: _con.logout,
          ),
        ],
      ),
    );
  }


  Widget _googleMaps(){
    return _con.position != null ?  maps.GoogleMap(
      mapType: maps.MapType.normal,
      initialCameraPosition: _con.posicionInicial,
      onMapCreated: _con.onMapController,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: Set<maps.Marker>.from(_con.markers),
      onTap: (maps.LatLng latLng) {
        _con.hideBottomWidget(); // Cambia esto para mostrar el widget
      },
    ):Center(
      child: CircularProgressIndicator(),
    )
    ;
  }


  Widget _mostrarDatos() {
    double? promedio = _con.selectedEmpresa?.promedio;
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinear el texto a la izquierda
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           Center(
              child: ClipOval(
                  child: Image.asset('assets/img/taller_mecanico.png'),
              ),
            ),
          const SizedBox(width: 10), // Separación entre los textos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _mostrarRazonSocial(),
              const SizedBox(height: 2),
              _calificacion(promedio!),
              const SizedBox(height: 2),
              _mostrarKm(),
              const SizedBox(height: 2),
              _mostrarAuxilio()
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _infoWindow(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: Center(
                  child: GestureDetector(
                    onTap: _con.openMaps,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow,
                      ),
                      child: Image.asset('assets/img/moto.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _mostrarRazonSocial(){
    return Text(
      _con.selectedEmpresa?.razon_social ?? 'No se ha seleccionado ninguna empresa',
      style: const TextStyle(
        fontSize: 18,
        fontFamily: 'NimbusSans'
      ),
    );
  }

  Widget _mostrarAuxilio(){
    return Row(
      children: [
        const Text('Auxilio Mecanico:', style: TextStyle(
            fontSize: 18,
            fontFamily: 'NimbusSans'
        ),
        ),
        const SizedBox(width: 5),
         Text(_con.selectedEmpresa?.auxilio_mecanico == true ? 'SI' : 'NO',
          style: const TextStyle(
              fontSize: 18,
              fontFamily: 'NimbusSans'
          ),
        )
      ],
    );
  }

  Widget _mostrarKm() {
    String distancia = (_con.selectedEmpresa?.distancia ?? 0).toStringAsFixed(2);
    return Text(
      '$distancia km',
      style: const TextStyle(
          fontSize: 16,
          fontFamily: 'NimbusSans'
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


  Widget _buildBottomButtonWidget() {
    return Stack(
      children: [
           AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _con.isBottomWidgetVisible ? 200 : 70,
              right: 40,
             child: GestureDetector(
               onTap: (){
                 showModalBottomSheet(
                   context: context,
                   isScrollControlled: true,
                   builder: (BuildContext context) {
                     return SingleChildScrollView(
                       child: Container(
                         height: MediaQuery.of(context).size.height * 0.8,
                         child: ChatPage(),
                       ),
                     );
                   },
                 );
               },
                child: Material(
                    elevation: 10,
                    shape: CircleBorder(),
                    color: Colors.transparent,
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset('assets/img/message.png',width: 70,height: 70, color: Color.fromARGB(255, 3, 169, 244 ),))
             ),
             ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _con.isBottomWidgetVisible ? 160 : 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_gopagina) {
                      _currentBody = _googleMaps();
                      _gopagina = false;
                    } else {
                      _currentBody = const ListPage();
                      _gopagina = true;
                      _con.hideBottomWidget();
                    }
                    refresh();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 255),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  elevation: 2,
                ),
                icon: _gopagina ? const Icon(
                  Icons.map,
                  size: 24,
                  color: Colors.white,
                ) : const Icon(
                  Icons.list,
                  size: 24,
                  color: Colors.white,
                ),
                label: Text(
                  _gopagina ? 'Mapa' : 'Listar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
    );
  }

  Widget _buildBottomWidget() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: InformacionPage(empresa: _con.selectedEmpresa),
            ),
          );
        },
      ),
      child: Stack(
        children: [
          if (_con.isBottomWidgetVisible)
            Positioned(
              bottom: 15,
              left: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: _mostrarDatos(),
              ),
            ),
        ],
      ),
    );
  }


  Widget _infoWindow() {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      decoration: ShapeDecoration(
        color: Colors.blue,
        shape: const _InfoWindowShape(), // Usa la forma personalizada _InfoWindowShape
        shadows: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              'Iniciar ruta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white
              ),
            ),
          ),
    );
  }

  void refresh() {
    setState(() {});
  }
}

class _InfoWindowShape extends ShapeBorder {
  const _InfoWindowShape();

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const double radius = 10.0;
    final path = Path()
      ..moveTo(rect.left + radius , rect.top) // Comienza en la esquina superior izquierda del rectángulo
      ..lineTo(rect.right - radius, rect.top ) // Línea superior del rectángulo
      ..arcToPoint(Offset(rect.right, rect.top + radius), radius: const Radius.circular(radius)) // Esquina superior derecha redondeada
      ..lineTo(rect.right, rect.bottom - radius) // Línea derecha del rectángulo con un pequeño desplazamiento hacia arriba para la "cola"
      ..arcToPoint(Offset(rect.right - radius, rect.bottom), radius: const Radius.circular(radius)) // Esquina inferior derecha redondeada
      ..lineTo(rect.center.dx + 5, rect.bottom) // Línea derecha de la "cola"
      ..lineTo(rect.center.dx, rect.bottom + 10) // Punto de unión entre la "cola" y el rectángulo principal
      ..lineTo(rect.center.dx - 5, rect.bottom) // Línea izquierda de la "cola"
      ..lineTo(rect.left + radius, rect.bottom) // Línea izquierda del rectángulo con un pequeño desplazamiento hacia arriba para la "cola"
      ..arcToPoint(Offset(rect.left, rect.bottom - radius), radius: const Radius.circular(radius)) // Esquina inferior izquierda redondeada
      ..lineTo(rect.left, rect.top + radius) // Línea izquierda del rectángulo sin el borde redondeado
      ..arcToPoint(Offset(rect.left + radius, rect.top), radius: const Radius.circular(radius)) // Esquina superior izquierda redondeada
      ..close(); // Cierra el contorno

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}



