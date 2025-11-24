import os

class Config:
    DB_HOST = os.environ.get("DATABASE_HOST", "db")
    DB_PORT = int(os.environ.get("DATABASE_PORT", 5432))
    DB_USER = os.environ.get("DATABASE_USER", "user")
    DB_PASSWORD = os.environ.get("DATABASE_PASSWORD", "1234")
    DB_NAME = os.environ.get("DATABASE_NAME", "isitdb")
