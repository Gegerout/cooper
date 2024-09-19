import 'package:eco_admin/presentation/screens/add_event_screen.dart';
import 'package:eco_admin/presentation/screens/download_screen.dart';
import 'package:eco_admin/presentation/screens/events_screen.dart';
import 'package:eco_admin/data/models/user_model.dart';
import 'package:eco_admin/presentation/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Начальный экран для навигации
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.model});

  final UserModel model;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      AddEventScreen(model: widget.model),
      const DownloadScreen()
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            groupAlignment: 0.0, // Center the items vertically
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.event),
                label: Text('Мероприятия'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star),
                label: Text('Рейтинг'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Добавить'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.download),
                label: Text('Выгрузка'),
              )
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }
}
