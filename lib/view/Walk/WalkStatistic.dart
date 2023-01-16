import 'dart:convert';
import 'dart:typed_data';

import 'package:animal_app/model/Walk.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:animal_app/view/User/UserStartPage.dart';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';

class WalkStatistic extends StatefulWidget {
  const WalkStatistic(
      {Key? key,
      required this.image,
      required this.parameters,
      required this.animalIdList})
      : super(key: key);
  final Uint8List? image;
  final Map<int, String> parameters;
  final List<int> animalIdList;
  @override
  State<WalkStatistic> createState() => _WalkStatistic();
}

class _WalkStatistic extends State<WalkStatistic> {
  _convertTime(int sec) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    seconds =
        sec % 60; // reszta z dzielenia sekund przez 60 => ile sekund zostalo
    minutes = sec ~/ 60; // dzielenie calkowite sekund przez 60 => ile minut
    setState(() {
      if (minutes >= 60) {
        hours = minutes ~/ 60;
        minutes -= hours * 60;
      }
      minutes < 10 ? _minute = '0$minutes' : _minute = '$minutes';
      seconds < 10 ? _second = '0$seconds' : _second = '$seconds';
      hours < 10 ? _hour = '0$hours' : _hour = '$hours';
      _time = "$_hour : $_minute : $_second";
    });
  }

  String? _hour, _minute, _second, _time;
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _convertTime(int.parse(widget.parameters[3]!));

    super.initState();
  }

  Future saveWalk({body}) async {
    String? token = await storage.read(key: 'jwt');
    final String jwt = token!.replaceAll('"', '');
    String url = '$ServerIP/walk/add';
    NetworkUtil network = NetworkUtil();
    return await network.post(url, body: json.encode(body), headers: {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json'
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Hour = $_hour , Mins = $_minute, Sec = $_second");
    BorderRadiusGeometry radius = const BorderRadius.only(
        topLeft: Radius.circular(24), topRight: Radius.circular(24));
    return ScaffoldClass(
        axis: true,
        appBarIcon: true,
        appBarText: 'Statystyki Spaceru',
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Image.memory(
                    widget.image!,
                    scale: 5,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.18,
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                  borderRadius: radius,
                ),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
                    child: Text(
                      'Czas: $_time',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Dystans',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 10, 0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.directions_walk),
                                    Text(
                                      '${widget.parameters[1]} km',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                        Column(
                          children: [
                            Text('Monety',
                                style: Theme.of(context).textTheme.bodyLarge),
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 10, 0),
                                  child: Image.asset('assets/Coin.png'),
                                ),
                                Text('${widget.parameters[2]}'),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ]),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: ElevatedButton(
                        onPressed: (() async {
                          
                          Walk walk = Walk(
                            animalIdList: widget.animalIdList,
                            coins: int.parse(
                              widget.parameters[2]!,
                            ),
                            distance: double.parse(widget.parameters[1]!),
                            photo: widget.image,
                            time: _time,
                          );
                          var response = await saveWalk(body: walk.toMap());
                          // dodano zwierzaka tutaj jeszcze alert
                          /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => UserStartPage())));*/
                        }),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).backgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Text(
                          'Zapisz spacer',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: ElevatedButton(
                        onPressed: (() => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => UserStartPage())))),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).backgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Text(
                          'Anuluj',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ))
                ],
              )
            ],
          ),
        ]);
  }
}
