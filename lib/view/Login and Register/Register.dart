import 'dart:convert';
import 'package:animal_app/main.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../model/User.dart';
import 'Login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  bool passwordInVisible = true;
  bool? valueRegulations = false; //a boolean value
  bool? valuePersonalData = false; //a boolean value
  String chbValidationRegulations = ""; // error msg var
  String chbValidationPersonalData = ""; // error msg var
  AutovalidateMode autoValidate = AutovalidateMode.onUserInteraction;

  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future createUser({body}) async {
    NetworkUtil network = NetworkUtil();
    String url = '$ServerIP/user/mobile_register';
    return await network.post(url,
        body: json.encode(body), headers: {"content-type": "application/json"});
  }

  @override
  void dispose() {
    emailController.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
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
          autovalidateMode: autoValidate,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Register',
                style: style.headline2,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: 'Email'),
                    style: Theme.of(context).textTheme.subtitle1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email address';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Not a vaild email address.';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: TextFormField(
                    controller: loginController,
                    decoration: const InputDecoration(hintText: 'Login'),
                    style: style.subtitle1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter login';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: passwordInVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(passwordInVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      color: Theme.of(context).iconTheme.color,
                      iconSize: Theme.of(context).iconTheme.size,
                      onPressed: () {
                        setState(() {
                          passwordInVisible = !passwordInVisible;
                        });
                      },
                    ),
                  ),
                  style: style.subtitle1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                },
                child: Text(
                  'Or Log in!',
                  style: style.headline6,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login())),
                  child: Text(
                    'I accept the conditions.',
                    style: style.headline6,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Column(children: [
                  Checkbox(
                    value: valueRegulations,
                    onChanged: (bool? value) {
                      setState(() {
                        valueRegulations = value;
                        if (valueRegulations! == false) {
                          chbValidationRegulations = "Required!";
                        } else {
                          chbValidationRegulations = "";
                        }
                      });
                    },
                  ),
                  Text(chbValidationRegulations,
                      style: TextStyle(color: Theme.of(context).errorColor)),
                ]),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login())),
                  child: Text(
                    'I agree to the\nprocessing of personal data.',
                    style: style.headline6,
                    softWrap: true,
                  ),
                ),
                Column(
                  children: [
                    Checkbox(
                      value: valuePersonalData,
                      onChanged: (bool? value) {
                        setState(() {
                          valuePersonalData = value;
                          if (valuePersonalData! == false) {
                            chbValidationPersonalData = "Required!";
                          } else {
                            chbValidationPersonalData = "";
                          }
                        });
                      },
                    ),
                    Text(chbValidationPersonalData,
                        style: TextStyle(color: Theme.of(context).errorColor)),
                  ],
                )
              ]),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  child: Text(
                    'Register',
                    style: style.headline4,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        valuePersonalData! &&
                        valueRegulations!) {
                      // api call db save itp
                      User user = User(
                          email: emailController.text,
                          password: passwordController.text,
                          login: loginController.text);
                      print(user.toMapLogin());
                      var u = await createUser(body: user.toMapLogin());
                      print(u);
                      if (u == "Internal Server Error") {
                        AwesomeDialog failureDialog = AwesomeDialog(
                          dialogBackgroundColor:
                              Theme.of(context).disabledColor,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.bottomSlide,
                          title: 'Błąd przy rejestracji :(',
                          dismissOnTouchOutside: true,
                          body: Text(u),
                          btnOkText: 'Ok',
                          btnOkOnPress: () {},
                        );

                        await failureDialog.show();
                      } else {
                        AwesomeDialog successDialog = AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          dialogBackgroundColor: Colors.lightGreen.shade100,
                          animType: AnimType.bottomSlide,
                          title: 'Udało się zarejestrować',
                          dismissOnTouchOutside: true,
                          btnOkOnPress: () => Navigator.pop(context),
                          btnOkText: 'Zaloguj się',
                        );

                        await successDialog.show();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      }
                    } else {
                      setState(() {
                        autoValidate = AutovalidateMode.always;
                        if (!valuePersonalData!) {
                          chbValidationPersonalData = "Required!";
                        }
                        if (!valueRegulations!) {
                          chbValidationRegulations = "Required!";
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
