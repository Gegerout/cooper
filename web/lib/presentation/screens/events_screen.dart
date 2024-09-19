import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../states/states.dart';
import 'event_card_screen.dart';

// Экран списка всех мероприятий
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key, required this.model});

  final UserModel model;

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final TextEditingController commCont = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          centerTitle: true,
          title: const Text(
            "Мероприятия",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "btn1",
          onPressed: () {
            ref.refresh(loadEvents).value;
          },
          child: const Icon(Icons.refresh),
        ),
        body: ref.watch(loadEvents).when(
            data: (value) {
              return Center(
                child: SizedBox(
                  width: 400,
                  child: ScrollConfiguration(
                    behavior:
                        const ScrollBehavior().copyWith(scrollbars: false),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final row = value[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EventCardScreen(row,
                                          model: widget.model))).then((value) {
                                ref.refresh(loadEvents).value;
                              });
                            },
                            child: SizedBox(
                              width: 400,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    row.photos.first.toString().replaceAll(
                                        "http://127.0.0.1:5000",
                                        "https://9164-5-18-146-225.ngrok-free.app"),
                                    width: 400,
                                    height: 400,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return SizedBox(
                                        height: 400,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
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
                                          row.isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: row.isLiked
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 27,
                                        ),
                                        onPressed: () async {
                                          await ref
                                              .read(authProvider)
                                              .likeEvent(row.id,
                                                  widget.model.accessToken);
                                          setState(() {
                                            row.isLiked = !row.isLiked;
                                            row.likes += row.isLiked ? 1 : -1;
                                          });
                                        },
                                      ),
                                      Text(
                                        '${row.likes}',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 18,
                                      ),
                                      const Text(
                                        'Зарегистрировано: ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        '${row.userCount}',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(row.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      row.description,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      row.date,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  row.comments.isEmpty
                                      ? Container()
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12, top: 12),
                                          child: SizedBox(
                                            height: 20,
                                            child: ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  min(row.comments.length, 1),
                                              itemBuilder:
                                                  (context, commentIndex) {
                                                return RichText(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  text: TextSpan(
                                                    style: DefaultTextStyle.of(
                                                            context)
                                                        .style,
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            "${row.comments[commentIndex]["username"]} ",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .black, // Ensure color is set
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            "${row.comments[commentIndex]["comment"]}",
                                                        style: const TextStyle(
                                                          color: Colors
                                                              .black, // Ensure color is set for normal text
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EventCardScreen(row,
                                                            model:
                                                                widget.model)))
                                            .then((value) {
                                          ref.refresh(loadEvents).value;
                                        });
                                      },
                                      child: Text(
                                        row.comments.isEmpty
                                            ? "Подробнее"
                                            : "Смотреть все комментарии",
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: value.length,
                    ),
                  ),
                ),
              );
            },
            error: (e, s) => Center(child: Text(e.toString())),
            loading: () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Подбираем мероприятия для вас)",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20),
                    )
                  ],
                )));
  }
}
