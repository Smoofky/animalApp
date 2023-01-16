import 'dart:convert';

import 'package:animal_app/model/User.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:animal_app/view/Login%20and%20Register/Login.dart';
import 'package:animal_app/view/Login%20and%20Register/Register.dart';
import 'package:animal_app/view/User/UserStartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class Mockito extends Mock implements NetworkUtil {}

void main() {
  test('returns a Map if there is no error', () async {
    NetworkUtil mock = NetworkUtil();
    String url = 'http://10.0.2.2:8000/user/login/';

    User u = User(email: "user@example.pl", password: "string");
    when(mock.post(url,
        body: json.encode(u.toMapLogin()),
        headers: {"content-type": "application/json"})).thenAnswer((v) async {
      v.toString().contains("Tokens");
    });
    //expect(await fetchFromDatabase(mockitoExample), isA<Map>());
  });
}
