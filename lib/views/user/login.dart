import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
    // emailController.text = "petersen.nico@icloud.com";
    // passwordController.text = "Petersen1!";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: loginForm,
          autovalidateMode: AutovalidateMode.disabled,
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
                autocorrect: false,
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
                autocorrect: false,
              ),

              CupertinoButton(
                  child: const Text("Einloggen", style: TextStyle(fontWeight: FontWeight.bold),),
                  onPressed: () {
                    if (loginForm.currentState!.validate()) {
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text)
                          .then(
                        (_) {
                          Navigator.of(context).pop();
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
              CupertinoButton(
                  child: const Text("Abbrechen"),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),

      ],
    );
  }
}
