// utils/storage_keys.dart (or add to an existing utils file)
import 'package:shared_preferences/shared_preferences.dart';

/// Generates a key for SharedPreferences based on the user's email.
/// Returns null if email cannot be retrieved.
Future<String?> getUserSpecificKey(String baseKey) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? email = prefs.getString('email'); // Use the key where you store the email
  if (email == null || email.isEmpty) {
    // Handle case where email is not found (e.g., not logged in)
    print("Error: User email not found for storage key generation.");
    return null;
  }
  // Sanitize email to make it safe for use as a SharedPreferences key
  // (Replace characters that might be problematic)
  final String safeEmail = email.replaceAll('.', '_dot_').replaceAll('@', '_at_');
  return '${baseKey}_$safeEmail';
}