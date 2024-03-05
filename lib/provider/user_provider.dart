
import 'dart:convert';
import 'dart:io';

import 'package:app_mecanica/api/environment.dart';
import 'package:app_mecanica/models/response_api.dart';
import 'package:app_mecanica/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';


class UserProvider{
  final String _url = Environment.API_MEDICO;
  final String _api = '/api/users';
  late BuildContext context;

  Future init(BuildContext context) async {
    this.context = context;
  }

  Future<ResponseApi?> login(String email, String password) async{
    try {
      Uri url = Uri.http(_url, '$_api/login');
      String bodiParams = json.encode({
        'email': email,
        'password': password
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodiParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(e){
      return null;
    }
  }

  Future<ResponseApi?> logout(String idUsuario) async {
    try {
      Uri url = Uri.http(_url, '$_api/logout');
      String bodyParams = json.encode({
        'id_usuario': idUsuario,
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> create(User user) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(user.toJson());
      Map<String, String> headers = {
        'Content-type': 'application/json',
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      final responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
  Future<ResponseApi?> validarEmail(String email) async {
    try{
      Uri url = Uri.http(_url, '$_api/lookEmail');
      String bodyParams = json.encode({
        'email': email,
      });
      Map<String, String> headers = {
        'Content-type':'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data  = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(e){
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> codeRegister (String email) async{
    try {
      Uri url = Uri.http(_url, '$_api/forgot-registro');
      String bodyParams = json.encode({
        'email': email,
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      print(data);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;

    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }
  Future<ResponseApi?> validateTokenRegistro(String token) async {

    try {
      Uri url = Uri.http(_url, '$_api/validarTokenRegistro');
      String bodyParams = json.encode({
        'token': token,
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      print(data);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<User?> getById(String? id_usuario) async {
    try {
      Uri url = Uri.http(_url, '$_api/getById/$id_usuario');
      Map<String, String> headers = {
        'Content-type': 'application/json',
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      User user = User.fromJson(data);
      return user;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> updatePassword(String? idUsuario, String? password) async{
    try{
      Uri url = Uri.http(_url, '$_api/editPassword');
      String bodiParams = json.encode({
        'id_usuario': idUsuario,
        'password': password
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers ,body: bodiParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(e){
      print('Error: $e');
      return null;
    }
  }

  Future<Stream?> update(User user, File? image) async {
    try {
      Uri url = Uri.http(_url, '$_api/update');
      final request = http.MultipartRequest('PUT', url);
      if (image != null) {
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(image.openRead().cast()),
            await image.length(),
            filename: basename(image.path)
        ));
      }
      request.fields['user'] = json.encode(user);
      final response = await request.send(); // ENVIARA LA PETICION
      return response.stream.transform(utf8.decoder);
    } catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> forgotPassword (String email) async{
    try {
      Uri url = Uri.http(_url, '$_api/forgot-password');
      String bodyParams = json.encode({
        'email': email,
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      print(data);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;

    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }
}
