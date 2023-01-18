import 'dart:convert';
import 'dart:ffi';

import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart' as loc;
import 'package:http/http.dart' as http;

/*
typy miejsc

Sklep => bakery, convenience_store, drugstore,electronics_store, shopping_mall,florist, supermarket,
Zwierzeta => pet_store, veterinary_care
Parki => park
Restauracje => bar, meal_takeaway, cafe, restaurant

*/
class WalkSettings extends StatefulWidget {
  WalkSettings(
      {Key? key,
      required this.ekran,
      required this.wybranaTrasa,
      required this.location,
      this.pickedLocation})
      : super(key: key);

  String ekran;
  String wybranaTrasa;
  loc.Location location;
  Map<String, LatLng>? pickedLocation;

  @override
  State<StatefulWidget> createState() => _WalkSettings();
}

class _WalkSettings extends State<WalkSettings> {
  String? punktPierwszy;
  String? punktDrugi;
  String? punktDocelowy;
  final int maximumDistance = 10000;
  String? Address;
  String apiKey = 'API KEY HERE';
  Map<String, List<String>> type = {
    "Sklepy": ['bakery|drugstore|shopping_mall|florist|supermarket'],
    "Zwierzęta": ['pet_store|veterinary_care'],
    "Parki": ['park'],
    "Restauracje": ['bar|meal_takeaway|cafe|restaurant']
  };
  String location = "Wpisz zapytanie...";
  Future<void> GetAddressFromLatLong() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.location.lat, widget.location.lng);
    //print(placemarks);
    Placemark place = placemarks[0];
    setState(() => Address = '${place.street}, ${place.locality}');
  }

  void _navigateToPrevScreen() {
    Navigator.pop(context, {
      if (punktPierwszy != null)
        punktPierwszy: pierwszyCoords
      else
        'brak miejsca1': const LatLng(0, 0),
      if (punktDrugi != null)
        punktDrugi: drugiCoords
      else
        'brak miejsca2': const LatLng(0, 0),
      if (punktDocelowy != null)
        punktDocelowy: destCoords
      else
        'brak miejsca3': const LatLng(0, 0)
    });
  }

  @override
  void initState() {
    if (widget.wybranaTrasa == 'AB') trasaAb = true;
    listaMiejsc = widget.pickedLocation;
    print(listaMiejsc);
    if (listaMiejsc != null) {
      var listKeys = listaMiejsc!.keys.toList();
      var listValues = listaMiejsc!.values.toList();
      if (listKeys[0] != 'brak miejsca1') {
        punktPierwszy = listKeys[0];
        pierwszyCoords = listValues[0];
      }
      if (listKeys[1] != 'brak miejsca2') {
        punktDrugi = listKeys[1];
        drugiCoords = listValues[1];
      }
      if (listKeys[2] != 'brak miejsca3') {
        punktDocelowy = listKeys[2];
        destCoords = listValues[2];
      }
    }

    // print('LISTA MIEJSC SET STATEEEEEEEEEEEEEEEEE $listaMiejsc');
    GetAddressFromLatLong();
    super.initState();
  }

  int tapCount = 1;
  LatLng? pierwszyCoords;
  LatLng? drugiCoords;
  LatLng? destCoords;
  Map<String, LatLng>? listaMiejsc; // to mamy

  bool trasaAb = false;
  String distanceError = '';

  @override
  Widget build(BuildContext context) {
    List<String> nazwyDoTekstu = [];

    //print('WalkSettings  $listaMiejsc');
    var isNull = listaMiejsc ?? 'yep';
    if (isNull != 'yep') {
      listaMiejsc!.forEach((key, value) {
        setState(
          () => nazwyDoTekstu.add(key),
        );
      });
    }
    print(
        "Lista Stringów $nazwyDoTekstu"); /*
    print("Nazwy isnotEmpty : ${nazwyDoTekstu.contains(null)}");
    print("isNull isEmpty ? - ${isNull}");*/

    return ScaffoldClass(
      axis: false,
      appBarText: widget.ekran,
      children: [
        if (Address == null) ...[
          SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
        if (Address != null) ...[
          Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * .9,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  child: ListTile(
                    title: Text(location),
                    trailing: const Icon(Icons.search),
                    dense: true,
                  ),
                ),
                onTap: () async {
                  var miejsce = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: apiKey,
                    mode: Mode.overlay,
                    types: type[widget.ekran],
                    strictbounds: false,
                    language: 'pl',
                    hint: 'Wyszukaj miejsca',
                    radius: 15,
                    location: widget.location,
                    logo: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).canvasColor,
                                  blurRadius: 5.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                              color: Theme.of(context).focusColor,
                              border: Border.all(
                                  width: 3, color: Colors.lightGreen),
                              borderRadius: BorderRadius.circular(
                                25,
                              ),
                            ),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Kategoria ${widget.ekran}.\n\n\nWyszukaj w polu powyżej miejsce, które chcesz odwiedzić podczas spaceru.',
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                    textAlign: TextAlign.center,
                                  ),
                                  widget.ekran == "Sklepy"
                                      ? Text(
                                          '\nDla tej kategorii możesz znaleźć różne popularne markety, sklepy, piekarnie, apteki oraz wiele innych.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                          textAlign: TextAlign.center,
                                        )
                                      : widget.ekran == "Zwierzęta"
                                          ? Text(
                                              '\nDla tej kategorii możesz znaleźć różne popularne sklepy z artykułami dla zwierząt oraz gabinety weterynaryjne.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3,
                                              textAlign: TextAlign.center,
                                            )
                                          : widget.ekran == "Parki"
                                              ? Text(
                                                  '\nDla tej kategorii możesz znaleźć różne parki.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline3,
                                                  textAlign: TextAlign.center,
                                                )
                                              : Text(
                                                  '\nDla tej kategorii możesz znaleźć różne restauracje, bary czy kawiarnie przyjazne zwierzętom.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline3,
                                                  textAlign: TextAlign.center,
                                                ),
                                  const Icon(
                                    Icons.pets,
                                    size: 150,
                                  )
                                ]))),
                    overlayBorderRadius:
                        const BorderRadius.all(Radius.elliptical(20, 40)),
                    components: [loc.Component(loc.Component.country, 'pl')],
                  );
                  var url = Uri.parse(
                      "https://maps.googleapis.com/maps/api/place/details/json?fields=geometry&place_id=${miejsce!.placeId}&key=$apiKey");
                  final placeLatLng = await http.get(url);
                  Map<String, dynamic> map = jsonDecode(placeLatLng.body);
                  LatLng coords = LatLng(
                      map['result']['geometry']['location']['lat'],
                      map['result']['geometry']['location']['lng']);

                  var distanceMeters = Geolocator.distanceBetween(
                      coords.latitude,
                      coords.longitude,
                      widget.location.lat,
                      widget.location.lng);
                  print(
                      'Dystans w km miedzy obiektami : ${distanceMeters / 1000}');
                  if (distanceMeters <= maximumDistance) {
                    setState(() {
                      if (tapCount == 1) {
                        punktPierwszy = miejsce.description;
                        pierwszyCoords = coords;
                      } else if (tapCount == 2) {
                        punktDrugi = miejsce.description;
                        drugiCoords = coords;
                      } else if (tapCount == 3) {
                        punktDocelowy = miejsce.description;
                        destCoords = coords;
                      }
                      distanceError = '';
                    });

                    //setState(() => location = value.description.toString());
                    print('---\n---\n---\nDystans mniejszy niz 10km');
                  } else {
                    setState(
                      () => distanceError =
                          'Błąd.\nMaksymalny dystans od twojej początkowej lokacji musi wynosić mniej niż 15 km.',
                    );
                    print('BLAD za duzy dystans');
                  }
                },
              )),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                distanceError,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center(
              heightFactor: 3,
              child: Text(
                'Twoja lokalizacja początkowa',
                style: Theme.of(context).textTheme.headline4,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pin_drop),
              Container(
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).canvasColor,
                      blurRadius: 1.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                  color: Theme.of(context).focusColor,
                  border: Border.all(width: 3, color: Colors.black),
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                ),
                width: 300,
                height: 50,
                child: Text(
                  Address!,
                  style: Theme.of(context).textTheme.headline3,
                ),
              )
            ],
          ),
          Center(
              heightFactor: 2,
              child: Text(
                'Punkty na trasie',
                style: Theme.of(context).textTheme.headline4,
              )),
          Center(
              child: Text(
            'Wybierz pole a następnie wyszukaj punkt!',
            style: Theme.of(context).textTheme.headline5,
          )),
          /*

                Pierwszy punkt na trasie

              */
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.push_pin),
              GestureDetector(
                  onLongPress: () => setState(() {
                        punktPierwszy = null;
                        pierwszyCoords = null;
                        // nazwyDoTekstu[0] == 'brak miejsca1';
                      }),
                  onTap: () {
                    if (trasaAb) {
                      if (tapCount == 3) setState(() => tapCount = 0);
                    } else {
                      if (tapCount == 2) setState(() => tapCount = 0);
                    }
                    setState(() => tapCount++);
                    /*pierwszyWybrany = !pierwszyWybrany;
                        drugiWybrany = !drugiWybrany;
                        if (widget.wybranaTrasa == 'AB' &&
                            drugiWybrany == false) trasaAb = !trasaAb;*/
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).canvasColor,
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      color: Theme.of(context).focusColor,
                      border: Border.all(
                          width: 3,
                          color: tapCount == 1
                              ? const Color.fromARGB(255, 58, 241, 216)
                              : Colors.black),
                    ),
                    width: 300,
                    height: 50,
                    child: Text(
                      punktPierwszy == null
                          ? '...pusto tutaj...'
                          : punktPierwszy!,
                      style: Theme.of(context).textTheme.headline3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          /*

                Drugi punkt na trasie

          */
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.push_pin),
              GestureDetector(
                  onLongPress: () => setState(() {
                        punktDrugi = null;
                        drugiCoords = null;
                        //nazwyDoTekstu[1] == 'brak miejsca2';
                      }),
                  onTap: () {
                    if (trasaAb) {
                      if (tapCount == 3) setState(() => tapCount = 0);
                    } else {
                      if (tapCount == 2) setState(() => tapCount = 0);
                    }
                    setState(() => tapCount++);
                    /*setState(() {
                      pierwszyWybrany = !pierwszyWybrany;
                      drugiWybrany = !drugiWybrany;
                    });*/
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).canvasColor,
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      color: Theme.of(context).focusColor,
                      border: Border.all(
                          width: 3,
                          color: tapCount == 2
                              ? const Color.fromARGB(255, 58, 241, 216)
                              : Colors.black),
                    ),
                    width: 300,
                    height: 50,
                    child: Text(
                      punktDrugi != null ? punktDrugi! : '...pusto tutaj...',
                      style: Theme.of(context).textTheme.headline3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
            ],
          ),
          Center(
              heightFactor: 3,
              child: Text(
                'Twoja lokalizacja końcowa',
                style: Theme.of(context).textTheme.headline4,
              )),

          /*

                Lokalizacja końcowa

              */
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pin_drop),
              GestureDetector(
                  onLongPress: () => setState(() {
                        punktDocelowy = null;
                        //nazwyDoTekstu[2] == 'brak miejsca3';

                        destCoords = null;
                      }),
                  onTap: () {
                    print('Tap count = $tapCount');
                    if (trasaAb) {
                      if (tapCount == 3) setState(() => tapCount = 0);
                    } else {
                      if (tapCount == 2) setState(() => tapCount = 0);
                    }
                    setState(() => tapCount++);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).canvasColor,
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      color: Theme.of(context).focusColor,
                      border: Border.all(
                          width: 3,
                          color: tapCount == 3
                              ? const Color.fromARGB(255, 58, 241, 216)
                              : Colors.black),
                      borderRadius: BorderRadius.circular(
                        25,
                      ),
                    ),
                    width: 300,
                    height: 50,
                    child: Text(
                      widget.wybranaTrasa == 'AA'
                          ? Address!
                          : punktDocelowy != null
                              ? punktDocelowy!
                              : '...pusto tutaj...',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ))
            ],
          ),
          ElevatedButton(
              onPressed: () {
                if (!trasaAb) {
                  if (punktPierwszy == null && punktDrugi == null) {
                    setState(
                      () => distanceError =
                          'W trasie A-A należy wybrać co najmniej jeden punk!',
                    );
                  } else {
                    _navigateToPrevScreen();
                  }
                } else {
                  if (punktDocelowy == null) {
                    setState(
                      () => distanceError =
                          'W trasie A-B należy wybrać lokalizację końcową!',
                    );
                  } else {
                    _navigateToPrevScreen();
                  }
                }
              },
              child: const Text('Zapisz'))
        ]
      ],
    );
  }
}
