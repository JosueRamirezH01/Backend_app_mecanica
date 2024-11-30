import 'dart:convert';
import 'dart:ffi';


Empresa responseApiFromJson(String str) => Empresa.fromJson(json.decode(str));

String responseApiToJson(Empresa data) => json.encode(data.toJson());

class Empresa {
  String? id_empresa;
  String? ruc;
  String? id_empresa_cal;
  String? razon_social;
  String? imagen;
  String? celular;
  bool? auxilio_mecanico;
  bool? tienda_fisica;
  bool? taller_mecanico;
  bool? activo;
  bool? isColorFavorite;
  String? id_coordenadas;
  double? latitud;
  double? longitud;
  double? distancia;
  double? promedio;
  double? puntuacion;
  String? hora_atencion_lv;
  String? hora_atencion_s;
  String? hora_atencion_d;
  String? url_tienda;
  String? url_faccebook;
  List<Empresa> locations = [];


  Empresa({
    this.id_empresa,
    this.id_empresa_cal,
    this.auxilio_mecanico,
    this.ruc,
    this.distancia,
    this.razon_social,
    this.tienda_fisica,
    this.taller_mecanico,
    this.activo,
    this.celular,
    this.imagen,
    this.isColorFavorite,
    this.id_coordenadas,
    this.latitud,
    this.promedio,
    this.puntuacion,
    this.longitud,
    this.hora_atencion_lv,
    this.hora_atencion_s,
    this.hora_atencion_d,
    this.url_faccebook,
    this.url_tienda
  });

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
      id_empresa: json["id_empresa"],
      id_empresa_cal: json["id_empresa_cal"],
      ruc: json["ruc"],
      razon_social: json["razon_social"],
      tienda_fisica: json["tienda_fisica"],
      taller_mecanico: json["taller_mecanico"],
      auxilio_mecanico: json["auxilio_mecanico"],
      activo: json["activo"],
      isColorFavorite:  json["isColorFavorite"],
      distancia: json["distancia"],
      celular: json["celular"],
      imagen: json["imagen"],
      promedio: double.tryParse(json["promedio"]?.toString() ?? "0.0"),
      puntuacion: double.tryParse(json["puntuacion"]?.toString() ?? "0.0"),
      hora_atencion_lv: json["hora_atencion_lv"],
      hora_atencion_s: json["hora_atencion_s"],
      hora_atencion_d: json["hora_atencion_d"],
      url_faccebook: json["url_faccebook"],
      url_tienda: json["url_tienda"],
      id_coordenadas:json["id_coordenadas"],
      latitud: double.tryParse(json["latitud"]?.toString() ?? "0.0"),
      longitud: double.tryParse(json["longitud"]?.toString() ?? "0.0"),
  );
      Empresa.fromJsonList(List<dynamic> jsonList) {
          try {
              if (jsonList == null) return;
                jsonList.forEach((item) {
                  Empresa empresa = Empresa.fromJson(item);
                  locations.add(empresa);
              });
              } catch (e) {
                  return;
              }}
  Map<String, dynamic> toJson() => {
    "razon_social": razon_social,
    "id_empresa": id_empresa,
    "id_empresa_cal": id_empresa_cal,
    "ruc": ruc,
    "isColorFavorite": isColorFavorite,
    "taller_mecanico": taller_mecanico,
    "auxilio_mecanico": auxilio_mecanico,
    "tienda_fisica": tienda_fisica,
    "activo": activo,
    "celular": celular,
    "distancia": distancia,
    "imagen": imagen,
    "promedio": promedio,
    "puntuacion": puntuacion,
    "hora_atencion_lv": hora_atencion_lv,
    "hora_atencion_s": hora_atencion_s,
    "hora_atencion_d": hora_atencion_d,
    "id_coordenadas": id_coordenadas,
    "latitud": latitud,
    "url_tienda": url_tienda,
    "url_faccebook": url_faccebook,
    "longitud": longitud,
  };
}