#!/usr/bin/env python3
"""
Small helper to seed MongoDB for demo purposes. Adjust or replace with real JSON imports
from your `Resources/Objects` folder as needed.
"""
import os
import json
from pymongo import MongoClient

MONGO_URI = os.getenv('MONGO_URI', 'mongodb://localhost:27017/')
DB_NAME = os.getenv('MONGO_DB_NAME', 'projetofinal')

def main():
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    equipment = db['equipment']

    # Insert a small sample document if the collection is empty
    if equipment.count_documents({}) == 0:
        sample = {
            "postgres_id": 1,
            "designation": "Sample Equipment",
            "description": "Inserted by seed_mongo.py",
            "price": 100.0
        }
        equipment.insert_one(sample)
        print("Inserted sample equipment document")
    else:
        print("Equipment collection already has data; skipping sample insert")

if __name__ == '__main__':
    main()
