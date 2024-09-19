# models.py
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()  # Инициализация объекта базы данных SQLAlchemy

# Связующая таблица для участия пользователей в событиях
event_attendance = db.Table('event_attendance',
    db.Column('user_id', db.Integer, db.ForeignKey('user.id'), primary_key=True),
    db.Column('event_id', db.Integer, db.ForeignKey('event.id'), primary_key=True)
)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Уникальный идентификатор пользователя
    username = db.Column(db.String(80), unique=True, nullable=False)  # Уникальное имя пользователя
    password_hash = db.Column(db.String(128), nullable=False)  # Хэш пароля пользователя
    role = db.Column(db.String(50), nullable=False, default='user')  # Роль пользователя (по умолчанию 'user')
    location = db.Column(db.String(255), nullable=True)  # Место проживания пользователя
    age = db.Column(db.Integer, default=0)  # Возраст пользователя
    gender = db.Column(db.String(50), nullable=True)  # Пол пользователя
    activity = db.Column(db.Integer, default=0)  # Уровень активности пользователя

    def __init__(self, username, password, role='user', location=None, age=0, gender='Мужской', activity=0):
        self.username = username
        self.password_hash = generate_password_hash(password)  # Генерация хэша пароля
        self.role = role
        self.location = location
        self.age = age
        self.gender = gender
        self.activity = activity

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)  # Установка нового пароля

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)  # Проверка пароля


class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Уникальный идентификатор комментария
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)  # Ссылка на событие
    username = db.Column(db.String(80), nullable=False)  # Имя пользователя, оставившего комментарий
    comment = db.Column(db.Text, nullable=False)  # Текст комментария
    date = db.Column(db.DateTime, default=datetime.utcnow)  # Дата создания комментария

    def __init__(self, event_id, username, comment):
        self.event_id = event_id
        self.username = username
        self.comment = comment


class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Уникальный идентификатор события
    title = db.Column(db.String(120), nullable=False)  # Заголовок события
    description = db.Column(db.Text, nullable=False)  # Описание события
    place = db.Column(db.String(120), nullable=False)  # Место проведения события
    date = db.Column(db.DateTime, nullable=False)  # Дата и время события
    comments = db.relationship('Comment', backref='event', lazy=True, cascade="all, delete-orphan")  # Связь с комментариями
    photos = db.relationship('Photo', backref='event', lazy=True, cascade="all, delete-orphan")  # Связь с фотографиями
    type = db.Column(db.String(120), nullable=False)  # Тип события
    kind = db.Column(db.String(120), nullable=False)  # Вид события
    frequency = db.Column(db.String(120), nullable=False)  # Периодичность события
    likes = db.Column(db.Integer, default=0)  # Количество лайков
    popularity = db.Column(db.Double, default=0.0)  # Популярность события
    attendees = db.relationship('User', secondary=event_attendance, lazy='subquery',
                                backref=db.backref('events', lazy=True))  # Связь с участниками события

    @property
    def userCount(self):
        return len(self.attendees)  # Возвращает количество участников события


class Photo(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Уникальный идентификатор фотографии
    filename = db.Column(db.String(200), nullable=False)  # Путь или URL к фотографии
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)  # Ссылка на событие, к которому принадлежит фотография
