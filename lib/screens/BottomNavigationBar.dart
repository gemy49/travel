import 'package:FlyHigh/screens/Favorite.dart';
import 'package:FlyHigh/screens/SideMenu/about_us_screen.dart';
import 'package:FlyHigh/screens/SideMenu/faq_screen.dart';
import 'package:FlyHigh/screens/flights/flights_screen.dart';
import 'package:FlyHigh/screens/hotels/hotels_screen.dart';
import 'package:FlyHigh/screens/places/places_screen.dart';
import 'package:FlyHigh/screens/SideMenu/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:FlyHigh/screens/homeScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flights/MyFlights.dart';
import 'hotels/MyHotels.dart';
import 'package:FlyHigh/providers/counter_bloc.dart'; // Should point to the file with `class CounterBloc extends Cubit<PageState>`
import 'package:FlyHigh/providers/counter_state.dart';
class Bottomnavigationbar extends StatefulWidget {
  const Bottomnavigationbar({super.key});

  @override
  State<Bottomnavigationbar> createState() => _BottomnavigationbarState();
}

class _BottomnavigationbarState extends State<Bottomnavigationbar> {
  String? username;
  String? email;
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("IsLoggedIn");
    Navigator.pushReplacementNamed(context, '/Login');
  }

  Future<void> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? "${username}@example.com";
      username = email?.split('@')[0] ?? "";
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
      child: BlocBuilder<CounterBloc, PageState>(
        builder: (context, currentPageIndex) {
          var cubit = context.read<CounterBloc>();
          var currentIndex = cubit.state.pageIndex;
          var Favorite = cubit.state.favoriteIds.length;
          const int bottomNavPagesCount = 5;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        decoration:BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                        width: 50,
                        height: 80,
                      ),
                    ],
                  ),
                  SizedBox(width:5),
                  Text(
                    'FlyHigh',
                    style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade300,
                    ),
                  ),
                  SizedBox(width: 10),

                ],
              ),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    color: Colors.blue.shade500,
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyFlightsScreen(), // Make sure MyFlightsScreen is accessible
                                ),
                                );
                          },
                        ),
                         ListTile(
                          leading: Icon(Icons.hotel),
                          title: Text('MY Rooms'),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyHotelsScreen(), // Make sure MyFlightsScreen is accessible
                                ),
                                );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.menu_book),
                          title: Text('Privacy and Policy'),
                          onTap: () {
                            cubit.updatePage(5);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.groups),
                          title: Text('About Us'),
                          onTap: () {
                            cubit.updatePage(6);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.question_mark_rounded),
                          title: Text('FAQ'),
                          onTap: () {
                            cubit.updatePage(7);
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
              backgroundColor: Colors.white,
              onDestinationSelected: (int index) {
                cubit.updatePage(index);
              },
              indicatorColor: Colors.blue.shade100,
              selectedIndex: currentIndex >= bottomNavPagesCount
                  ? 0
                  : currentIndex,
              destinations: <Widget>[
                const NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.flight),
                  label: 'Flights',
                ),

                const NavigationDestination(
                  icon: Icon(Icons.home_work_outlined),
                  label: 'Hotels',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.location_on),
                  label: 'Places',
                ),
                NavigationDestination(
                  icon: Favorite == 0
                      ? Icon(Icons.favorite_border_outlined)
                      : Badge(
                    backgroundColor: Colors.blue.shade200,
                          label: Text('${Favorite}'),
                          child: const Icon(Icons.favorite_border_outlined),
                        ),
                  label: 'Favorites',
                ),
              ],
            ),
            body: <Widget>[
              HomeScreen(),
              const FlightsScreen(),
              const HotelsScreen(),
              CitiesPage(),
              const FavoriteFlightsScreen(),
              const PrivacyPolicyScreen(),
              const AboutUsScreen(),
              const FaqScreen(),
            ][currentIndex],
          );
        },
      ),
    );
  }
}
