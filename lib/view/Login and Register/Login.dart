import 'dart:convert';
import 'package:animal_app/main.dart';
import 'package:animal_app/utils/Network.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../model/User.dart';
import '../User/UserStartPage.dart';
import 'PwdResetEmail.dart';
import 'Register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordInVisible = true; //toggle pw visibility
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // formkey to locate it easier[testing]
  final AutovalidateMode _autoValidate = AutovalidateMode.onUserInteraction;
  @override
  void initState() {
    super.initState();
    //listUsers = fetchUsers();
  }

  Future login({body}) async {
    String url = '$ServerIP/user/login/';
    NetworkUtil network = NetworkUtil();
    return await network.post(url,
        body: json.encode(body), headers: {"content-type": "application/json"});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final style = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: size.width,
        height: size.height,
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
                width: 200,
                height: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Logo.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  'Paw Paw',
                  style: style.headline1,
                ),
              ),
              Text(
                'Login',
                style: style.headline2,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: 'Email'),
                    style: style.subtitle1,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !EmailValidator.validate(value)) {
                        return 'Please enter valid email address';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextFormField(
                  controller: passwordController,
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PwdResetEmail()));
                },
                child: Text(
                  'Forgot Password',
                  style: style.headline6,
                ),
              ),
              Container(
                height: 70,
                width: 120,
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  child: Text(
                    'Login',
                    style: style.headline4,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // formularz przeszedł walidację
                      User u = User(
                          email: emailController.text,
                          password: passwordController.text);
                      var response = await login(body: u.toMapLogin());
                      if (json.encode(response).contains('detail')) {
                        // odpowiedź od serwera zawiera informacje o błędzie (detail)
                        AwesomeDialog failureDialog = AwesomeDialog(
                          dialogBackgroundColor: Colors.lightGreen.shade100,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.bottomSlide,
                          title: 'Błąd :(',
                          dismissOnTouchOutside: true,
                          body: Text(
                            'Wrong email or password!',
                            style: style.bodySmall,
                          ),
                          btnOkText: 'Ok',
                          btnOkOnPress: () {},
                        );
                        await failureDialog.show();
                      } else {
                        print(json.encode(response));
                        var jwtToken = json.encode(response["Tokens"]);

                        await storage.write(
                            key: 'jwt', value: jwtToken); // global storage

                        user.login = json.decode(
                            json.encode(response["User Info"]["login"]));
                        user.id =
                            int.parse(json.encode(response["User Info"]["id"]));
                        user.coins =
                            json.encode(response["User Info"]["coins"]);
                        user.photo =
                            json.encode(response["User Info"]["photo_url"]);
                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const UserStartPage()),
                            (route) => false);
                      }
                    }
                  },
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Or just ',
                    style: style.headline5,
                  ),
                  GestureDetector(
                    child: Text(
                      'Sign in',
                      style: style.headline6,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
