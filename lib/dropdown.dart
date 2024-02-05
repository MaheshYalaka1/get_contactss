import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_contacts/login.dart';
import 'package:get_contacts/screens/events_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends ConsumerStatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Hi Veera"),
            accountEmail: Text("veera.doe@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "Veera",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          DrawerListItem(
            icon: Icons.home,
            title: 'Home',
            page: 0,
          ),
          DrawerListItem(
            icon: Icons.settings,
            title: 'Settings',
            page: 1,
          ),
          DrawerListItem(
            icon: Icons.login_outlined,
            title: 'Sign out',
            page: 2,
          ),
        ],
      ),
    );
  }
}

class DrawerListItem extends ConsumerStatefulWidget {
  final IconData icon;
  final String title;
  final int page;

  const DrawerListItem({
    required this.icon,
    required this.title,
    required this.page,
    Key? key,
  }) : super(key: key);

  @override
  _DrawerListItemState createState() => _DrawerListItemState();
}

class _DrawerListItemState extends ConsumerState<DrawerListItem> {
  Future<void> signOut() async {
    // Clear the login status in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(), // Replace with your home page
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon),
      title: Text(widget.title),
      onTap: () {
        Navigator.pop(context); // Close the drawer

        // Conditional navigation based on the selected page
        switch (widget.page) {
          case 0:
            // Home Page
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventScreenList(),
              ),
            );
            break;
          case 2:
            signOut();
            break;
        }
      },
    );
  }
}
