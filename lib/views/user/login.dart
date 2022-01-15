import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:who_is_it/helper.dart';
import 'package:who_is_it/views/loading_page.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var loginForm = GlobalKey<FormState>();

  @override
  void initState() {
    emailController.text = "petersen.nico@icloud.com";
    passwordController.text = "Petersen1!";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Helper.getHeadline("Einloggen"),
            const Spacer(),
            Form(
              key: loginForm,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: () {
                Form.of(primaryFocus!.context!)?.save();
              },
              child: Column(
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text('E-Mail'),
                    controller: emailController,
                    placeholder: 'E-Mailadresse eingeben',
                    padding: const EdgeInsets.all(10.0),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.none,
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          !EmailValidator.validate(value)) {
                        return 'Bitte eine gültige E-Mailadresse eingeben';
                      }
                      return null;
                    },
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: const Text('Passwort'),
                    controller: passwordController,
                    placeholder: 'Passwort eingeben',
                    obscureText: true,
                    padding: const EdgeInsets.all(10.0),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.none,
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          !Helper.validatePasswordStrength(value)) {
                        return "Das Passwort entspricht nicht den Richlinien. Es muss Groß- und Kleinschreibung, sowie Zahlen und Sonderzeichen enthalten, sowie mind. 8 Zeichen lang sein.";
                      }
                      return null;
                    },
                  ),
                  CupertinoButton(
                      child: const Text("Einloggen"),
                      onPressed: () {
                        if (loginForm.currentState!.validate()) {
                          FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text)
                              .then(
                            (_) {
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => LoadingPage(),
                                ),
                              );
                            },
                          ).catchError((error) {});
                        }
                      }),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
