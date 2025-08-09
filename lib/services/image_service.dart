import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final String _apiKey = "43f73617e06ead79c1ca94038e1e2862";
  final String _uploadUrl = "https://api.imgbb.com/1/upload";

  /// Pick image from gallery
  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Upload image to ImgBB and return the URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$_uploadUrl?key=$_apiKey"),
      )..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(body);
        return jsonResponse['data']['url'];
      }
      return null;
    } catch (e) {
      print("❌ Upload Error: $e");
      return null;
    }
  }
}
