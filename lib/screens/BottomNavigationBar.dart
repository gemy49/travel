import 'package:FlyHigh/screens/Favorite.dart' hide CounterBloc;
import 'package:FlyHigh/screens/SideMenu/about_us_screen.dart';
import 'package:FlyHigh/screens/SideMenu/contact_us_screen.dart';
import 'package:FlyHigh/screens/SideMenu/faq_screen.dart';
import 'package:FlyHigh/screens/flights/flights_screen.dart';
import 'package:FlyHigh/screens/hotels/hotels_screen.dart';
import 'package:FlyHigh/screens/places/places_screen.dart';
import 'package:FlyHigh/screens/SideMenu/privacy_policy_screen.dart';
import 'package:FlyHigh/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:FlyHigh/screens/homeScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/image_service.dart';
import 'flights/MyFlights.dart';
import 'hotels/MyHotels.dart';
import 'package:FlyHigh/providers/counter_bloc.dart';
import 'package:FlyHigh/providers/counter_state.dart';

class Bottomnavigationbar extends StatefulWidget {
  const Bottomnavigationbar({super.key});

  @override
  State<Bottomnavigationbar> createState() => _BottomnavigationbarState();
}

class _BottomnavigationbarState extends State<Bottomnavigationbar> {
  String? username;
  String? email;
  String? profilePhotoUrl; // رابط الصورة من الـ API
  final ImageService imageService = ImageService();

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("IsLoggedIn");
    Navigator.pushReplacementNamed(context, '/Login');
  }

  Future<void> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? "user@example.com";
      username = prefs.getString('name') ?? email?.split('@')[0];
    });

    final apiPhoto = await ApiService().getProfilePhoto();
    setState(() {
      profilePhotoUrl = apiPhoto; // ممكن تكون null
    });
  }

  Future<void> pickAndUploadProfileImage() async {
    final imageFile = await imageService.pickImage();
    if (imageFile == null) return;

    final uploadedUrl = await imageService.uploadImage(imageFile);
    if (uploadedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل رفع الصورة")),
      );
      return;
    }

    final success = await ApiService().updateProfilePhoto(
      profilePhotoUrl: uploadedUrl,
    );

    if (success) {
      setState(() {
        profilePhotoUrl = uploadedUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث صورة البروفايل")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل تحديث الصورة في السيرفر")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc(),
      child: BlocBuilder<CounterBloc, PageState>(
        builder: (context, currentPageIndex) {
          var cubit = context.read<CounterBloc>();
          var currentIndex = cubit.state.pageIndex;
          var favoriteCount = cubit.state.favorites.length;
          const int bottomNavPagesCount = 4;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                    ),
                    width: 50,
                    height: 80,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'FlyHigh',
                    style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade300,
                    ),
                  ),
                ],
              ),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    color: Colors.blue.shade500,
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ],
            ),
            endDrawer: Drawer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: Colors.blue.shade500,
                    padding: const EdgeInsets.only(top: 60, bottom: 20),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
                                    ? Image.network(
                                  profilePhotoUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/profile.png', fit: BoxFit.cover);
                                  },
                                )
                                    : Image.asset('assets/profile.png', fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white.withOpacity(0.8),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.edit, size: 18, color: Colors.blue.shade500),
                                  onPressed: pickAndUploadProfileImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          username?.toUpperCase() ?? "USER",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          email ?? 'user@example.com',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerSectionTitle("My Bookings", Colors.blue.shade500),
                        _buildDrawerListItem(
                          context: context,
                          icon: Icons.flight,
                          title: 'My Flights',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyFlightsScreen()));
                          },
                        ),
                        _buildDrawerListItem(
                          context: context,
                          icon: Icons.hotel,
                          title: 'My Hotels',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyHotelsScreen()));
                          },
                        ),
                        const Divider(indent: 16, endIndent: 16),
                        _buildDrawerSectionTitle("App", Colors.blue.shade500),
                        _buildDrawerListItem(
                          context: context,
                          icon: Icons.menu_book,
                          title: 'Privacy Policy',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));

                          },
                        ),
                        _buildDrawerListItem(
                          context: context,
                          icon: Icons.groups,
                          title: 'About Us',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));

                          },
                        ),
                        _buildDrawerListItem(
                          context: context,
                          icon: Icons.question_mark_rounded,
                          title: 'FAQ',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen()));

                          },
                        ),
                        const Divider(indent: 16, endIndent: 16),
                        _buildDrawerListItem(
                          context: context,
                          icon: Icons.logout,
                          title: 'Log Out',
                          textColor: Colors.redAccent,
                          iconColor: Colors.redAccent,
                          onTap: () {
                            Navigator.pop(context);
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
              selectedIndex: currentIndex >= bottomNavPagesCount ? 0 : currentIndex,
              destinations: <Widget>[
                const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                const NavigationDestination(icon: Icon(Icons.flight), label: 'Flights'),
                const NavigationDestination(icon: Icon(Icons.home_work_outlined), label: 'Hotels'),
                // const NavigationDestination(icon: Icon(Icons.location_on), label: 'Places'),
                NavigationDestination(
                  icon: favoriteCount == 0
                      ? const Icon(Icons.favorite_border_outlined)
                      : Badge(
                    backgroundColor: Colors.blue.shade200,
                    label: Text('$favoriteCount'),
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
              // CitiesPage(),
              const FavoriteScreen(),
            ][currentIndex],
          );
        },
      ),
    );
  }
}

Widget _buildDrawerSectionTitle(String title, Color color) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
    child: Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
    ),
  );
}

Widget _buildDrawerListItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? iconColor,
  Color? textColor,
}) {
  final defaultIconColor = Theme.of(context).iconTheme.color ?? Colors.grey;
  final defaultTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;

  return ListTile(
    leading: Icon(icon, color: iconColor ?? defaultIconColor, size: 24),
    title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? defaultTextColor)),
    onTap: onTap,
    splashColor: (iconColor ?? defaultIconColor).withOpacity(0.1),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  );
}
