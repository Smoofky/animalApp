import 'package:animal_app/main.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:animal_app/view/Pet/PetDetails.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'dart:convert';

import '../model/Animal.dart';
import '../view/Pet/AddPet.dart';

class ListTileClass extends StatefulWidget {
  const ListTileClass({Key? key, this.animals}) : super(key: key);
  final Future<List<Animal>>? animals;
  @override
  State<ListTileClass> createState() => _ListTileClass();
}

class _ListTileClass extends State<ListTileClass> {
  List<Animal> parseAnimals(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Animal>((json) => Animal.fromJson(json)).toList();
  }

  Future<List<Animal>> fetchUserAnimals(int id) async {
    NetworkUtil network = NetworkUtil();
    String url = "http://192.168.0.129:8000/users/$id/animals";

    final result = await (network.get(url));
    return parseAnimals(
        json.encode(result['Animals with user_id: ${user.id!}']));
  }

  Future animalDelete(int id) async {
    String url = 'http://192.168.0.129:8000/animal/delete/$id';
    NetworkUtil network = NetworkUtil();
    return network.delete(url);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
      child: FutureBuilder<List<Animal>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error} occured'));
            } else if (snapshot.hasData) {
              List<Widget> pets = [];
              for (var i = 0; i < snapshot.data!.length; i++) {
                pets.add(GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PetDetails(animal: snapshot.data![i]))),
                  child: GFListTile(
                    color: Theme.of(context).bottomAppBarColor,
                    avatar: GFAvatar(
                      size: 50,
                      backgroundImage: NetworkImage(snapshot.data![i].photo!),
                    ),
                    title: Text(
                      '${snapshot.data![i].name}, ${snapshot.data![i].sex}\nur. ${snapshot.data![i].birthDate}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    icon: IconButton(
                      icon: Icon(Icons.delete),
                      iconSize: 40,
                      onPressed: () async {
                        //pets.removeAt(i);
                        print(i);
                        var res = await animalDelete(snapshot.data![i].id!);
                        print(res);
                        print(snapshot.data![i].id!);
                        if (res['detail'] != null) {
                          //zwierze nie istnieje w bazie
                          AwesomeDialog failureDialog = AwesomeDialog(
                            dialogBackgroundColor: Colors.lightGreen.shade100,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.bottomSlide,
                            title: 'Błąd :(',
                            dismissOnTouchOutside: true,
                            body: Text(
                              'Zwierze nie istnieje!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            btnOkText: 'Ok',
                            btnOkOnPress: () {},
                          );
                          await failureDialog.show();
                        } else {
                          AwesomeDialog successDialog = AwesomeDialog(
                            dialogBackgroundColor: Colors.lightGreen.shade100,
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.scale,
                            title: 'Usunięto !',
                            dismissOnTouchOutside: true,
                            body: Text(
                              'Usunięto!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            btnOkText: 'Ok',
                            btnOkOnPress: () {
                              setState(() {});
                            },
                          );
                          await successDialog.show();
                        }
                      },
                    ),
                  ),
                ));
              }
              pets.add(GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddPet())),
                child: GFListTile(
                  color: Theme.of(context).bottomAppBarColor,
                  avatar: const GFAvatar(
                      size: 50,
                      backgroundImage: AssetImage('assets/Dog_black.png'),
                      child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image(
                            image: AssetImage('assets/add.png'),
                            alignment: Alignment.bottomRight,
                          ))),
                  title: Text(
                    'Dodaj nowego zwierzaka',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ));
              return Column(
                children: pets,
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
        future: fetchUserAnimals(user.id!),
      ),
    ));
  }
}
