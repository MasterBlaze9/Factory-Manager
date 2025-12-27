from django.db import connections


def warehouseComponent_GetList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM viewGetWarehouseComponents WHERE viewGetWarehouseComponents.warehouse_stock > 0')

        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def warehouseComponent_GetById(is_admin, warehouse_component_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetWarehouseComponentsById(%s)', [warehouse_component_id])

        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

def warehouseComponent_GetByComponentSupplierAndWarehouse(is_admin, component_id, supplier_id, warehouse_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetWarehouseComponentsByComponentSupplierAndWarehouse(%s,%s,%s)', [component_id, supplier_id, warehouse_id])

        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
    
def warehouseComponent_GetByIdList(is_admin, warehouse_component_id_list):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetWarehouseComponentsByIdsList(%s)', [warehouse_component_id_list])

        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def warehouseComponent_Create(is_admin, component_id, supplier_id, warehouse_id, quantity, unit_price, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateWarehouseComponent(%s,%s,%s,%s,%s,%s)',
                       [component_id, supplier_id, warehouse_id, quantity, unit_price, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
    
def warehouseComponent_UpdateStock(is_admin, warehouse_component_id, quantity):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spUpdateWarehouseComponentStock(%s,%s)',
                       [warehouse_component_id, quantity])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
