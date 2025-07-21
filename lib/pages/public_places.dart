import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/counter_bloc.dart';

class PublicPlacesPage extends StatefulWidget {
  const PublicPlacesPage({super.key});

  @override
  State<PublicPlacesPage> createState() => _PublicPlacesPageState();
}

class _PublicPlacesPageState extends State<PublicPlacesPage> {
  final List<Map<String,dynamic>> places = [
    {
      "City":"england",
      "images":[
        "https://i.postimg.cc/9MPHFvQh/British-Museum.jpg",
        "https://i.postimg.cc/PJ8Zwz0T/London-Eye.jpg",
        "https://i.postimg.cc/hjvVSqrJ/Tower-Bridge.jpg",
      ],
      "names":[
        "British Museum",
        "London Eye",
        "Tower Bridge",
      ]

    },
    {
      "City":"Dubai",
      "images":[
        "https://i.postimg.cc/vmJGmr7W/Dubai-Burj-Khalifa.jpg",
        "https://i.postimg.cc/3RQHhK71/dubai-mall.jpg",
        "https://i.postimg.cc/8c1QFt7r/Dubai-Marina.jpg",
      ],
      "names":[
        "Dubai Burj Khalifa",
        "Dubai Mall",
        "Dubai Marina",
      ]
    },
    {
      "City":"paris",
      "images":[
        "https://i.postimg.cc/28sG23x0/Notre-Dame-Cathedral.jpg",
        "https://i.postimg.cc/sg5c8y6s/Louvre-Museum.jpg",
        "https://i.postimg.cc/3J49X22y/Montmartre-Sacr-C-ur.jpg",
      ],
      "names":[
        "Notre Dame Cathedral",
        "Louvre Museum",
        "Montmartre Sacré-Cœur",
      ]
    },
    {
      "City":"tokyo",
      "images":[
        "https://i.postimg.cc/HsXvGQnq/Tokyo-Tower.jpg",
        "https://i.postimg.cc/nrsK1t98/Shibuya-Crossing.jpg",
        "https://i.postimg.cc/cHLBr3sL/Senso-ji-Temple.jpg",
      ],
      "names":[
        "Tokyo Tower",
        "Shibuya Crossing",
        "Senso-ji Temple",
      ]
    },
    {
      "City":"egypt",
      "images":[
        "https://i.postimg.cc/MH8Z97vW/Cairo-Tower.jpg",
        "https://i.postimg.cc/yY8CspqM/Egyptian-Museum.jpg",
        "https://i.postimg.cc/VvTgyNPL/Khan-El-Khalili-Bazaar.jpg",
      ],
      "names":[
        "Cairo Tower",
        "Egyptian Museum",
        "Khan El Khalili Bazaar",
      ]
    }
  ];
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CounterBloc>();
    var id =cubit.state.id;
    return  LayoutBuilder(
        builder: (context, constraints) {
          return Container(
      width: double.infinity,
      height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

        ),
        child: ListView.builder(
          itemCount: places[id]["images"].length,
          itemBuilder: (context, index) {
            final place = places[id];
            final image = place["images"][index];
            final name = place["names"][index];
            return Card(
              margin: EdgeInsets.all(constraints.maxHeight * 0.015),
              child: Column(
                children: [
                  Image.network(image, height: constraints.maxHeight * 0.3, width: double.infinity, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      name,
                      style: TextStyle(fontSize: constraints.maxWidth * 0.05, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
        });
  }
}
