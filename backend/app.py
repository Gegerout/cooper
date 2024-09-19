from datetime import datetime
import os
from io import BytesIO

import pandas as pd
from flask import Flask, request, jsonify, url_for, send_from_directory, send_file
from flask_jwt_extended import JWTManager, create_access_token
from sqlalchemy.orm import joinedload
from werkzeug.utils import secure_filename

from utils import send_notification
from ai.event_probability import predict_event_popularity
from utils.models import db, User, Event, Comment, Photo
from utils.config import Config
from flask.signals import request_started

from ai.user_recomendation import predict_for_new_user

app = Flask(__name__)  # Инициализация Flask приложения
app.config.from_object(Config)  # Загрузка конфигурации из файла

db.init_app(app)  # Инициализация базы данных для Flask приложения
jwt = JWTManager(app)  # Инициализация JWT для управления аутентификацией

UPLOAD_FOLDER = 'images'

# Проверка существования папки для загрузки изображений и создание ее при необходимости
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)


def create_admin(*args, **kwargs):
    # Функция для создания администратора при старте приложения
    if User.query.filter_by(username="admin@mail.ru").first():
        return

    # Создание пользователя с правами администратора
    admin_user = User(username="admin@mail.ru", password="admin", role="Организатор", location="Департамент Москвы",
                      age=30, gender="Мужской")
    db.session.add(admin_user)
    db.session.commit()


# Подключение функции create_admin на событие начала запроса
request_started.connect(create_admin, app)


@app.route('/images/<filename>')
def uploaded_file(filename):
    # Маршрут для доступа к загруженным изображениям
    return send_from_directory(UPLOAD_FOLDER, filename)


@app.route('/export', methods=['GET'])
def export_data():
    # Получаем тип выгрузки из запроса ('users' или 'events')
    export_type = request.args.get('type')

    # Если тип не указан, возвращаем ошибку
    if not export_type:
        return jsonify({"msg": "Please specify what to export: 'users' or 'events'"}), 400

    # Определяем логику в зависимости от типа выгрузки
    if export_type == 'users':
        return export_filtered_users()
    elif export_type == 'events':
        return export_filtered_events()
    else:
        return jsonify({"msg": "Invalid export type. Please specify 'users' or 'events'."}), 400


# Функция для выгрузки пользователей с фильтрами
def export_filtered_users():
    # Получаем фильтры из запроса
    selected_location = request.args.get('location')
    selected_gender = request.args.get('gender')
    min_age = request.args.get('min_age')
    max_age = request.args.get('max_age')

    # Начинаем формировать запрос для выборки пользователей из базы данных
    query = User.query

    # Применяем фильтры
    if selected_location:
        query = query.filter(User.location == selected_location)
    if selected_gender:
        query = query.filter(User.gender == selected_gender)
    if min_age:
        query = query.filter(User.age >= int(min_age))  # фильтруем пользователей по минимальному возрасту
    if max_age:
        query = query.filter(User.age <= int(max_age))  # фильтруем пользователей по максимальному возрасту

    users = query.all()

    if not users:
        return jsonify({"msg": "No users found"}), 404

    # Собираем данные пользователей
    user_data = []
    for user in users:
        user_data.append({
            'id пользователя': user.id,
            'Имя': user.username,
            'Место жительства': user.location,
            'Возраст': user.age,
            'Пол': user.gender,
            'Активность': user.activity
        })

    # Преобразуем в DataFrame и создаем CSV с правильной кодировкой (UTF-8 с BOM)
    df = pd.DataFrame(user_data)
    output = BytesIO()
    df.to_csv(output, index=False, encoding='utf-8-sig')  # Указали кодировку 'utf-8-sig'
    output.seek(0)

    # Отправляем CSV на скачивание
    return send_file(output, mimetype='text/csv', as_attachment=True, download_name='filtered_users.csv')


# Функция для выгрузки мероприятий с фильтрами
def export_filtered_events():
    # Получаем параметры фильтра из запроса
    selected_place = request.args.get('place')
    selected_type = request.args.get('event_type')  # используем event_type, чтобы избежать конфликта с type
    selected_kind = request.args.get('kind')
    selected_frequency = request.args.get('frequency')

    # Начинаем формировать запрос для выборки событий из базы данных
    query = Event.query

    # Фильтры по полям мероприятия
    if selected_place:
        query = query.filter(Event.place == selected_place)
    if selected_type:
        query = query.filter(Event.type == selected_type)
    if selected_kind:
        query = query.filter(Event.kind == selected_kind)
    if selected_frequency:
        query = query.filter(Event.frequency == selected_frequency)

    events = query.all()

    if not events:
        return jsonify({"msg": "No events found"}), 404

    all_data = []

    # Проходим по каждому мероприятию и добавляем данные
    for event in events:
        event_data = {
            'id': event.id,
            'Заголовок': event.title,
            'Описание': event.description,
            'Место проведения': event.place,
            'Дата и время': event.date,
            'Тип': event.type,
            'Вид': event.kind,
            'Частота проведения': event.frequency,
            'Количество лайков': event.likes,
            'Популярность': event.popularity
        }

        # Добавляем данные мероприятия
        all_data.append(event_data)

    # Преобразуем данные в DataFrame и создаем CSV
    df = pd.DataFrame(all_data)
    output = BytesIO()
    df.to_csv(output, index=False, encoding='utf-8-sig')
    output.seek(0)

    # Отправляем файл на скачивание
    return send_file(output, mimetype='text/csv', as_attachment=True, download_name='filtered_events.csv')


@app.route('/register', methods=['POST'])
def register():
    # Получение данных из запроса в формате JSON
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    location = data.get('location')
    age = data.get('age')
    gender = data.get('gender')

    # Проверка, существует ли пользователь с таким же именем
    if User.query.filter_by(username=username).first():
        return jsonify({"msg": "User already exists"}), 400  # Возвращаем ошибку, если пользователь существует

    # Создание нового пользователя и добавление его в базу данных
    user = User(username=username, password=password, location=location, age=age, gender=gender)
    db.session.add(user)
    db.session.commit()

    # Генерация JWT токена для созданного пользователя
    access_token = create_access_token(identity={"id": user.id, "role": user.role})

    # Возвращаем успешный ответ с данными пользователя и токеном
    return jsonify(
        {"accessToken": access_token, "role": user.role, "location": location, "age": age, "gender": gender,
         "username": username, "id": user.id}), 201  # Статус 201 (Created)


@app.route('/login', methods=['POST'])
def login():
    # Получение данных для входа
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    # Поиск пользователя по имени
    user = User.query.filter_by(username=username).first()
    # Проверка существования пользователя и правильности пароля
    if user is None or not user.check_password(password):
        return jsonify({"msg": "Bad username or password"}), 401  # Ошибка аутентификации

    # Генерация JWT токена при успешной аутентификации
    access_token = create_access_token(identity={"id": user.id, "role": user.role})

    # Возвращаем токен и информацию о пользователе
    return jsonify({"accessToken": access_token, "role": user.role, "location": user.location, "age": user.age,
                    "gender": user.gender, "username": username}), 200  # Статус 200 (OK)


@app.route('/users', methods=['GET'])
def get_users():
    # Получение всех пользователей из базы данных
    users = User.query.all()

    # Формируем список пользователей с нужными данными для ответа
    users_list = [{'username': user.username, 'activity': user.activity} for user in users]

    # Возвращаем список пользователей в формате JSON
    return jsonify(users_list), 200  # Статус 200 (OK)


@app.route('/events', methods=['POST'])
def create_event():
    # Получение данных из запроса формы (multipart/form-data)
    title = request.form.get('title')
    description = request.form.get('description')
    place = request.form.get('place')
    date_str = request.form.get('date')
    type = request.form.get('type')
    kind = request.form.get('kind')
    frequency = request.form.get('frequency')
    photos = request.files.getlist('photos')  # Получение списка фотографий
    popularity = request.form.get('popularity')

    # Проверка на наличие обязательных полей
    if not title or not description or not place or not date_str:
        return jsonify({"msg": "All fields are required"}), 400

    # Попытка преобразования строки даты в объект datetime
    try:
        date = datetime.strptime(date_str, "%Y-%m-%d %H:%M")
    except ValueError:
        return jsonify({"msg": "Invalid date format. Use 'YYYY-MM-DD HH:MM'"}), 400

    # Создание нового события и добавление его в базу данных
    new_event = Event(title=title, description=description, place=place, date=date, type=type, kind=kind,
                      frequency=frequency, popularity=popularity)
    db.session.add(new_event)
    db.session.commit()

    # Обработка фотографий и сохранение их на сервере
    for photo in photos:
        if photo:
            filename = secure_filename(photo.filename)  # Защищенное сохранение имени файла
            filepath = os.path.join(UPLOAD_FOLDER, filename)
            photo.save(filepath)  # Сохранение файла
            relative_path = os.path.join(UPLOAD_FOLDER, filename)
            new_photo = Photo(filename=relative_path, event_id=new_event.id)  # Создание записи о фото
            db.session.add(new_photo)

    db.session.commit()

    # Отправка уведомления о новом событии
    send_notification.send_notification(description, title)

    return jsonify({"msg": "Event created successfully with photos"}), 201  # Статус 201 (Created)


@app.route('/events', methods=['GET'])
def get_events():
    # Получение всех событий из базы данных
    events = Event.query.all()

    # Формирование списка событий с их данными и связанной информацией
    events_list = [
        {
            "id": event.id,
            "title": event.title,
            "description": event.description,
            "place": event.place,
            "date": event.date.strftime("%Y-%m-%d %H:%M"),  # Преобразование даты в строку
            "comments": [
                {
                    "username": comment.username,
                    "comment": comment.comment
                }
                for comment in event.comments  # Список комментариев к событию
            ],
            "userCount": event.userCount,
            "type": event.type,
            "kind": event.kind,
            "frequency": event.frequency,
            "photos": [
                url_for('uploaded_file', filename=os.path.basename(photo.filename), _external=True)  # URL для фото
                for photo in event.photos  # Список фотографий события
            ],
            "likes": event.likes,
            "popularity": event.popularity,
            "attendees": [  # Информация об участниках события
            {
                "id": attendee.id,
                "username": attendee.username,
                "gender": attendee.gender,
                "age": attendee.age,
                "location": attendee.location,
                "activity": attendee.activity
            }
            for attendee in event.attendees]
        }
        for event in events  # Проход по всем событиям
    ]

    return jsonify(events_list[::-1]), 200  # Возвращаем события в обратном порядке (сначала новые)


@app.route('/predict_popularity', methods=['POST'])
def predict_popularity():
    # Получение данных из JSON-запроса
    data = request.get_json()

    # Извлечение входных данных для предсказания популярности события
    event_type = data.get('event_type')
    event_format = data.get('event_format')
    location = data.get('location')
    periodicity = data.get('periodicity')

    # Проверка на наличие обязательных полей
    if not event_type or not event_format or not location or not periodicity:
        return jsonify({"msg": "All fields are required"}), 400

    # Попытка предсказания популярности события
    try:
        probability = predict_event_popularity(
            event_type=event_type,
            event_format=event_format,
            location=location,
            periodicity=periodicity
        )
    except Exception as e:
        # Возвращаем ошибку, если возникла проблема при предсказании
        return jsonify({"msg": f"Error during prediction: {str(e)}"}), 500

    # Возвращаем результат предсказания популярности
    return jsonify({"probability": round(probability, 2)}), 200  # Округляем вероятность до двух знаков


@app.route('/events/<int:event_id>/comments', methods=['POST'])
def add_comment(event_id):
    # Поиск события по ID
    event = Event.query.get(event_id)
    if not event:
        return jsonify({"msg": "Event not found"}), 404  # Ошибка, если событие не найдено

    # Получение данных из запроса
    data = request.get_json()
    username = data.get('username')
    comment_text = data.get('comment')

    # Проверка наличия обязательных полей
    if not username or not comment_text:
        return jsonify({"msg": "Username and comment are required"}), 400

    # Создание комментария и добавление его в базу данных
    comment = Comment(event_id=event.id, username=username, comment=comment_text)
    db.session.add(comment)
    db.session.commit()

    return jsonify({"msg": "Comment added successfully"}), 201  # Успешное добавление комментария


@app.route('/events/<int:event_id>/join', methods=['POST'])
def join_event(event_id):
    # Получение данных пользователя из запроса
    data = request.get_json()
    user_id = data.get('user_id')

    # Проверка наличия ID пользователя
    if not user_id:
        return jsonify({"msg": "User ID is required"}), 400

    # Поиск пользователя и события по ID
    user = User.query.get(user_id)
    if not user:
        return jsonify({"msg": "User not found"}), 404

    event = Event.query.get(event_id)
    if not event:
        return jsonify({"msg": "Event not found"}), 404

    # Проверка, если пользователь уже присоединился к событию
    if user in event.attendees:
        return jsonify({"msg": "User has already joined this event"}), 200  # Пользователь уже присоединился

    # Увеличение активности пользователя
    user.activity += 1
    db.session.commit()

    # Добавление пользователя к событию
    event.attendees.append(user)
    db.session.commit()

    return jsonify({"msg": "User joined successfully", "userCount": event.userCount}), 200  # Успешное присоединение


@app.route('/events/<int:event_id>/like', methods=['POST'])
def like_event(event_id):
    # Поиск события по ID
    event = Event.query.get(event_id)
    if not event:
        return jsonify({"msg": "Event not found"}), 404  # Ошибка, если событие не найдено

    # Увеличение количества лайков
    event.likes += 1
    db.session.commit()

    return jsonify({"msg": "User liked successfully", "likes": event.likes}), 200  # Успешное добавление лайка


def calculate_event_similarity(predicted_data, event):
    similarity = 0

    # Сравнение типа мероприятия
    if predicted_data['тип мероприятия'] in event.type:
        similarity += 0.2

    # Сравнение вида мероприятия
    if predicted_data['вид мероприятия'] in event.kind:
        similarity += 0.2

    # Сравнение места проведения
    if predicted_data['место проведения мероприятия'] in event.place:
        similarity += 0.4

    # Сравнение периодичности мероприятия
    if predicted_data['периодичность проведения мероприятия'] in event.frequency:
        similarity += 0.2

    return similarity  # Возвращаем рассчитанное сходство


@app.route('/events/sorted', methods=['POST'])
def get_sorted_events():
    # Получение данных пользователя из запроса
    data = request.get_json()

    # Извлечение данных о возрасте, поле и месте жительства
    age = data.get('age')
    gender = data.get('gender')
    residence = data.get('residence')

    # Проверка наличия всех обязательных полей
    if not age or not gender or not residence:
        return jsonify({"msg": "Age, gender, and residence are required"}), 400

    # Прогнозирование предпочтений пользователя на основе введенных данных
    predicted_data = predict_for_new_user(age, gender, residence)

    # Получение всех событий, включая комментарии к ним
    events = Event.query.options(joinedload(Event.comments)).all()

    event_similarity_list = []  # Список для хранения событий с их схожестью
    for event in events:
        # Расчет схожести события с предпочтениями пользователя
        similarity = calculate_event_similarity(predicted_data, event)

        # Формирование данных о событии для ответа
        event_data = {
            "id": event.id,
            "title": event.title,
            "description": event.description,
            "place": event.place,
            "date": event.date.strftime("%Y-%m-%d %H:%M"),  # Преобразование даты в строку
            "comments": [
                {
                    "username": comment.username,
                    "comment": comment.comment
                }
                for comment in event.comments  # Включение комментариев к событию
            ],
            "userCount": event.userCount,
            "type": event.type,
            "kind": event.kind,
            "frequency": event.frequency,
            "photos": [
                url_for('uploaded_file', filename=os.path.basename(photo.filename), _external=True)  # Ссылки на фото
                for photo in event.photos  # Включение фотографий события
            ],
            "likes": event.likes,
            "popularity": event.popularity,
            "similarity": similarity  # Добавление рассчитанной схожести
        }
        event_similarity_list.append(event_data)  # Добавляем событие в список

    # Сортировка событий по схожести с предпочтениями пользователя (от большего к меньшему)
    sorted_events = sorted(event_similarity_list, key=lambda x: x['similarity'], reverse=True)

    # Возвращаем отсортированный список событий
    return jsonify(sorted_events), 200


if __name__ == '__main__':
    # Запуск приложения Flask
    app.run(debug=True, host="0.0.0.0")

