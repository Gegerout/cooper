import 'package:eco_mobile/presentation/screens/home_screen.dart';
import 'package:eco_mobile/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/states.dart';

// Экран входа
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController nameCont = TextEditingController();
  final TextEditingController passCont = TextEditingController();
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
                      "Вход",
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 320,
                    child: TextFormField(
                      controller: nameCont,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(left: 23, top: 16, bottom: 16),
                        labelText: "Имя",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16))),
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
                        contentPadding:
                            EdgeInsets.only(left: 23, top: 16, bottom: 16),
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
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final model = await ref
                              .read(authProvider)
                              .loginUser(nameCont.text, passCont.text);

                          await ref.read(authProvider).saveAuth(model);

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                          model: model,
                                        )),
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).textTheme.bodyLarge!.color),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Войти",
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
                                builder: (context) => RegisterScreen()));
                      },
                      child: const Text(
                        "Зарегистрироваться",
                        style: TextStyle(fontSize: 20),
                      )),
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
