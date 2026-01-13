# TechHaven — Factory Manager

## Table of Contents
- **Overview**: What this project is and who it's for
- **Features**: Primary app capabilities
- **Architecture & Flow**: High-level component interactions
- **Quick Start (Docker)**: How to run locally using Docker
- **Databases**: PostgreSQL and MongoDB roles
- **Useful Scripts**: Helpful repo scripts for setup & maintenance
- **Project Structure**: Top-level folders and purpose
- **Contributing & Notes**: How to help and other tips

## Overview

`TechHaven` (Factory Manager) is a Django-based application that helps manage factory resources: clients, suppliers, components, equipment, production orders, warehouses, and deliveries. It combines a relational database for core transactional data (PostgreSQL) with MongoDB for specialized or denormalized data where appropriate.

## Features

- Component, Equipment and Supplier management
- Client orders, order deliveries and invoices
- Production planning and equipment-production associations
- Warehouse and stock component tracking
- Admin interface for CRUD operations and data administration
- Backup/import utilities and scripts to seed or restore data

## Architecture & Flow

- The Django project contains multiple apps: `client`, `component`, `equipment`, `production`, `supplier`, `warehouse`, and `user`.
- User/UI actions (create order, add component, register equipment) are handled by Django views and persisted in PostgreSQL.
- MongoDB is used for additional platform-specific information (see `equipment/database_mongodb.py`).
- Background and maintenance tasks are supported by repository scripts in the `scripts/` folder (backups, seeding, imports).

## Quick Start (Docker - recommended)

> Docker Compose is the maintained and recommended way to run the project locally.

1. Clone the repo:

```bash
git clone <repository-url>
cd Factory-Manager
```

2. Copy and edit environment variables:

```bash
cp .env.example .env
# Edit .env to set DB credentials, secret keys, and service ports
```

3. Start services:

```bash
docker-compose up -d
```

4. Visit the app:

- Open http://localhost:8000
- Django admin (example credentials in repo): `admin` / `adminpass`

## Databases

- PostgreSQL: primary transactional DB for models and relations.
- MongoDB: stores auxiliary or denormalized data (see `equipment/database_mongodb.py`).

Files and scripts that interact with these DBs live under `Application/projetofinalbdII_grupo27/` and `scripts/`.

## Useful Scripts

- `scripts/init_database.sh` / `scripts/init_db.sh`: initialize DB schema and basic data (when applicable)
- `scripts/seed_mongo.py`: populate MongoDB with sample or required documents
- `scripts/backup_and_dedupe.py`: create backups and deduplicate entries
- `scripts/create_superuser.py`: scripted creation of a Django superuser
- `scripts/import_objects.py`: utilities to import CSV/Objects into the DB

Run any script via Docker service shell for the Django container, e.g.:

```bash
docker-compose exec web bash
python scripts/create_superuser.py
```

## Backups & Data

- Backups are stored under `backups/` (CSV exports grouped by timestamp). Use `scripts/backup_and_dedupe.py` to generate or clean backups.
- Resources and DB DDL scripts are available under `Resources/` for reference or manual DB setup.

## Project Structure (high level)

- `Application/projetofinalbdII_grupo27/` — Django project root
  - `client/`, `component/`, `equipment/`, `production/`, `supplier/`, `warehouse/`, `user/` — Django apps
  - `static/`, `templates/` — assets and templates
- `scripts/` — helpful CLI scripts for setup, seeding, backups, and imports
- `Resources/` — SQL DDL, populate scripts, and DB privilege files
- `backups/` — generated CSV backups

## Running Tests

Run Django tests inside the web container:

```bash
docker-compose exec web bash
python manage.py test
```

## Contributing & Notes

- Use Docker for local development to ensure consistent environment.
- Keep secrets out of source control; use `.env` and Docker secrets for production.
- If adding features that touch large data flows, update `Resources/` and the backup scripts accordingly.

If you'd like, I can also:
- add a small developer quick-start script, or
- create a checklist for production hardening (secrets, SSL, DB backup schedule).

---

Last updated: January 2026
# TechHaven



## Table of Contents
- [TechHaven](#TechHaven)
  - [Table of Contents](#table-of-contents)
  - [Technologies Used](#technologies-used)
  - [Setup](#setup)

## Technologies Used

- **Django**: Used framework for the website development.
- **PostgreSQL**: Main database engine.
- **MongoDB**: Used to store additional information about a concept of the platform.

## Setup

### Using Docker (Default & Supported Method)

> **Note:** Docker is the default and only supported way to run this project. Manual setup is not maintained.

1. **Clone the repository:**
  

2. **Configure environment variables:**
  ```bash
  cp .env.example .env
  # Edit .env file with your credentials
  ```

3. **Start with Docker Compose:**
  ```bash
  docker-compose up -d
  ```

4. **Access the application:**
  
  - Access the application at: http://localhost:8000
  - Use the Admin credentials: admin / adminpass


