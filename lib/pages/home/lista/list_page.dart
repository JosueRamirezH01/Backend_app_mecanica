

import 'package:TallerGo/models/empresa.dart';
import 'package:TallerGo/pages/home/lista/list_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}


class _ListPageState extends State<ListPage> {
  final ListController _con = ListController();
  bool isLoading = true;
  bool _isExpanded = false;
  double _selectedOptionIndex = -1;
  late bool? _auxilioMecanico;
  String? _selectedEmpresa;
  double? _selectedCalificacion;
  @override
  void initState() {
    super.initState();
    _auxilioMecanico = null;
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Filtrar Busqueda', style: TextStyle(color: Colors.black87, fontSize: 24, fontFamily: 'Roboto')),
          actions: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
              ),
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 2), // Ajusta el espacio interno según sea necesario
              child: IconButton(
                icon: _isExpanded ? const Icon(Icons.close, color: Colors.blue, size: 30) : const Icon(Icons.search, color: Colors.blue, size: 30),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // Alternar la expansión del panel de búsqueda
                  });
                },
              ),
            ),
          ],
        ),

        body: isLoading
            ? AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Duración de la animación
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.white70.withOpacity(0.5), // Color de sombra
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // Cambia la posición de la sombra horizontalmente y verticalmente
              ),
            ],
          ),
          child: const Center(child: CircularProgressIndicator()),
        )
            : RefreshIndicator(
          onRefresh: () => _con.init(context, refresh),
             child: SingleChildScrollView( // Utiliza SingleChildScrollView para hacer que el contenido sea desplazable
               child: Column(
                children: [
                _buildSearchPanel(),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true, // Asegúrate de que la lista se ajuste a su contenido
                  physics: const NeverScrollableScrollPhysics(), // Desactiva el desplazamiento de la lista para evitar conflictos con SingleChildScrollView
                  itemCount: _con.empresas.length,
                  itemBuilder: (BuildContext context, int index) {
                    Empresa empresa = _con.empresas[index];
                    return _card(empresa);
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
  Widget _buildSearchPanel() {
    return Visibility(
      visible: _isExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                child: Text(
                  'Calificación :',
                  style: TextStyle(fontFamily: 'NimbusSans', fontSize: 18),
                ),
              ),
              Container(
                height: 50,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                constraints: const BoxConstraints(maxWidth: 220),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOptionIndex = -1;
                            });
                            _con.applyFilters(null, null);
                          },
                          child: Material( // Envuelve el Container con Material
                            elevation: 5, // Establece la elevación deseada
                            borderRadius: BorderRadius.circular(20), // Establece el radio de borde
                            color: _selectedOptionIndex == -1 ? Colors.blue : Colors.grey[300], // Establece el color del Material
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children:  [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                                    child: Icon(Icons.star, color: _selectedOptionIndex == -1 ? Colors.amber : Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Todos',
                                    style: TextStyle(fontSize: 18, fontFamily: 'NimbusSans'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (double i = 5; i >= 1; i--)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOptionIndex = i - 1;
                                _selectedEmpresa = null;
                                _selectedCalificacion = i;
                              });
                              _con.applyFilters(null, i);
                              print('Opción $i ');

                            },
                            child: Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedOptionIndex == i - 1 ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, bottom: 5),
                                      child: Icon(Icons.star, color: _selectedOptionIndex == i - 1 ? Colors.amber : Colors.white, size: 20),
                                    ), // Agrega aquí el icono que desees
                                    const SizedBox(width: 5),
                                    Text(
                                      i.toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 18, fontFamily: 'NimbusSans'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      const SizedBox(height: 5),
      Row(
        children:  [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: Text(
              'Auxlio Mecanico :',
              style: TextStyle(fontFamily: 'NimbusSans', fontSize: 18),
            ),
          ),
          Flexible(
            child: Row(
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      _auxilioMecanico = null;
                    });
                    _con.applyFilters(null, _selectedCalificacion);
                  },
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _auxilioMecanico == null ? Colors.lightGreenAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Todos',
                        style: TextStyle(fontSize: 18, fontFamily: 'NimbusSans'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      _auxilioMecanico = true;

                    });
                    _con.applyFilters(true, _selectedCalificacion);
                    print('Si');
                  },
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _auxilioMecanico == true ? Colors.lightGreenAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SI',
                        style: TextStyle(fontSize: 18, fontFamily: 'NimbusSans'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      _auxilioMecanico = false;
                    });
                    _con.applyFilters(false, _selectedCalificacion);

                    print('NO');
                  },
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _auxilioMecanico == false ? Colors.lightGreenAccent : Colors.grey[300], // Cambiar el color cuando _auxilioMecanico es false
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(fontSize: 18, fontFamily: 'NimbusSans'),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
    ]
    ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccione una empresa',
                hintText: 'Seleccione una empresa',
                prefixIcon: const Icon(Icons.business), // Icono a la izquierda del campo
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              value: _selectedEmpresa,
              items: _con.razonesSociales.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedEmpresa = value; // Actualiza la variable de control con el valor seleccionado
                  _selectedOptionIndex = -1;
                  _auxilioMecanico = null;
                });
                _con.filtersEmpresa(_selectedEmpresa);
                print('Razón social seleccionada: $_selectedEmpresa');
              },
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 240),
            child: GestureDetector(
              onTap: (){
                setState(() {
                  _auxilioMecanico = null; // Cambia todas las opciones a null
                  _selectedOptionIndex = -1;
                  _selectedEmpresa = null;
                });
                  _con.applyFilters(null, null);
                  refresh();
              },
                child: const Text('Borrar Filtros', style: TextStyle(
                  fontSize: 16,
                  color: Colors.lightBlue,
                ))
            ),
          )
        ],
      ),
    );
  }



  Widget _card(Empresa empresa) {
    double? promedio = empresa.promedio;
    double? distancia = _con.calcularDistancia(_con.position!.latitude, _con.position!.longitude, empresa.latitud!, empresa.longitud!);
    double? lat = empresa.latitud;
    double? lng = empresa.longitud;
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
                Text(
                  '${distancia.toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 5),

                GestureDetector(
                  onTap: () {
                    _con.openMaps(lat!, lng!);
                  },
                  child: const Icon(
                      Icons.location_on,
                      color: Colors.amber,
                    ),
                ),

              ],
            ),
          ],
        ),
        onTap: () {
          _con.show(empresa);
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
  void refresh() {
    setState(() {
      isLoading = true; // Cambiar isLoading a true antes de cargar los datos

    });
    _con.init(context, () {
      setState(() {
        isLoading = false; // Cambiar isLoading a false una vez que los datos se hayan cargado
      });
    });
  }


}


