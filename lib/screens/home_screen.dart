import 'package:chatapp_2/helpers.dart';
import 'package:chatapp_2/pages/calls_page.dart';
import 'package:chatapp_2/pages/messages_page.dart';
import 'package:chatapp_2/widgets/glowing_action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/contacts_page.dart';
import '../pages/notifications_page.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Messages');

  final pages = const [
    MessagesPage(),
    NotificationsPage(),
    CallsPage(),
    ContactsPage(),
  ];

  final pageTitles = const [
    'Messages',
    'Notifications',
    'Calls',
    'Contacts',
  ];

  void _onNavigationItemSelected(index) {
    title.value = pageTitles[index];
    pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, _) {
            return Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          },
        ),
        leadingWidth: 54,
        leading: Align(
            alignment: Alignment.centerRight,
            child: IconBackground(icon: Icons.search, onTap: () {})),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Avatar.small(url: Helpers.randomPictureUrl()),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, int value, _) {
          return pages[value];
        },
      ),
      bottomNavigationBar: _BottomNavigationBar(
        onItemSelected: _onNavigationItemSelected,
      ),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({
    required this.onItemSelected,
  });

  final ValueChanged<int> onItemSelected;

  @override
  State<_BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;

  void handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Card(
      color: (brightness == Brightness.light) ? Colors.transparent : null,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 16, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 0,
                lable: 'Messages',
                icon: CupertinoIcons.bubble_left_bubble_right_fill,
                isSelected: (selectedIndex == 0),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 1,
                lable: 'Notification',
                icon: CupertinoIcons.bell_solid,
                isSelected: (selectedIndex == 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GlowingActionButton(
                    color: AppColors.secondary,
                    icon: CupertinoIcons.add,
                    onPressed: () {}),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 2,
                lable: 'Calls',
                icon: CupertinoIcons.phone_fill,
                isSelected: (selectedIndex == 2),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 3,
                lable: 'Contacts',
                icon: CupertinoIcons.person_2_fill,
                isSelected: (selectedIndex == 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({
    required this.index,
    required this.lable,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  final int index;
  final String lable;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.secondary : null,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              lable,
              textAlign: TextAlign.center,
              style: isSelected
                  ? GoogleFonts.comfortaa(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    )
                  : GoogleFonts.comfortaa(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
