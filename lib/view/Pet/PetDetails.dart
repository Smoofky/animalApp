import 'package:animal_app/view/Pet/AddPet.dart';
import 'package:animal_app/view/Pet/EditPet.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/getwidget.dart';
import '../../model/Animal.dart';
import '../../utils/ScaffoldClass.dart';

class PetDetails extends StatefulWidget {
  PetDetails({Key? key, required this.animal}) : super(key: key);
  Animal animal;
  @override
  State<PetDetails> createState() => _PetDetails();
}

class _PetDetails extends State<PetDetails> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldClass(
      appBarIcon: false,
      axis: true,
      children: [
        Center(
          child: CircleAvatar(
            backgroundColor: Colors.green.shade400,
            radius: 101,
            child: CircleAvatar(
              radius: 100,
              backgroundImage: NetworkImage(widget.animal.photo!), //Text
            ), //CircleAvatar
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Center(
            child: Text(
              widget.animal.name.toString(),
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Center(
            child: Text(
              "${widget.animal.sex}\nur. ${widget.animal.birthDate}",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 45, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) =>
                            EditPet(animal: widget.animal)))),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.17,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Center(
                    child: Text(
                      'Edytuj dane',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).focusColor,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.17,
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
                  height: MediaQuery.of(context).size.height * 0.17,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Center(
                    child: Text(
                      'Pinezki',
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
