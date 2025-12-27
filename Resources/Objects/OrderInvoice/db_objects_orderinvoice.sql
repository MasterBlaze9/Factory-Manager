CREATE OR REPLACE VIEW viewGetOrderInvoices
AS
    SELECT orderinvoice.id AS orderinvoice_id,
        orderinvoice.invoice_number AS invoice_number,
        to_date(cast(orderinvoice.invoice_date as TEXT), 'YYYY-MM-DD') AS invoice_date,
		orderdelivery.order_id AS order_id
    FROM orderdelivery_component
		JOIN orderinvoice ON orderdelivery_component.order_invoice_id = orderinvoice.id
		JOIN orderdelivery ON orderdelivery_component.order_delivery_id = orderdelivery.id
		JOIN component ON orderdelivery_component.component_id = component.id
    WHERE component.is_active = TRUE
	GROUP BY orderinvoice_id, order_id;

CREATE OR REPLACE FUNCTION fnGetOrderInvoiceByOrderId(filter_order_id INT)
RETURNS TABLE (
    orderinvoice_id INT,
    invoice_number VARCHAR(100),
    invoice_date DATE,
	order_id INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM viewGetOrderInvoices
    WHERE viewGetOrderInvoices.order_id = filter_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW viewGetOrderInvoiceDetails
AS
    SELECT orderinvoice.id AS orderinvoice_id,
        orderinvoice.invoice_number AS invoice_number,
        to_date(cast(orderinvoice.invoice_date as TEXT), 'YYYY-MM-DD') AS invoice_date,
        orderdelivery_component.id AS order_delivery_component_id,
        component.id AS component_id,
        component.designation AS component_designation,
        supplier.id AS supplier_id,
        supplier.name AS supplier_name,
        warehouse.id AS warehouse_id,
        warehouse.designation AS warehouse_designation,
        orderdelivery_component.delivered_quantity AS delivered_quantity,
        to_date(cast(orderdelivery_component.delivered_date as TEXT), 'YYYY-MM-DD') AS delivered_date,
		orderdelivery.order_id AS order_id
    FROM orderdelivery_component
        JOIN orderdelivery ON orderdelivery_component.order_delivery_id = orderdelivery.id
        JOIN orderinvoice ON orderdelivery_component.order_invoice_id = orderinvoice.id
        JOIN component ON orderdelivery_component.component_id = component.id
        JOIN supplier ON orderdelivery_component.supplier_id = supplier.id
        JOIN warehouse ON orderdelivery_component.warehouse_id = warehouse.id
    WHERE component.is_active = TRUE
        AND supplier.is_active = TRUE
        AND warehouse.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetOrderInvoiceDetailsById(filter_order_id INT, filter_order_invoice_id INT)
RETURNS TABLE (
    orderinvoice_id INT,
    invoice_number VARCHAR(100),
    invoice_date DATE,
    order_delivery_component_id INT,
    component_id INT,
    component_designation VARCHAR(100),
    supplier_id INT,
    supplier_name VARCHAR(100),
    warehouse_id INT,
    warehouse_designation VARCHAR(100),
    delivered_quantity INT,
    delivered_date DATE,
    order_id INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM viewGetOrderInvoiceDetails
    WHERE viewGetOrderInvoiceDetails.order_id = filter_order_id
		AND viewGetOrderInvoiceDetails.orderinvoice_id = filter_order_invoice_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateOrderInvoice(
    rec_invoice_date DATE,
    rec_created_by INT
)
AS $$
DECLARE
    last_order_invoice_number VARCHAR(100);
    generated_order_invoice_number VARCHAR(100);
BEGIN
    IF rec_invoice_date IS NULL THEN
        RAISE EXCEPTION 'Data da fatura não pode ser vazia';
    ELSE
        SELECT MAX(invoice_number) INTO last_order_invoice_number
        FROM orderinvoice
        LIMIT 1;

        IF last_order_invoice_number IS NULL THEN
            generated_order_invoice_number := 'FAT_ENCC001';
        ELSE
            generated_order_invoice_number := 'FAT_ENCC' || LPAD(CAST(SUBSTRING(last_order_invoice_number FROM 9) :: INTEGER + 1 AS VARCHAR), 3, '0');
        END IF;

        INSERT INTO orderinvoice(invoice_number, invoice_date, created_by)
        VALUES(generated_order_invoice_number, rec_invoice_date, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetLastOrderInvoiceId()
RETURNS INT
AS $$
BEGIN
    RETURN (SELECT currval('order_invoice_id_seq'));
END;
$$ LANGUAGE plpgsql;