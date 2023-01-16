import 'dart:convert';
import 'dart:math';

import 'package:animal_app/main.dart';
import 'package:animal_app/model/Pin.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/Network.dart';

class AddPin extends StatefulWidget {
  const AddPin({Key? key, required this.animalId, required this.latLng})
      : super(key: key);
  final LatLng latLng;
  final List<int> animalId;
  @override
  State<StatefulWidget> createState() => _AddPin();
}

class _AddPin extends State<AddPin> {
  String _nazwaMiejsca = '';
  TextEditingController name = TextEditingController(),
      description = TextEditingController();
  var res;

  Future savePin({body}) async {
    String? token = await storage.read(key: 'jwt');
    final String jwt = token!.replaceAll('"', '');
    String url = '$ServerIP/pin/add';
    NetworkUtil network = NetworkUtil();
    return await network.post(url, body: json.encode(body), headers: {
      "Authorization": "Bearer $jwt",
      "content-type": "application/json"
    });
  }

  Future<List<Pin>> fetchPin(int id) async {
    String url = '$ServerIP/pins/$id';
    String? token = await storage.read(key: 'jwt');
    final String jwt = token!.replaceAll('"', '');
    NetworkUtil network = NetworkUtil();
    final result = await network.get(url, headers: {
      'Authorization': 'Bearer $jwt',
      "content-type": "application/json"
    });

    return parsePin(json.encode(result['pins']));
  }

  List<Pin> parsePin(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Pin>((json) => Pin.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Pin> pinList = [];
    Set<Marker> markers = {};

    var style = Theme.of(context).textTheme;
    print(widget.animalId);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Dodaj koordynaty miejsca",
            style: style.bodyLarge,
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Długość geograficzna',
                  style: style.bodyMedium,
                ),
                TextFormField(
                  enabled: false,
                  initialValue: widget.latLng.latitude.toString(),
                ),
                Text(
                  'Szerokość geograficzna',
                  style: style.bodyMedium,
                ),
                TextFormField(
                  enabled: false,
                  initialValue: widget.latLng.longitude.toString(),
                ),
                Text(
                  'Nazwa miejsca',
                  style: style.bodyMedium,
                ),
                TextFormField(controller: name),
                Text(
                  'Opis miejsca',
                  style: style.bodyMedium,
                ),
                TextFormField(
                  controller: description,
                  maxLength: 255,
                  maxLines: 6,
                ),
                ElevatedButton(
                    onPressed: () async {
                      widget.animalId.forEach((element) async {
                        //stworzenie obiektow dla kazdego animal ID
                        Pin pin = Pin(
                            animalId: element,
                            description: description.text,
                            latitude: widget.latLng.latitude,
                            longtitude: widget.latLng.longitude,
                            name: name.text);
                        res = await savePin(body: pin.toMap());
                        print(res);
                        // pobranie pinow z bazy
                        var listofPins = await fetchPin(element);
                        print(listofPins);
                        pinList.addAll(listofPins);
                      });
                      var idCounter = 0;
                      // get all pins
                      pinList.forEach((element) {
                        var markerIdValue = 'Marker${idCounter}_id_element';
                        idCounter++;
                        final MarkerId markerId = MarkerId(markerIdValue);
                        markers.add(Marker(
                          markerId: markerId,
                          position:
                              LatLng(element.latitude!, element.longtitude!),
                          infoWindow: InfoWindow(
                              title: element.name,
                              snippet: element.description),
                        ));
                      });
                      if (res['Added pin'] != null) {
                        AwesomeDialog successDialog = AwesomeDialog(
                          dialogBackgroundColor:
                              Theme.of(context).disabledColor,
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.scale,
                          dismissOnTouchOutside: false,
                          body: const Text("Dodano pinezkę!"),
                          btnOkText: 'Ok',
                          btnOkOnPress: () {
                            Navigator.pop(context,markers);
                          },
                        );
                        await successDialog.show();
                      }
                    },
                    child: Text(
                      'Zapisz',
                      style: style.headline4,
                    ))
              ],
            )));
  }
}
