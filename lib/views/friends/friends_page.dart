import 'package:flutter/cupertino.dart';
import 'package:who_is_it/views/friends/tabs/invites.dart';
import 'package:who_is_it/views/friends/tabs/search_and_request.dart';


class FriendsPage extends StatelessWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [
      const SearchPage(),
      const InvitesPage()
    ];
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Freunde'),
      ),
      child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: 'Suchen'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.arrow_down), label: 'Anfragen')
            ],
          ),
          tabBuilder: (BuildContext context, index) {
            return _tabs[index];
          }),
    );
  }
}

