import 'package:app_mecanica/models/empresa.dart';
import 'package:app_mecanica/models/response_api.dart';
import 'package:app_mecanica/provider/empresa_provider.dart';
import 'package:app_mecanica/utils/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class InformacionController {
  late BuildContext context;
  late Function refresh;
  late String direccion;
  double? puntuacion;
  final EmpresaProvider _empresaProvider = EmpresaProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    refresh();
  }

  Future<void> showMyDialog(BuildContext context, String? idEmpresa) async {
    return showDialog<void>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 249, 251, 231 ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          title:  const Text('CALIFICAME', style: TextStyle(color: Colors.blue),textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Center(
              child: RatingBar.builder(
                initialRating: 0,
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      );
                    case 1:
                      return Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.redAccent,
                      );
                    case 2:
                      return Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                    case 3:
                      return Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      );
                    case 4:
                      return Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                    default:
                      return Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                  }
                },
                onRatingUpdate: (rating) {
                  puntuacion = rating;
                  print(puntuacion);
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Enviar', style: TextStyle(fontSize: 20)),
              onPressed: () async {
                Empresa empresa = Empresa(
                    puntuacion:  puntuacion,
                    id_empresa_cal: idEmpresa
                    );
                  ResponseApi? response = await _empresaProvider.crearCalificacion(empresa);
                  MySnackbarPositivo.show(context, response!.message);
                  Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  }
