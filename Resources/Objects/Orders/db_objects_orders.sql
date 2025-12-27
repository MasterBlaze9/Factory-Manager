CREATE OR REPLACE VIEW viewGetOrders
AS
    WITH get_order_price AS (
        SELECT order_id AS order_id,
            SUM(quantity * unit_price) AS order_price
        FROM order_component
        GROUP BY order_id
    )
    SELECT DISTINCT orders.id AS order_id,
        orders.order_number AS order_number,
        get_order_price.order_price AS order_price,
        to_date(cast(orders.ordered_on as TEXT), 'YYYY-MM-DD') AS order_date,
        cast(auth_user.first_name || ' ' || auth_user.last_name as VARCHAR(100)) AS ordered_by,
        fnCalculateOrderDeliveryStatus(orders.id) AS order_delivery_calculated_status
    FROM orders
        JOIN get_order_price ON orders.id = get_order_price.order_id
        JOIN auth_user ON orders.ordered_by = auth_user.id

CREATE OR REPLACE FUNCTION fnGetOrderById(filter_order_id INT)
RETURNS TABLE (
	order_id INT,
	order_number VARCHAR(100),
    order_price DECIMAL(10, 2),
    order_date DATE,
	ordered_by VARCHAR(100),
    order_delivery_calculated_status TEXT
)
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetOrders
	WHERE viewGetOrders.order_id = filter_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateOrder(
    rec_ordered_by INT,
    rec_created_by INT
)
AS $$
DECLARE last_order_number VARCHAR(100);
DECLARE generated_order_number VARCHAR(100);
BEGIN
    IF rec_ordered_by IS NULL OR rec_ordered_by = 0 THEN
        RAISE EXCEPTION 'Id de quem encomendou não pode ser vazio';
    ELSE
        SELECT MAX(order_number) INTO last_order_number
        FROM Orders
        LIMIT 1;

        IF last_order_number IS NULL THEN
            generated_order_number := 'ENCC001';
        ELSE
            generated_order_number := 'ENCC' || LPAD(CAST(SUBSTRING(last_order_number FROM 5) :: INTEGER + 1 AS VARCHAR), 3, '0');
        END IF;
        
        INSERT INTO orders(order_number, ordered_by, ordered_on, created_by)
        VALUES(generated_order_number, rec_ordered_by, CURRENT_TIMESTAMP, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetLastOrderId()
RETURNS INT
AS $$
BEGIN
    RETURN (SELECT currval('orders_id_seq'));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnExportOrders_JSON() RETURNS JSON AS $$
DECLARE orders_json JSON;
BEGIN
	SELECT JSON_AGG(JSON_BUILD_OBJECT(
		'order_number', viewGetOrders.order_number,
		'order_price', viewGetOrders.order_price,
		'order_date', viewGetOrders.order_date
	))
	INTO orders_json
	FROM viewGetOrders;

	RETURN orders_json;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnExportOrders_XML() RETURNS XML AS $$
DECLARE orders_xml XML;
BEGIN
	SELECT XMLELEMENT(
        NAME "orders",
        XMLAGG(
            XMLELEMENT(
                NAME "order",
                XMLFOREST(
                    viewGetOrders.order_number AS "order_number",
                    viewGetOrders.order_price AS "order_price",
                    viewGetOrders.order_date AS "order_date"
                )
            )
        )
    )
	INTO orders_xml
	FROM viewGetOrders;

	RETURN orders_xml;
END;
$$ LANGUAGE plpgsql;