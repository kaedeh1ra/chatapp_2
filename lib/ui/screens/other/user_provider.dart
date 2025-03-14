import 'package:chatapp_2/core/models/user_model.dart';
import 'package:chatapp_2/core/services/database_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;

  UserProvider(this._db);

  UserModel? _currentUser;

  UserModel? get user => _currentUser;

  loadUser(String uid) async {
    final userData = await _db.loadUser(uid);

    if (userData != null) {
      _currentUser = UserModel.fromMap(userData);
      notifyListeners();
    }
  }

  clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
