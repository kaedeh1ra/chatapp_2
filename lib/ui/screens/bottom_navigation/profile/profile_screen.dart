import 'package:chatapp_2/core/services/auth_service.dart';
import 'package:chatapp_2/ui/screens/other/user_provider.dart';
import 'package:chatapp_2/ui/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05),
        child: Column(
          children: [
            50.verticalSpace,
            CustomButton(
              text: "Logout",
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).clearUser();
                AuthService().logout();
              },
            )
          ],
        ),
      ),
    );
  }
}
