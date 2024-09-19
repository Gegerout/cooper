import 'package:eco_admin/data/models/user_model.dart';
import 'package:eco_admin/data/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Провайдер для загрузки событий
final loadEvents = FutureProvider((ref) async {
  final data = await Repository().getEvents();
  ref.read(authProvider).getUsers();  // Получение пользователей после загрузки событий
  return data.events;  // Возврат списка событий
});

// Провайдер для аутентификации
final authProvider = ChangeNotifierProvider((ref) => AuthNotifier());

class AuthNotifier extends ChangeNotifier {
  bool isLoading = false;  // Флаг загрузки
  double popularity = 0.0;  // Популярность события
  List<UserModel> users = [];  // Список пользователей

  // Метод для входа пользователя
  Future<UserModel> loginUser(String login, String password) async {
    final data = await Repository().loginUser(login, password);
    return data.userModel;  // Возврат модели пользователя
  }

  // Метод для добавления комментария
  Future<void> addComment(int id, String accessToken, String username, String comment) async {
    await Repository().addComment(id, accessToken, username, comment);
  }

  // Метод для лайка события
  Future<void> likeEvent(int id, String accessToken) async {
    await Repository().likeEvent(id, accessToken);
  }

  // Метод для предсказания типа мероприятия
  Future<Map<String, dynamic>> predictTypes(String description) async {
    isLoading = true;  // Установка флага загрузки
    notifyListeners();  // Уведомление слушателей
    final data = await Repository().predictType(description);
    isLoading = false;  // Сброс флага загрузки
    notifyListeners();  // Уведомление слушателей
    return data;  // Возврат предсказанных данных
  }

  // Метод для предсказания популярности
  Future<double> predictPopularity(String type, String format, String location, String frequency) async {
    final data = await Repository().predictPopularity(type, format, location, frequency);
    popularity = data;  // Установка предсказанной популярности
    notifyListeners();  // Уведомление слушателей
    return data;  // Возврат предсказанной популярности
  }

  // Метод для добавления мероприятия
  Future<void> addEvent(
      String accessToken,
      String title,
      String description,
      String place,
      DateTime date,
      String type,
      String kind,
      String frequency,
      List<XFile> imageFiles) async {
    await Repository().addEvent(accessToken, title, description, place, date,
        type, kind, frequency, imageFiles, popularity);
    popularity = 0;  // Сброс популярности
    notifyListeners();  // Уведомление слушателей
  }

  // Метод для получения пользователей
  Future<List<UserModel>> getUsers() async {
    final data = await Repository().getUsers();
    users = data;  // Установка списка пользователей
    users.removeWhere((val) => val.username == "admin@mail.ru");  // Удаление администратора из списка
    users.sort((a, b) => b.activity.compareTo(a.activity));  // Сортировка пользователей по активности
    notifyListeners();  // Уведомление слушателей
    return data;  // Возврат списка пользователей
  }
}
