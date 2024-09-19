import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:eco_admin/data/models/event_model.dart';
import 'package:eco_admin/data/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Api {
  final Dio dio = Dio(); // Инициализация Dio для HTTP-запросов

  Future<UserModel> loginUser(String login, String password) async {
    try {
      final res = await dio.post(
          "https://9164-5-18-146-225.ngrok-free.app/login",
          options: Options(
              validateStatus: (_) => true,
              headers: {"ngrok-skip-browser-warning": "69420"}),
          data: {"username": login, "password": password});
      if (res.statusCode == 200) {
        final UserModel model = UserModel.fromJson(res.data);
        return model; // Возврат модели пользователя
      } else {
        throw "Неправильный логин или пароль"; // Обработка ошибок
      }
    } catch (e) {
      throw "Неправильный логин или пароль";
    }
  }

  Future<List<EventModel>> getEvents() async {
    try {
      final res = await dio.get(
          "https://9164-5-18-146-225.ngrok-free.app/events",
          options: Options(
              validateStatus: (_) => true,
              headers: {"ngrok-skip-browser-warning": "69420"}));
      if (res.statusCode == 200) {
        final models =
            (res.data as List).map((e) => EventModel.fromJson(e)).toList();
        return models; // Возврат списка моделей событий
      } else {
        throw "Ошибка при загрузке мероприятий";
      }
    } catch (e) {
      throw "Ошибка при загрузке мероприятий";
    }
  }

  Future<void> addLike(int id, String accessToken) async {
    try {
      final res = await dio.post(
          "https://9164-5-18-146-225.ngrok-free.app/events/$id/like",
          options: Options(validateStatus: (_) => true, headers: {
            "Authorization": "Bearer $accessToken",
            "ngrok-skip-browser-warning": "69420"
          }));
      if (res.statusCode != 200) {
        throw "Ошибка при лайке";
      }
    } catch (e) {
      throw "Ошибка при лайке";
    }
  }

  Future<void> addComment(
      int id, String accessToken, String username, String comment) async {
    try {
      final res = await dio.post(
          "https://9164-5-18-146-225.ngrok-free.app/events/$id/comments",
          options: Options(validateStatus: (_) => true, headers: {
            "Authorization": "Bearer $accessToken",
            "ngrok-skip-browser-warning": "69420"
          }),
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
        return res.data; // Возврат предсказанных данных
      }
    } catch (e) {
      throw "Ошибка при предсказании типа";
    }
  }

  Future<double> predictPopularity(
      String type, String format, String location, String frequency) async {
    try {
      final res = await dio.post(
          "https://9164-5-18-146-225.ngrok-free.app/predict_popularity",
          options: Options(
              validateStatus: (_) => true,
              headers: {"ngrok-skip-browser-warning": "69420"}),
          data: {
            "event_type": type,
            "event_format": format,
            "location": location,
            "periodicity": frequency
          });
      if (res.statusCode != 200) {
        throw "Ошибка при подсчете популярности";
      } else {
        return res.data["probability"]; // Возврат предсказанной вероятности
      }
    } catch (e) {
      throw "Ошибка при подсчете популярности";
    }
  }

  Future<void> addEventWeb(
      String accessToken,
      String title,
      String description,
      String place,
      DateTime date,
      String type,
      String kind,
      String frequency,
      List<XFile> imageFiles,
      double popularity) async {
    try {
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm').format(date); // Форматирование даты
      List<MultipartFile> multipartImages = [];

      // Конвертация XFile в MultipartFile
      for (XFile file in imageFiles) {
        Uint8List fileBytes =
            await file.readAsBytes(); // Чтение файла как байтов
        MultipartFile multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: file.name, // Использование имени файла
        );
        multipartImages.add(multipartFile);
      }

      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'place': place,
        'date': formattedDate,
        'type': type,
        'kind': kind,
        'frequency': frequency,
        'photos': multipartImages, // Список MultipartFiles
        'popularity': popularity
      });

      final res = await dio.post(
        "http://127.0.0.1:5000/events",
        options: Options(
          validateStatus: (_) => true,
          headers: {
            "Authorization": "Bearer $accessToken",
            "ngrok-skip-browser-warning": "69420"
          },
        ),
        data: formData,
      );

      if (res.statusCode != 201) {
        throw "Ошибка при создании мероприятия";
      }
    } catch (e) {
      throw "Ошибка при создании мероприятия";
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final res = await dio.get(
          "https://9164-5-18-146-225.ngrok-free.app/users",
          options: Options(
              validateStatus: (_) => true,
              headers: {"ngrok-skip-browser-warning": "69420"}));

      if (res.statusCode != 200) {
        throw "Ошибка при загрузке рейтига";
      } else {
        final models =
            (res.data as List).map((e) => UserModel.fromJson(e)).toList();
        return models; // Возврат списка моделей пользователей
      }
    } catch (e) {
      throw "Ошибка при загрузке рейтига";
    }
  }
}
