import 'dart:convert';
import 'package:eco_admin/presentation/screens/home_screen.dart';
import 'package:eco_admin/presentation/states/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../data/models/user_model.dart';

// Экран добавления нового мероприятия
class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key, required this.model});

  final UserModel model;

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  List<XFile> selectedImages = [];
  DateTime? selectedDate;

  final _formKey = GlobalKey<FormState>();

  final List<String> placeOptions = [
    'Подольск',
    'Мытищи',
    'Лосиный Остров',
    'Зеленоград',
    'Измайловский парк',
    'Сокольники',
    'Битцевский лес',
    'Химки',
    'Парк Горького',
    'Воробьевы горы',
    'Крылатское',
    'Люблино'
  ];
  final List<String> typeOptions = [
    'Насаждение деревьев',
    'Уход за парком',
    'Субботник',
    'Уборка территории',
    'Эко-лекция'
  ];
  final List<String> kindOptions = [
    'Групповое',
    'Индивидуальное',
    'Волонтерская деятельность'
  ];
  final List<String> frequencyOptions = [
    'Еженедельно',
    'Раз в месяц',
    'Раз в год'
  ];

  String? selectedPlace;
  String? selectedType;
  String? selectedKind;
  String? selectedFrequency;

  Future<void> pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if(context.mounted) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Добавить мероприятие",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: "Название",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите название';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: descriptionController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: "Описание",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                            onEditingComplete: () async {
                              final data = await ref
                                  .read(authProvider)
                                  .predictTypes(descriptionController.text);

                              final decoded = jsonDecode(data["response"]);

                              setState(() {
                                selectedType = decoded["тип мероприятия"];
                                selectedKind = decoded["вид мероприятия"];
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите описание';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await pickDateTime(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color),
                              child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Выбрать дату",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  )),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              selectedDate != null
                                  ? DateFormat('yyyy-MM-dd HH:mm')
                                      .format(selectedDate!)
                                  : "Дата не выбрана",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                XFile? image =
                                await picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  setState(() {
                                    selectedImages.add(image);
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color),
                              child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Выбрать фото",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  )),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "${selectedImages.length} фото выбрано",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Dropdown for Place
                        SizedBox(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            value: selectedPlace,
                            focusColor: Colors.transparent,
                            decoration: const InputDecoration(
                              labelText: "Место",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                            items: placeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPlace = value;
                              });
                              if (selectedFrequency != null &&
                                  selectedKind != null &&
                                  selectedPlace != null &&
                                  selectedType != null) {
                                ref.read(authProvider).predictPopularity(
                                    selectedType!,
                                    selectedKind!,
                                    selectedPlace!,
                                    selectedFrequency!);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Выберите место';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Dropdown for Type
                        SizedBox(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            value: selectedType,
                            focusColor: Colors.transparent,
                            decoration: const InputDecoration(
                              labelText: "Тип",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                            items: typeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedType = value;
                              });
                              if (selectedFrequency != null &&
                                  selectedKind != null &&
                                  selectedPlace != null &&
                                  selectedType != null) {
                                ref.read(authProvider).predictPopularity(
                                    selectedType!,
                                    selectedKind!,
                                    selectedPlace!,
                                    selectedFrequency!);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Выберите тип';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Dropdown for Kind
                        SizedBox(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            value: selectedKind,
                            focusColor: Colors.transparent,
                            decoration: const InputDecoration(
                              labelText: "Вид",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                            items: kindOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedKind = value;
                              });
                              if (selectedFrequency != null &&
                                  selectedKind != null &&
                                  selectedPlace != null &&
                                  selectedType != null) {
                                ref.read(authProvider).predictPopularity(
                                    selectedType!,
                                    selectedKind!,
                                    selectedPlace!,
                                    selectedFrequency!);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Выберите вид';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Dropdown for Frequency
                        SizedBox(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            value: selectedFrequency,
                            focusColor: Colors.transparent,
                            decoration: const InputDecoration(
                              labelText: "Частота",
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                            items: frequencyOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFrequency = value;
                              });
                              if (selectedFrequency != null &&
                                  selectedKind != null &&
                                  selectedPlace != null &&
                                  selectedType != null) {
                                ref.read(authProvider).predictPopularity(
                                    selectedType!,
                                    selectedKind!,
                                    selectedPlace!,
                                    selectedFrequency!);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Выберите частоту';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Возможная популярность",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 25.0,
                  percent: ref.watch(authProvider).popularity,
                  center: Text(
                    "${ref.watch(authProvider).popularity * 100}%",
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  progressColor: Colors.green,
                  backgroundColor: Colors.grey[300]!,
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref.read(authProvider).addEvent(
                            widget.model.accessToken,
                            titleController.text,
                            descriptionController.text,
                            selectedPlace!,
                            selectedDate!,
                            selectedType!,
                            selectedKind!,
                            selectedFrequency!,
                            selectedImages,
                          );

                      ref.refresh(loadEvents).value;

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Мероприятие успешно создано")),
                        );
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(model: widget.model)),
                            (route) => false);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Пожалуйста, введите все поля")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).textTheme.bodyLarge!.color),
                  child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Добавить мероприятие",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
