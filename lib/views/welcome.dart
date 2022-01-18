import 'package:flutter/cupertino.dart';
import 'package:who_is_it/views/user/login.dart';
import 'package:who_is_it/views/user/register.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        transitionBetweenRoutes: true,
        middle: Text("Wer ist es?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CupertinoButton(
                    child: const Text("Einloggen"),
                    onPressed: () => showCupertinoDialog(
                        context: context,
                        builder: (BuildContext bc) {
                          return const CupertinoAlertDialog(
                            title: Text("Einloggen"),
                            content: Login(),
                          );
                        })),
                CupertinoButton(
                    child: const Text("Registrieren"),
                    onPressed: () => showCupertinoDialog(
                        context: context,
                        builder: (BuildContext bc) {
                          return const CupertinoAlertDialog(
                            title: Text("Neuen Account erstellen"),
                            content: Register(),
                          );
                        })),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  

}
