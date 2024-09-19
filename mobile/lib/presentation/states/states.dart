// Импортируем необходимые пакеты
import 'package:eco_mobile/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/repository/repository.dart';

// Провайдер для загрузки событий с параметрами
final loadEvents = FutureProvider.family<List<EventModel>, (int, String, String, String)>((ref, vals) async {
  ref.read(authProvider).getUsers();
  // Запрашиваем события из репозитория на основе возраста, пола, местоположения и токена доступа
  final data = await Repository().getEvents(vals.$1, vals.$2, vals.$3, vals.$4);
  final events = data.events; // Извлекаем список событий

  return events; // Возвращаем события
});

// Провайдер для загрузки информации о пользователе
final loadUser = FutureProvider((ref) async {
  final data = await Repository().getUser(); // Получаем данные о пользователе

  if (data != null) {
    ref.read(authProvider).getUsers(); // Загружаем пользователей, если данные о пользователе не нулевые
    return data.userModel; // Возвращаем модель пользователя
  } else {
    return null; // Если данных нет, возвращаем null
  }
});

// Провайдер для аутентификации
final authProvider = ChangeNotifierProvider((ref) => AuthNotifier());

// Класс для управления состоянием аутентификации
class AuthNotifier extends ChangeNotifier {
  bool isLoading = false; // Состояние загрузки
  double popularity = 0.0; // Переменная для хранения популярности
  List<UserModel> users = []; // Список пользователей

  // Метод для регистрации пользователя
  Future<UserModel> registerUser(String login, String password, String location,
      int age, String gender) async {
    final data = await Repository().registerUser(login, password, location, age, gender);
    return data.userModel; // Возвращаем модель пользователя после регистрации
  }

  // Метод для входа пользователя
  Future<UserModel> loginUser(String login, String password) async {
    final data = await Repository().loginUser(login, password);
    return data.userModel; // Возвращаем модель пользователя после входа
  }

  // Метод для добавления комментария к событию
  Future<void> addComment(int id, String accessToken, String username, String comment) async {
    await Repository().addComment(id, accessToken, username, comment);
  }

  // Метод для участия в событии
  Future<void> joinEvent(int id, String accessToken, int userId) async {
    await Repository().joinEvent(id, accessToken, userId);
  }

  // Метод для лайка события
  Future<void> likeEvent(int id, String accessToken) async {
    await Repository().likeEvent(id, accessToken);
  }

  // Метод для сохранения данных аутентификации
  Future<void> saveAuth(UserModel auth) async {
    await Repository().saveUser(auth);
  }

  // Метод для получения списка пользователей
  Future<List<UserModel>> getUsers() async {
    final data = await Repository().getUsers(); // Получаем пользователей
    users = data; // Сохраняем пользователей в списке
    // Убираем пользователя с логином "admin@mail.ru"
    users.removeWhere((val) => val.username == "admin@mail.ru");
    // Сортируем пользователей по активности
    users.sort((a, b) => b.activity.compareTo(a.activity));
    notifyListeners(); // Уведомляем слушателей об изменении состояния
    return data; // Возвращаем список пользователей
  }
}
