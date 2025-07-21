import 'package:FlyHigh/pages/HowAreWe.dart';
import 'package:FlyHigh/pages/public_places.dart';
import 'package:flutter/material.dart';
import 'package:FlyHigh/pages/homeScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/counter_State.dart';
import 'bloc/counter_bloc.dart';

class Bottomnavigationbar extends StatefulWidget {
  const Bottomnavigationbar({super.key});

  @override

  State<Bottomnavigationbar> createState() => _BottomnavigationbarState();
}

class _BottomnavigationbarState extends State<Bottomnavigationbar> {
  String? username ;
  String? email ;
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("IsLoggedIn");
    Navigator.pushReplacementNamed(context, '/Login');
  }
  Future<void> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
   setState(() {
     email=prefs.getString('email')??"${username}@example.com";
     username=email?.split('@')[0]??"";
   });
  }

  @override
  void initState() {
    super.initState();
    getUsername();
  }
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (BuildContext context) => CounterBloc(),
  child: BlocBuilder<CounterBloc,PageState>(
      builder: (context,currentPageIndex){
    var cubit=context.read<CounterBloc>();
    var currentIndex=cubit.state.pageIndex;
    const int bottomNavPagesCount = 4;
        return Scaffold(
          backgroundColor: Color(0xFF3DB9EF),
          appBar: AppBar(
            backgroundColor: Color(0xFF3DB9EF),
            title: Row(
              children: [
                Text('FlyHigh',
                  style: TextStyle(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.flight, color: Colors.white, size: 30),
                SizedBox(width: 10),
              ],
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),
          endDrawer: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  color: Color(0xFF3DB9EF),
                  padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${username?.toUpperCase()}",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        email ?? '',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.flight),
                        title: Text('MY FIGHTS'),
                        onTap: () {
                          cubit.updatePage(7);
                          Navigator.pop(context);
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.groups),
                        title: Text('Who Are we'),
                        onTap: () {
                          cubit.updatePage(8);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.question_mark_rounded),
                        title: Text('FAQ'),
                        onTap: () {
                          cubit.updatePage(9);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('LogOut'),
                        onTap: () {
                          clearPreferences();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Color(0xFF3DB9EF),
            onDestinationSelected: (int index) {
             cubit.updatePage(index);
            },
            indicatorColor:Colors.amber,
            selectedIndex: currentIndex >= bottomNavPagesCount ? 0 : currentIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ), NavigationDestination(
                icon: Icon(Icons.flight),
                label: 'Flights',
              ),
              NavigationDestination(
                icon:  Icon(Icons.home_work_outlined),
                label: 'Hotels',
              ),
              NavigationDestination(
                icon: Badge(label: Text('2',), child: Icon(Icons.favorite_border_outlined)),
                label: 'Favorites',
              ),

            ],
          ),
          body:
          <Widget>[
            HomeScreen(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 2'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 3'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 4'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),

                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 6'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),

                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 7'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),

                ],
              ),
            ),
            PublicPlacesPage(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 8'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),

                ],
              ),
            ),
            const HowAreWe(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 10'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),

                ],
              ),
            ),

          ][currentIndex],
        );
      }
    ),
);
  }
}
