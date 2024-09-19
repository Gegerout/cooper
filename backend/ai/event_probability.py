import joblib  # Импортируем библиотеку для загрузки моделей
import pandas as pd  # Импортируем pandas для работы с данными
from sklearn.preprocessing import LabelEncoder  # Импортируем класс для кодирования категориальных данных

# Загружаем набор данных событий из CSV файла
df = pd.read_csv('data/events_dataset.csv')

# Загружаем предобученную модель логистической регрессии
model = joblib.load('ai/logistic_regression_model.pkl')

# Словарь для хранения кодировщиков меток для различных колонок
label_encoders = {}

# Кодируем категориальные переменные
for column in ['Тип мероприятия', 'Формат мероприятия', 'Место проведения', 'Периодичность']:
    le = LabelEncoder()  # Создаем новый кодировщик
    df[column] = le.fit_transform(df[column])  # Кодируем данные в колонке
    label_encoders[column] = le  # Сохраняем кодировщик для последующего использования

def predict_event_popularity(event_type, event_format, location, periodicity):
    # Кодируем входные параметры с помощью сохраненных кодировщиков
    event_type_encoded = label_encoders['Тип мероприятия'].transform([event_type])[0]
    event_format_encoded = label_encoders['Формат мероприятия'].transform([event_format])[0]
    location_encoded = label_encoders['Место проведения'].transform([location])[0]
    periodicity_encoded = label_encoders['Периодичность'].transform([periodicity])[0]

    # Создаем DataFrame с закодированными данными события
    event_data = pd.DataFrame({
        'Тип мероприятия': [event_type_encoded],
        'Формат мероприятия': [event_format_encoded],
        'Место проведения': [location_encoded],
        'Периодичность': [periodicity_encoded]
    })

    # Предсказываем вероятность популярности события
    predicted_prob = model.predict_proba(event_data)[:, 1][0]

    return predicted_prob  # Возвращаем предсказанную вероятность
