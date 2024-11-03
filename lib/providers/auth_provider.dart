// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';

class AuthProvider extends ChangeNotifier {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'userId';
  static const String _userPhoneNoKey = 'userPhoneNo';
  bool _isLoggedIn = false;
  String? _loggedInUsername;
  int? _loggedInUserId;
  int? _loggedInUserPhoneNo;

  bool get isLoggedIn => _isLoggedIn;
  String? get loggedInUsername => _loggedInUsername;
  int? get loggedInUserId => _loggedInUserId;
  int? get loggedInUserPhoneNo => _loggedInUserPhoneNo;

  Future<void> login(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
  ) async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    final url = Uri.parse('http://192.168.137.50:8080/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _isLoggedIn = true;
      _loggedInUsername = responseData['username'];
      _loggedInUserId = responseData['userId'];
      _loggedInUserPhoneNo = responseData['phoneNo'];

      notifyListeners();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid username or password'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> signup(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
    TextEditingController phoneNoController,
    String? imagePath,
  ) async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final int phoneNo = int.parse(phoneNoController.text);

    try {
      final url = Uri.parse('http://192.168.137.50:8080/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'phoneNo': phoneNo,
        }),
      );

      if (response.statusCode == 200) {
        notifyListeners();
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          },
        ));

        String? imageUrl;
        if (imagePath != null) {
          imageUrl = await _uploadImageToServer(imagePath, username);
        }
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User already exists'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $error'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String?> _uploadImageToServer(
      String imagePath, String username) async {
    final url = Uri.parse('http://192.168.137.50:8080/upload');

    List<int> imageBytes = await File(imagePath).readAsBytes();

    Map<String, dynamic> requestBody = {
      'username': username,
      'image': base64Encode(imageBytes),
    };

    String jsonBody = jsonEncode(requestBody);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      final String responseText = response.body;
      return responseText;
    } else {
      throw 'Failed to upload image';
    }
  }

  Future<String?> getImageForUsername(String username) async {
    try {
      final url = Uri.parse('http://192.168.137.50:8080/get_image');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['image_url'];
        return imageUrl;
      } else {
        throw 'Failed to get image for username: $username';
      }
    } catch (error) {
      print('Error getting image for username: $error');
      return null;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _loggedInUsername = null;
    notifyListeners();
  }
}
