import 'dart:developer';
import 'dart:math';

import 'Animal.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  String? name;
  String? surname;
  int? age;

  String? email;
  String? password;
  String? passwordRepeat;
  String? login;
  String? coins;
  int? id;

  String? phoneNumber;
  String? photo;
  //final List<Animal> animals;
  // Walk walks[];
  // Post posts[];
  String? sex;

  User(
      {this.email,
      this.login,
      this.password,
      this.passwordRepeat,
      this.coins,
      this.id,
      this.photo,
      this.age,
      this.name,
      this.phoneNumber,
      this.sex,
      this.surname});

  factory User.fromJson(Map json) {
    return User(
      email: json['email'],
      login: json['login'],
      password: json['password'],
      passwordRepeat: json['password_repeat'],
      photo: json['photo_url'],
      phoneNumber: json['phone_number'],
      name: json['name'],
      surname: json['surname'],
      sex: json['sex'],
    );
  }

  Map toMapLogin() {
    var map = {};
    map["email"] = email;
    map["password"] = password;
    map["login"] = login;
    return map;
  }
}
