from django.conf import settings
import pymongo
from bson import SON
from static.functions import *

db = pymongo.MongoClient(settings.MONGO_URI)[settings.MONGO_DB_NAME]["equipment"]


def mongodb_getEquipmentList():
    return db.find({}, {})


def mongodb_getEquipmentById(postgres_id):
    return db.find_one({"postgres_id": postgres_id}, {"_id": 0})


def mongodb_createEquipment(doc):
    bson_doc = SON({key: convert_decimal(value) for key, value in doc.items()})
    return db.insert_one(bson_doc)


def mongodb_updateEquipment(postgres_id, doc):
    bson_doc = SON({key: convert_decimal(value) for key, value in doc.items()})
    return db.update_one({"postgres_id": postgres_id}, {"$set": bson_doc})


def mongodb_RemoveExtraAttribute(postgres_id, attribute):
    return db.update_one({"postgres_id": postgres_id}, {"$unset": {attribute: ""}})


def mongodb_DeleteEquipment(postgres_id):
    return db.delete_one({"postgres_id": postgres_id})
