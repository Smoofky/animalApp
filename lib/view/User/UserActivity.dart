import 'dart:convert';

import 'package:animal_app/main.dart';
import 'package:animal_app/view/Login%20and%20Register/PwdResetEmail.dart';
import 'package:animal_app/view/User/UserDeleteAccount.dart';
import 'package:animal_app/view/User/UserEditableProfile.dart';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:animal_app/view/User/UserPets.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/Walk.dart';
import '../../utils/Network.dart';

class UserActivity extends StatefulWidget {
  const UserActivity({Key? key}) : super(key: key);

  @override
  State<UserActivity> createState() => _UserActivity();
}

class _UserActivity extends State<UserActivity> {
  late Future<List<Walk>> walkList;

  Future<List<Walk>> fetchWalkList() async {
    String url = '$ServerIP/walks';
    String? token = await storage.read(key: 'jwt');
    final String jwt = token!.replaceAll('"', '');
    NetworkUtil network = NetworkUtil();
    final result =
        await network.get(url, headers: {'Authorization': 'Bearer $jwt'});

    return parseWalks(json.encode(result['Walks']));
  }

  List<Walk> parseWalks(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Walk>((json) => Walk.fromJson(json)).toList();
  }

  Future walkDelete(int id) async {
    String url = '$ServerIP/walk/delete/$id';
    String? token = await storage.read(key: 'jwt');
    final String jwt = token!.replaceAll('"', '');
    final headers = {'Authorization': 'Bearer $jwt'};
    NetworkUtil network = NetworkUtil();
    return network.delete(url, headers: headers);
  }

  @override
  void initState() {
    walkList = fetchWalkList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldClass(
        axis: false,
        appBarIcon: true,
        appBarText: "Lista odbytych spacerów",
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder<List<Walk>>(
                  future: walkList,
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(child: Text('${snapshot.error} occured'));
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        // future resolved
                        return SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.85,
                            child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onLongPress: () async {
                                      var res = await walkDelete(
                                          snapshot.data![index].id!);
                                      print(res);
                                      if (res['Deleted walk']['message'] ==
                                          'Record successfully deleted') {
                                        AwesomeDialog successDialog =
                                            AwesomeDialog(
                                          dialogBackgroundColor:
                                              Theme.of(context).disabledColor,
                                          context: context,
                                          dialogType: DialogType.success,
                                          animType: AnimType.scale,
                                          dismissOnTouchOutside: false,
                                          body: Text(
                                              res['Deleted walk']['message']),
                                          btnOkText: 'Ok',
                                          btnOkOnPress: () {
                                            setState(() {});
                                          },
                                        );

                                        await successDialog.show();
                                      } else {
                                        AwesomeDialog failureDialog =
                                            AwesomeDialog(
                                          dialogBackgroundColor:
                                              Theme.of(context).disabledColor,
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.scale,
                                          dismissOnTouchOutside: true,
                                          body: Text(res),
                                          btnOkText: 'Ok',
                                          btnOkOnPress: () {
                                            ;
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 40, 10, 5),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.55,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 31, 104, 60),
                                            border: Border.all(
                                                width: 2, color: Colors.black),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context)
                                                      .focusColor,
                                                  blurRadius: 5)
                                            ]),
                                        child: Row(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                snapshot.data![index].photo!
                                                        .isEmpty
                                                    ? SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        child: const Text(
                                                            'No image :('))
                                                    : Image.memory(
                                                        Uint8List.fromList(
                                                            snapshot
                                                                .data![index]
                                                                .photo!
                                                                .cast()),
                                                        scale: 5.5,
                                                        fit: BoxFit.fill,
                                                      ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(15),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                RichText(
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(children: [
                                                      const WidgetSpan(
                                                          child: Icon(
                                                        Icons.timer_sharp,
                                                        size: 50,
                                                      )),
                                                      TextSpan(
                                                          text:
                                                              '\n${snapshot.data![index].time!}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge)
                                                    ])),
                                                RichText(
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(children: [
                                                      const WidgetSpan(
                                                          child: Icon(
                                                        Icons.directions_walk,
                                                        size: 50,
                                                      )),
                                                      TextSpan(
                                                          text:
                                                              '\n${snapshot.data![index].distance!} km',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge)
                                                    ])),
                                                RichText(
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(children: [
                                                      WidgetSpan(
                                                          child: Image.asset(
                                                        'assets/Coin.png',
                                                        scale: 0.9,
                                                      )),
                                                      TextSpan(
                                                          text:
                                                              '\n${snapshot.data![index].coins!}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge)
                                                    ])),
                                              ],
                                            ),
                                          )
                                        ])),
                                  );
                                }));
                      } else if (snapshot.data!.isEmpty) {
                        return SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .9,
                          child: const Center(child: Text('BRAK DANYCH')),
                        );
                      }
                    }
                    return SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * .9,
                      child: const Center(
                          child: CircularProgressIndicator.adaptive()),
                    );
                  })),
            ),
          )
        ]);
  }
}
