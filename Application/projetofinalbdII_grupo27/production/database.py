from django.db import connections


def worktype_GetList(is_admin):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("SELECT * FROM viewGetWorkTypes")
    return cursor.fetchall()


def worktype_GetById(is_admin, worktype_id):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute('SELECT * FROM fnGetWorkTypeById(%s);', [worktype_id])
    return cursor.fetchone()


def worktype_Create(is_admin, designation, cost, created_by):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("CALL spCreateWorkType(%s,%s,%s);",
                    (designation, cost, created_by))


def worktype_Update(is_admin, worktype_id, name, address):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("CALL spUpdateWorkType(%s, %s, %s);",
                    ([worktype_id, name, address]))


def worktype_SoftDelete(is_admin, worktype_id):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("CALL spSoftDeleteWorkType(%s);", [worktype_id])


def production_GetList(is_admin):
    if is_admin: cursor = connections["admin_psql"].cursor()
    else: cursor = connections["default"].cursor()
    
    cursor.execute("SELECT * FROM viewgetproduction")
    return cursor.fetchall()