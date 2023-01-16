import 'package:animal_app/main.dart';
import 'package:animal_app/view/Login%20and%20Register/Login.dart';
import 'package:animal_app/view/Pet/PetDetails.dart';
import 'package:animal_app/view/User/UserActivity.dart';
import 'package:animal_app/view/Walk/WalkStartPage.dart';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:flutter/material.dart';
import 'UserPets.dart';

class UserStartPage extends StatefulWidget {
  const UserStartPage({Key? key}) : super(key: key);

  @override
  State<UserStartPage> createState() => _UserStartPage();
}

class _UserStartPage extends State<UserStartPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldClass(
      axis: true,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 250,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      NetworkImage(user.photo.toString().replaceAll('"', '')))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: Center(
            child: Text(
              "Witaj ${user.login}!\nPosiadasz ${user.coins} monet.",
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WalkStartPage())),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Center(
                    child: Text(
                      'Spacer',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UserPets())),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Center(
                    child: Text(
                      'Zwierzaki',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Center(
                    child: Text(
                      'Konto',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserActivity())),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Center(
                    child: Text(
                      'Aktywność',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
