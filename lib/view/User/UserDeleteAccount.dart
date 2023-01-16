import 'package:animal_app/main.dart';
import 'package:flutter/material.dart';

import '../Login and Register/Login.dart';
import '../Login and Register/PwdResetEmail.dart';
import '../Login and Register/Register.dart';
import 'UserStartPage.dart';

class UserDeleteAccount extends StatefulWidget {
  const UserDeleteAccount({Key? key}) : super(key: key);
  @override
  State<UserDeleteAccount> createState() => _UserDeleteAccount();
}

class _UserDeleteAccount extends State<UserDeleteAccount> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordInVisible = true; //a boolean value
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Logowanie.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * .45,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  'W celu usunięcia swojego konta prosimy, abyś wpisał swoje hasło celem weryfikacji. Pamiętaj, że dany proces jest nieodwracalny.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextFormField(
                  obscureText: _passwordInVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: IconButton(
                      icon: Icon(_passwordInVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordInVisible = !_passwordInVisible;
                        });
                      },
                    ),
                  ),
                  style: Theme.of(context).textTheme.subtitle1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 40,
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Anuluj',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 180,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Wysylamy kod i przekazujemy go do kolejnej aktywnosic
                          // tu ta funkcja z początku async

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => Login(),
                            ),
                            (route) => false,
                          );
                        } else {
                          setState(
                              () => _autoValidate = AutovalidateMode.always);
                        }
                      },
                      child: Text(
                        'Usuń konto',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
