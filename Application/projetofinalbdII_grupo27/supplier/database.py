from django.db import connections


def supplier_GetList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT * FROM viewGetSuppliers")
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def supplier_GetById(is_admin, supplier_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetSupplierById(%s);', [supplier_id])
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def supplier_Create(is_admin, name, address, fiscal_number, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spCreateSupplier(%s,%s,%s,%s);",
                       (name, address, fiscal_number, created_by))
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def supplier_GetLastSupplierId(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetLastSupplierId()')
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def supplier_Update(is_admin, supplier_id, name, address, fiscal_number):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spUpdateSupplier(%s, %s, %s, %s);",
                       ([supplier_id, name, address, fiscal_number]))
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def supplier_SoftDelete(is_admin, supplier_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spSoftDeleteSupplier(%s);", [supplier_id])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


#! Supplier_component

def supplierComponent_Create(is_admin, supplier_id, component_id, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spCreateSupplierComponent(%s,%s,%s);",
                       (supplier_id, component_id, created_by))
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
#! -- Functions to retrieve components from database to associate them to a supplier -- !#


def component_GetList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM viewGetComponents')
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def supplier_GetComponents_SelectedOrToSelect(is_admin, supplier_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetComponentsToBeSelected_SupplierBySupplierId(%s);', [supplier_id])
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
#! ------------------------------- // --------------------------------- !#

def supplierComponent_DeleteBySupplierId(is_admin, supplier_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spDeleteSupplierComponentsBySupplierId(%s);", [supplier_id])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
