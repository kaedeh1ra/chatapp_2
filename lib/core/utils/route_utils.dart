import 'package:chatapp_2/core/constants/string.dart';
import 'package:chatapp_2/core/models/user_model.dart';
import 'package:chatapp_2/ui/screens/auth/login/login_screen.dart';
import 'package:chatapp_2/ui/screens/auth/signup/signup_screen.dart';
import 'package:chatapp_2/ui/screens/bottom_navigation/chats_list/chat_room/chat_screen.dart';
import 'package:chatapp_2/ui/screens/splash/splash_screen.dart';
import 'package:chatapp_2/ui/screens/wrapper/wrapper.dart';
import 'package:flutter/material.dart';

class RouteUtils {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      // Auth
      case signup:
        return MaterialPageRoute(builder: (context) => const SignupScreen());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case wrapper:
        return MaterialPageRoute(builder: (context) => const Wrapper());
      case chatRoom:
        return MaterialPageRoute(
            builder: (context) => ChatScreen(
                  receiver: args as UserModel,
                ));

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("No Route Found")),
          ),
        );
    }
  }
}
