import 'package:flutter/material.dart';

class GlobalMethod {
  static void showErrorDialog(
      {required String error, required BuildContext ctx}) {
    showDialog(
        context: ctx,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Une erreur s\'est produite ',
                  ),
                ),
              ],
            ),
            content: Text(
              '$error',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }
}
