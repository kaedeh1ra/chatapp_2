import 'package:chatapp_2/app.dart';
import 'package:chatapp_2/screens/screens.dart';
import 'package:chatapp_2/theme.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

void main() {
  final client = StreamChatClient(streamKey);

  runApp(MyApp(
    client: client,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.client});

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      title: 'chatapp_2',
      builder: (context, child) {
        return StreamChatCore(client: client, child: child!);
      },
      home: HomeScreen(),
    );
  }
}
