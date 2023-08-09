import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'User List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        users = (jsonData['data'] as List).map((data) => User.fromJson(data)).toList();
      });
      saveUsersLocally(users);
    } else {
      List<User> locallySavedUsers = await loadUsersLocally();
      if (locallySavedUsers.isNotEmpty) {
        setState(() {
          users = locallySavedUsers;
        });
      }
    }
  }

  Future<void> saveUsersLocally(List<User> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userStrings = users.map((user) => json.encode(user.toJson())).toList();
    await prefs.setStringList('users', userStrings);
  }

  Future<List<User>> loadUsersLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userStrings = prefs.getStringList('users') ?? [];
    List<User> locallySavedUsers = userStrings.map((userString) => User.fromJson(json.decode(userString))).toList();
    return locallySavedUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Get.to(UserDetailsPage(user: users[index]));
            },
            title: Text(users[index].name),
            subtitle: Text(users[index].email),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(users[index].avatar),
            ),
          );
        },
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String avatar;

  User({required this.id, required this.name, required this.email, required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['first_name'] + ' ' + json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}

class UserDetailsPage extends StatelessWidget {
  final User user;

  UserDetailsPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
              radius: 50,
            ),
            SizedBox(height: 20),
            Text('Name: ${user.name}'),
            Text('Email: ${user.email}'),
            Text('ID: ${user.id}'),
          ],
        ),
      ),
    );
  }
}
