import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:who_is_it/helper.dart';
import 'package:who_is_it/model/user_model.dart';
import 'package:who_is_it/views/loading_page.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepeatController = TextEditingController();
  var registerForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Helper.getHeadline("Neuen Account anlegen"),
            const Spacer(),
            Form(
              key: registerForm,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: () {
                Form.of(primaryFocus!.context!)?.save();
              },
              child: Column(
                children: [
                  CupertinoTextFormFieldRow(
                    prefix: const Text('Name'),
                    controller: nameController,
                    placeholder: 'Anzeigenamen eingeben',
                    padding: const EdgeInsets.all(10.0),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.none,
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Bitte gebe einen Namen ein';
                      }
                      return null;
                    },
                  ),
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
                  CupertinoTextFormFieldRow(
                    prefix: const Text('Passwortwiederholung'),
                    controller: passwordRepeatController,
                    placeholder: 'Passwort wiederholen',
                    obscureText: true,
                    padding: const EdgeInsets.all(10.0),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.none,
                    validator: (String? value) {
                      if (passwordController.text !=
                          passwordRepeatController.text) {
                        return "Die beiden Passwörter stimmen nicht überein";
                      }
                      return null;
                    },
                  ),
                  CupertinoButton(
                      child: const Text("Account erstellen"),
                      onPressed: () {
                        if (registerForm.currentState!.validate()) {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text)
                              .then((user) async {
                                await FirebaseFirestore.instance.collection('gameNumbers').doc(user.user!.uid).set({"picture": -1});
                                DocumentReference userDocument = FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(user.user!.uid);
                                await userDocument.set(
                                    UserModel(nameController.text, [], [], [])
                                        .toJson());
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => LoadingPage(),
                                  ),
                                );
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext bc) {
                                  return CupertinoAlertDialog(
                                    title: const Text(
                                        "Account anlegen erfolgreich"),
                                    content: Column(
                                      children: const [
                                        Text(
                                            "Der Account wurde erfolgreich angelegt"),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: const Text("OK"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ],
                                  );
                                });
                          });
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
