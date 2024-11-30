
import 'package:TallerGo/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class SharedPref {

  void save (String key,  value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == null) return null;
    return json.decode(prefs.getString(key).toString());
  }

  // Nombre - true - false
  // SI EXISTE UN VALOR CON UNA KEY ESTABLECIDA
  Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
  void logout(BuildContext context, String idUsuario) async {
    UserProvider userProvider = new UserProvider();
    userProvider.init(context);
    await userProvider.logout(idUsuario);
    await remove('user');
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

}

