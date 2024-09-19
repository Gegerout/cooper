// Модель пользователя
class UserModel {
  final int id;
  final String accessToken;
  final String username;
  final String role;
  final String location;
  final int age;
  final String gender;
  final int activity;

  UserModel(this.id, this.accessToken, this.username, this.role, this.location,
      this.age, this.gender, this.activity);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        json["id"] ?? 0,
        json["accessToken"] ?? "",
        json["username"] ?? "",
        json["role"] ?? "",
        json["location"] ?? "",
        json["age"] ?? 0,
        json["gender"] ?? "",
        json["activity"] ?? 0);
  }

  Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "role": role,
        "location": location,
        "age": age,
        "gender": gender,
        "activity": activity,
        "id": id,
        "username": username,
      };
}
