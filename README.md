# ProjetoFinalBDII

Projeto final de Base de Dados II

## Table of Contents
- [ProjetoFinalBDII](#projetofinalbdii)
  - [Table of Contents](#table-of-contents)
  - [Technologies Used](#technologies-used)
  - [Setup](#setup)

## Technologies Used

- **Django**: Used framework for the website development.
- **PostgreSQL**: Main database engine.
- **MongoDB**: Used to store additional information about a concept of the platform.

## Setup

### Using Docker (Recommended)

1. **Clone the repository:**
    ```bash
    git clone https://github.com/AndreGonc06/ProjetoFinalBDII.git
    cd ProjetoFinalBDII
    ```

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
    - Web app: http://localhost:8000
    - PostgreSQL: localhost:5432
    - MongoDB: localhost:27017

### Manual Setup

1. **Clone the repository:**
    ```bash
    git clone https://github.com/AndreGonc06/ProjetoFinalBDII.git
    cd ProjetoFinalBDII
    ```

2. **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

3. **Configure environment variables:**
    - Copy `.env.example` to `.env`
    - Update database credentials in `.env`

4. **Run Migrations:**
    ```bash
    cd Application/projetofinalbdII_grupo27
    python manage.py migrate
    ```

5. **Start the Development Server:**
    ```bash
    python manage.py runserver
    ```
