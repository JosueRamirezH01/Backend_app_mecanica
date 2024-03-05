import 'dart:convert';


User responseApiFromJson(String str) => User.fromJson(json.decode(str));

String responseApiToJson(User data) => json.encode(data.toJson());

class User {
  String? id_usuario;
  String? email;
  String? verificador_token;
  String? password;
  String? nombre;
  String? dni;
  String? sexo;
  String? celular;
  String? image;
  String? usuario_id;

  User({
    this.id_usuario,
    this.verificador_token,
    this.email,
    this.password,
    this.nombre,
    this.dni,
    this.sexo,
    this.celular,
    this.image,
    this.usuario_id
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    verificador_token: json["verificador_token"],
    id_usuario: json["id_usuario"],
    email: json["email"],
    password: json["password"],
    nombre: json["nombre"],
    dni: json["dni"],
    sexo: json["sexo"],
    celular: json["celular"],
    image: json["image"],
      usuario_id:json["usuario_id"]
  );

  Map<String, dynamic> toJson() => {
    "verificador_token": verificador_token,
    "id_usuario": id_usuario,
    "email": email,
    "password": password,
    "nombre": nombre,
    "dni": dni,
    "sexo": sexo,
    "celular": celular,
    "image": image,
    "usuario_id": usuario_id
  };
}