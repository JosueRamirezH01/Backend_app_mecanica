import 'dart:convert';

import 'package:TallerGo/models/empresa.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosProvider extends ChangeNotifier {
  late List<Empresa> _listaFavoritos;
  final String _prefsKey = 'favoritos';

  FavoritosProvider() {
    _listaFavoritos = [];
    _loadFavoritos();
  }

  List<Empresa> get listaFavoritos => _listaFavoritos;

  Future<void> _loadFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritosJson = prefs.getString(_prefsKey);
    if (favoritosJson != null) {
      final List<dynamic> favoritosData = jsonDecode(favoritosJson);
      _listaFavoritos = favoritosData.map((data) => Empresa.fromJson(data)).toList();
    }
    notifyListeners();
  }



  Future<void> _saveFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritosJson = jsonEncode(_listaFavoritos.map((empresa) => empresa.toJson()).toList());
    await prefs.setString(_prefsKey, favoritosJson);
  }


  void agregarFavorito(Empresa empresa) {
    empresa.isColorFavorite = true; // Marcar como favorito
    _listaFavoritos.add(empresa);
    _saveFavoritos();
    notifyListeners();
  }

  void eliminarFavorito(Empresa empresa) {
    empresa.isColorFavorite = false; // Desmarcar como favorito
    _listaFavoritos.removeWhere((element) => element.id_empresa == empresa.id_empresa);
    _saveFavoritos();
    notifyListeners();
  }
}

