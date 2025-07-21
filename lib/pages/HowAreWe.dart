import 'package:flutter/material.dart';

class HowAreWe extends StatefulWidget {
  const HowAreWe({super.key});

  @override
  State<HowAreWe> createState() => _HowAreWeState();
}

class _HowAreWeState extends State<HowAreWe> {
  final List<Map<String, String>> teamMembers = [
    {
      'name': 'محمد جمال',
      'image': 'https://i.postimg.cc/GhLmhMLk/Whats-App-Image-2025-07-20-at-17-41-32-6f9c7c45.jpg',
    },
    {
      'name': 'أحمد الحلواني',
      'image': 'assets/images/member2.jpg',
    },
    {
      'name': 'محمد الشريف ',
      'image': 'assets/images/member3.jpg',
    },
    {
      'name': 'غادة احمد',
      'image': 'assets/images/member4.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints)
    {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'نحن فريق مكون من أربعة شباب طموحين، نعمل على مشروع تخرج مميز بهدف تطوير مهاراتنا، وإنشاء سيرة ذاتية قوية تساعدنا في إيجاد فرصة عمل جيدة في سوق العمل.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  final member = teamMembers[index];
                  final name = member['name'];
                  final image = member['image'];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Image.network(image!, height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            name!,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
    }
  }

