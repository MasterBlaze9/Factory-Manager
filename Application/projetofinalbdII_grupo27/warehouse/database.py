from django.db import connections


def warehouse_GetList(is_admin):
    try:
        if is_admin: cursor = connections["admin_psql"].cursor()
        else: cursor = connections["default"].cursor()
        
        cursor.execute("SELECT * FROM viewGetWarehouses")
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def warehouse_GetById(is_admin, warehouse_id):
    try:
        if is_admin: cursor = connections["admin_psql"].cursor()
        else: cursor = connections["default"].cursor()
        
        cursor.execute('SELECT * FROM fnGetWarehouseById(%s);', [warehouse_id])
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def warehouse_Create(is_admin, designation, address, created_by):
    try:
        if is_admin: cursor = connections["admin_psql"].cursor()
        else: cursor = connections["default"].cursor()
        
        cursor.execute("CALL spCreateWarehouse(%s,%s,%s);",
                        (designation, address, created_by))
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def warehouse_Update(is_admin, warehouse_id, designation, address):
    try:
        if is_admin: cursor = connections["admin_psql"].cursor()
        else: cursor = connections["default"].cursor()
        
        cursor.execute("CALL spUpdateWarehouse(%s, %s, %s);",
                        ([warehouse_id, designation, address]))
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def warehouse_SoftDelete(is_admin, warehouse_id):
    try:
        if is_admin: cursor = connections["admin_psql"].cursor()
        else: cursor = connections["default"].cursor()
        
        cursor.execute("CALL spSoftDeleteWarehouse(%s);", [warehouse_id])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
