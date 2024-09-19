import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Экран выгрузки данных
class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String? selectedOption;
  String? selectedGender;
  int? minAge; // Минимальный возраст
  int? maxAge; // Максимальный возраст
  String? selectedDistrict;
  String? selectedPlace;
  String? selectedType;
  String? selectedKind;
  String? selectedFrequency;

  final List<String> options = [
    'Выгрузка пользователей',
    'Выгрузка мероприятий'
  ];
  final List<String> genderOptions = ['Мужской', 'Женский'];
  final List<String> districts = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          "Выгрузка данных",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: selectedOption != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedOption = null;
                  });
                },
              )
            : null,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: selectedOption == null
              ? SizedBox(
                  width: 380,
                  child: DropdownButtonFormField<String>(
                    key: const ValueKey('menu'),
                    value: selectedOption,
                    focusColor: Colors.transparent,
                    decoration: const InputDecoration(
                      labelText: "Выберите тип выгрузки",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                )
              : selectedOption == 'Выгрузка пользователей'
                  ? _buildUserFields()
                  : _buildEventFields(),
        ),
      ),
    );
  }

  // Поля для "Выгрузка пользователей"
  Widget _buildUserFields() {
    return SizedBox(
      width: 380,
      child: Column(
        key: const ValueKey('userFields'),
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedGender,
            focusColor: Colors.transparent,
            decoration: const InputDecoration(
              labelText: "Пол",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            items: genderOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Возраст от",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                minAge = int.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 16),
          // Поле для максимального возраста
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Возраст до",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                maxAge = int.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedDistrict,
            focusColor: Colors.transparent,
            decoration: const InputDecoration(
              labelText: "Место проживания",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            items: districts.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDistrict = value;
              });
            },
          ),
          const SizedBox(height: 50),
          ElevatedButton(
              onPressed: () async {
                // Собираем параметры фильтров для пользователей
                String locationFilter = selectedDistrict != null ? 'location=$selectedDistrict' : '';
                String genderFilter = selectedGender != null ? 'gender=$selectedGender' : '';
                String minAgeFilter = minAge != null ? 'min_age=$minAge' : '';
                String maxAgeFilter = maxAge != null ? 'max_age=$maxAge' : '';

                // Формируем URL для выгрузки пользователей с параметрами
                String exportUrl = 'http://127.0.0.1:5000/export?type=users&'
                    '$locationFilter&$genderFilter&$minAgeFilter&$maxAgeFilter&';

                // Открываем новую страницу браузера с этим URL для загрузки
                await launchUrl(Uri.parse(exportUrl));
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Выгрузить",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Поля для "Выгрузка мероприятий"
  Widget _buildEventFields() {
    return SizedBox(
      width: 380,
      child: Column(
        key: const ValueKey('eventFields'),
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedPlace,
            focusColor: Colors.transparent,
            decoration: const InputDecoration(
              labelText: "Место",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
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
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedType,
            focusColor: Colors.transparent,
            decoration: const InputDecoration(
              labelText: "Тип",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
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
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedKind,
            focusColor: Colors.transparent,
            decoration: const InputDecoration(
              labelText: "Вид",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
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
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedFrequency,
            focusColor: Colors.transparent,
            decoration: const InputDecoration(
              labelText: "Частота",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
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
            },
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              // Собираем параметры фильтров для мероприятий
              String placeFilter = selectedPlace != null ? 'place=$selectedPlace' : '';
              String eventTypeFilter = selectedType != null ? 'event_type=$selectedType' : '';
              String kindFilter = selectedKind != null ? 'kind=$selectedKind' : '';
              String frequencyFilter = selectedFrequency != null ? 'frequency=$selectedFrequency' : '';

              // Формируем URL для выгрузки мероприятий с параметрами
              String exportUrl = 'http://127.0.0.1:5000/export?type=events&'
                  '$placeFilter&$eventTypeFilter&$kindFilter&$frequencyFilter';

              // Открываем новую страницу браузера с этим URL для загрузки
              await launchUrl(Uri.parse(exportUrl));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Выгрузить",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
