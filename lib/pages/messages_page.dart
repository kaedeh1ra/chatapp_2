import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp_2/helpers.dart';
import 'package:chatapp_2/theme.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../models/messageData.dart';
import '../models/models.dart';
import '../screens/chat_screen.dart';
import '../widgets/widgets.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final List<String> imageUrls = [
    "https://storage.yandexcloud.net/elyts-prod/main/83e/83e0cc855b1ec736ae36b009e2f7d486/169597335265167fe8a8c71.png",
    "https://storage.yandexcloud.net/elyts-prod/main/8bc/8bcd493a88002d692b77ebed507364d7/169597333665167fd8f35a4.png",
    "https://storage.yandexcloud.net/elyts-prod/main/dbd/dbd266725bdcd8abff458af0411b58d9/1695974109651682dd5e4bd.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 20, // Number of news items
        itemBuilder: (context, index) {
          // Generate a random index to pick a random image
          final random = Random();
          final imageUrl = imageUrls[random.nextInt(imageUrls.length)];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Random News Title ${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Новость реального пользователя',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          );
        },
      ),
    );
  }
}
