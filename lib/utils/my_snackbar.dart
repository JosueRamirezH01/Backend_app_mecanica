import 'package:flutter/material.dart';

class MySnackbarError {

  static void show(BuildContext context, String text) {
    if (context == null) return;

    FocusScope.of(context).requestFocus(new FocusNode());

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OneDay',
            fontSize: 16
          ),
        ),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 1000),
      )
    );
  }
}

class MySnackbarPositivo{
  static void show(BuildContext context, String text) {
    if (context == null) return;

    FocusScope.of(context).requestFocus(new FocusNode());

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'OneDay',
                fontSize: 16
            ),
          ),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 2000),
        )
    );
  }
}

