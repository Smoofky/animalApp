import 'dart:io';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../Login and Register/Login.dart';

/*
Dodać form walidację
Uzupełnić dane z bazy
Przycisk uaktualnia dane jeżeli są poprawne itp.
*/
enum ImageSourceType { gallery, camera }

class UserEditableProfile extends StatefulWidget {
  const UserEditableProfile({Key? key}) : super(key: key);

  @override
  State<UserEditableProfile> createState() => _UserEditableProfile();
}

class _UserEditableProfile extends State<UserEditableProfile> {
  List<String> userData = [
    'Adrian',
    'Nowak',
    'Żalno',
    'Adrainno@żal.pl',
    '21',
    '777888999',
    'Mężczyzna'
  ];
  List<String> userFields = [
    'imie',
    'nazwisko',
    'miejscowość',
    'email',
    'wiek',
    'telefon',
    'płeć'
  ];
  var imagePicker;
  var type;
  var _image;
  
  @override
  void initState()  {imagePicker = ImagePicker();
    
    super.initState();
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
    List<Widget> editableWidgets = [];
    //List<TextEditingController> listOfControllers =
    //    List.generate(userData.length, (i) => TextEditingController());
    for (var i = 0; i < userData.length; i++) {
      //listOfControllers[i].text = userData[i];
      editableWidgets.add(
        Container(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: TextFormField(
            initialValue: userData[i],
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
      children: [
      GestureDetector(
          onTap: () {
            AlertDialog alert = AlertDialog(
              content: Text(
                'Ustaw swoje zdjęcie',
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
