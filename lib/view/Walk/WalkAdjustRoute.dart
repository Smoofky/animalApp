import 'package:animal_app/view/Walk/WalkScreen.dart';
import 'package:animal_app/view/Walk/WalkSettings.dart';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:slider_button/slider_button.dart';

class WalkAdjustRoute extends StatefulWidget {
  const WalkAdjustRoute({Key? key, this.timeInMinutes, required this.animalId})
      : super(key: key);
  final int? timeInMinutes;
  final List<int> animalId;
  @override
  State<StatefulWidget> createState() => _WalkAdjustRoute();
}

class _WalkAdjustRoute extends State<WalkAdjustRoute> {
  List<bool> czyKlikniety = [false, false, false, false, false, true];
  Position? currentLocation;
  Map<String, LatLng>? waypointCoords;

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition().then((Position position) async {
      setState(
        () => currentLocation = position,
      );
    });
  }

  @override
  void initState() {
    _getCurrentLocation();
    print("Walk Adjust Route animal ID = ${widget.animalId}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> listaMiejsc = [
      'Sklepy',
      'Zwierzęta',
      'Parki',
      'Restauracje',
      'Od A do B',
      'Od A do A'
    ];
    List<dynamic> listaIkon = [
      Icons.shopping_cart_outlined,
      Icons.pets,
      Icons.park,
      Icons.restaurant,
      Icons.timeline,
      Icons.radio_button_unchecked
    ];

    // pierwsza wartosc - czy wybrany zostal typ trasy. 1 = tak, 0 = nie. druga wartosc - czy wybrane zostaly miejsca - 0 brak, 1 miejsce, 2 miejsca max
    List<int> ileWybranych = [0, 0];
    List<Widget> miejsca = [];
    var style = Theme.of(context).textTheme;
    var size = MediaQuery.of(context).size;
    for (var i = 0; i < 6; i++) {
      // i==4 i==5 to od A-B i A-A
      miejsca.add(
        SizedBox(
          width: i < 4 ? size.width * .35 : size.width * .30,
          height: i < 4 ? size.height * .15 : size.height * .20,
          child: GestureDetector(
              onTap: () async {
                if (i < 4) {
                  if (czyKlikniety[i]) {
                    setState(
                      () => czyKlikniety[i] = !czyKlikniety[i],
                    );
                  } else {
                    var map = {};
                    czyKlikniety.forEach((x) =>
                        map[x] = !map.containsKey(x) ? (1) : (map[x] + 1));

                    // jezeli mamy zaznaczony typ trasy[zawsze jest] oraz do 2 miejsc
                    if (map[true] <= 2) {
                      setState(() => czyKlikniety[i] = !czyKlikniety[i]);
                      if (czyKlikniety[4]) {
                        final placesCoords = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WalkSettings(
                                    ekran: listaMiejsc[i],
                                    wybranaTrasa: "AB",
                                    pickedLocation: waypointCoords,
                                    location: Location(
                                        lat: currentLocation!.latitude,
                                        lng: currentLocation!.longitude),
                                  )),
                        );

                        setState(() {
                          waypointCoords = placesCoords;
                        });
                      } else if (czyKlikniety[5]) {
                        final placesCoords = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalkSettings(
                                    ekran: listaMiejsc[i],
                                    wybranaTrasa: "AA",
                                    pickedLocation: waypointCoords,
                                    location: Location(
                                        lat: currentLocation!.latitude,
                                        lng: currentLocation!.longitude))));

                        setState(
                          () => waypointCoords = placesCoords,
                        );
                      }
                    } else {}
                  }
                } else {
                  // default - trasa od A do A.
                  setState(() {
                    if (i == 5) {
                      czyKlikniety[i] = !czyKlikniety[i];
                      czyKlikniety[i - 1] = !czyKlikniety[i - 1];
                    } else {
                      czyKlikniety[i] = !czyKlikniety[i];
                      czyKlikniety[i + 1] = !czyKlikniety[i + 1];
                    }
                  });
                }
              },
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
                      width: !czyKlikniety[i] ? 1 : 5,
                      color:
                          !czyKlikniety[i] ? Colors.black : Colors.lightGreen),
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      listaIkon[i],
                      size: i > 3 ? 90 : 55,
                      color: const Color.fromARGB(255, 31, 104, 60),
                    ),
                    Text(
                      listaMiejsc[i],
                      style: style.headline3,
                    ),
                  ],
                ),
              )),
        ),
      );
    }
    _displayDialog(BuildContext context, String textToDisplay) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Uwaga!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            content: Text(textToDisplay),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Wróć',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
    }

    return ScaffoldClass(
      key: UniqueKey(),
      axis: false,
      appBarIcon: false,
      appBarText: 'Autodopasowanie trasy',
      children: [
        if (currentLocation != null) ...[
          Center(
            heightFactor: 3,
            child: Text(
              'Wybierz typ trasy',
              style: style.bodyLarge,
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Padding(padding: const EdgeInsets.all(10), child: miejsca[4]),
            Padding(
              padding: const EdgeInsets.all(10),
              child: miejsca[5],
            ),
          ]),
          Center(
            heightFactor: 3,
            child: Text(
              'Wybierz max dwa miejsca',
              style: style.bodyLarge,
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Padding(padding: const EdgeInsets.all(10), child: miejsca[0]),
            Padding(
              padding: const EdgeInsets.all(10),
              child: miejsca[1],
            ),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Padding(padding: const EdgeInsets.all(10), child: miejsca[2]),
            Padding(
              padding: const EdgeInsets.all(10),
              child: miejsca[3],
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Center(
              child: SliderButton(
                dismissible: false,
                shimmer: false,
                alignLabel: const Alignment(0.5, 0),
                boxShadow: BoxShadow(
                    color: Theme.of(context).backgroundColor, blurRadius: 10),
                //highlightedColor: Theme.of(context).canvasColor,
                width: MediaQuery.of(context).size.width * 0.8,
                backgroundColor: Theme.of(context).focusColor,
                buttonColor: Theme.of(context).canvasColor,

                action: () {
                  if (waypointCoords != null) {
                    if (czyKlikniety[4]) {
                      // trasa A->B
                      bool? x;
                      waypointCoords?.forEach((key, value) {
                        key == 'brak miejsca3' ? x = true : x = false;
                        print('Klucz - $key');
                      });
                      print('Nasz x = $x');
                      if (x!) {
                        _displayDialog(context,
                            'Gdzie ma się kończyć spacer? W trasie od A do B musisz podać punkt końcowy.\nUstaw go i spróbuj ponownie.');
                      } else {
                        // w przeciwnym wypadku navigator do trasy spaceru z punktami na mapie
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalkScreen(
                                      animalId: widget.animalId,
                                      timeInMinutes: widget.timeInMinutes,
                                      wayPointsFromWalkSettngs: waypointCoords,
                                    )));
                      }
                    } else if (czyKlikniety[5]) {
                      // trasa A->A
                      int count = 0;
                      waypointCoords?.forEach((key, value) {
                        if (key == 'brak miejsca1' || key == 'brak miejsca2') {
                          count++;
                        }
                      });
                      if (count == 2) {
                        _displayDialog(context,
                            'Przez jaki punkt ma przechodzić spacer? W traacie od A do B musisz podać conajmniej jeden punkt na drodze spaceru.\nUstaw go i spróbuj ponownie.');
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalkScreen(
                                      animalId: widget.animalId,
                                      timeInMinutes: widget.timeInMinutes,
                                      wayPointsFromWalkSettngs: waypointCoords,
                                    )));
                      }
                    }
                  } else {
                    _displayDialog(context,
                        'W autodopasowaniu trasy należy wybrać conajmniej jeden punkt na drodze spaceru (w przypadku trasy od A do A), oraz punkt końcowy (w przypadku trasy od A do B).\nPopraw błędy.');
                  }
                  setState(() {});
                },
                label: Text(
                  'Zacznij spacer >>>',
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
                icon: const ImageIcon(
                  AssetImage('assets/running_dog.png'),
                  size: 50,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
        if (currentLocation == null)
          SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
