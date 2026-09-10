from pymongo import MongoClient
from dotenv import load_dotenv
import os

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")
DATABASE_NAME = os.getenv("DATABASE_NAME")

client = MongoClient(MONGODB_URI)

db = client[DATABASE_NAME]

users_collection = db["users"]
patients_collection = db["patients"]
game_scores_collection = db["game_scores"]
reminders_collection = db["reminders"]
game_performance_collection = db["game_performance"]

try:
    game_performance_collection.create_index([("patient_id", 1), ("timestamp", -1)])
    game_performance_collection.create_index([("patient_id", 1), ("game_name", 1)])
except Exception:
    pass