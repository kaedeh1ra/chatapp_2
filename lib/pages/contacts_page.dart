import 'dart:io';

import 'package:chatapp_2/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key, required this.database});
  final Database database;
  Future<String> getUserName() async {
    try {
      // Get the currently signed-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user's profile information from the Firebase Realtime Database
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Extract the name from the user's profile information
        String name = (snapshot.data() as Map)['name'];

        return name;
      } else {
        return '';
      }
    } catch (e) {
      // Handle any errors that occur during the retrieval process
      return '';
    }
  }

  Future<String> getEmail() async {
    try {
      // Get the currently signed-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user's profile information from the Firebase Realtime Database
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Extract the name from the user's profile information
        String name = (snapshot.data() as Map)['email'];

        return name;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> _loadClothesByCategory(
      String category) async {
    return await database.query(
      'clothes',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<String> userNameFuture =
        getUserName(); // Changed variable name to userNameFuture

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Profile Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[800],
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.orange.shade100,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Name
            FutureBuilder<String>(
              future: userNameFuture,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot
                        .data!, // Use snapshot.data! to access the String value
                    style: TextStyle(
                      color: AppColors.cardDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator(); // Show a loading indicator while waiting
                }
              },
            ),
            SizedBox(height: 5),
            FutureBuilder<String>(
              future: getEmail(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    "Ошибка получения email",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  );
                } else {
                  return CircularProgressIndicator(); // Или другой индикатор загрузки
                }
              },
            ),
            SizedBox(height: 20),

            // Follower Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "1",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "follow",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 50),
                Column(
                  children: [
                    Text(
                      "0",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "followers",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),

            // Grid of Images
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _loadClothesByCategory('Созданные наряды'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final clothes = snapshot.data ?? [];
                      if (clothes.isEmpty) {
                        return const Center(
                            child: Text('No outfits created yet.'));
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: clothes.length,
                          itemBuilder: (context, index) {
                            final cloth = clothes[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Image.file(
                                    File(cloth['imagePath']),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(cloth['name']),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Мои подборки",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
