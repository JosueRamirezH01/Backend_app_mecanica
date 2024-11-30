

import 'dart:convert';

import 'package:TallerGo/api/environment.dart';
import 'package:TallerGo/models/empresa.dart';
import 'package:TallerGo/models/response_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmpresaProvider {
  final String _url = Environment.API_MEDICO;
  final String _api = '/api/empresa';
  late BuildContext context;

  Future init(BuildContext context) async {
    this.context = context;
  }

  Future<List<Empresa>?> getAll() async {
    try {
      Uri url = Uri.https(_url, '$_api/getAll');
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      print('Datos recibidos: $data');
      Empresa empresa = Empresa.fromJsonList(data);
      return empresa.locations;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> crearCalificacion(Empresa empresa) async {
    try {
      Uri url = Uri.https(_url, '$_api/crearCalificacion');
      String bodyParams = json.encode(empresa);
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      print(data);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }



}