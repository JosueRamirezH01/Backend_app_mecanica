import 'package:TallerGo/models/empresa.dart';
import 'package:TallerGo/pages/home/informacion/informacion_page.dart';
import 'package:TallerGo/provider/empresa_provider.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ListController {
  late BuildContext context;
  late Function refresh;
  final EmpresaProvider _empresaProvider = EmpresaProvider();
  List<Empresa> empresas = [];
  Position? position;
  List<String> razonesSociales = [];
  List<Empresa> _originalEmpresas = [];
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    await fetchEmpresas();
    _originalEmpresas = List.from(empresas);
    refresh();
  }

  void filtersEmpresa(String? selectedEmpresa) {
    if (selectedEmpresa != null) {
      // Filtrar la lista original de empresas en base a la empresa seleccionada
      List<Empresa> filteredList = _originalEmpresas.where((empresa) => empresa.razon_social == selectedEmpresa).toList();
      // Actualizar la lista de empresas con la lista filtrada
      empresas = List.from(filteredList);
    } else {
      // Si no se ha seleccionado ninguna empresa, restaurar la lista completa de empresas
      empresas = List.from(_originalEmpresas);
    }
    // Actualizar la interfaz de usuario
    refresh();
  }

  void applyFilters(bool? auxilioMecanico, double? selectedOptionIndex) {
    if (empresas.isEmpty) {
      print('La lista de empresas está vacía. No se pueden aplicar filtros.');
      return;
    }

    // Inicializa la lista filtrada con todas las empresas originales
    List<Empresa> filteredList = List.from(_originalEmpresas);

    // Aplica los filtros acumulativos
    if (auxilioMecanico != null) {
      filteredList = filteredList.where((empresa) => empresa.auxilio_mecanico == auxilioMecanico).toList();
    }
    if (selectedOptionIndex != null && selectedOptionIndex != -1.0) {
      filteredList = filteredList.where((empresa) => empresa.promedio == selectedOptionIndex).toList();
    }

    // Actualiza la lista de empresas con la lista filtrada
    empresas = filteredList;

    // Actualiza la interfaz de usuario
    refresh();
  }


  Future<void> openMaps(double latitud, double longitud) async {
    // Obtener la posición actual del usuario
    Position? currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Validar si la posición actual se obtuvo correctamente
    if (currentPosition != null) {
      // Obtener la latitud y longitud de la posición actual del usuario
      double currentLat = currentPosition.latitude;
      double currentLng = currentPosition.longitude;

      // Construir la URL de Google Maps para la navegación desde la posición actual del usuario hasta la ubicación de la empresa
      String googleUrl = 'https://www.google.com/maps/dir/?api=1&origin=$currentLat,$currentLng&destination=$latitud,$longitud';

      // Verificar si es posible abrir la URL en Google Maps
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl); // Abrir Google Maps
      } else {
        throw 'No se pudo abrir Google Maps';
      }
    } else {
      throw 'No se pudo obtener la posición actual del usuario';
    }
  }

  Future<void> fetchEmpresas() async {
    try {
      // Obtener la posición actual del usuario
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (position != null) {
        // Filtrar las empresas dentro del radio de 10 km
        double radioKm = 5;
        double latitudUsuario = position!.latitude;
        double longitudUsuario = position!.longitude;

        // Obtener todas las empresas
        List<Empresa>? todasLasEmpresas = await _empresaProvider.getAll();

        if (todasLasEmpresas != null) {
          empresas = filtrarEmpresasCercanas(todasLasEmpresas, latitudUsuario, longitudUsuario, radioKm);

          razonesSociales = empresas.map((empresa) => empresa.razon_social ?? '').toList();

          // Ordenar las empresas por distancia de menor a mayor
          empresas.sort((a, b) {
            double distanciaA = calcularDistancia(latitudUsuario, longitudUsuario, a.latitud!, a.longitud!);
            double distanciaB = calcularDistancia(latitudUsuario, longitudUsuario, b.latitud!, b.longitud!);
            return distanciaA.compareTo(distanciaB);
          });

          // Imprimir la lista de empresas ordenadas
          for (Empresa empresa in empresas) {
            print('Empresa: ${empresa.razon_social}');
            print('Distancia: ${calcularDistancia(latitudUsuario, longitudUsuario, empresa.latitud!, empresa.longitud!)} km');
          }
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

  List<Empresa> filtrarEmpresasCercanas(List<Empresa> todasLasEmpresas, double latitudUsuario, double longitudUsuario, double radioKm) {
    List<Empresa> empresasCercanas = [];
    for (Empresa empresa in todasLasEmpresas) {
      double distancia = calcularDistancia(latitudUsuario, longitudUsuario, empresa.latitud!, empresa.longitud!);
      if (distancia <= radioKm) {
        empresasCercanas.add(empresa);
      }
    }
    return empresasCercanas;
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
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * pi / 180.0;
  }
  void show(Empresa empresa){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: InformacionPage(empresa: empresa),
          ),
        );
      },
    );
  }
}

