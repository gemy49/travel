import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF77BEF0);
  static const double horizontalPadding = 16;

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.6),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String content,
    IconData? icon,
    Color? iconColor,
  }) {
    return Card(
      elevation: 5,
      shadowColor: primaryColor.withOpacity(0.2),
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? primaryColor, size: 30),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width / 2 - 32;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "About Fly High",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your trusted partner in seamless and affordable flight bookings.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            sectionTitle("Who We Are"),
            sectionText(
              "Fly High is a leading flight booking platform dedicated to making air travel accessible, affordable, and hassle-free. Founded with a passion for connecting people and places, we partner with a vast network of airlines to offer competitive prices and personalized travel options. Our goal is to empower every traveler to explore the world with confidence and ease.",
            ),

            sectionTitle("Our Mission & Vision"),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  buildCard(
                    title: "Our Mission",
                    content:
                        "To simplify the flight booking process by providing an intuitive platform with transparent pricing, real-time updates, and exceptional customer support, ensuring stress-free journeys for all travelers.",
                  ),
                  buildCard(
                    title: "Our Vision",
                    content:
                        "To redefine air travel by creating a world where booking a flight is effortless. We aim to be the leading global platform for flight reservations, integrating innovative technology to deliver unforgettable travel experiences.",
                  ),
                ],
              ),
            ),

            sectionTitle("Our Values"),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Wrap(
                runSpacing: 16,
                spacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "Transparency",
                      content:
                          "Clear pricing and honest communication with no hidden fees.",
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "Innovation",
                      content:
                          "Leveraging cutting-edge technology for better booking.",
                      icon: Icons.lightbulb_outline,
                      iconColor: Colors.orange,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "Customer Satisfaction",
                      content: "24/7 support to ensure a seamless experience.",
                      icon: Icons.people_alt,
                      iconColor: Colors.purple,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "Sustainability",
                      content:
                          "Promoting eco-friendly travel and sustainable practices.",
                      icon: Icons.eco,
                      iconColor: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),

            sectionTitle("Why Choose Us"),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Wrap(
                runSpacing: 16,
                spacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "Affordable Prices",
                      content: "Competitive prices with no hidden fees.",
                      icon: Icons.attach_money,
                      iconColor: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "Live Updates",
                      content: "Real-time flight tracking and updates.",
                      icon: Icons.update,
                      iconColor: Colors.indigo,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "Custom Options",
                      content: "Customizable travel plans and filters.",
                      icon: Icons.settings,
                      iconColor: Colors.brown,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: buildCard(
                      title: "24/7 Support",
                      content: "Get help anytime from our expert team.",
                      icon: Icons.support_agent,
                      iconColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            sectionTitle("Our Journey"),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: buildCard(
                          title: "2018",
                          content:
                              "Fly High was founded with a vision to simplify travel.",
                        ),
                      ),
                      Expanded(
                        child: buildCard(
                          title: "2020",
                          content:
                              "Launched our mobile app for seamless booking.",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: buildCard(
                          title: "2022",
                          content:
                              "Partnered with over 100 airlines worldwide.",
                        ),
                      ),
                      Expanded(
                        child: buildCard(
                          title: "2025",
                          content: "Introduced eco-friendly travel options.",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
