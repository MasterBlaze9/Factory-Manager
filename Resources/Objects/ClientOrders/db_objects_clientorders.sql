CREATE OR REPLACE VIEW viewGetClientOrders
AS
    WITH get_client_order_price AS (
        SELECT client_order_id AS client_order_id,
            SUM(quantity * unit_price) AS client_order_price
        FROM clientorder_equipment
        GROUP BY client_order_id
    )
    SELECT DISTINCT clientorder.id AS client_order_id,
        clientorder.client_order_number AS client_order_number,
        get_client_order_price.client_order_price AS client_order_price,
        to_date(cast(clientorder.ordered_on as TEXT), 'YYYY-MM-DD') AS client_order_date,
        cast(auth_user.first_name || ' ' || auth_user.last_name as VARCHAR(100)) AS client_ordered_by,
        fnCalculateClientOrderDeliveryStatus(clientorder.id) AS client_order_delivery_calculated_status,
        client.id AS client_ordered_to_id, 
        client.name AS client_ordered_to 
    FROM clientorder
        JOIN get_client_order_price ON clientorder.id = get_client_order_price.client_order_id
        JOIN auth_user ON clientorder.ordered_by = auth_user.id
        JOIN client ON clientorder.client_id = client.id;

CREATE OR REPLACE FUNCTION fnGetClientOrderById(filter_client_order_id INT)
RETURNS TABLE (
	client_order_id INT,
	client_order_number VARCHAR(100),
    client_order_price DECIMAL(10, 2),
    client_order_date DATE,
	client_ordered_by VARCHAR(100),
    client_order_delivery_calculated_status TEXT,
    client_ordered_to_id INT,
    client_ordered_to VARCHAR(100)
)
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetClientOrders
	WHERE viewGetClientOrders.client_order_id = filter_client_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateClientOrder(
    rec_client_id INT,
	rec_ordered_by INT,
    rec_created_by INT
)
AS $$
DECLARE last_client_order_number VARCHAR(100);
DECLARE generated_client_order_number VARCHAR(100);
BEGIN
	IF rec_client_id IS NULL OR rec_client_id = 0 THEN
        RAISE EXCEPTION 'Id de cliente não pode ser vazio';
    ELSIF rec_ordered_by IS NULL OR rec_ordered_by = 0 THEN
        RAISE EXCEPTION 'Id de quem encomendou não pode ser vazio';
    ELSE
        SELECT MAX(client_order_number) INTO last_client_order_number
        FROM ClientOrder
        LIMIT 1;

        IF last_client_order_number IS NULL THEN
            generated_client_order_number := 'CLTENCC001';
        ELSE
            generated_client_order_number := 'CLTENCC' || LPAD(CAST(SUBSTRING(last_client_order_number FROM 5) :: INTEGER + 1 AS VARCHAR), 3, '0');
        END IF;
        
        INSERT INTO clientorder(client_order_number, client_id, ordered_by, ordered_on, created_by)
        VALUES(generated_client_order_number, rec_client_id, rec_ordered_by, CURRENT_TIMESTAMP, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetLastClientOrderId()
RETURNS INT
AS $$
BEGIN
    RETURN (SELECT currval('client_order_id_seq'));
END;
$$ LANGUAGE plpgsql;