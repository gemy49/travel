import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF77BEF0);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color questionColor = Colors.black87;
  static const Color answerColor = Color(0xFF57564F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Frequently Asked Questions",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              _buildFaqItem(
                question: "How do I book a flight?",
                answer:
                    "To book a flight, go to the 'Flights' section, enter your departure and destination cities, select your travel dates, and choose a flight from the list. Confirm your details and proceed to payment.",
              ),
              _buildFaqItem(
                question: "Can I cancel my booking?",
                answer:
                    "Yes, you can cancel your booking from the 'Saved Trips' section. Cancellations are subject to the airline's policy, and refunds may take 5-7 business days to process.",
              ),
              _buildFaqItem(
                question: "Is my payment secure?",
                answer:
                    "Yes, we use industry-standard encryption to protect your payment information. We do not store your credit card details on our servers.",
              ),
              _buildFaqItem(
                question: "What if my flight is delayed or canceled?",
                answer:
                    "If your flight is delayed or canceled, you will receive a notification. You can check the updated status in the app or contact the airline directly.",
              ),
              _buildFaqItem(
                question: "Can I modify my booking after payment?",
                answer:
                    "Some bookings allow modifications for a fee. Check the terms of your ticket in the 'Booking Details' section. If allowed, you can change dates or passenger details through the app.",
              ),
              _buildFaqItem(
                question: "How do I contact customer support?",
                answer:
                    "You can contact our support team through the 'Contact Us' page, available 24/7 via email or phone. We aim to respond within 24 hours.",
              ),
              _buildFaqItem(
                question: "Do you offer discounts for frequent travelers?",
                answer:
                    "Yes! Join our loyalty program in the app to earn points on every booking. Points can be redeemed for discounts on future flights and hotels.",
              ),
              _buildFaqItem(
                question: "Is my personal data safe with you?",
                answer:
                    "Absolutely. We comply with data protection regulations and never share your personal information with third parties without your consent.",
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          collapsedIconColor: primaryColor,
          iconColor: primaryColor,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: questionColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: answerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
