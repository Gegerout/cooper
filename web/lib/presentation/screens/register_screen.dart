import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';

// Экран регистрации
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController loginCont = TextEditingController();
  final TextEditingController passCont = TextEditingController();
  final TextEditingController innCont = TextEditingController(); // INN field
  final TextEditingController websiteCont = TextEditingController(); // Website field
  final TextEditingController regCont = TextEditingController(); // Legal registration field

  final _formKey = GlobalKey<FormState>();

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
                      "Регистрация для организаций",
                      style: TextStyle(
                          fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Login Field (Username)
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: loginCont,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "Логин",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите логин';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Password Field
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: passCont,
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "Пароль",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
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
                  // INN Field
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: innCont,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "ИНН",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите ИНН';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Website Field
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: websiteCont,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "Веб-сайт",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите веб-сайт организации';
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
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Ваше заявление принято в обработку")));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())));
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).textTheme.bodyLarge!.color),
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
                    ),
                  ),
                  const SizedBox(height: 40),
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
