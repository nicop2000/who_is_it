import 'package:flutter/cupertino.dart';
import 'package:who_is_it/views/add/tabs/add_category.dart';
import 'package:who_is_it/views/add/tabs/add_picture.dart';

class TabViewController extends StatefulWidget {
  const TabViewController({Key? key}) : super(key: key);

  @override
  State<TabViewController> createState() => _TabViewControllerState();
}

class _TabViewControllerState extends State<TabViewController> {
  final List<Widget> _tabs = [
    const AddCategory(),
    const AddPicture()
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Daten zum Spiel hinzufügen'),
      ),
      child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              //TODO: Icons
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'Neue Kategorie'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.camera), label: 'Neues Bild')
            ],
          ),
          tabBuilder: (BuildContext context, index) {
            return _tabs[index];
          }),
    );
  }
}
