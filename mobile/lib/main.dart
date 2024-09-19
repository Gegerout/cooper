import 'dart:developer';
import 'package:eco_mobile/presentation/screens/home_screen.dart';
import 'package:eco_mobile/presentation/screens/register_screen.dart';
import 'package:eco_mobile/presentation/states/states.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fbMes = FirebaseMessaging.instance;

  await fbMes.requestPermission();

  final token = await fbMes.getToken();
  log(token.toString());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Экопросвет',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              color: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent)),
      home: Scaffold(
        body: ref.watch(loadUser).when(
            data: (value) {
              if (value != null) {
                return HomeScreen(model: value);
              } else {
                return RegisterScreen();
              }
            },
            error: (e, s) => Center(child: Text(e.toString())),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )),
      ),
    );
  }
}
