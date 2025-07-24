import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/counter_bloc.dart';

const Color primaryColor = Color(0xFF77BEF0);

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSubTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(text, style: const TextStyle(fontSize: 16, height: 1.6));
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CounterBloc>();
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(Icons.privacy_tip, "Privacy Policy"),
            const SizedBox(height: 12),
            _buildParagraph(
              "At TravelEasy, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our flight booking application.",
            ),
            const SizedBox(height: 20),

            _buildSubTitle("Information We Collect"),
            const SizedBox(height: 8),
            _buildParagraph(
              "We collect information you provide directly, such as your name, email address, and payment details when you book a flight. We also collect usage data, such as your browsing activity and preferences, to improve our services.",
            ),
            const SizedBox(height: 20),

            _buildSubTitle("How We Use Your Information"),
            const SizedBox(height: 8),
            _buildParagraph(
              "Your information is used to process bookings, personalize your experience, and send you relevant offers. We do not share your personal data with third parties except as necessary to complete your booking or comply with legal requirements.",
            ),
            const SizedBox(height: 20),

            _buildSubTitle("Data Security"),
            const SizedBox(height: 8),
            _buildParagraph(
              "We implement industry-standard security measures to protect your data. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.",
            ),
            const SizedBox(height: 30),

            _buildSectionTitle(Icons.description, "Terms of Service"),
            const SizedBox(height: 12),
            _buildParagraph(
              "By using TravelEasy, you agree to these Terms of Service. These terms govern your use of our flight booking application and services.",
            ),
            const SizedBox(height: 20),

            _buildSubTitle("Booking and Payments"),
            const SizedBox(height: 8),
            _buildParagraph(
              "All bookings are subject to availability and airline policies. Payments must be made in full at the time of booking. Refunds and cancellations are subject to the airline's terms and conditions.",
            ),
            const SizedBox(height: 20),

            _buildSubTitle("User Responsibilities"),
            const SizedBox(height: 8),
            _buildParagraph(
              "You agree to provide accurate information when booking flights. You are responsible for complying with all applicable laws and regulations related to travel.",
            ),
            const SizedBox(height: 20),

            _buildSubTitle("Limitation of Liability"),
            const SizedBox(height: 8),
            _buildParagraph(
              "TravelEasy is not liable for any delays, cancellations, or disruptions caused by airlines or other third parties. We are not responsible for any loss or damage resulting from your use of our services.",
            ),
            const SizedBox(height: 40),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  cubit.updatePage(10);
                },
                icon: const Icon(Icons.contact_support),
                label: const Text(
                  "Contact Us for More Information",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
