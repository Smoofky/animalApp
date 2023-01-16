import 'package:animal_app/utils/ListTileClass.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../utils/ScaffoldClass.dart';

class UserPets extends StatefulWidget {
  const UserPets({Key? key}) : super(key: key);

  @override
  State<UserPets> createState() => _UserPets();
}

class _UserPets extends State<UserPets> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldClass(
      axis: true,
      appBarIcon: false,
      appBarText: 'Podopieczni',
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        user.photo.toString().replaceAll('"', '')))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Center(
            child: Text(
              user.login.toString(),
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Text(
            'Twoi podopieczni',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        ListTileClass(),
      ],
    );
  }
}
