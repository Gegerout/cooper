import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

// Экран с профилем пользователя
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.model});

  final UserModel model;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          "Профиль",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.model.username,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'Активность: ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: '${widget.model.activity}',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: 'Возраст: ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: '${widget.model.age}',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: 'Пол: ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: widget.model.gender,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: 'Локация: ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                children: [
                  TextSpan(
                    text: widget.model.location,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
