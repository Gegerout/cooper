import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class Api {
  final Dio dio = Dio();

  Future<UserModel> registerUser(String login, String password, String location, int age, String gender) async {
    try {
      final res = await dio.post("https://9164-5-18-146-225.ngrok-free.app/register",
          options: Options(validateStatus: (_) => true),
          data: {
            "username": login,
            "password": password,
            "location": location,
            "age": age,
            "gender": gender
          });
      if (res.statusCode == 201) {
        return UserModel.fromJson(res.data);
      } else {
        throw "Ошибка при создании пользователя";
      }
    } catch (e) {
      throw "Ошибка при создании пользователя";
    }
  }

  Future<UserModel> loginUser(String login, String password) async {
    try {
      final res = await dio.post("https://9164-5-18-146-225.ngrok-free.app/login",
          options: Options(validateStatus: (_) => true),
          data: {"username": login, "password": password});
      if (res.statusCode == 200) {
        return UserModel.fromJson(res.data);
      } else {
        throw "Неправильный логин или пароль";
      }
    } catch (e) {
      throw "Неправильный логин или пароль";
    }
  }

  Future<List<EventModel>> getEvents(int age, String gender, String location, String accessToken) async {
    try {
      final res = await dio.post("https://9164-5-18-146-225.ngrok-free.app/events/sorted",
          options: Options(
              validateStatus: (_) => true,
              headers: {"Authorization": "Bearer $accessToken"}),
          data: {"age": age, "gender": gender, "residence": location});
      if (res.statusCode == 200) {
        return (res.data as List).map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw "Ошибка при загрузке мероприятий";
      }
    } catch (e) {
      throw "Ошибка при загрузке мероприятий";
    }
  }

  Future<void> addLike(int id, String accessToken) async {
    try {
      final res = await dio.post("https://9164-5-18-146-225.ngrok-free.app/events/$id/like",
          options: Options(
              validateStatus: (_) => true,
              headers: {"Authorization": "Bearer $accessToken"}));
      if (res.statusCode != 200) {
        throw "Ошибка при лайке";
      }
    } catch (e) {
      throw "Ошибка при лайке";
    }
  }

  Future<void> addComment(int id, String accessToken, String username, String comment) async {
    try {
      final res = await dio.post("https://9164-5-18-146-225.ngrok-free.app/events/$id/comments",
          options: Options(validateStatus: (_) => true),
          data: {"username": username, "comment": comment});
      if (res.statusCode != 201) {
        throw "Ошибка при комментарии";
      }
    } catch (e) {
      throw "Ошибка при комментарии";
    }
  }

  Future<Map<String, dynamic>> predictTypes(String description) async {
    try {
      final res = await dio.post(
          "https://xyandex.pythonanywhere.com/process_event",
          options: Options(validateStatus: (_) => true),
          data: {"description": description});
      if (res.statusCode != 200) {
        throw "Ошибка при предсказании типа";
      } else {
        return res.data;
      }
    } catch (e) {
      throw "Ошибка при предсказании типа";
    }
  }

  Future<void> joinEvent(int id, String accessToken, int userId) async {
    try {
      final res = await dio.post("https://9164-5-18-146-225.ngrok-free.app/events/$id/join",
          options: Options(validateStatus: (_) => true),
          data: {"user_id": userId});
      if (res.statusCode != 200) {
        throw "Ошибка при участии";
      }
    } catch (e) {
      throw "Ошибка при участии";
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final res = await dio.get("https://9164-5-18-146-225.ngrok-free.app/users",
          options: Options(validateStatus: (_) => true));
      if (res.statusCode != 200) {
        throw "Ошибка при загрузке рейтига";
      } else {
        return (res.data as List).map((e) => UserModel.fromJson(e)).toList();
      }
    } catch (e) {
      throw "Ошибка при загрузке рейтига";
    }
  }
}
