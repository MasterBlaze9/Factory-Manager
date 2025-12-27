# MongoDB Access Guide

This guide shows different ways to access and interact with MongoDB in the Factory Management application.

## Connection Details

- **Host**: localhost
- **Port**: 27017
- **Database**: projetofinal
- **Collection**: equipment
- **Connection String**: `mongodb://localhost:27017/`

## Method 1: Using MongoDB Shell (mongosh) via Docker

### Interactive Shell
```bash
# Enter MongoDB shell
docker exec -it factory-management-mongo-1 mongosh

# Once inside, switch to the database
use projetofinal

# Show all collections
show collections

# Query equipment collection
db.equipment.find().pretty()

# Count documents
db.equipment.countDocuments()

# Find specific equipment by postgres_id
db.equipment.findOne({"postgres_id": 1})

# Insert a new document
db.equipment.insertOne({
    "postgres_id": 2,
    "designation": "Laptop Dell XPS",
    "description": "High-performance laptop",
    "price": 1299.99
})

# Update a document
db.equipment.updateOne(
    {"postgres_id": 1},
    {"$set": {"price": 150.00}}
)

# Delete a document
db.equipment.deleteOne({"postgres_id": 2})

# Exit
exit
```

### One-Line Commands
```bash
# Show databases
docker exec -it factory-management-mongo-1 mongosh --eval "show dbs"

# Show collections in projetofinal database
docker exec -it factory-management-mongo-1 mongosh projetofinal --eval "show collections"

# Query all equipment
docker exec -it factory-management-mongo-1 mongosh projetofinal --eval "db.equipment.find().pretty()"

# Count documents
docker exec -it factory-management-mongo-1 mongosh projetofinal --eval "db.equipment.countDocuments()"
```

## Method 2: Using MongoDB Compass (GUI)

1. **Download MongoDB Compass**: https://www.mongodb.com/try/download/compass
2. **Connect** using: `mongodb://localhost:27017`
3. **Select Database**: projetofinal
4. **Browse Collections**: equipment

## Method 3: Using Python Script

Create a Python script to interact with MongoDB:

```python
from pymongo import MongoClient

# Connect to MongoDB
client = MongoClient('mongodb://localhost:27017/')
db = client['projetofinal']
equipment_collection = db['equipment']

# Query all equipment
for item in equipment_collection.find():
    print(item)

# Insert new equipment
new_equipment = {
    "postgres_id": 3,
    "designation": "Monitor LG UltraWide",
    "description": "34-inch curved monitor",
    "price": 499.99
}
equipment_collection.insert_one(new_equipment)

# Find one
equipment = equipment_collection.find_one({"postgres_id": 1})
print(equipment)

# Update
equipment_collection.update_one(
    {"postgres_id": 1},
    {"$set": {"price": 199.99}}
)

# Delete
equipment_collection.delete_one({"postgres_id": 3})
```

## Method 4: Using Django Shell

Access MongoDB through the Django application:

```bash
# Enter Django shell
docker exec -it factory-management-web-1 python manage.py shell
```

Then in the shell:
```python
from equipment.database_mongodb import *

# Get all equipment
equipment_list = mongodb_getEquipmentList()
for eq in equipment_list:
    print(eq)

# Get equipment by postgres_id
equipment = mongodb_getEquipmentById(1)
print(equipment)

# Create new equipment
new_equipment = {
    "postgres_id": 4,
    "designation": "Tablet Samsung Galaxy",
    "description": "10-inch tablet",
    "price": 349.99
}
mongodb_createEquipment(new_equipment)

# Update equipment
update_data = {"price": 329.99}
mongodb_updateEquipment(4, update_data)

# Delete equipment
mongodb_DeleteEquipment(4)

# Exit
exit()
```

## Method 5: Using VS Code Extension

1. Install **MongoDB for VS Code** extension
2. Add connection: `mongodb://localhost:27017`
3. Browse databases and collections visually
4. Run queries directly in VS Code

## Common MongoDB Commands

```javascript
// Show current database
db

// Show all databases
show dbs

// Switch database
use projetofinal

// Show collections
show collections

// Find all documents
db.equipment.find()

// Find with pretty print
db.equipment.find().pretty()

// Find with filter
db.equipment.find({"postgres_id": 1})

// Find with projection (select specific fields)
db.equipment.find({}, {"designation": 1, "price": 1})

// Count documents
db.equipment.countDocuments()

// Aggregation example
db.equipment.aggregate([
    { $group: { _id: null, avgPrice: { $avg: "$price" } } }
])

// Drop collection (careful!)
db.equipment.drop()

// Create index
db.equipment.createIndex({"postgres_id": 1})

// Show indexes
db.equipment.getIndexes()
```

## Seeding MongoDB

To populate MongoDB with sample data:

```bash
# Run the seed script
docker exec factory-management-web-1 python /app/scripts/seed_mongo.py
```

## Backup and Restore

### Backup
```bash
# Backup entire database
docker exec factory-management-mongo-1 mongodump --db projetofinal --out /data/backup

# Copy backup to host
docker cp factory-management-mongo-1:/data/backup ./mongodb_backup
```

### Restore
```bash
# Restore from backup
docker exec factory-management-mongo-1 mongorestore --db projetofinal /data/backup/projetofinal
```

## MongoDB in the Application

The application uses MongoDB to store additional equipment details that are not stored in PostgreSQL. The equipment data is synchronized between both databases:

- **PostgreSQL**: Stores core equipment data (id, type, relationships)
- **MongoDB**: Stores extended equipment details (descriptions, specifications, flexible attributes)

The `equipment/database_mongodb.py` module handles all MongoDB operations for the equipment collection.
