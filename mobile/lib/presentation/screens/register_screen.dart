import 'package:eco_mobile/presentation/screens/home_screen.dart';
import 'package:eco_mobile/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/states.dart';

// Экран регистрации
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController nameCont = TextEditingController();
  final TextEditingController passCont = TextEditingController();
  final TextEditingController ageCont = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? selectedLocation;
  String? selectedGender;

  final List<String> locations = [
    'НАО',
    'ЮЗАО',
    'ЗелАО',
    'ВАО',
    'ТАО',
    'ЦАО',
    'СВАО',
    'ЮАО',
    'СЗАО',
    'ЗАО',
    'САО',
    'ЮВАО'
  ];
  final List<String> genders = ['Мужской', 'Женский'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/be.png",
                    width: 250,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Регистрация",
                      style:
                          TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: nameCont,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "Имя",
                        border: OutlineInputBorder( borderRadius:
                        BorderRadius.all(Radius.circular(16))),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите имя';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: passCont,
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "Пароль",
                        border: OutlineInputBorder( borderRadius:
                        BorderRadius.all(Radius.circular(16))),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Dropdown для выбора места проживания
                  SizedBox(
                    width: 320,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16, right: 18),
                        labelText: "Место проживания",
                        border: OutlineInputBorder( borderRadius:
                        BorderRadius.all(Radius.circular(16))),
                      ),
                      value: selectedLocation,
                      items: locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите место проживания';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Dropdown для выбора пола
                  SizedBox(
                    width: 320,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16, right: 18),
                        labelText: "Пол",
                        border: OutlineInputBorder( borderRadius:
                        BorderRadius.all(Radius.circular(16))),
                      ),
                      value: selectedGender,
                      items: genders.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите пол';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Поле для ввода возраста
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: ageCont,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "Возраст",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите возраст';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age <= 0) {
                          return 'Введите корректный возраст';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final model = await ref
                              .read(authProvider)
                              .registerUser(
                                  nameCont.text,
                                  passCont.text,
                                  selectedLocation ?? "",
                                  int.parse(ageCont.text),
                                  selectedGender ?? "");

                          await ref.read(authProvider).saveAuth(model);

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen(model: model)),
                                (route) => false);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())));
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).textTheme.bodyLarge!.color),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Зарегистрироваться",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "или",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: const Text(
                        "Войти",
                        style: TextStyle(fontSize: 20),
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/vk.png",
                            width: 50,
                            height: 50,
                          )),
                      const SizedBox(width: 20,),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/epgu.png',
                          width: 50,
                          height: 50,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
