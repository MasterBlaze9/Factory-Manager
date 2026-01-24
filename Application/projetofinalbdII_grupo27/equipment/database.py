from django.db import connections


def equipmenttype_GetList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            "SELECT * FROM viewGetEquipmentTypes ORDER BY viewGetEquipmentTypes.equipmenttype_designation;")
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipmenttype_GetById(is_admin, equipmenttype_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetEquipmentTypeById(%s);',
                       [equipmenttype_id])
        return cursor.fetchone()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipmenttype_Create(is_admin, designation, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spCreateEquipmentType(%s, %s);",
                       (designation, created_by))
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipmenttype_Update(is_admin, equipmenttype_id, designation):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spUpdateEquipmentType(%s, %s);",
                       ([equipmenttype_id, designation]))
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipmenttype_SoftDelete(is_admin, equipmenttype_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spSoftDeleteEquipmentType(%s);",
                       [equipmenttype_id])
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipment_GetList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT * FROM viewGetEquipments")
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipment_Create(is_admin, designation, description, equipmenttype_id, price, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT fncreateequipment(%s, %s, %s, %s, %s);",
                       (designation, description, equipmenttype_id, price, created_by))
        new_id = cursor.fetchone()[0]
        return new_id, ""
    except Exception as e:
        print(f"Database error: {e}")
        return None, str(e)


def equipment_GetLastEquipmentId(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetLastEquipmentId();')
        return cursor.fetchone()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipment_GetById(is_admin, equipment_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetEquipmentById(%s);', [equipment_id])
        return cursor.fetchone()
    except Exception as e:
        print(f"Database error: {e}")
        return []

def equipment_GetProductionsByEquipmentId(is_admin, equipment_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetEquipmentProductionsByEquipmentId(%s);', [equipment_id])
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []

def equipment_GetToOrderList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM viewGetEquipmentsToOrder')
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipments_GetByProductionIdList(is_admin, equipment_production_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetEquipmentsByProductionIdsList(%s);', [equipment_production_id])
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipment_Update(is_admin, equipment_id, designation, description, equipmenttype_id, price):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spUpdateEquipment(%s, %s, %s, %s, %s);",
                       ([equipment_id, designation, description, equipmenttype_id, price]))
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipment_SoftDelete(is_admin, equipment_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spSoftDeleteEquipment(%s);", [equipment_id])
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipmentProduction_Create(is_admin, equipment_id, work_type_id, warehouse_id, quantity, start_date, end_date, cost, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spCreateEquipmentProduction(%s, %s, %s, %s, %s, %s, %s, %s);",
                       (equipment_id, work_type_id, warehouse_id, quantity, start_date, end_date, cost, created_by))
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipmentProduction_GetLastEquipmentProductionId(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetLastEquipmentProductionId()')
        return cursor.fetchone()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def equipmentProduction_Component_Create(is_admin, equipment_production_id, component_id, supplier_id, warehouse_id, quantity, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spCreateEquipmentProduction_Component(%s, %s, %s, %s, %s, %s);",
                       (equipment_production_id, component_id, supplier_id, warehouse_id, quantity, created_by))
    except Exception as e:
        print(f"Database error: {e}")
        return []

#! Client Orders

def clientOrder_GetLastClientOrderId(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetLastClientOrderId()')
        return cursor.fetchone()
    except Exception as e:
        print(f"Database error: {e}")
        return []

def clientOrder_Create(is_admin, client_id, ordered_by, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateClientOrder(%s,%s,%s)',
                       [client_id, ordered_by, created_by])
    except Exception as e:
        print(f"Database error: {e}")
        return []

def clientOrders_GetList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM viewGetClientOrders')
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []

def clientOrders_GetDetail(is_admin, client_order_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetClientOrderById(%s)', [client_order_id])
        return cursor.fetchone()
    except Exception as e:
        print(f"Database error: {e}")
        return []

def clientOrders_GetEquipmentsToDeliver(is_admin, ids_list):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetClientOrderEquipmentsToDeliver(%s)', [ids_list])
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []

def clientOrders_GetClientOrderEquipmentsByClientOrderId(is_admin, client_order_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetClientOrderEquipmentsByClientOrderId(%s)', [client_order_id])
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []

def clientOrderEquipment_Create(is_admin, client_order_id, equipment_id, equipment_production_id, quantity, unit_price, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateClientOrderEquipment(%s,%s,%s,%s,%s,%s)',
                       [client_order_id, equipment_id, equipment_production_id, quantity, unit_price, created_by])
    except Exception as e:
        print(f"Database error: {e}")
        return []


def clientOrderDelivery_Create(is_admin, client_order_id, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateClientOrderDelivery(%s,%s)',
                       [client_order_id, created_by])
    except Exception as e:
        print(f"Database error: {e}")
        return []


def clientOrderDelivery_Equipment_Create(is_admin, client_order_id, client_order_equipment_id, delivered_quantity, delivered_date, client_order_invoice_id, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateClientOrderDelivery_Equipment(%s,%s,%s,%s,%s,%s)',
                       [client_order_id, client_order_equipment_id, delivered_quantity, delivered_date, client_order_invoice_id, created_by])
    except Exception as e:
        print(f"Database error: {e}")
        return []

#! ClientOrderInvoice


def clientOrderInvoice_Create(is_admin, invoice_date, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateClientOrderInvoice(%s,%s)',
                       [invoice_date, created_by])
    except Exception as e:
        print(f"Database error: {e}")
        return []

def clientOrderInvoice_GetLastClientOrderInvoiceId(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetLastClientOrderInvoiceId()')
        return cursor.fetchone()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def clientOrderInvoice_GetListByClientOrderId(is_admin, client_order_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetClientOrderInvoiceByClientOrderId(%s)', [client_order_id])
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []


def clientOrderInvoice_GetDetailById(is_admin, client_order_id, clientorderinvoice_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetClientOrderInvoiceDetailsById(%s,%s)', [client_order_id, clientorderinvoice_id])
        return cursor.fetchall()
    except Exception as e:
        print(f"Database error: {e}")
        return []

#! ------------------------------- // --------------------------------- !#
