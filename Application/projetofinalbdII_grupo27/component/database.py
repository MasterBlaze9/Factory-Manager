from django.db import connections


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


def component_GetToOrderList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM viewGetComponentsToOrder')
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_GetById(is_admin, component_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.callproc('fetch_component_details', [component_id])
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_GetComponentForOrder(is_admin, component_id, supplier_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            "SELECT * FROM fnGetComponentByComponentAndSupplier(%s,%s);",
            [component_id, supplier_id]
        )

        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_GetOrderComponents(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT * FROM show_component_orders")
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_Create(is_admin, designation, price, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateComponent(%s,%s,%s)',
                       [designation, price, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_Update(is_admin, component_id, designation, price):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spUpdateComponent(%s,%s,%s)',
                       [component_id, designation, price])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_SoftDelete(is_admin, component_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spSoftDeleteComponent(%s);", [component_id])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_ImportJSON(is_admin, json_data, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spImportComponents_JSON(%s,%s);",
                       [json_data, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_ExportJSON(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT * FROM fnExportComponents_JSON();")
        return cursor.fetchone()[0]
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_ImportXML(is_admin, xml_data, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("CALL spImportComponents_XML(%s,%s);",
                       [xml_data, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def component_ExportXML(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT * FROM fnExportComponents_XML();")
        return cursor.fetchone()[0]
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

#! Orders


def orders_Create(is_admin, ordered_by, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateOrder(%s,%s)',
                       [ordered_by, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orders_GetLastOrderId(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetLastOrderId()')
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orders_GetList(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM viewGetOrders')
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

def orders_ExportJSON(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT * FROM fnExportOrders_JSON();")
        return cursor.fetchone()[0]
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

def orders_ExportXML(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute("SELECT * FROM fnExportOrders_XML();")
        return cursor.fetchone()[0]
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orders_GetDetail(is_admin, order_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetOrderById(%s)', [order_id])
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orders_GetOrderComponentsByOrderId(is_admin, order_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetOrderComponentsByOrderId(%s)', [order_id])
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orders_GetComponentsToDeliver(is_admin, ids_list):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetOrderComponentsToDeliver(%s)', [ids_list])
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

def orders_GetSuppliersByOrderComponent(is_admin, order_id, component_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetSuppliersByOrderComponent(%s,%s)', [order_id, component_id])
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

def orderComponent_GetById(is_admin, order_component_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetOrderComponentById(%s)', [order_component_id])
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

def orderComponent_Create(is_admin, order_id, component_id, quantity, unit_price, supplier_id, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateOrderComponent(%s,%s,%s,%s,%s,%s)',
                       [order_id, component_id, quantity, unit_price, supplier_id, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orderDelivery_Create(is_admin, order_id, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateOrderDelivery(%s,%s)',
                       [order_id, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orderDelivery_Component_Create(is_admin, order_id, order_component_id, warehouse_id, delivered_quantity, delivered_date, orderinvoice_id, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateOrderDelivery_Component(%s,%s,%s,%s,%s,%s,%s)',
                       [order_id, order_component_id, warehouse_id, delivered_quantity, delivered_date, orderinvoice_id, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]
#! ------------------------------- // --------------------------------- !#

#! OrderInvoice


def orderInvoice_Create(is_admin, invoice_date, created_by):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('CALL spCreateOrderInvoice(%s,%s)',
                       [invoice_date, created_by])
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

def orderInvoice_GetLastOrderInvoiceId(is_admin):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute('SELECT * FROM fnGetLastOrderInvoiceId()')
        return cursor.fetchone()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orderInvoice_GetListByOrderId(is_admin, order_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetOrderInvoiceByOrderId(%s)', [order_id])
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]


def orderInvoice_GetDetailById(is_admin, order_id, orderinvoice_id):
    try:
        if is_admin:
            cursor = connections["admin_psql"].cursor()
        else:
            cursor = connections["default"].cursor()

        cursor.execute(
            'SELECT * FROM fnGetOrderInvoiceDetailsById(%s,%s)', [order_id, orderinvoice_id])
        return cursor.fetchall()
    except Exception as e:
        index_to_cut = str(e).find("CONTEXT")
        return e.args[0][0:index_to_cut - 1]

#! ------------------------------- // --------------------------------- !#
