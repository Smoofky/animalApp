import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animal_app/main.dart';
import 'package:http/http.dart' as http;

class NetworkUtil {
  static final NetworkUtil _instance = NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = const JsonDecoder();

  // @Get
  Future<dynamic> get(String url, {headers}) {
    return http
        .get(Uri.parse(url), headers: headers)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 201 || statusCode > 400) {
        return res;
      }
      return _decoder.convert(res);
    });
  }

  // @Post
  Future<dynamic> post(String url, {headers, body}) {
    return http
        .post(Uri.parse(url), body: body, headers: headers)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 201 || statusCode > 400) {
        return res;
      }
      return _decoder.convert(res);
    });
  }

  // @Patch Image
  Future multipartFunc(String url, String file, String token) async {
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers.addAll({
      "Authorization": "Bearer $token",
    });
    
    request.files.add(http.MultipartFile.fromBytes(
        "file", File(file).readAsBytesSync(),
        filename: file.split("/").last));
    
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
  
    return responseData;
  }

  //@Delete
  Future<dynamic> delete(String url, {headers}) async {
    return http
        .delete(
      Uri.parse(url), headers: headers
    )
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 201 || statusCode > 400) {
        return res;
      }
      return _decoder.convert(res);
    });
  }
}
