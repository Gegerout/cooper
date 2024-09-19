import 'package:eco_mobile/data/models/user_model.dart';
import 'package:eco_mobile/data/sources/local.dart';
import '../../domain/repository/repository_impl.dart';
import '../../domain/usecases/event_usecase.dart';
import '../../domain/usecases/user_usecase.dart';
import '../sources/api.dart';

class Repository extends RepositoryImpl {
  @override
  Future<EventUseCase> getEvents(int age, String gender, String location, String accessToken) async {
    final data = await Api().getEvents(age, gender, location, accessToken);
    return EventUseCase(data);
  }

  @override
  Future<UserUseCase> registerUser(String login, String password,
      String location, int age, String gender) async {
    final data = await Api().registerUser(login, password, location, age, gender);
    return UserUseCase(data);
  }

  @override
  Future<UserUseCase> loginUser(String login, String password) async {
    final data = await Api().loginUser(login, password);
    return UserUseCase(data);
  }

  @override
  Future<void> addComment(int id, String accessToken, String username, String comment) async {
    await Api().addComment(id, accessToken, username, comment);
  }

  @override
  Future<void> joinEvent(int id, String accessToken, int userId) async {
    await Api().joinEvent(id, accessToken, userId);
  }

  @override
  Future<void> likeEvent(int id, String accessToken) async {
    await Api().addLike(id, accessToken);
  }

  @override
  Future<UserUseCase?> getUser() async {
    final data = await Local().getAuth();
    return data != null ? UserUseCase(data) : null;  // Использование тернарного оператора для компактности
  }

  @override
  Future<void> saveUser(UserModel auth) async {
    await Local().saveAuth(auth);
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final data = await Api().getUsers();
    return data;
  }
}
