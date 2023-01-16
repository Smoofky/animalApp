import 'package:animal_app/main.dart';
import 'package:animal_app/view/Login%20and%20Register/PwdResetEmail.dart';
import 'package:animal_app/view/User/UserDeleteAccount.dart';
import 'package:animal_app/view/User/UserEditableProfile.dart';
import 'package:animal_app/utils/ScaffoldClass.dart';
import 'package:animal_app/view/User/UserPets.dart';
import 'package:flutter/material.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({Key? key}) : super(key: key);

  @override
  State<UserAccount> createState() => _UserAccount();
}

class _UserAccount extends State<UserAccount> {
  @override
  Widget build(BuildContext context) {
    List<Widget> userOptions = [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 150,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      NetworkImage(user.photo.toString().replaceAll('"', '')))),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Center(
          child: Text(
            user.login.toString(),
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
    List<String> assets = [
      'assets/Dog.png',
      'assets/Happy.png',
      'assets/Eye.png',
      'assets/Delete.png',
    ];
    List<String> textOptions = [
      'Podopieczni',
      'Mój profil',
      'Zmiana hasła',
      'Usunięcie konta',
    ];
    List<Widget> routeOptions = [
      const UserPets(),
      const UserEditableProfile(),
      const PwdResetEmail(),
      const UserDeleteAccount(),
    ];
    for (var i = 0; i < 4; i++) {
      userOptions.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 35, 0),
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => routeOptions[i])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: 45,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 3,
                              color: Color.fromARGB(174, 141, 90, 1)))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                    child: Text(
                      textOptions[i],
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(assets[i]), fit: BoxFit.fill),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ScaffoldClass(axis: false, appBarIcon: true, children: userOptions);
  }
}
