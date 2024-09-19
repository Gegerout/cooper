import 'package:eco_admin/data/sources/api.dart';  // Импорт API для взаимодействия с сервером
import 'package:eco_admin/domain/repository/repository_impl.dart';  // Импорт базового класса репозитория
import 'package:eco_admin/domain/usecases/event_usecase.dart';  // Импорт класса использования событий
import 'package:eco_admin/domain/usecases/user_usecase.dart';  // Импорт класса использования пользователей
import 'package:image_picker/image_picker.dart';  // Импорт для выбора изображений из галереи

import '../models/user_model.dart';  // Импорт модели пользователя

// Класс Repository, который реализует методы для работы с данными
class Repository extends RepositoryImpl {
  @override
  Future<EventUseCase> getEvents() async {
    // Получение списка событий из API
    final data = await Api().getEvents();
    return EventUseCase(data);  // Возвращаем данные в виде EventUseCase
  }

  @override
  Future<UserUseCase> loginUser(String login, String password) async {
    // Аутентификация пользователя через API
    final data = await Api().loginUser(login, password);
    return UserUseCase(data);  // Возвращаем данные в виде UserUseCase
  }

  @override
  Future<void> addComment(int id, String accessToken, String username, String comment) async {
    // Добавление комментария к событию через API
    await Api().addComment(id, accessToken, username, comment);
  }

  @override
  Future<void> likeEvent(int id, String accessToken) async {
    // Добавление лайка к событию через API
    await Api().addLike(id, accessToken);
  }

  @override
  Future<void> addEvent(String accessToken, String title, String description, String place,
      DateTime date, String type, String kind, String frequency, List<XFile> imageFiles, double popularity) async {
    // Добавление нового события через API
    await Api().addEventWeb(accessToken, title, description, place, date, type,
        kind, frequency, imageFiles, popularity);
  }

  @override
  Future<Map<String, dynamic>> predictType(String description) async {
    // Предсказание типа события на основе описания через API
    final data = await Api().predictTypes(description);
    return data;  // Возвращаем предсказанные данные
  }

  @override
  Future<double> predictPopularity(String type, String format, String location, String frequency) async {
    // Предсказание популярности события на основе различных факторов через API
    final data = await Api().predictPopularity(type, format, location, frequency);
    return data;  // Возвращаем предсказанную популярность
  }

  @override
  Future<List<UserModel>> getUsers() async {
    // Получение списка пользователей из API
    final data = await Api().getUsers();
    return data;  // Возвращаем данные пользователей
  }
}
