import 'package:eco_mobile/presentation/states/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';

// Экран рейтинга пользователей
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key, required this.model});

  final UserModel model;

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          "Рейтинг",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final row = ref.watch(authProvider).users[index];
          return ListTile(
            title: Text(row.username),
            subtitle: Text("Рейтинг: ${row.activity.toString()}"),
          );
        },
        itemCount: ref.watch(authProvider).users.length,
      ),
    );
  }
}
