import 'package:chat_app/providers/contact_provider.dart';
import 'package:chat_app/providers/contact_provider.dart';
import 'package:contacts_service/contacts_service.dart' as contactservice;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Contact {
  final int id;
  final String username;
  final String contactPhone;

  Contact(
      {required this.id, required this.username, required this.contactPhone});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      username: json['username'],
      contactPhone: json['contactPhone'],
    );
  }
}

class ContactsProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  List<contactservice.Contact> _phoneContacts = [];
  List<contactservice.Contact> get phoneContacts => _phoneContacts;

  List<Contact> get contacts => _contacts;

  Future<void> loadContacts(String username) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.137.50:8080/get_contacts'),
        body: jsonEncode({'username': username}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _contacts = data.map((item) => Contact.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load contacts');
      }
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }

  void setPhoneContacts(List<contactservice.Contact> contacts) {
    _phoneContacts = contacts;
    notifyListeners();
  }

  void clearPhoneContact() {
    _phoneContacts.clear();
    notifyListeners();
  }

  Future<void> addContact(
      String username, String contactUsername, String contactPhone) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.137.50:8080/add_contact'),
        body: jsonEncode({
          'username': username,
          'contactUsername': contactUsername,
          'contactPhone': contactPhone
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _contacts.add(Contact(
            id: 0, username: contactUsername, contactPhone: contactPhone));

        notifyListeners();
      } else {
        throw Exception('Failed to add contact');
      }
    } catch (e) {
      print('Error adding contact: $e');
    }
  }

  Future<void> removeContact(String username, String contactUsername) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.137.50:8080/remove_contact'),
        body: jsonEncode(
            {'username': username, 'contactUsername': contactUsername}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        await loadContacts(username);
      } else {
        throw Exception('Failed to remove contact');
      }
    } catch (e) {
      print('Error removing contact: $e');
    }
  }
}
