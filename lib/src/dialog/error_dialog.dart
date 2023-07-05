import 'package:flutter/material.dart';

void errorDialog(BuildContext context, String errorMsg) {
  showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errorMsg.toString()),
              ],
            ),
          ),
          backgroundColor: Color.fromARGB(255, 253, 226, 223),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
