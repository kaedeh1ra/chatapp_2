import 'package:chatapp_2/screens/neironka.dart';
import 'package:chatapp_2/screens/screens.dart';
import 'package:chatapp_2/theme.dart';
import 'package:chatapp_2/ui/screens/auth/login/login_screen.dart';
import 'package:chatapp_2/ui/screens/other/user_provider.dart';
import 'package:chatapp_2/ui/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'core/services/database_service.dart';
import 'core/utils/route_utils.dart';
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
    return ScreenUtilInit(
      builder: (context, child) => ChangeNotifierProvider(
        create: (context) => UserProvider(DatabaseService()),
        child: MaterialApp(
          onGenerateRoute: RouteUtils.onGenerateRoute,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          title: 'chatapp_2',
          home: HomeScreen(database: database),
        ),
      ),
    );
  }
}
