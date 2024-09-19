import 'package:eco_admin/domain/usecases/event_usecase.dart';
import 'package:eco_admin/domain/usecases/user_usecase.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/user_model.dart';
// Репозиторий уровня Домен
abstract class RepositoryImpl {
  Future<UserUseCase> loginUser(String login, String password);

  Future<EventUseCase> getEvents();

  Future<void> likeEvent(int id, String accessToken);

  Future<void> addComment(
      int id, String accessToken, String username, String comment);

  Future<Map<String, dynamic>> predictType(String description);

  Future<double> predictPopularity(String type, String format, String location, String frequency);

  Future<void> addEvent(String accessToken,
      String title,
      String description,
      String place,
      DateTime date,
      String type,
      String kind,
      String frequency,
      List<XFile> imageFiles, double popularity);

  Future<List<UserModel>> getUsers();
}
