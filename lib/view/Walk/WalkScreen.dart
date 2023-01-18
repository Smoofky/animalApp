import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:animal_app/view/Walk/AddPin.dart';
import 'package:animal_app/view/Walk/WalkStatistic.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
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

  // Czas przekazany z poprzedniego ekranu. Domyślnie null
  int? timeInMinutes;
  // Lista id zwierząt, które biorą udział w spacerze.
  final List<int> animalId;
  // Mapa par - Nazwa miejsce + Koordynaty. Przekazana tylko z ekranu konfiguracji spaceru z autodopasowaniem trasy
  Map<String, LatLng>? wayPointsFromWalkSettngs;
  @override
  State<StatefulWidget> createState() => _WalkScreen();
}

class _WalkScreen extends State<WalkScreen> {
  // Autodopasowanie trasy
  List<PolylineWayPoint> waypoints = [];
  List<LatLng> coords = [];
  bool adjustRoute = false;

  // Polylines
  int polyCounter = 1;
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoords = [];
  List<LatLng> polylineCoordsAdjustRoute = [];
  Map<PolylineId, Polyline> polylines = {};
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];

  // Markers
  Set<Marker> markers = {};
  Set<Marker> emptySet = {};
  int _markerIdCounter = 1;
  bool _markersVisibility = true;

  // Time & Map snapshoot

  final StopWatchTimer stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);
  Uint8List? _image;

  // Google Api & Positioning
  double distance = 0.0;
  int coins = 0;
  late Position _currentPosition;
  late GoogleMapController mapController;
  final CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));

  // initState
  @override
  void initState() {
    print(widget.animalId);
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
    super.initState();
  }

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
      // ignore: empty_catches
    } catch (e) {}
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
    AwesomeDialog dlg = AwesomeDialog(
        context: context,
        dialogBackgroundColor: Theme.of(context).disabledColor,
        dialogType: DialogType.info,
        animType: AnimType.scale,
        title: 'Uwaga!',
        body: Text(
          'Masz ustawiony limit czasu spaceru na ${widget.timeInMinutes} minut. Kliknij przycisk poniżej aby wydłużyć spacer o dodatkowe 1minut.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        dismissOnTouchOutside: false,
        btnOkOnPress: () {
          setState(() {
            widget.timeInMinutes = widget.timeInMinutes! + 1;
            petla = !petla;
          });
          //Navigator.of(context).pop();
          stopWatchTimer.onStartTimer();
          _updateMapAndValues();
        },
        btnCancelOnPress: () async {
          final Uint8List? image = await mapController.takeSnapshot();
          setState(() {
            _image = image;
            polylineCoords.clear();
            petla = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => WalkStatistic(
                          image: _image,
                          animalIdList: widget.animalId,
                          parameters: {
                            1: distance.toStringAsFixed(2),
                            2: coins.toString(),
                            3: stopWatchTimer.secondTime.value.toString(),
                          })),
              (route) => false);
        },
        btnOkText: 'Wydłuż spacer',
        btnCancelText: 'Zakończ');

    await dlg.show();
  }

  _mainUpdatingFunc() async {
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) async {
      if (_currentPosition.latitude != position.latitude &&
          _currentPosition.longitude != position.longitude) {
        if (!adjustRoute) {
          _createPolylines(
              _currentPosition.latitude,
              _currentPosition.longitude,
              position.latitude,
              position.longitude);
        }
        await _calculateDistance(_currentPosition.latitude,
            _currentPosition.longitude, position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            _currentPosition = position;
            int result = distance * 1000 ~/ 70;
            if (result > 0) {
              while (coins < result) {
                if (mounted) {
                  setState(
                    () => coins++,
                  );
                }
              }
            }
          });
        }
      }
    });
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
        if (stopWatchTimer.minuteTime.value == widget.timeInMinutes!) {
          stopWatchTimer.onStopTimer();
          petla = !petla;
          await _displayDialog(context);
        }
        await _mainUpdatingFunc();
      }
    } else {
      while (petla) {
        await _mainUpdatingFunc();
      }
    }
  }

  _createPolylines(double startLat, double startLng, double endLat, double endLng) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'xxxx',
        PointLatLng(startLat, startLng),
        PointLatLng(endLat, endLng),
        travelMode: TravelMode.walking,
        wayPoints: adjustRoute ? waypoints : []);

    if (adjustRoute) {
      result.points.forEach((PointLatLng point) {
        polylineCoords.add(LatLng(point.latitude, point.longitude));
      });
    } else if (result.points.isNotEmpty) {
      polylineCoords.add(
          LatLng(result.points.last.latitude, result.points.last.longitude));
    }

    PolylineId id = PolylineId('poly$polyCounter');
    polyCounter++;
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.green,
        points: polylineCoords,
        width: 5,
        patterns: patterns[0]);

    polylines[id] = polyline;
  }

  void _addDroppedMarker(LatLng pos, String nazwa) {
    var markerIdValue = 'Marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdValue);

    // create marker
    final Marker marker = Marker(
        markerId: markerId,
        position: pos,
        flat: true,
        infoWindow: InfoWindow(title: nazwa));

    setState(() => markers.add(marker));
  }

  void _addMarkers(marker) {
    setState(() {
      markers.addAll(marker);
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose();
    mapController.dispose();
    petla = false;
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = const BorderRadius.only(
        topLeft: Radius.circular(24), topRight: Radius.circular(24));
    Future<bool> promptExit() async {
      bool? canExit;
      // zatrzymaj spacer
      stopWatchTimer.onStopTimer();
      setState(
        () => petla = !petla,
      );
      AwesomeDialog dlg = AwesomeDialog(
          context: context,
          dialogType: DialogType.question,
          animType: AnimType.bottomSlide,
          title: 'Chcesz wyjść ze spaceru?',
          dismissOnTouchOutside: false,
          btnCancelOnPress: () => canExit = false,
          btnOkOnPress: () => canExit = true,
          btnOkText: 'Zakończ spacer',
          btnCancelText: 'Zostań');

      await dlg.show();
      if (!canExit!) {
        stopWatchTimer.onStartTimer();
        setState(
          () => petla = !petla,
        );
      } else {
        final Uint8List? image = await mapController.takeSnapshot();
        setState(() {
          _image = image;
          polylineCoords.clear();
          petla = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => WalkStatistic(
                        image: _image,
                        animalIdList: widget.animalId,
                        parameters: {
                          1: distance.toStringAsFixed(2),
                          2: coins.toString(),
                          3: stopWatchTimer.secondTime.value.toString(),
                        })),
            (route) => false);
      }
      return Future.value(canExit);
    }

    return WillPopScope(
      onWillPop: () async => promptExit(),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Click the pin to show/hide markers'),
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
                            builder: ((context) => AddPin(
                                animalId: widget.animalId, latLng: pos))));
                    if (result != null) _addMarkers(result);
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
                                        color:
                                            Colors.orange[100], // button color
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
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 10),
                                child: Text(
                                  displayTime,
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 0, 30, 0),
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
                                                const Icon(
                                                    Icons.directions_walk),
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
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 10, 0),
                                              child: Image.asset(
                                                  'assets/Coin.png'),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                                      // ignore: use_build_context_synchronously
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WalkStatistic(
                                                      image: _image,
                                                      animalIdList:
                                                          widget.animalId,
                                                      parameters: {
                                                        1: distance
                                                            .toStringAsFixed(2),
                                                        2: coins.toString(),
                                                        3: stopWatchTimer
                                                            .secondTime.value
                                                            .toString(),
                                                      })),
                                          (route) => false);
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
              ]))),
    );
  }
}
