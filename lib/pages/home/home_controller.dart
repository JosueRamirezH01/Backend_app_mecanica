

import 'dart:async';
import 'dart:math';

import 'package:TallerGo/models/empresa.dart';
import 'package:TallerGo/models/user.dart';
import 'package:TallerGo/provider/empresa_provider.dart';
import 'package:TallerGo/provider/user_provider.dart';
import 'package:TallerGo/utils/my_snackbar.dart';
import 'package:TallerGo/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController{
    late BuildContext context;
    late Function refresh;
    final SharedPref _sharedPref = SharedPref();
    final UserProvider _userProvider = UserProvider();
    final EmpresaProvider _empresaProvider = EmpresaProvider();
    User? users;
    bool isBottomWidgetVisible = false;
    Position? position;
    double? promedio;
    Empresa? selectedEmpresa;
    late ProgressDialog progressDialog;
    List<Empresa> empresas = [];
    CameraPosition posicionInicial =  CameraPosition(target: LatLng(-12.0102912,-77.0108907),zoom: 14.0);
    final Completer<GoogleMapController> _mapController = Completer();
    final Set<Marker> markers = {};
    Map<String, MarkerId> empresaMarkers = {};
    bool isLoading = false;
    StreamSubscription<Position>? _positionStream;
    Future init(BuildContext context, Function refresh) async{
      this.context = context;
      this.refresh = refresh;
      await _empresaProvider.init(context);
      await _userProvider.init(context);
      users = User.fromJson(await _sharedPref.read('user'));
      checkGPS();
      await fetchEmpresas();
    }

    Future<void> openMaps() async {
      double? lat = selectedEmpresa?.latitud;
      double? lng = selectedEmpresa?.longitud;
      print(lat);
      print(lng);
      String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'No se pudo abrir Google Maps';
      }
    }

    Future<void> fetchEmpresas() async {
      try {
        // Obtener la posición actual del usuario
        position = await Geolocator.getLastKnownPosition();

        if (position != null) {
          // Obtener todas las empresas
          List<Empresa>? empresas = await _empresaProvider.getAll();

          if (empresas != null) {
            // Filtrar las empresas que están dentro del radio de 10 km
            List<Empresa> empresasCercanas = empresas.where((empresa) {
              double distancia = calcularDistancia(position!.latitude, position!.longitude, empresa.latitud!, empresa.longitud!);
              empresa.distancia = distancia;
              return distancia <= 10; // Filtrar empresas dentro del radio de 10 km
            }).toList();
            // Asignar empresas filtradas
            this.empresas = empresasCercanas;

            // Agregar marcadores solo para las empresas cercanas
            addMarkers(empresasCercanas);
          } else {
            print('No se pudo obtener la lista de empresas');
          }
        } else {
          print('No se pudo obtener la posición del usuario');
        }
      } catch (e) {
        print('Error fetching empresas: $e');
      }
    }
    double calcularDistancia(double latitudUsuario, double longitudUsuario, double latitudEmpresa, double longitudEmpresa) {
      const double radioTierra = 6371.0; // Radio de la Tierra en kilómetros

      double latitudUsuarioRad = _gradosARadianes(latitudUsuario);
      double longitudUsuarioRad = _gradosARadianes(longitudUsuario);
      double latitudEmpresaRad = _gradosARadianes(latitudEmpresa);
      double longitudEmpresaRad = _gradosARadianes(longitudEmpresa);

      double dLatitud = latitudEmpresaRad - latitudUsuarioRad;
      double dLongitud = longitudEmpresaRad - longitudUsuarioRad;

      double a = sin(dLatitud / 2) * sin(dLatitud / 2) +
          cos(latitudUsuarioRad) * cos(latitudEmpresaRad) * sin(dLongitud / 2) * sin(dLongitud / 2);
      num c = 2 * atan2(sqrt(a), sqrt(1 - a));

      return radioTierra * c;
    }
    double _gradosARadianes(double grados) {
      return grados * pi / 180.0;
    }

    void addMarkers(List<Empresa> empresas) {
      markers.clear(); // Limpiar los marcadores anteriores
      empresaMarkers.clear();
      for (var empresa in empresas) {
        print('Adding marker for: ${empresa.razon_social}');
        print('Coordinates: ${empresa.latitud}, ${empresa.longitud}');
        markers.add(
          Marker(
            markerId:MarkerId(empresa.id_empresa!), // Usar toString para el ID del marcador
            position: LatLng(empresa.latitud!, empresa.longitud!),
            onTap: () async {
              showBottomWidget(empresa); // Llama la pantalla (muetsra los datos de la empresa)
            },
            infoWindow: InfoWindow(
              title: empresa.razon_social!,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Por ejemplo, un marcador azul
          ),
        );
        empresaMarkers[empresa.razon_social!] = MarkerId(empresa.razon_social!);
      }
      print('Total markers added: ${markers.length}');
      print('Markers: $markers');
      refresh(); // Actualizar la interfaz de usuario después de agregar los marcadores
    }

    void showBottomWidget(Empresa empresa) {
      isBottomWidgetVisible = true;
      selectedEmpresa = empresa;
      refresh();
    }
    void hideBottomWidget() {
      isBottomWidgetVisible = false;
      refresh();
    }



    void onMapController(GoogleMapController controller){
      if (!_mapController.isCompleted) {
        _mapController.complete(controller);
      }
      refresh();
    }

    logout(){
      _sharedPref.logout(context, users?.id_usuario ?? '');
    }
    void goToEditar(){
      Navigator.pushNamed(context, 'perfil');
    }
    void goFavoritos(){
      Navigator.pushNamed(context, 'favoritos');
    }

    void goChat(){
      Navigator.pushNamed(context, 'chat');
    }

    void centerPosition(){
      if(position != null){
        animateCameraToPosition(position?.latitude, position?.longitude);
      }else {
        MySnackbarError.show(context, 'Activa el GPS para activar tu posicion');
      }
    }

    void updateLocation() async {
      try {

        await _determinePosition();
        position = await Geolocator.getLastKnownPosition();
        centerPosition();
        animateCameraToPosition(position?.latitude, position?.longitude);
        _positionStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                distanceFilter: 1,
                accuracy: LocationAccuracy.best
            )
        ).listen((Position position) {
          position = position;
          animateCameraToPosition(position.latitude, position.longitude);
          //fetchEmpresas();
          refresh();
        });
      } catch(e) {
        print('Error: $e');
      }
    }
    /*Future<void> centrarMapaEnMarker(MarkerId markerId) async {
      final GoogleMapController controller = await _mapController.future;

      final marker = markers.firstWhere((marker) => marker.markerId == markerId);
      final cameraUpdate = CameraUpdate.newLatLng(marker.position);
      await controller.animateCamera(cameraUpdate);
    }

    void centrarMapaEnEmpresa(String? empresaName) {
      if (empresaName != null) {
        // Suponiendo que `empresaMarkers` es un Map<String, MarkerId> que mapea los nombres de las empresas con los identificadores de los marcadores
        final markerId = empresaMarkers[empresaName];
        if (markerId != null) {
          centrarMapaEnMarker(markerId);
        } else {
          print('No se encontró ninguna empresa con el nombre $empresaName');
        }
      }
    }*/

    void checkGPS() async {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (isLocationEnabled) {
        updateLocation();
      }
      else {
        bool locationGPS = await location.Location().requestService();
        if (locationGPS) {
          updateLocation();
        }
      }
    }

    Future animateCameraToPosition(double? latitude, double? longitude) async {
      GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(latitude!, longitude!),
          zoom: 16, // Usar el valor de zoom proporcionado
        ),
      ));
      refresh();
    }

    Future<Position> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      return await Geolocator.getCurrentPosition();
    }
}