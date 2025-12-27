#!/usr/bin/env python3
"""
Back up key tables and (optionally) deduplicate core entities while remapping
foreign keys. Safe to run inside the `web` container.

Usage:
  docker-compose exec -T web python3 scripts/backup_and_dedupe.py --dry-run
  docker-compose exec -T web python3 scripts/backup_and_dedupe.py --apply

Targets:
  - supplier (by name)
  - component (by designation)
  - warehouse (by designation)

Backups:
  - supplier, component, supplier_component, warehouse, warehouse_component,
    order_component, orderdelivery_component, equipmentproduction_component

Notes:
  - Runs in a transaction. With --dry-run, prints the plan and exits without changes.
  - When applying, keeps the lowest id for each duplicate group and remaps all FK
    references discovered via pg_constraint.
"""
import csv
import os
import sys
import argparse
from datetime import datetime
import psycopg2


PG_HOST = os.getenv('POSTGRES_HOST', 'db')
PG_PORT = int(os.getenv('POSTGRES_PORT', '5432'))
PG_DB = os.getenv('POSTGRES_DB', 'factorydb')
PG_USER = os.getenv('POSTGRES_USER', 'factoryuser')
PG_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'factorypass')

BACKUP_DIR = os.getenv('BACKUP_DIR', '/app/backups')

BACKUP_TABLES = [
    'supplier', 'component', 'supplier_component', 'warehouse',
    'warehouse_component', 'order_component', 'orderdelivery_component',
    'equipmentproduction_component'
]

DEDUP_TARGETS = [
    ('supplier', 'name'),
    ('component', 'designation'),
    ('warehouse', 'designation'),
]


def backup_tables(conn, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    with conn.cursor() as cur:
        for table in BACKUP_TABLES:
            path = os.path.join(out_dir, f"{table}.csv")
            cur.execute(f"SELECT * FROM {table}")
            cols = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
            with open(path, 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(cols)
                writer.writerows(rows)
    return out_dir


def find_fk_references(conn, target_table):
    sql = """
    SELECT conrelid::regclass AS table_from, a.attname AS column_from
    FROM pg_constraint c
    JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
    WHERE contype = 'f' AND confrelid = %s::regclass
    ORDER BY conrelid::regclass::text;
    """
    with conn.cursor() as cur:
        cur.execute(sql, (target_table,))
        return cur.fetchall()  # list of (table_from, column_from)


def gather_duplicates(conn, table, key_col):
    sql = f"""
    SELECT {key_col}, MIN(id) AS keep_id, ARRAY_AGG(id ORDER BY id) AS ids
    FROM {table}
    GROUP BY {key_col}
    HAVING COUNT(*) > 1
    ORDER BY {key_col};
    """
    with conn.cursor() as cur:
        cur.execute(sql)
        return cur.fetchall()  # list of (key_value, keep_id, ids[])


def dedupe_target(conn, target_table, key_col, dry_run=False):
    dups = gather_duplicates(conn, target_table, key_col)
    plan = []
    if not dups:
        return plan

    refs = find_fk_references(conn, target_table)
    for key_value, keep_id, ids in dups:
        delete_ids = [i for i in ids if i != keep_id]
        plan.append({
            'table': target_table,
            'key': key_value,
            'keep_id': keep_id,
            'remove_ids': delete_ids,
            'refs': refs,
        })

        if dry_run:
            continue

        with conn.cursor() as cur:
            for dup_id in delete_ids:
                # Remap FKs
                for (table_from, column_from) in refs:
                    cur.execute(
                        f"UPDATE {table_from} SET {column_from} = %s WHERE {column_from} = %s",
                        (keep_id, dup_id),
                    )
                # Delete duplicate row
                cur.execute(f"DELETE FROM {target_table} WHERE id = %s", (dup_id,))

    return plan


def cleanup_link_duplicates(conn, dry_run=False):
    stmts = [
        """
        DELETE FROM supplier_component a USING supplier_component b
        WHERE a.ctid < b.ctid
          AND a.supplier_id = b.supplier_id
          AND a.component_id = b.component_id;
        """,
        """
        DELETE FROM warehouse_component a USING warehouse_component b
        WHERE a.ctid < b.ctid
          AND a.warehouse_id = b.warehouse_id
          AND a.component_id = b.component_id
          AND a.supplier_id = b.supplier_id;
        """,
    ]
    if dry_run:
        return stmts
    with conn.cursor() as cur:
        for s in stmts:
            cur.execute(s)
    return stmts


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dry-run', action='store_true', help='Backup and print plan only, no changes')
    parser.add_argument('--apply', action='store_true', help='Apply dedupe changes (not dry run)')
    args = parser.parse_args()

    dry_run = not args.apply

    conn = psycopg2.connect(host=PG_HOST, port=PG_PORT, dbname=PG_DB, user=PG_USER, password=PG_PASSWORD)
    try:
        conn.autocommit = False

        # Backups
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        out_dir = os.path.join(BACKUP_DIR, ts)
        backup_tables(conn, out_dir)
        print(f"Backups written to: {out_dir}")

        total_plan = []
        for table, key_col in DEDUP_TARGETS:
            plan = dedupe_target(conn, table, key_col, dry_run=dry_run)
            total_plan.extend(plan)

        link_dupe_stmts = cleanup_link_duplicates(conn, dry_run=dry_run)

        if dry_run:
            print("DRY RUN — no changes applied. Plan:")
            for entry in total_plan:
                print(f"- {entry['table']} key='{entry['key']}' keep={entry['keep_id']} delete={entry['remove_ids']}")
            print("Link-table cleanup statements:")
            for s in link_dupe_stmts:
                print(s.strip().splitlines()[0] + ' ...')
            conn.rollback()
        else:
            conn.commit()
            print("Dedupe applied successfully.")
    finally:
        conn.close()


if __name__ == '__main__':
    main()
