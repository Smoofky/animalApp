// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:animal_app/utils/ImagePickerClass.dart';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../model/Animal.dart';
import '../../utils/Network.dart';

class AddPet extends StatefulWidget {
  const AddPet({Key? key}) : super(key: key);

  @override
  State<AddPet> createState() => _AddPet();
}

class _AddPet extends State<AddPet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final key = GlobalKey<ScaffoldState>();
  final TextEditingController nameController = TextEditingController(),
      weightController = TextEditingController(),
      heightController = TextEditingController(),
      bioController = TextEditingController(),
      searchQueryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  NetworkUtil netowrk = NetworkUtil();
  bool _isSearching = true;
  String _searchText = "";
  Map<int, String> _searchList = {};
  bool _onTap = false;
  int _onTapTextLength = 0;
  int breedId = -1;
  List<String> petFields = [
    'Wpisz imie...',
    'Wybierz rasę z listy ...',
    'Wybierz datę urodzenia...',
    'Podaj wagę...',
    'Podaj wysokość w centymetrach...',
    'Opowiedz krótko o swoim pupilu...',
  ];

  Future fetchBreedList() async {
    String url = '$ServerIP/breeds';
    NetworkUtil network = NetworkUtil();
    return await network.get(url);
  }

  DateTime selectedDate = DateTime.now();
  var format = DateFormat('yyyy/MM/dd');
  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  Future createPet({body}) async {
    String url = '$ServerIP/animal/${user.id}/add';
    NetworkUtil network = NetworkUtil();
    return await network.post(url,
        body: json.encode(body), headers: {"content-type": "application/json"});
  }

  Future saveAnimalImage(int id, String file) async {
    String? token = await storage.read(key: 'jwt');
    final String jwt = token!.replaceAll('"', '');
    String url = '$ServerIP/animal/$id/animal-image-change';
    NetworkUtil network = NetworkUtil();
    var res = await network.multipartFunc(url, file, jwt);
    return res;
  }

  String dropdownSexopt = 'Pies';

  _AddPet() {
    searchQueryController.addListener(() {
      if (searchQueryController.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
          _searchList = {};
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = searchQueryController.text;

          _onTap = _onTapTextLength == _searchText.length;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isSearching = false;
  }

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme;
    List<String> sexOpt = ['Pies', 'Suczka'];

    return ScaffoldClass(
        resizeToAvoidInset: true,
        key: key,
        appBarText: 'Dodaj nowego pupila',
        appBarIcon: false,
        axis: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ImagePickerClass(),
          ),
          Form(
              key: _formKey,
              child: Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(hintText: petFields[0]),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Uzupełnij pole...";
                              }
                              return null;
                            },
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Wybierz płeć swojego pupila   "),
                          Container(
                              padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
                              child: DropdownButton<String>(
                                value: dropdownSexopt,
                                dropdownColor:
                                    Theme.of(context).bottomAppBarColor,
                                icon: const Icon(Icons.arrow_downward),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownSexopt = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Pies',
                                  'Suczka'
                                ].map<DropdownMenuItem<String>>((String val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(
                                      val,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  );
                                }).toList(),
                              )),
                        ],
                      ),
                      Stack(
                        children: [
                          TextFormField(
                            controller: searchQueryController,
                            focusNode: _focusNode,
                            onFieldSubmitted: (String value) {
                              setState(() {
                                searchQueryController.text = value;
                                _onTap = true;
                              });
                              print(searchQueryController.text);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              hintText: petFields[1],
                            ),
                          ),
                          Container(
                              alignment: Alignment.topCenter,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 50, 20, 10),
//
                              child: _isSearching && (!_onTap)
                                  ? getFutureWidget()
                                  : null),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Wybierz datę urodzenia     "),
                                Container(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _selectDate(context);
                                        },
                                        child: selectedDate != DateTime.now()
                                            ? Text(formatDate(selectedDate,
                                                [yyyy, '-', mm, '-', dd]))
                                            : const Text(
                                                "Podaj datę urodzenia...")))
                              ])),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: weightController,
                            decoration: InputDecoration(hintText: petFields[3]),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Uzupełnij pole...";
                              } else if (double.tryParse(value) == null) {
                                return "Podaj prawidłową wagę!";
                              }
                              return null;
                            },
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: heightController,
                            decoration: InputDecoration(hintText: petFields[4]),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Uzupełnij pole...";
                              } else if (double.tryParse(value) == null) {
                                return "Podaj prawidłową wysokość!";
                              }
                              return null;
                            },
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: TextFormField(
                            controller: bioController,
                            decoration: InputDecoration(hintText: petFields[5]),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Uzupełnij pole...";
                              }
                              return null;
                            },
                          )),
                      Container(
                          height: 70,
                          width: 150,
                          padding: const EdgeInsets.all(15),
                          child: ElevatedButton(
                              child: Text(
                                'Dodaj',
                                style: style.headline4,
                              ),
                              onPressed: () async {
                                _searchList.forEach((key, value) {
                                  if (value == searchQueryController.text) {
                                    breedId = key;
                                  }
                                });
                                print("Breed ID = $breedId");
                                if (_formKey.currentState!.validate() &&
                                    breedId >= 0) {
                                  Animal animal = Animal(
                                    name: nameController.text,
                                    sex: dropdownSexopt,
                                    birthDate: formatDate(
                                        selectedDate, [yyyy, '-', mm, '-', dd]),
                                    weight: double.parse(weightController.text),
                                    height: double.parse(heightController.text),
                                    bio: bioController.text,
                                    breed: breedId,
                                  );

                                  var response =
                                      await createPet(body: animal.toMap());
                                  var animalId = response['Added animal']['id'];
                                  if (animalId != null) {
                                    // dodano zwierzaka
                                    if (animalImage != '') {
                                      // dolaczono zdjecie - update rekordu dodanego zwierzaka
                                      var response = await saveAnimalImage(
                                          animalId, animalImage);
                                      if (response[
                                              'Updated animal\'s picture.'] ==
                                          null) {
                                        AwesomeDialog successDialog =
                                            AwesomeDialog(
                                          dialogBackgroundColor:
                                              Theme.of(context).disabledColor,
                                          context: context,
                                          dialogType: DialogType.success,
                                          animType: AnimType.scale,
                                          dismissOnTouchOutside: false,
                                          body: const Text(
                                              'Sukces! Stworzono profil zwierzaka!'),
                                          btnOkText: 'Ok',
                                          btnOkOnPress: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                        await successDialog.show();
                                      }
                                    } else {
                                      AwesomeDialog successDialog =
                                          AwesomeDialog(
                                        dialogBackgroundColor:
                                            Theme.of(context).disabledColor,
                                        context: context,
                                        dialogType: DialogType.success,
                                        animType: AnimType.scale,
                                        dismissOnTouchOutside: false,
                                        body: const Text(
                                            'Sukces! Stworzono profil zwierzaka!'),
                                        btnOkText: 'Ok',
                                        btnOkOnPress: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                      await successDialog.show();
                                    }
                                  } else {
                                    AwesomeDialog failureDialog = AwesomeDialog(
                                      dialogBackgroundColor:
                                          Theme.of(context).disabledColor,
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.scale,
                                      dismissOnTouchOutside: false,
                                      body: const Text('Coś poszło nie tak :('),
                                      btnOkText: 'Ok',
                                      btnOkOnPress: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                    await failureDialog.show();
                                  }
                                }
                              }))
                    ],
                  ),
                ),
              ))
        ]);
  }

  ListTile _getListTile(String suggestedPhrase) {
    return ListTile(
      dense: true,
      title: Text(
        suggestedPhrase,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: () {
        setState(() {
          _onTap = true;
          _isSearching = false;
          _onTapTextLength = suggestedPhrase.length;
          searchQueryController.text = suggestedPhrase;
        });
        searchQueryController.selection = TextSelection.fromPosition(
            TextPosition(offset: suggestedPhrase.length));
      },
    );
  }

  Widget getFutureWidget() {
    return FutureBuilder(
        future: _buildSearchList(),
        initialData: const <ListTile>[],
        builder:
            (BuildContext context, AsyncSnapshot<List<ListTile>> childItems) {
          return Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: ListView(
//            padding: new EdgeInsets.only(left: 50.0),
              children: childItems.data != null
                  ? ListTile.divideTiles(
                          context: context,
                          tiles: getChildren(childItems) as Iterable<Widget>)
                      .toList()
                  : [],
            ),
          );
        });
  }

  List<ListTile>? getChildren(AsyncSnapshot<List<ListTile>> childItems) {
    if (_onTap && _searchText.length != _onTapTextLength) _onTap = false;
    List<ListTile>? childrenList =
        _isSearching && !_onTap ? childItems.data : [];
    return childrenList;
  }

  Future<List<ListTile>> _buildSearchList() async {
    if (_searchText.isEmpty) {
      _searchList = {};
      return [];
    } else {
      _searchList = await _getSuggestion(_searchText) ?? {};

      List<ListTile> childItems = [];
      _searchList.forEach((key, value) {
        childItems.add(_getListTile(value));
      });

      return childItems;
    }
  }

  Future<Map<int, String>?> _getSuggestion(String hintText) async {
    String url = "$ServerIP/breeds";
    var response = await http.get(Uri.parse(url));
    var decode = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 201 || decode.isEmpty) {
      return null;
    }
    Map<int, String> suggestedWords = {};
    print(response.body);
    for (var f in decode['All breeds']) {
      if (f['name'].toString().toLowerCase().contains(hintText)) {
        suggestedWords.addAll({f['id']: f['name']});
      }
    }
    return suggestedWords;
  }
}
