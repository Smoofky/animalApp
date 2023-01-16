import 'dart:io';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/Animal.dart';

/*
Dodać form walidację
Uzupełnić dane z bazy
Przycisk uaktualnia dane jeżeli są poprawne itp.
*/
enum ImageSourceType { gallery, camera }

class EditPet extends StatefulWidget {
  EditPet({Key? key, required this.animal}) : super(key: key);
  Animal animal;
  @override
  State<EditPet> createState() => _EditPet();
}

class _EditPet extends State<EditPet> {
  List<String> userFields = [
    'imię',
    'rasę',
    'płeć',
    'datę urodzenia',
    'wagę',
    'opis',
  ];
  var imagePicker;
  var type;
  var _image;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  void pickImage() async {
    var source = type == ImageSourceType.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    XFile image = await imagePicker.pickImage(
        source: source,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    List animalParameters = [];
    animalParameters.addAll([
      widget.animal.name,
      widget.animal.kind,
      widget.animal.sex,
      widget.animal.birthDate,
      widget.animal.weight.toString(),
      widget.animal.bio,
    ]);

    List<Widget> editableWidgets = [];
    //List<TextEditingController> listOfControllers =
    //    List.generate(userData.length, (i) => TextEditingController());
    for (var i = 0; i < 6; i++) {
      //listOfControllers[i].text = userData[i];

      editableWidgets.add(
        Container(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: TextFormField(
            initialValue: animalParameters[i],
            //controller: listOfControllers[i],
            decoration: InputDecoration(
              labelText: 'Podaj ${userFields[i]}',
              hintText: userFields[i],
            ),
          ),
        ),
      );
    }
    return ScaffoldClass(
        axis: true,
        appBarIcon: false,
        appBarText: widget.animal.name,
        children: [
          GestureDetector(
              onTap: () {
                AlertDialog alert = AlertDialog(
                  content: Text(
                    'Ustaw zdjęcie',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  actions: [
                    TextButton(
                        style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        onPressed: () {
                          type = ImageSourceType.camera;
                          Navigator.pop(context);
                          pickImage();
                        },
                        child: Text(
                          'Zrób teraz',
                          style: Theme.of(context).textTheme.headline3,
                        )),
                    TextButton(
                        style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        onPressed: () {
                          type = ImageSourceType.gallery;
                          Navigator.pop(context);
                          pickImage();
                        },
                        child: Text(
                          'Galeria',
                          style: Theme.of(context).textTheme.headline3,
                        ))
                  ],
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              child: _image != null
                  ? Stack(alignment: Alignment.bottomRight, children: [
                      CircleAvatar(
                          backgroundImage: FileImage(_image),
                          radius: MediaQuery.of(context).size.height * .1),
                      const Icon(Icons.edit),
                    ])
                  : Image.asset('assets/user.png')),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: editableWidgets,
              ),
            ),
          ),
        ]);
  }
}
