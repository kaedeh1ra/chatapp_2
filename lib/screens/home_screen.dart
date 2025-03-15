import 'dart:convert';
import 'dart:io';

import 'package:chatapp_2/helpers.dart';
import 'package:chatapp_2/pages/calls_page.dart';
import 'package:chatapp_2/pages/messages_page.dart';
import 'package:chatapp_2/ui/screens/bottom_navigation/chats_list/chats_list_screen.dart';
import 'package:chatapp_2/ui/screens/wrapper/wrapper.dart';
import 'package:chatapp_2/widgets/glowing_action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../pages/contacts_page.dart';
import '../pages/notifications_page.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'neironka.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.database});

  Database database;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Messages');
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const MessagesPage(),
      Wrapper(),
      NeuroScreen(database: widget.database),
      ContactsPage(database: widget.database),
    ];
  }

  final pageTitles = const [
    'Лента',
    'Сообщения',
    'Гардероб',
    'Дом',
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
        database: widget.database,
      ),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({
    required this.onItemSelected,
    required this.database,
  });

  final Database database;
  final ValueChanged<int> onItemSelected;

  @override
  State<_BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;
  String _iamToken =
      't1.9euelZqbl5ebkpeKjJmSzciRyp2czO3rnpWajZWOmM3HmJSdycmUlJmVzo3l8_cWXSpB-e8fJ14D_t3z91YLKEH57x8nXgP-zef1656Vmo3KypedmpqVnpvLkIvOzpaN7_zF656Vmo3KypedmpqVnpvLkIvOzpaN.tiOTccXaMN18bZvtIGrEktYDcWQVwrgUfRWqJqejI-Yjmx9amDqFFnk5nDSi_WCq_OiWNDxmT4FR3UV5VoftAQ';
  String _operationId = '';
  String _imageUrl = '';
  bool _isLoading = false;

  void handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  Future<String> getAllClothesNames(Database database) async {
    final List<Map<String, dynamic>> maps = await database.query('clothes');
    return maps.map((e) => e['name'] as String).join(' ');
  }

  Future<void> generateImage(String prompt) async {
    setState(() {
      _isLoading = true;
      _imageUrl = '';
    });

    final url = Uri.parse(
      'https://llm.api.cloud.yandex.net/foundationModels/v1/imageGenerationAsync',
    );
    final headers = {
      'Authorization': 'Bearer $_iamToken',
      'Content-Type': 'application/json',
    };

    final data = {
      "modelUri": "art://b1gur8mji0okqtoumgpg/yandex-art/latest",
      "generationOptions": {
        "seed": "1863",
        "aspectRatio": {"widthRatio": "1", "heightRatio": "1"},
      },
      "messages": [
        {"weight": "3", "text": prompt},
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        _operationId = decodedResponse['id'];
        print('Operation ID: $_operationId');
        // Запускаем функцию для получения результата
        getImageResult(_operationId);
      } else {
        print('Failed to start image generation: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error during image generation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getImageResult(String operationId) async {
    // Ждем 10 секунд (или другое подходящее время)
    await Future.delayed(Duration(seconds: 10));

    final url = Uri.parse(
      'https://llm.api.cloud.yandex.net/operations/$operationId',
    );
    final headers = {'Authorization': 'Bearer $_iamToken'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse.containsKey('response') &&
            decodedResponse['response'].containsKey('image')) {
          final imageBase64 = decodedResponse['response']['image'];

          // Save image to storage
          final imagePath = await _saveImageToStorage(imageBase64);

          // Save to database
          await widget.database.insert(
              'clothes',
              {
                'name': 'Generated Outfit',
                'category': 'Созданные наряды',
                'imagePath': imagePath,
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
          setState(() {
            _imageUrl = 'data:image/jpeg;base64,$imageBase64';
            _isLoading = false;

            // Show AlertDialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Generated Outfit'),
                  content: Image.memory(base64Decode(imageBase64)),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          });
        } else {
          print('Failed to save image to storage or database');
        }
      } else {
        print('Failed to get image result: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error during getting image result: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _saveImageToStorage(String imageBase64) async {
    final decodedBytes = base64Decode(imageBase64);
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/generated_image.jpg';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(decodedBytes);
    return imagePath;
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
                lable: 'Лента',
                icon: CupertinoIcons.pano,
                isSelected: (selectedIndex == 0),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 2,
                lable: 'Гардероб',
                icon: CupertinoIcons.bell_solid,
                isSelected: (selectedIndex == 2),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GlowingActionButton(
                    color: AppColors.secondary,
                    icon: CupertinoIcons.add,
                    onPressed: () {
                      Future<String> clothesStr =
                          getAllClothesNames(widget.database);
                      String _prompt =
                          '$clothesStr собери всю эту одежду и выбери лучшую на твой взгляд для мальчика 16 лет с рыжими волосами Два ракурса: спереди и сбоку. Разрешение 1:1 (квадратное). Фотореалистичный стиль. Высокое разрешение (HD). Четкий фокус. Белый фон.';
                      generateImage(_prompt);
                    }),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 1,
                lable: 'Сообщения',
                icon: CupertinoIcons.person_2_fill,
                isSelected: (selectedIndex == 1),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 3,
                lable: 'Дом',
                icon: CupertinoIcons.home,
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
