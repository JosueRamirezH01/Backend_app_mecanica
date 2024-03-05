

import 'dart:async';
import 'dart:math';

import 'package:app_mecanica/models/empresa.dart';
import 'package:app_mecanica/models/user.dart';
import 'package:app_mecanica/provider/empresa_provider.dart';
import 'package:app_mecanica/provider/user_provider.dart';
import 'package:app_mecanica/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController{
    late BuildContext context;
    late Function refresh;
    final SharedPref _sharedPref = SharedPref();
    final UserProvider _userProvider = UserProvider();
    final EmpresaProvider _empresaProvider = EmpresaProvider();
    User? users;
    bool isBottomWidgetVisible = false;
    Position? _position;
    double? promedio;
    Empresa? selectedEmpresa;
    List<Empresa> empresas = [];
    CameraPosition posicionInicial = const CameraPosition(target: LatLng(-12.0962912,-77.0218907),zoom: 14.0);
    final Completer<GoogleMapController> _mapController = Completer();
    final Set<Marker> markers = {};
    bool isLoading = false;
    Future init(BuildContext context, Function refresh) async{
      this.context = context;
      this.refresh = refresh;
      await _empresaProvider.init(context);
      await _userProvider.init(context);
      users = User.fromJson(await _sharedPref.read('user'));
      checkGPS();
      await fetchEmpresas();
      refresh();
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
        _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        if (_position != null) {
          // Obtener todas las empresas
          List<Empresa>? empresas = await _empresaProvider.getAll();

          if (empresas != null) {
            // Filtrar las empresas que están dentro del radio de 10 km
            List<Empresa> empresasCercanas = empresas.where((empresa) {
              double distancia = calcularDistancia(_position!.latitude, _position!.longitude, empresa.latitud!, empresa.longitud!);
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
    }

    logout(){
      _sharedPref.logout(context, users?.id_usuario ?? '');
    }
    void goToEditar(){
      Navigator.pushNamed(context, 'perfil');
    }

    Future<void> updateLocation() async {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      animateCameraToPosition(_position?.latitude, _position?.longitude);
    }

    void checkGPS() async {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (isLocationEnabled) {
        print('GPS ACTIVADO');
        updateLocation();
      }
      else {
        print('GPS DESACTIVADO');
        bool locationGPS = await location.Location().requestService();
        if (locationGPS) {
          updateLocation();
          print('ACTIVO EL GPS');
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
    }

    Future<Position> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
    }
}