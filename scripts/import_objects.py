#!/usr/bin/env python3
"""
Import SQL object files from Resources/Objects into Postgres in a safe order.

Behavior:
- Executes non-insert SQL files (views, functions, procedures) first.
- Then executes INSERT SQL files, rewriting INSERT statements to set
  any `created_by` column values to the admin id (default 1) to avoid FK
  failures referencing unknown users.

Run this inside the `web` container (it has psycopg2 installed):
  docker-compose exec -T web python3 scripts/import_objects.py
"""
import os
import re
import sys
import psycopg2
from psycopg2 import sql

PG_HOST = os.getenv('POSTGRES_HOST', os.getenv('POSTGRES_HOST', 'db'))
PG_PORT = int(os.getenv('POSTGRES_PORT', os.getenv('POSTGRES_PORT', '5432')))
PG_DB = os.getenv('POSTGRES_DB', 'factorydb')
PG_USER = os.getenv('POSTGRES_USER', 'factoryuser')
PG_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'factorypass')

OBJECTS_ROOT = os.getenv('OBJECTS_ROOT', '/app/Resources/Objects')
ADMIN_ID = int(os.getenv('IMPORT_ADMIN_ID', '1'))

def find_sql_files(root):
    files = []
    for dirpath, dirnames, filenames in os.walk(root):
        for f in filenames:
            if f.lower().endswith('.sql'):
                files.append(os.path.join(dirpath, f))
    return sorted(files)

def is_data_file(path):
    name = os.path.basename(path).lower()
    return 'insert' in name or 'test_data' in name or name.startswith('insert_')

def adjust_insert_created_by(sql_text, admin_id):
    # Find INSERT ... (col1, col2, ...) VALUES (v1, v2, ...);
    insert_re = re.compile(r"INSERT\s+INTO\s+[^\(\n]+\(([^)]+)\)\s+VALUES\s*(\(.+?\));", re.IGNORECASE | re.DOTALL)

    def replace_match(m):
        cols_raw = m.group(1)
        vals_raw = m.group(2)
        cols = [c.strip().strip('"') for c in cols_raw.split(',')]

        # support multiple value tuples separated by '),(' by splitting
        tuples = []
        inner = vals_raw.strip()
        # remove trailing semicolon if present
        if inner.endswith(';'):
            inner = inner[:-1]
        # split on '),(' while keeping parentheses
        parts = re.split(r"\),\s*\(", inner[1:-1]) if inner.startswith('(') and inner.endswith(')') else [inner]

        new_parts = []
        for part in parts:
            vals = [v.strip() for v in re.split(r",(?=(?:[^']*'[^']*')*[^']*$)", part)]
            # if created_by present, replace its value with admin_id
            if 'created_by' in cols:
                idx = cols.index('created_by')
                # ensure idx within vals
                if idx < len(vals):
                    vals[idx] = str(admin_id)
            new_parts.append('(' + ', '.join(vals) + ')')

        new_vals = ','.join(new_parts)
        return f"INSERT INTO {m.string[m.start():m.start(1)-1].split('INTO',1)[1].split('(' ,1)[0].strip()}({cols_raw}) VALUES {new_vals};"

    new_sql = insert_re.sub(replace_match, sql_text)
    return new_sql

def main():
    if not os.path.isdir(OBJECTS_ROOT):
        print(f"Objects root not found: {OBJECTS_ROOT}")
        sys.exit(1)

    files = find_sql_files(OBJECTS_ROOT)
    object_files = [f for f in files if not is_data_file(f)]
    data_files = [f for f in files if is_data_file(f)]

    conn = psycopg2.connect(host=PG_HOST, port=PG_PORT, dbname=PG_DB, user=PG_USER, password=PG_PASSWORD)
    conn.autocommit = True
    cur = conn.cursor()

    print(f"Found {len(object_files)} object files and {len(data_files)} data files under {OBJECTS_ROOT}")

    # Execute object files first
    for p in object_files:
        print(f"Executing object file: {p}")
        with open(p, 'r', encoding='utf-8') as fh:
            sql_text = fh.read()
        try:
            cur.execute(sql_text)
        except Exception as e:
            print(f"ERROR executing {p}: {e}")

    # Execute data files with adjustments
    for p in data_files:
        print(f"Processing data file (idempotent): {p}")
        with open(p, 'r', encoding='utf-8') as fh:
            sql_text = fh.read()
        try:
            new_sql = adjust_insert_created_by(sql_text, ADMIN_ID)
            # Naive idempotency: skip INSERT lines where a unique value already exists.
            # Handle supplier(name), component(designation)
            lines = [l for l in new_sql.splitlines() if l.strip()]
            batch = []
            for line in lines:
                lower = line.lower()
                if lower.startswith('insert into supplier '):
                    m = re.search(r"VALUES\s*\(([^)]+)\)", line, re.IGNORECASE)
                    if m:
                        parts = [x.strip() for x in m.group(1).split(',')]
                        name = parts[0].strip("'\"")
                        cur.execute("SELECT 1 FROM supplier WHERE name=%s", (name,))
                        if cur.fetchone():
                            print(f"  Skipping existing supplier '{name}'")
                            continue
                if lower.startswith('insert into component '):
                    m = re.search(r"VALUES\s*\(([^)]+)\)", line, re.IGNORECASE)
                    if m:
                        parts = [x.strip() for x in m.group(1).split(',')]
                        designation = parts[0].strip("'\"")
                        cur.execute("SELECT 1 FROM component WHERE designation=%s", (designation,))
                        if cur.fetchone():
                            print(f"  Skipping existing component '{designation}'")
                            continue
                batch.append(line)
            if batch:
                cur.execute("\n".join(batch))
        except Exception as e:
            print(f"ERROR executing data file {p}: {e}")

    cur.close()
    conn.close()
    print("Import finished.")

if __name__ == '__main__':
    main()
