import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class NeuroScreen extends StatefulWidget {
  const NeuroScreen({super.key, required this.database});
  final Database database;
  @override
  State<NeuroScreen> createState() => _NeuroScreenState();
}

class _NeuroScreenState extends State<NeuroScreen> {
  final List<String> _categories = [
    'Верхняя одежда',
    'Нижнее бельё',
    'Обувь',
    'Лёгкая одежда'
  ];
  String? _selectedCategory;
  File? _selectedImage;
  final TextEditingController _textController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _addItem() async {
    String name = _textController.text;
    String category = _selectedCategory ?? '';
    String imagePath = _selectedImage?.path ?? '';

    if (name.isNotEmpty && category.isNotEmpty && imagePath.isNotEmpty) {
      await widget.database.insert(
        'clothes',
        {'name': name, 'category': category, 'imagePath': imagePath},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      setState(() {
        _textController.clear();
        _selectedCategory = null;
        _selectedImage = null;
      });
      Navigator.of(context).pop();
    }
  }

  Future<List<Map<String, dynamic>>> _loadClothesByCategory(
      String category) async {
    return await widget.database.query(
      'clothes',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future<void> _deleteItem(int id) async {
    await widget.database.delete(
      'clothes',
      where: 'id = ?',
      whereArgs: [id],
    );
    setState(() {});
  }

  void _showClothesForCategory(String category) async {
    final clothes = await _loadClothesByCategory(category);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category),
          content: clothes.isEmpty
              ? const Text('No clothes in this category yet.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: clothes.length,
                    itemBuilder: (context, index) {
                      final cloth = clothes[index];
                      return GestureDetector(
                        onDoubleTap: () => _deleteItem(cloth['id']),
                        child: ListTile(
                          leading: Image.file(File(cloth['imagePath'])),
                          title: Text(cloth['name']),
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Select Category'),
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Choose Image'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addItem,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index < _categories.length) {
            final category = _categories[index];
            return GestureDetector(
              onTap: () => _showClothesForCategory(category),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
                child: Center(
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: _showAddDialog,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white),
                ),
                child: const Icon(Icons.add, size: 48),
              ),
            );
          }
        },
      ),
    );
  }
}
