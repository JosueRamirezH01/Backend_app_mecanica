
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FavoritosController {
  late BuildContext context;
  late Function refresh;
  Position? position;

  Future init(BuildContext  context, Function refresh) async{
    this.context = context;
    this.refresh = refresh;
  }

}