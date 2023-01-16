import 'dart:async';
import 'dart:convert';

import 'package:animal_app/main.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:animal_app/view/Login%20and%20Register/Login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import '../../model/User.dart';

class PwdResetEmail extends StatefulWidget {
  const PwdResetEmail({Key? key}) : super(key: key);

  @override
  State<PwdResetEmail> createState() => _PwdResetEmail();
}

class _PwdResetEmail extends State<PwdResetEmail> {
  TextEditingController emailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController pwdRepeatController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isDiasbled = false; // for the "Next" button
  String _password = "", _passwordConfirm = "";
  bool _passwordInVisible1 = true,
      _passwordInVisible2 = true; //a boolean value; //a boolean value
  Future emailSender({body}) async {
    String url = '$ServerIP/user/recovery_password';
    NetworkUtil network = NetworkUtil();

    return await network.post(url,
        body: json.encode(body), headers: {"content-type": "application/json"});
  }

  Future pwdChanger({body}) async {
    String url = '$ServerIP/user/password_recovery_page';
    NetworkUtil network = NetworkUtil();

    return await network.post(url,
        body: json.encode(body), headers: {"content-type": "application/json"});
  }

  int timeClicked = 0;
  @override
  Widget build(BuildContext context) {
    List<String> information = [
      'Please, let us verify who you are! Fill the email box and click "Next".',
      'We\'ve sent a confirmation code. Please check your email.',
      'Type your new password!'
    ];
    List<Widget> pwdProcess = [
      Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email...',
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                  suffixIcon: Icon(
                    Icons.email_rounded,
                    color: IconTheme.of(context).color,
                    size: IconTheme.of(context).size,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email.';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Not a vaild email address.';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'Enter the code...',
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                  suffixIcon: Icon(
                    Icons.numbers_rounded,
                    color: IconTheme.of(context).color,
                    size: IconTheme.of(context).size,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your code';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextFormField(
                controller: pwdController,
                obscureText: _passwordInVisible1,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: IconButton(
                    icon: Icon(_passwordInVisible1
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordInVisible1 = !_passwordInVisible1;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: TextFormField(
                controller: pwdRepeatController,
                obscureText: _passwordInVisible2,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: IconButton(
                    icon: Icon(_passwordInVisible2
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordInVisible2 = !_passwordInVisible2;
                      });
                    },
                  ),
                ),
                style: Theme.of(context).textTheme.subtitle1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter confirm password';
                  }
                  if (value != pwdController.text) {
                    return 'Confirm password not matching';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    ];

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: 200,
              height: 120,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Logo.png'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                'Reset your password',
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            ),
            pwdProcess[timeClicked],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                border: Border.all(width: 5),
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: Text(information[timeClicked],
                  style: Theme.of(context).textTheme.headline3),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 40,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => timeClicked == 0);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Go back',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!isDiasbled) {
                        // disabled = false
                        setState(() => isDiasbled = !isDiasbled);
                        Timer(const Duration(seconds: 5),
                            () => isDiasbled = !isDiasbled);
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            timeClicked++;
                          });
                          print("Timeclicked = $timeClicked");
                          if (timeClicked == 1) {
                            var body = {"email_receiver": emailController.text};
                            var response = await emailSender(body: body);
                          }
                          if (timeClicked == 3) {
                            setState(
                              () => timeClicked--,
                            );
                            // proba zapisania hasla
                            var body = {
                              "email_receiver": emailController.text,
                              "recovery_token": codeController.text,
                              "new_password": pwdController.text,
                              "new_password_repeat": pwdRepeatController.text
                            };
                            var response = await pwdChanger(body: body);

                            if (response['detail'] ==
                                    "Recovery token is invalid! (emailHelpers file)" ||
                                response == "Internal Server Error") {
                              AwesomeDialog failureDialog = AwesomeDialog(
                                dialogBackgroundColor:
                                    Colors.lightGreen.shade100,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.bottomSlide,
                                dismissOnTouchOutside: true,
                                body: Text(
                                  'The code is invalid.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                btnOkText: 'Ok',
                                btnOkOnPress: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const Login()),
                                      (route) => false);
                                },
                              );
                              await failureDialog.show();
                            } else {
                              AwesomeDialog successDialog = AwesomeDialog(
                                dialogBackgroundColor:
                                    Colors.lightGreen.shade100,
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.scale,
                                title: 'Błąd :(',
                                dismissOnTouchOutside: true,
                                body: Text(
                                  'Password changed!',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                btnOkText: 'Ok',
                                btnOkOnPress: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const Login()),
                                      (route) => false);
                                },
                              );
                              await successDialog.show();
                            }
                          }
                        }
                      }
                    },
                    child: Text(
                      'Next',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
