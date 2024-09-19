import 'package:eco_mobile/presentation/screens/map_screen.dart';
import 'package:eco_mobile/presentation/screens/users_screen.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import 'events_screen.dart';
import 'profile_screen.dart';

// Начальный экран для навигации
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.model});

  final UserModel model;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      EventsScreen(model: widget.model),
      UsersScreen(model: widget.model),
      const MapScreen(),
      ProfileScreen(model: widget.model),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Мероприятия',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Рейтинг',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Карта',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
