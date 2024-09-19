import '../../data/models/user_model.dart';
import '../usecases/event_usecase.dart';
import '../usecases/user_usecase.dart';

// Репозиторий уровня Домен
abstract class RepositoryImpl {
  Future<UserUseCase> registerUser(String login, String password,
      String location, int age, String gender);

  Future<UserUseCase> loginUser(String login, String password);

  Future<EventUseCase> getEvents(int age, String gender, String location, String accessToken);

  Future<void> likeEvent(int id, String accessToken);

  Future<void> addComment(
      int id, String accessToken, String username, String comment);

  Future<void> joinEvent(
      int id, String accessToken, int userId);

  Future<void> saveUser(UserModel auth);

  Future<UserUseCase?> getUser();

  Future<List<UserModel>> getUsers();
}
