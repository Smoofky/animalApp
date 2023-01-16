import 'dart:convert';

import 'package:animal_app/main.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:animal_app/view/Walk/WalkAdjustRoute.dart';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'package:slider_button/slider_button.dart';
import '../../model/Animal.dart';
import 'WalkScreen.dart';
import 'package:permission_handler/permission_handler.dart';

class WalkStartPage extends StatefulWidget {
  const WalkStartPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WalkStartPage();
}

class _WalkStartPage extends State<WalkStartPage> {
  late Future<List<Animal>> future;
  Future<void> requestLocationPermission() async {
    final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;
    bool isLocation = serviceStatusLocation == ServiceStatus.enabled;
    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      //print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      requestLocationPermission();
      //print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      //print('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  Future<List<Animal>> fetchAnimals(int userId) async {
    String url = "$ServerIP/users/$userId/animals";
    NetworkUtil network = NetworkUtil();
    final result = await (network.get(url));
    return parseAnimals(
        json.encode(result['Animals with user_id: ${user.id!}']));
  }

  @override
  void initState() {
    requestLocationPermission();
    future = fetchAnimals(user.id!).then((value) {
      wybrany = List<bool>.generate(value.length, (index) => false);
      return fetchAnimals(user.id!);
    });
    print('INIT STATE WYBRANY => $wybrany');

    super.initState();
  }

  // biezremy data z db o spacerach
  bool? ograniczonyCzasSpaceru = false;
  bool? autodopasowanieTrasySpaceru = false;
  int liczbaMinut = 10;
  double containerHeight = .075;
  late Future length;
  Widget _dialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Text(
        "Uwaga!",
        style: Theme.of(context).textTheme.headline1,
        textAlign: TextAlign.center,
      ),
      content: Text(
        "Aby rozpocząć spacer musisz wybrać przynajmniej jednego pupila z listy.",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: <Widget>[
        Center(
            child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Ok",
                  style: Theme.of(context).textTheme.headline3,
                )))
      ],
    );
  }

  List<Animal> parseAnimals(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Animal>((json) => Animal.fromJson(json)).toList();
  }

  late List<bool> wybrany = [];
  List<int> passAnimals = [];
  @override
  Widget build(BuildContext context) {
    List<Widget> walk = [
      FutureBuilder<List<Animal>>(
          future: future,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error} occured'));
              } else if (snapshot.hasData) {
                // future resolved
                if (snapshot.data!.isEmpty) {
                  return Column(children: [
                    Container(
                      width: 300,
                      alignment: Alignment.center,
                      child: Text(
                          'Aby korzystać ze spaceru musisz najpierw dodać zwierzaka!'),
                    )
                  ]);
                } else {
                  return SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * .35,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print(index);
                                    wybrany[index] = !wybrany[index];
                                    if (wybrany[index]) {
                                      // zwierzak wybrany do spaceru
                                      if (!passAnimals.contains(
                                          snapshot.data![index].id!)) {
                                        passAnimals
                                            .add(snapshot.data![index].id!);
                                      }
                                    } else {
                                      // zwierzak odrzucony od spaceru
                                      print(
                                          "Remove value: ${snapshot.data![index].id!}");
                                      passAnimals
                                          .remove(snapshot.data![index].id!);
                                    }
                                    print(wybrany);
                                    print(passAnimals);
                                  });
                                },
                                child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 40, 10, 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .4,
                                          decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 31, 104, 60),
                                              border: wybrany[index]
                                                  ? Border.all(
                                                      width: 3,
                                                      color: Colors.greenAccent)
                                                  : Border.all(
                                                      width: 2,
                                                      color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    blurRadius: 5)
                                              ]),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 45),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    snapshot.data![index].sex!,
                                                    maxLines: 2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                  Container(
                                                    width: 130,
                                                    height: 65,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black26,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            width: 2,
                                                            color: Theme.of(
                                                                    context)
                                                                .canvasColor)),
                                                    child: Text(
                                                      snapshot
                                                          .data![index].name!,
                                                      maxLines: 2,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline4,
                                                    ),
                                                  ),
                                                ],
                                              ))),
                                      Positioned(
                                          top: .0,
                                          left: .0,
                                          right: .0,
                                          child: Center(
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot.data![index].photo!),
                                              radius: 45,
                                            ),
                                          ))
                                    ]));
                          }));
                }
              }
            }
            return SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .35,
              child: const Center(child: CircularProgressIndicator.adaptive()),
            );
          })),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).canvasColor,
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * containerHeight,
        width: MediaQuery.of(context).size.width * .8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CheckboxListTile(
              value: ograniczonyCzasSpaceru,
              onChanged: ((value) => setState(() {
                    ograniczonyCzasSpaceru = value;
                    value == true
                        ? containerHeight = .15
                        : containerHeight = .075;
                  })),
              title: Text(
                'Mam ograniczony czas',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            ograniczonyCzasSpaceru == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () => setState(
                              () => liczbaMinut > 10 ? liczbaMinut-- : null),
                          icon: const Icon(Icons.remove_circle_outline)),
                      Container(
                        alignment: Alignment.center,
                        child: Text('$liczbaMinut minut'),
                      ),
                      IconButton(
                          onPressed: () => setState(() => liczbaMinut++),
                          icon: const Icon(Icons.add_circle_outline)),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).canvasColor,
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.075,
        width: MediaQuery.of(context).size.width * .8,
        child: CheckboxListTile(
          value: autodopasowanieTrasySpaceru,
          onChanged: ((value) =>
              setState(() => autodopasowanieTrasySpaceru = value)),
          title: Text(
            'Autodopasowanie trasy',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          checkboxShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      Center(
        child: SliderButton(
          disable: wybrany.contains(true) ? false : true,
          shimmer: wybrany.contains(true) ? true : false,
          alignLabel: const Alignment(0.5, 0),
          boxShadow: BoxShadow(
              color: Theme.of(context).backgroundColor, blurRadius: 10),
          width: MediaQuery.of(context).size.width * 0.8,
          backgroundColor: Theme.of(context).focusColor,
          buttonColor: Theme.of(context).canvasColor,
          action: () {
            if (autodopasowanieTrasySpaceru == true) {
              if (ograniczonyCzasSpaceru == true) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WalkAdjustRoute(
                              timeInMinutes: liczbaMinut,
                              animalId: passAnimals,
                            )));
              } else {
                // czas == false
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WalkAdjustRoute(
                              timeInMinutes: null,
                              animalId: passAnimals,
                            )));
              }
            } else {
              if (ograniczonyCzasSpaceru == true) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WalkScreen(
                              timeInMinutes: liczbaMinut,
                              animalId: passAnimals,
                            )));
              } else {
                // czas == false
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WalkScreen(
                              timeInMinutes: null,
                              animalId: passAnimals,
                            )));
              }
            }
          },
          label: Text(
            autodopasowanieTrasySpaceru!
                ? 'Przejdź Dalej>>>'
                : 'Zacznij spacer >>>',
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
    ];

    return ScaffoldClass(
        key: UniqueKey(),
        axis: true,
        appBarIcon: false,
        appBarText: 'Rozpocznij spacer',
        children: walk);
  }
}
