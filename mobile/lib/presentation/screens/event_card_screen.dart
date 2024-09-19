import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/event_model.dart';
import '../../data/models/user_model.dart';
import '../states/states.dart';

// Экран карточки мероприятия
class EventCardScreen extends ConsumerStatefulWidget {
  const EventCardScreen(this.eventModel, {super.key, required this.model});

  final EventModel eventModel;
  final UserModel model;

  @override
  ConsumerState<EventCardScreen> createState() => _EventCardScreenState();
}

class _EventCardScreenState extends ConsumerState<EventCardScreen> {
  TextEditingController commCont = TextEditingController();

  @override
  void dispose() {
    commCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.eventModel;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Center(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  event.photos.first.toString().replaceAll(
                      "http://10.0.2.2:5000",
                      "https://e350-5-18-146-225.ngrok-free.app"),
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, child, e) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                          child: Icon(
                        Icons.image,
                        size: 60,
                      )),
                    );
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        event.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: event.isLiked ? Colors.red : Colors.grey,
                        size: 27,
                      ),
                      onPressed: () async {
                        await ref
                            .read(authProvider)
                            .likeEvent(event.id, widget.model.accessToken);
                        setState(() {
                          event.isLiked = !event.isLiked;
                          event.likes += event.isLiked ? 1 : -1;
                        });
                      },
                    ),
                    Text(
                      '${event.likes}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await ref.read(authProvider).joinEvent(event.id,
                                widget.model.accessToken, widget.model.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Вы успешно зарегистировались на мероприятие")));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).textTheme.bodyLarge!.color),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Участвовать",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(event.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    event.description,
                    maxLines: null,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Основная информация",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Дата проведения: ${event.date}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Место проведения: ${event.place}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Количество участников: ${event.userCount}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Дополнительная информация",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Тип мероприятия: ${event.type}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Вид мероприятия: ${event.kind}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    "Частота проведения: ${event.frequency}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Text(
                    "Комментарии",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: event.comments.length,
                    itemBuilder: (context, commentIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text:
                                    "${event.comments[commentIndex]["username"]} ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${event.comments[commentIndex]["comment"]}",
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: commCont,
                    decoration: InputDecoration(
                      hintText: 'Оставить комментарий...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          if (commCont.text.isNotEmpty) {
                            await ref.read(authProvider).addComment(
                                  event.id,
                                  widget.model.accessToken,
                                  widget.model.username,
                                  commCont.text,
                                );
                            setState(() {
                              // Optionally update the local state for new comment
                              event.comments.add({
                                'username': widget.model.username,
                                'comment': commCont.text,
                              });
                              commCont.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
