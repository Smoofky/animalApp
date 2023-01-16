import 'package:animal_app/view/Login%20and%20Register/Login.dart';
import 'package:animal_app/view/User/UserStartPage.dart';
import 'package:animal_app/utils/DrawerItem.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ScaffoldClass extends StatelessWidget {
  ScaffoldClass(
      {Key? key,
      required this.children,
      this.appBarText,
      this.appBarIcon,
      required this.axis,
      this.resizeToAvoidInset})
      : super(key: key);

  final List<Widget> children;
  final String? appBarText;
  final bool? appBarIcon;
  final bool? axis;
  final bool? resizeToAvoidInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidInset == null ? false : true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          title: appBarText != null ? Text(appBarText!) : const Text(''),
          leading: appBarIcon == true
              ? IconButton(
                  icon: const Icon(Icons.pets),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserStartPage())),
                )
              : appBarIcon == null
                  ? const Text('')
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    )),
      endDrawer: const DrawerBar(),
      body: !axis!
          ? Column(children: children)
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            ),
    );
  }
}
