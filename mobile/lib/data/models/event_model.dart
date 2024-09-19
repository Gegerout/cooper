// Модель мероприятия
class EventModel {
  final List comments;
  final String date;
  final String description;
  final String frequency;
  final int id;
  final String kind;
  final String type;
  final String place;
  final String title;
  final List photos;
  final int userCount;
  int likes;
  bool isLiked;

  EventModel(
      this.comments,
      this.date,
      this.description,
      this.frequency,
      this.id,
      this.kind,
      this.type,
      this.place,
      this.title,
      this.photos,
      this.userCount,
      this.likes, this.isLiked);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
        json["comments"] ?? [],
        json["date"] ?? "",
        json["description"] ?? "",
        json["frequency"] ?? "",
        json["id"] ?? 0,
        json["kind"] ?? "",
        json["type"] ?? "",
        json["place"] ?? "",
        json["title"] ?? "",
        json["photos"] ?? [],
        json["userCount"] ?? 0, json["likes"] ?? 0, false);
  }
}
