import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/counter_bloc.dart';
import '../providers/videoPlayer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/Login');
    print("All shared preferences cleared.");
  }

  final List<Map<String, dynamic>> sections = [
    {
      'title': '1. Book your flight',
      'pageIndex': 1,
      "Id": [0,1, 2, 3, 4,],
      'images': [
        'assets/places/London.jpg',
        'assets/places/dubai.jpg',
        'assets/places/Paris.jpg',
        'assets/places/Tokyo.jpg',
        'assets/places/Cairo.jpg',
      ],
      'routs': "/PublicFlightsPage",

    },
    {
      'title': '2. Book your Rooms',
      'pageIndex': 2,
      "Id": [13,1, 29, 21,33,],
      'images': [
        'assets/Hotels/The Ritz London.jpg',
        'assets/Hotels/Atlantis The Palm.jpg',
        'assets/Hotels/Hotel Le Meurice.jpg',
        'assets/Hotels/Park Hyatt Tokyo.jpg',
        'assets/Hotels/Four Seasons Cairo Nile Plaza.jpg',
      ],
      'routs': "/hotel-details",
    },
    {
      'title': '3. Explore new places',
      'pageIndex': 3,
      "Id": [0,1, 2, 3, 4,],
      'images': [
        'assets/places/London.jpg',
        'assets/places/dubai.jpg',
        'assets/places/Paris.jpg',
        'assets/places/Tokyo.jpg',
        'assets/places/Cairo.jpg',
      ],
      'routs': "/PublicPlacesPage",
    },
  ];



  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CounterBloc>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: constraints.maxHeight * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(

                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Video Player
                          VideoPlayerWidget(), // Replace with your video player implementation

                          // Overlay Content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: constraints.maxHeight * 0.02,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Explore the",
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.06,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white, // Add color for better visibility
                                        shadows: [ // Add shadow for better text visibility
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                       " world",
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.06,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.blue.shade500, // Add color for better visibility
                                        shadows: [ // Add shadow for better text visibility
                                          Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "your way",
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),

                  // Dynamic Sections
                  ...List.generate(sections.length, (index) {
                    final section = sections[index];
                    return Padding(
                      padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: constraints.maxWidth * 0.001,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  section['title'],
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    cubit.updatePage(section['pageIndex']);
                                  },
                                  child: Text(
                                    "More",
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                section['images'].length,
                                (imgIndex) {
                                  final img = section['images'][imgIndex];
                                  final route = section['routs'];
                                  final id = section['Id'][imgIndex];
                                  return Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          cubit.updateId(id);
                                          Navigator.pushNamed(
                                            context,
                                            route,
                                            arguments: id
                                          );
                                          print(cubit.state.id);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(img),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          width: constraints.maxWidth * 0.5,
                                          height: constraints.maxHeight * 0.23,
                                        ),
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth * 0.02,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
