import 'dart:io';

import 'package:chat_app/model/group_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _groups = [];
  List<String> _groupNames = [];
  List<GroupMessage> _groupMessages = [];
  List<String> get groupNames => _groupNames;
  List<GroupMessage> get groupMessages => _groupMessages;

  List<Map<String, dynamic>> get groups => _groups;
  void addGroupMessage(GroupMessage message) {
    _groupMessages.add(message);
    notifyListeners();
  }

  GroupMessage? getLatestMessageForGroup(String groupName) {
    List<GroupMessage> messagesForGroup = _groupMessages
        .where((message) => message.groupName == groupName)
        .toList();

    messagesForGroup.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return messagesForGroup.isNotEmpty ? messagesForGroup.first : null;
  }

  Future<bool> checkGroupExists(String groupName) async {
    final response = await http.post(
      Uri.parse('http://192.168.137.50:8080/checkGroupExists'),
      body: jsonEncode({'groupName': groupName}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['exists'] ?? false;
    } else {
      throw Exception("Failed to check group existence.");
    }
  }

  Future<void> createGroup(String groupname, String groupowner,
      String groupImage, List<String> groupMembers) async {
    try {
      List<int> imageBytes = await File(groupImage).readAsBytes();
      final response =
          await http.post(Uri.parse('http://192.168.137.50:8080/create_group'),
              body: jsonEncode({
                'groupname': groupname,
                'groupowner': groupowner,
                'groupImage': base64Encode(imageBytes),
                'groupMembers': groupMembers
              }),
              headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        _groups.add({
          'groupname': groupname,
          'groupowner': groupowner,
          'groupImage': groupImage,
          'groupMembers': groupMembers
        });

        notifyListeners();
        print('created group successfully');
      }
    } catch (e) {
      print('Error adding group: $e');
    }
  }

  void clearGroups() {
    _groupNames.clear();
    _groupMessages.clear();
    notifyListeners();
  }

  void addCreatedGroupName(String name) {
    _groupNames.add(name);
    notifyListeners();
  }

  void addGroupNames(List<String> names) {
    _groupNames.addAll(names);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getGroupsForUser(String username) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.137.50:8080/groups/user/$username'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<Map<String, dynamic>> fetchedGroups =
            responseData.cast<Map<String, dynamic>>();
        for (var group in fetchedGroups) {
          if (!_groups.contains(group)) {
            _groups.add(group);
          }
        }

        return groups;
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (e) {
      print('Error fetching user groups: $e');
      return [];
    }
  }
}
