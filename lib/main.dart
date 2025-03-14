import 'package:chatapp_2/screens/neironka.dart';
import 'package:chatapp_2/screens/screens.dart';
import 'package:chatapp_2/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final database = await openDatabase(
    p.join(await getDatabasesPath(), 'clothing_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE clothes(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, imagePath TEXT)',
      );
    },
    version: 1,
  );

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final Database database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      title: 'chatapp_2',
      home: NeuroScreen(database: database),
    );
  }
}
