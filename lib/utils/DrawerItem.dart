import 'package:animal_app/view/User/UserAccount.dart';
import 'package:animal_app/view/User/UserActivity.dart';
import 'package:animal_app/view/User/UserStartPage.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../view/Login and Register/Login.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class DrawerBar extends StatefulWidget {
  @override
  State<DrawerBar> createState() => _DrawerBar();

  const DrawerBar({Key? key}) : super(key: key);
}

class _DrawerBar extends State<DrawerBar> {
  int _index = -1;
  bool _isDisabled = false;
  final _drawerItems = [
    DrawerItem("Konto", Icons.account_circle_sharp),
    DrawerItem("Aktywność", Icons.directions_run_sharp),
    DrawerItem("Wyloguj", Icons.logout_sharp),
  ];
  _navigateClearRoute(Widget route) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => route,
      ),
      (route) => false,
    );
  }

  _onSelectItem(int index) {
    switch (index) {

      // Account
      case 0:
        return _navigateClearRoute(const UserAccount());

      // Activity
      case 1:
        return _navigateClearRoute(const UserActivity());

      // Chat
      case 2:
        return _navigateClearRoute(const Login());

      default:
      //return Start();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < _drawerItems.length; i++) {
      var d = _drawerItems[i];
      drawerOptions.add(Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 15),
          child: Container(
              decoration: BoxDecoration(
                color: _index == i ? Colors.yellow : Colors.transparent,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(
                  15,
                ),
              ),
              child: ListTile(
                title: Text(
                  d.title,
                  style: Theme.of(context).textTheme.headline3,
                ),
                trailing: Icon(
                  d.icon,
                  size: Theme.of(context).iconTheme.size,
                  color: Colors.black87,
                ),
                selected: i == _index,
                onTap: () {
                  _index == i
                      ? setState(() {
                          _index = i;
                        })
                      : _onSelectItem(i);
                  setState(() {
                    _index = i;
                  });
                },
              ))));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
        ),
        width: MediaQuery.of(context).size.width * 2 / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Column(children: drawerOptions)],
        ),
      ),
    );
  }
}
