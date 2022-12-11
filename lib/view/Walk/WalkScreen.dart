import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:animal_app/view/Walk/AddPin.dart';
import 'package:animal_app/widget/TimerScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class WalkScreen extends StatefulWidget {
  WalkScreen(
      {Key? key,
      this.timeInMinutes,
      required this.animalId,
      this.wayPointsFromWalkSettngs})
      : super(key: key);
  int? timeInMinutes;
  final List<int> animalId;
  Map<String, LatLng>? wayPointsFromWalkSettngs;
  @override
  State<StatefulWidget> createState() => _WalkScreen();
}

class _WalkScreen extends State<WalkScreen> {
  // obecna lokacja do zmiennei -> 1 s czekania -> lokacja po 1 s do zmiennej
  //. then rysuj linie, obliczaj dystans, dodawaj linie do mapy,
  // dodawaj dystans do mapy, updateuj coiny
  List<PolylineWayPoint> waypoints = [];
  List<LatLng> coords = [];
  // Polylines
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoords = [];
  List<LatLng> polylineCoordsAdjustRoute = [];
  Map<PolylineId, Polyline> polylines = {};
  bool adjustRoute = false;

  // Google Api & Positioning
  double distance = 0.0;
  int coins = 0;
  late Position _currentPosition;
  late GoogleMapController mapController;
  final CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));

  Future<bool> _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    try {
      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      if (adjustRoute) {
        totalDistance = _coordinateDistance(lat1, lon1, lat2, lon2);
      } else {
        for (int i = 0; i < polylineCoords.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoords[i].latitude,
            polylineCoords[i].longitude,
            polylineCoords[i + 1].latitude,
            polylineCoords[i + 1].longitude,
          );
        }
      }

      setState(() {
        if (adjustRoute) {
          distance += totalDistance;
        } else {
          distance = totalDistance;
        }
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _getCurrentLocation();
    if (widget.wayPointsFromWalkSettngs != null) {
      adjustRoute = true;
      // dodaj pozycje poczatkowa do listy
      widget.wayPointsFromWalkSettngs?.forEach((key, value) {
        if (key != 'brak miejsca1' &&
            key != 'brak miejsca2' &&
            key != 'brak miejsca3') {
          waypoints.add(PolylineWayPoint(location: key));
        } else {
          waypoints.add(PolylineWayPoint(location: ''));
        } //  Polyline places - nazwy miejsc
        coords.add(value); // LatLng tych miejsc
      });
    }
    // jezeli A-B--> i 1.
    print('\n.\n.\n.\n Waypoints => $waypoints .\n.\n.\n.\n Coords -> $coords');
    super.initState();
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      Future.delayed(const Duration(seconds: 3), () {
        stopWatchTimer.onStartTimer();
        _updateMapAndValues();
      });
    }).catchError((e) {});
  }

  _displayDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Uwaga!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          content: Text(
              'Masz ustawiony limit czasu spaceru na ${widget.timeInMinutes} minut. Kliknij przycisk poniżej aby wydłużyć spacer o dodatkowe 1minut.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.timeInMinutes = widget.timeInMinutes! + 1;
                  petla = !petla;
                  print(widget.timeInMinutes);
                  print(petla);
                });
                Navigator.of(context).pop();
                stopWatchTimer.onStartTimer();
                _updateMapAndValues();
              },
              child: const Text(
                'Wydłuż spacer',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // zakonczenie sapceru
              },
              child: const Text(
                'NO',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  bool petla = true;
  _updateMapAndValues() async {
    // tworz markery kiedy coords jest inny niz latlng 0,0
    for (var i = 0; i < coords.length; i++) {
      if (coords[i] != const LatLng(0.0, 0.0)) {
        _addDroppedMarker(coords[i], waypoints[i].location);
      }
    }
    if (adjustRoute) {
      if (coords[2] == const LatLng(0.0, 0.0)) {
        // trasa A -> A
        // trasa A -> A
        setState(() {
          _createPolylines(
              _currentPosition.latitude,
              _currentPosition.longitude,
              _currentPosition.latitude,
              _currentPosition.longitude);
        });
      } else {
        // trasa A -> B
        setState(() {
          _createPolylines(
              _currentPosition.latitude,
              _currentPosition.longitude,
              coords[2].latitude,
              coords[2].longitude);
        });
      }
    }

    if (widget.timeInMinutes != null) {
      while (petla) {
        print(
            '\n-\n-\nTimer -> ${stopWatchTimer.minuteTime.value} Time przekazany -> ${widget.timeInMinutes}');
        if (stopWatchTimer.minuteTime.value == widget.timeInMinutes!) {
          stopWatchTimer.onStopTimer();
          petla = !petla;
          await _displayDialog(context);
        }

        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.best,
                forceAndroidLocationManager: true)
            .then((Position position) async {
          print("if $_currentPosition != $position");
          if (_currentPosition.latitude != position.latitude &&
              _currentPosition.longitude != position.longitude) {
            if (!adjustRoute) {
              _createPolylines(
                  _currentPosition.latitude,
                  _currentPosition.longitude,
                  position.latitude,
                  position.longitude);
            }
            await _calculateDistance(
                _currentPosition.latitude,
                _currentPosition.longitude,
                position.latitude,
                position.longitude);
            setState(() {
              _currentPosition = position;
              int result = distance * 1000 ~/ 50;
              // print('DYSTANS ILE COINOW : $result');
              if (result > 0) {
                while (coins < result) {
                  setState(
                    () => coins++,
                  );
                  // print(
                  //    "------------------------------------\nCoins inside of while loop: $coins\n-------------------------------------------");
                }
              }
            });
          }
        });
      }
    } else {
      while (petla) {
        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.best,
                forceAndroidLocationManager: true)
            .then((Position position) async {
          print("if $_currentPosition != $position");
          if (_currentPosition.latitude != position.latitude &&
              _currentPosition.longitude != position.longitude) {
            if (!adjustRoute) {
              _createPolylines(
                  _currentPosition.latitude,
                  _currentPosition.longitude,
                  position.latitude,
                  position.longitude);
            }
            await _calculateDistance(
                _currentPosition.latitude,
                _currentPosition.longitude,
                position.latitude,
                position.longitude);
            setState(() {
              _currentPosition = position;
              int result = distance * 1000 ~/ 50;
              if (result > 0) {
                while (coins < result) {
                  setState(
                    () => coins++,
                  );
                  // print(
                  //    "------------------------------------\nCoins inside of while loop: $coins\n-------------------------------------------");
                }
              }
            });
          }
        });
      }
    }
  }

  _createPolylines(
      double startLat, double startLng, double endLat, double endLng) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'xxxx',
        PointLatLng(startLat, startLng),
        PointLatLng(endLat, endLng),
        travelMode: TravelMode.bicycling,
        wayPoints: adjustRoute ? waypoints : []);

    if (adjustRoute) {
      result.points.forEach((PointLatLng point) {
        polylineCoords.add(LatLng(point.latitude, point.longitude));
      });
    } else if (result.points.isNotEmpty) {
      polylineCoords.add(
          LatLng(result.points.last.latitude, result.points.last.longitude));
    }

    PolylineId id = const PolylineId('poly');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoords,
      width: 3,
    );

    polylines[id] = polyline;
  }
  // markers start

  Set<Marker> markers = {};
  Set<Marker> emptySet = {};
  int _markerIdCounter = 1;
  void _addDroppedMarker(LatLng pos, String nazwa) {
    var markerIdValue = 'Marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdValue);

    // create marker
    final Marker marker = Marker(
        markerId: markerId,
        position: pos,
        infoWindow: InfoWindow(title: nazwa));

    setState(() => markers.add(marker));
  }

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose();
    mapController.dispose();
  }

  // markers end
  final StopWatchTimer stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);
  Uint8List? _image;
  bool _markersVisibility = true;
  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = const BorderRadius.only(
        topLeft: Radius.circular(24), topRight: Radius.circular(24));

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Click the pin to show/hide markers'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _markersVisibility = !_markersVisibility;
                  });
                },
                icon: const Icon(Icons.pin_drop_outlined)),
          ],
        ),
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              GoogleMap(
                polylines: Set<Polyline>.of(polylines.values),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                markers: _markersVisibility
                    ? Set<Marker>.from(markers)
                    : Set<Marker>.from(emptySet),
                initialCameraPosition: _initialLocation,
                onLongPress: (LatLng pos) async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) =>
                              AddPin(animalId: widget.animalId, latLng: pos))));
                  if (result != null) _addDroppedMarker(pos, result.toString());
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.blue[100],
                          child: InkWell(
                            splashColor: Colors.blue,
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.add),
                            ),
                            onTap: () {
                              mapController.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipOval(
                        child: Material(
                          color: Colors.blue[100], // button color
                          child: InkWell(
                            splashColor: Colors.blue, // inkwell color
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.remove),
                            ),
                            onTap: () {
                              mapController.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SafeArea(
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 6.0, bottom: 10.0),
                              child: ClipOval(
                                  child: Material(
                                      color: Colors.orange[100], // button color
                                      child: InkWell(
                                        splashColor:
                                            Colors.orange, // inkwell color
                                        child: const SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Icon(Icons.my_location),
                                        ),
                                        onTap: () {
                                          mapController.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: LatLng(
                                                  _currentPosition.latitude,
                                                  _currentPosition.longitude,
                                                ),
                                                zoom: 18.0,
                                              ),
                                            ),
                                          );
                                        },
                                      ))))),
                    ],
                  ),
                ),
              ),
              SlidingUpPanel(
                defaultPanelState: PanelState.OPEN,
                minHeight: 20,
                borderRadius: radius,
                maxHeight: MediaQuery.of(context).size.height * .33,
                panel: StreamBuilder<int>(
                  stream: stopWatchTimer.rawTime,
                  initialData: stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    final value = snap.data!;
                    final displayTime = StopWatchTimer.getDisplayTime(value,
                        hours: true,
                        milliSecond: false,
                        hoursRightBreak: ' : ',
                        minuteRightBreak: ' : ');
                    return Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.height * 0.15,
                        decoration: BoxDecoration(
                          color: Theme.of(context).bottomAppBarColor,
                          borderRadius: radius,
                        ),
                        child: Column(
                          children: [
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                child: Image(
                                    image: AssetImage('assets/line.png'))),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
                              child: Text(
                                displayTime,
                                style: Theme.of(context).textTheme.headline1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Dystans',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 10, 0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.directions_walk),
                                              Text(
                                                '${double.parse(distance.toStringAsFixed(2))} km',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('Monety',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 10, 10, 0),
                                            child:
                                                Image.asset('assets/Coin.png'),
                                          ),
                                          Text('$coins'),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final Uint8List? image =
                                        await mapController.takeSnapshot();
                                    setState(() {
                                      _image = image;

                                      polylineCoords.clear();
                                      petla = false;
                                    });
                                    print('\n Lista \n $image');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                CountUpTimerPage(
                                                    image: _image))));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).canvasColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                  child: Text(
                                    'Zakoncz spacer',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                ))
                          ],
                        ));
                  },
                ),
              ),
            ])));
  }
}
