# config.py
import os

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'yoursecretkey')  # For JWT
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'sqlite:///backend.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
