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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
          title: _isSearching
              ? TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Поиск...',
              border: InputBorder.none,
            ),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          )
              : const Text(
            "Мероприятия",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              icon: Icon(_isSearching ? Icons.close : Icons.search),
            ),
          ],
        ),
        body: ref
            .watch(loadEvents((
              widget.model.age,
              widget.model.gender,
              widget.model.location,
              widget.model.accessToken
            )))
            .when(
                data: (value) {
                  final filteredEvents = value.where((event) {
                    final title = event.title.toLowerCase();
                    return title.contains(_searchQuery.toLowerCase());
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .refresh(loadEvents((
                            widget.model.age,
                            widget.model.gender,
                            widget.model.location,
                            widget.model.accessToken
                          )))
                          .value;
                    },
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior()
                              .copyWith(scrollbars: false),
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              final row = filteredEvents[index];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EventCardScreen(row,
                                                        model: widget.model)))
                                        .then((value) {
                                      ref
                                          .refresh(loadEvents((
                                            widget.model.age,
                                            widget.model.gender,
                                            widget.model.location,
                                            widget.model.accessToken
                                          )))
                                          .value;
                                    });
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          row.photos.first.toString().replaceAll(
                                              "http://10.0.2.2:5000",
                                              "https://9164-5-18-146-225.ngrok-free.app"),
                                          width: double.infinity,
                                          height: 400,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return SizedBox(
                                              height: 400,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                                    .likeEvent(
                                                        row.id,
                                                        widget
                                                            .model.accessToken);
                                                setState(() {
                                                  row.isLiked = !row.isLiked;
                                                  row.likes +=
                                                      row.isLiked ? 1 : -1;
                                                });
                                              },
                                            ),
                                            Text(
                                              '${row.likes}',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12),
                                          child: Text(row.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12),
                                          child: Text(
                                            row.description,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12),
                                          child: Text(
                                            row.date,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.grey),
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
                                                    itemCount: min(
                                                        row.comments.length, 1),
                                                    itemBuilder: (context,
                                                        commentIndex) {
                                                      return RichText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  "${row.comments[commentIndex]["username"]} ",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black, // Ensure color is set
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "${row.comments[commentIndex]["comment"]}",
                                                              style:
                                                                  const TextStyle(
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
                                                              EventCardScreen(
                                                                  row,
                                                                  model: widget
                                                                      .model)))
                                                  .then((value) {
                                                ref
                                                    .refresh(loadEvents((
                                                      widget.model.age,
                                                      widget.model.gender,
                                                      widget.model.location,
                                                      widget.model.accessToken
                                                    )))
                                                    .value;
                                              });
                                            },
                                            child: Text(
                                              row.comments.isEmpty
                                                  ? "Подробнее"
                                                  : "Смотреть все комментарии",
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )),
                                        const Divider()
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: filteredEvents.length,
                          ),
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
