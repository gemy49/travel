import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/counter_bloc.dart';

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
        'https://i.postimg.cc/GmM2bTSQ/big-ben.jpg',
        'https://i.postimg.cc/VvBfpJCX/dubai.jpg',
        'https://i.postimg.cc/QdBLWBdS/Eiffel-Tower.jpg',
        'https://i.postimg.cc/XY6K9mVh/Tokyo-Skytree.jpg',
        'https://i.postimg.cc/MGyFy120/giza-egyptian-pyramids.jpg',
      ],
      'routs': 4,
    },
    {
      'title': '2. Book your Rooms',
      'pageIndex': 2,
      "Id": [0,1, 2, 3, 4,],
      'images': [
        'https://i.postimg.cc/fRK8xRm3/Hotel1.jpg',
        'https://i.postimg.cc/JhzPKC5p/Hotel2.jpg',
        'https://i.postimg.cc/ZqsjMsf4/Hotel3.jpg',
        'https://i.postimg.cc/C1ZJTCtD/Hotel4.jpg',
        'https://i.postimg.cc/j5Gcsw01/Hotel5.jpg',
      ],
      'routs': 5,
    },
    {
      'title': '3. Explore new places',
      'pageIndex': 1,
      "Id": [0,1, 2, 3, 4,],
      'images': [
        'https://i.postimg.cc/GmM2bTSQ/big-ben.jpg',
        'https://i.postimg.cc/VvBfpJCX/dubai.jpg',
        'https://i.postimg.cc/QdBLWBdS/Eiffel-Tower.jpg',
        'https://i.postimg.cc/XY6K9mVh/Tokyo-Skytree.jpg',
        'https://i.postimg.cc/MGyFy120/giza-egyptian-pyramids.jpg',
      ],
      'routs': 6,
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
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: AssetImage("assets/Home_banner1.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: constraints.maxWidth * 0.2,
                            top: constraints.maxHeight * 0.02,
                          ),
                          child: Text(
                            "Welcome to FlyHigh",
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: constraints.maxWidth * 0.37,
                            top: constraints.maxHeight * 0.03,
                          ),
                          child: Text(
                            "THE Best Way To Fly High",
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: constraints.maxWidth * 0.5,
                            top: constraints.maxHeight * 0.03,
                          ),
                          child: Text(
                            "With US, you can: ",
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                                          cubit.updatePage(route);
                                          cubit.updateId(id);
                                          print(cubit.state.id);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(img),
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
