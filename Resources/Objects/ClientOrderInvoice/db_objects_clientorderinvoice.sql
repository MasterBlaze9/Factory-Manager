CREATE OR REPLACE VIEW viewGetClientOrderInvoices
AS
    SELECT clientorderinvoice.id AS clientorderinvoice_id,
        clientorderinvoice.invoice_number AS invoice_number,
        to_date(cast(clientorderinvoice.invoice_date as TEXT), 'YYYY-MM-DD') AS invoice_date,
		clientorderdelivery.client_order_id AS client_order_id
    FROM clientorderdelivery_equipment
		JOIN clientorderinvoice ON clientorderdelivery_equipment.client_order_invoice_id = clientorderinvoice.id
		JOIN clientorderdelivery ON clientorderdelivery_equipment.client_order_delivery_id = clientorderdelivery.id
		JOIN equipment ON clientorderdelivery_equipment.equipment_id = equipment.id
    WHERE equipment.is_active = TRUE
	GROUP BY clientorderinvoice_id, client_order_id;

CREATE OR REPLACE FUNCTION fnGetClientOrderInvoiceByClientOrderId(filter_client_order_id INT)
RETURNS TABLE (
    clientorderinvoice_id INT,
    invoice_number VARCHAR(100),
    invoice_date DATE,
    client_order_id INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM viewGetClientOrderInvoices
    WHERE viewGetClientOrderInvoices.client_order_id = filter_client_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW viewGetClientOrderInvoiceDetails
AS
    SELECT clientorderinvoice.id AS clientorderinvoice_id,
        clientorderinvoice.invoice_number AS invoice_number,
        to_date(cast(clientorderinvoice.invoice_date as TEXT), 'YYYY-MM-DD') AS invoice_date,
        clientorderdelivery_equipment.id AS order_delivery_equipment_id,
        equipment.id AS equipment_id,
        equipment.designation AS equipment_designation,
        clientorderdelivery_equipment.delivered_quantity AS delivered_quantity,
        to_date(cast(clientorderdelivery_equipment.delivered_date as TEXT), 'YYYY-MM-DD') AS delivered_date,
		clientorderdelivery.client_order_id AS client_order_id
    FROM clientorderdelivery_equipment
        JOIN clientorderdelivery ON clientorderdelivery_equipment.client_order_delivery_id = clientorderdelivery.id
        JOIN clientorderinvoice ON clientorderdelivery_equipment.client_order_invoice_id = clientorderinvoice.id
        JOIN equipment ON clientorderdelivery_equipment.equipment_id = equipment.id
    WHERE equipment.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetOrderInvoiceDetailsById(filter_client_order_id INT, filter_client_order_invoice_id INT)
RETURNS TABLE (
    clientorderinvoice_id INT,
    invoice_number VARCHAR(100),
    invoice_date DATE,
    order_delivery_equipment_id INT,
    equipment_id INT,
    equipment_designation VARCHAR(100),
    delivered_quantity INT,
    delivered_date DATE,
    client_order_id INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM viewGetClientOrderInvoiceDetails
    WHERE viewGetClientOrderInvoiceDetails.client_order_id = filter_client_order_id
		AND viewGetClientOrderInvoiceDetails.clientorderinvoice_id = filter_client_order_invoice_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateClientOrderInvoice(
    rec_invoice_date DATE,
    rec_created_by INT
)
AS $$
DECLARE
    last_client_order_invoice_number VARCHAR(100);
    generated_client_order_invoice_number VARCHAR(100);
BEGIN
    IF rec_invoice_date IS NULL THEN
        RAISE EXCEPTION 'Data da fatura não pode ser vazia';
    ELSE
        SELECT MAX(invoice_number) INTO last_client_order_invoice_number
        FROM clientorderinvoice
        LIMIT 1;

        IF last_client_order_invoice_number IS NULL THEN
            generated_client_order_invoice_number := 'FAT_CLTENCC001';
        ELSE
            generated_client_order_invoice_number := 'FAT_CLTENCC' || LPAD(CAST(SUBSTRING(last_client_order_invoice_number FROM 12) :: INTEGER + 1 AS VARCHAR), 3, '0');
        END IF;

        INSERT INTO clientorderinvoice(invoice_number, invoice_date, created_by)
        VALUES(generated_client_order_invoice_number, rec_invoice_date, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetLastClientOrderInvoiceId()
RETURNS INT
AS $$
BEGIN
    RETURN (SELECT currval('client_order_invoice_id_seq'));
END;
$$ LANGUAGE plpgsql;