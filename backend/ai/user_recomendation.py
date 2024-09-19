import pandas as pd  # Импортируем библиотеку для работы с данными
from sklearn.preprocessing import LabelEncoder  # Импортируем класс для кодирования категориальных данных
from collections import Counter  # Импортируем класс для подсчета наиболее частых элементов

# Загружаем данные пользователей из CSV файла и ограничиваем выборку первыми 50000 строками
df = pd.read_csv('data/users_df.csv')[:50000]

# Словарь для хранения кодировщиков меток для категориальных колонок
label_encoders = {}
# Список категориальных колонок, которые нужно закодировать
categorical_columns = ['пол', 'тип мероприятия', 'вид мероприятия', 'место проведения мероприятия',
                       'периодичность проведения мероприятия', 'место жительства']

# Кодируем категориальные переменные
for column in categorical_columns:
    le = LabelEncoder()  # Создаем новый кодировщик
    df[column] = le.fit_transform(df[column].astype(str))  # Кодируем данные в колонке
    label_encoders[column] = le  # Сохраняем кодировщик для последующего использования

def predict_for_new_user(age, gender, residence):
    # Кодируем входные параметры
    gender_encoded = label_encoders['пол'].transform([gender])[0]
    residence_encoded = label_encoders['место жительства'].transform([residence])[0]

    similarities = []  # Список для хранения схожестей пользователей
    for i in range(len(df)):
        # Получаем профиль пользователя из DataFrame
        user_profile = df.iloc[i][['возраст', 'пол', 'место жительства']]
        similarity = 0  # Инициализируем коэффициент схожести
        # Увеличиваем схожесть на основе совпадений
        if user_profile['возраст'] == age:
            similarity += 0.3
        if user_profile['пол'] == gender_encoded:
            similarity += 0.3
        if user_profile['место жительства'] == residence_encoded:
            similarity += 0.4
        similarities.append((i, similarity))  # Добавляем индекс и схожесть в список

    # Сортируем пользователей по схожести
    similarities = sorted(similarities, key=lambda x: x[1], reverse=True)

    # Берем индексы 10 наиболее схожих пользователей
    top_similar_users = [i for i, _ in similarities[:10]]

    # Функция для получения наиболее частого значения
    def get_most_common(values):
        return Counter(values).most_common(1)[0][0]

    predicted_data = {}  # Словарь для хранения предсказанных значений
    for column in ['тип мероприятия', 'вид мероприятия', 'место проведения мероприятия', 'количество участников',
                   'периодичность проведения мероприятия']:
        values = []  # Список для хранения значений для каждой категории
        for user_id in top_similar_users:
            if column in ['количество участников']:
                # Если колонка - количество участников, разбиваем строку и добавляем в список
                values.extend(map(int, df.loc[user_id, column].replace(', ', ',').split(',')))
            else:
                values.append(df.loc[user_id, column])  # Добавляем значение из DataFrame

        # Получаем наиболее частое значение для предсказания
        if column in ['количество участников']:
            predicted_value = get_most_common(values)  # Для количества участников
        else:
            predicted_value = label_encoders[column].inverse_transform([get_most_common(values)])[0]  # Для остальных категорий

        predicted_data[column] = predicted_value  # Сохраняем предсказанное значение

    return predicted_data  # Возвращаем предсказанные данные
