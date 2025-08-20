import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../screens/flights/flight_details_screen.dart';
import '../../screens/hotels/hotel_details_screen.dart';

const Color primaryColor = Color(0xFF2196F3);

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': message});
      isLoading = true;
    });

    try {
      final requestBody = {
        'messages': messages
            .map((m) => {'role': m['role'], 'content': m['content']})
            .toList(),
      };

      final response = await http.post(
        Uri.parse('http://192.168.100.10:3000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage =
            data['choices']?[0]?['message']?['content']?.toString().trim() ??
            "No response";

        final input = message.toLowerCase();
        final isFlightSearch = input.contains("flight");
        final isHotelSearch = input.contains("hotel");

        final cityMatch = RegExp(
          r"\bin\s+([A-Za-z\s]+)(?:\s|$)",
        ).firstMatch(message);
        final city = cityMatch != null ? cityMatch.group(1)?.trim() : null;

        final flightMatch = RegExp(
          r"from\s+([A-Za-z\s]+)\s+to\s+([A-Za-z\s]+)",
        ).firstMatch(message);
        final from = flightMatch != null ? flightMatch.group(1)?.trim() : null;
        final to = flightMatch != null ? flightMatch.group(2)?.trim() : null;

        Map<String, dynamic> filteredData = {
          "role": "assistant",
          "content": aiMessage,
          "flights": null,
          "hotels": null,
        };

        if (isFlightSearch && !isHotelSearch) {
          filteredData["flights"] = (from != null && to != null)
              ? (data["flights"] as List?)
                    ?.where(
                      (f) =>
                          f["from"].toString().toLowerCase().contains(
                            from.toLowerCase(),
                          ) &&
                          f["to"].toString().toLowerCase().contains(
                            to.toLowerCase(),
                          ),
                    )
                    .toList()
              : data["flights"];
        } else if (isHotelSearch && !isFlightSearch) {
          filteredData["hotels"] = city != null
              ? (data["hotels"] as List?)
                    ?.where(
                      (h) => h["city"].toString().toLowerCase().contains(
                        city.toLowerCase(),
                      ),
                    )
                    .toList()
              : data["hotels"];
        } else if (isFlightSearch && isHotelSearch) {
          filteredData["hotels"] = city != null
              ? (data["hotels"] as List?)
                    ?.where(
                      (h) => h["city"].toString().toLowerCase().contains(
                        city.toLowerCase(),
                      ),
                    )
                    .toList()
              : data["hotels"];
          filteredData["flights"] = (from != null && to != null)
              ? (data["flights"] as List?)
                    ?.where(
                      (f) =>
                          f["from"].toString().toLowerCase().contains(
                            from.toLowerCase(),
                          ) &&
                          f["to"].toString().toLowerCase().contains(
                            to.toLowerCase(),
                          ),
                    )
                    .toList()
              : data["flights"];
        }

        setState(() {
          messages.add(filteredData);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get response from server')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    controller.clear();
  }

  Widget buildMessage(Map<String, dynamic> message) {
    final bool isUser = message['role'] == 'user';
    final flights = message['flights'] as List?;
    final hotels = message['hotels'] as List?;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser ? primaryColor.withOpacity(0.85) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message['content'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            if (flights != null) ...[
              const SizedBox(height: 10),
              const Text(
                "✈ Flights found:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...flights.map(
                (f) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlightDetailsScreen(flight: f),
                      ),
                    );
                  },
                  child: Text(
                    "• ${f['airline']} - \$${f['price']} (${f['from']} → ${f['to']})",
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
            if (hotels != null) ...[
              const SizedBox(height: 10),
              const Text(
                "🏨 Hotels found:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...hotels.map(
                (h) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelDetailsScreen(hotel: h),
                      ),
                    );
                  },
                  child: Text(
                    "• ${h['name']} (${h['city']})",
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Travel Chat Assistant"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) => buildMessage(messages[index]),
              ),
            ),
            if (isLoading)
              const LinearProgressIndicator(minHeight: 3, color: primaryColor),
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: sendMessage,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: isLoading ? Colors.grey : primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: isLoading
                          ? null
                          : () => sendMessage(controller.text.trim()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
