import 'dart:convert';
import 'dart:io';

import 'package:eco_mobile/data/models/user_model.dart';
import 'package:path_provider/path_provider.dart';

class Local {
  static const String _fileName = "auth_data.json";

  Future<void> saveAuth(UserModel auth) async {
    final file = await _getLocalFile();
    final jsonData = jsonEncode(auth.toJson());
    await file.writeAsString(jsonData);
  }

  Future<UserModel?> getAuth() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final Map<String, dynamic> jsonMap = jsonDecode(jsonData);
        return UserModel.fromJson(jsonMap);
      } else {
        return null;
      }
    } catch (e) {
      throw "Ошибка при получении данных";
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}