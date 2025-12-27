from django.db import connections


def client_GetList(is_admin):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("SELECT * FROM viewGetClients")
    return cursor.fetchall()


def client_GetById(is_admin, client_id):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute('SELECT * FROM fnGetClientById(%s);', [client_id])
    return cursor.fetchone()


def client_Create(is_admin, name, address, created_by):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("CALL spCreateClient(%s,%s,%s);",
                       (name, address, created_by))


def client_Update(is_admin, client_id, name, address):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("CALL spUpdateClient(%s, %s, %s);",
                    ([client_id, name, address]))


def client_SoftDelete(is_admin, client_id):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("CALL spSoftDeleteClient(%s);", [client_id])
