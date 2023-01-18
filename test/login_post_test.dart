import 'dart:convert';

import 'package:animal_app/main.dart';
import 'package:animal_app/model/User.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:animal_app/view/Login%20and%20Register/Login.dart';
import 'package:animal_app/view/Login%20and%20Register/Register.dart';
import 'package:animal_app/view/User/UserStartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// file which has the getNumberTrivia function
import 'package:http/http.dart';
import 'package:http/testing.dart';

Future<String> getUser(http.Client http) async {
  // get all users endpoint
  Uri url = Uri.parse('$ServerIP/users ');
  final response = await http.get(url);
  // 201 = successful response
  if (response.statusCode == 201) {
    final Map users = jsonDecode(response.body);
    return users['response'];
  } else {
    return 'Failed to fetch';
  }
}

void main() {
  test('if endpoints response if successfull returns "hello"', () async {
    final mockHTTPClient = MockClient((request) async {
      final response = {"response": "hello"};
      return Response(jsonEncode(response), 201);
    });
    expect(await getUser(mockHTTPClient), isA<String>());
  });

  test('if http response is not successfull returns error "Failed to fetch"',
      () async {
    final mockHTTPClient = MockClient((request) async {
      final response = {};
      return Response(jsonEncode(response), 404);
    });
    expect(await getUser(mockHTTPClient), 'Failed to fetch');
  });
}
