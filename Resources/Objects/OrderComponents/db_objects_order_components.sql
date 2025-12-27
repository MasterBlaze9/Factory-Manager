CREATE OR REPLACE VIEW viewGetOrderComponents
AS
	SELECT InnerQuery.component_id,
		InnerQuery.component,
		InnerQuery.quantity_ordered,
		InnerQuery.delivered_quantity,
		InnerQuery.quantity_ordered - InnerQuery.delivered_quantity AS remaining_quantity,
		InnerQuery.unit_price,
		InnerQuery.component_total_price,
		InnerQuery.supplier_id,
		InnerQuery.supplier_name,
		InnerQuery.component_calculated_order_delivery_status,
		InnerQuery.order_id,
		InnerQuery.order_component_id
	FROM (
		SELECT DISTINCT ON (o_c.id) 
			component.id AS component_id,
			component.designation AS component,
			o_c.quantity AS quantity_ordered,
			COALESCE((
				SELECT SUM(odc.delivered_quantity) AS total_delivered_quantity
				FROM orderdelivery_component odc
					JOIN orderdelivery od ON odc.order_delivery_id = od.id
				WHERE od.order_id = o_c.order_id
					AND odc.component_id = component.id
					AND odc.supplier_id = supplier.id
			)::INT, 0) AS delivered_quantity,
			o_c.unit_price AS unit_price,
			o_c.quantity * o_c.unit_price AS component_total_price,
			supplier.id AS supplier_id,
			supplier.name AS supplier_name,
			fnCalculateComponentOrderDeliveryStatus(
				o_c.order_id,
				o_c.component_id,
				o_c.supplier_id
			) AS component_calculated_order_delivery_status,
			o_c.order_id AS order_id,
			o_c.id AS order_component_id
		FROM order_component o_c
			JOIN component ON o_c.component_id = component.id
			JOIN orderdelivery ON o_c.order_id = orderdelivery.order_id
			LEFT JOIN orderdelivery_component ON orderdelivery.id = orderdelivery_component.order_delivery_id AND o_c.component_id = orderdelivery_component.component_id
			JOIN supplier ON o_c.supplier_id = supplier.id
		WHERE component.is_active = TRUE AND supplier.is_active = TRUE
		ORDER BY o_c.id
	) InnerQuery;

CREATE OR REPLACE FUNCTION fnGetOrderComponentsByOrderId(filter_order_id INT)
RETURNS TABLE (
    component_id INT,
	component VARCHAR(100),
    quantity_ordered INT,
	delivered_quantity INT,
	remaining_quantity INT,
    unit_price DECIMAL,
    component_total_price DECIMAL,
    supplier_id INT,
    supplier_name VARCHAR(100),
    component_calculated_order_delivery_status TEXT,
    order_id INT,
    order_component_id INT
)
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetOrderComponents
	WHERE viewGetOrderComponents.order_id = filter_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetOrderComponentsToDeliver(ids TEXT)
RETURNS TABLE (
    component_id INT,
	component VARCHAR(100),
    quantity_ordered INT,
	delivered_quantity INT,
    remaining_quantity INT,
    unit_price DECIMAL,
    component_total_price DECIMAL,
    supplier_id INT,
    supplier_name VARCHAR(100),
    component_calculated_order_delivery_status TEXT,
    order_id INT,
    order_component_id INT
)
AS $$
DECLARE
    id_list INT[];
BEGIN
    id_list := string_to_array(ids, ','::TEXT)::INT[];
	
    RETURN QUERY
	SELECT *
    FROM viewGetOrderComponents
	WHERE viewGetOrderComponents.order_component_id = ANY(id_list);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW viewGetSuppliersByOrderComponent
AS
    SELECT supplier.id AS supplier_id,
		supplier.name AS supplier_name,
		order_component.order_id AS order_id,
		order_component.component_id AS component_id
	FROM order_component
		JOIN supplier_component ON order_component.component_id = supplier_component.component_id
		JOIN supplier ON supplier_component.supplier_id = supplier.id
    ORDER BY supplier.name;

CREATE OR REPLACE FUNCTION fnGetSuppliersByOrderComponent(filter_order_id INT, filter_component_id INT)
RETURNS TABLE (
    supplier_id INT,
    supplier_name VARCHAR(100),
	order_id INT,
	component_id INT
)
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetSuppliersByOrderComponent
	WHERE viewGetSuppliersByOrderComponent.order_id = filter_order_id AND viewGetSuppliersByOrderComponent.component_id = filter_component_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetOrderComponentById(filter_order_component_id INT)
RETURNS TABLE (
	component_id INT,
	component VARCHAR(100),
	quantity_ordered INT,
	delivered_quantity INT,
	remaining_quantity INT,
	unit_price DECIMAL,
	component_total_price DECIMAL,
	supplier_id INT,
	supplier_name VARCHAR(100),
	component_calculated_order_delivery_status TEXT,
	order_id INT,
	order_component_id INT
)
AS $$
BEGIN
	RETURN QUERY
	SELECT *
	FROM viewGetOrderComponents
	WHERE viewGetOrderComponents.order_component_id = filter_order_component_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateOrderComponent(
    rec_order_id INT,
    rec_component_id INT,
    rec_quantity INT,
    rec_unit_price DECIMAL,
    rec_supplier_id INT,
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_order_id IS NULL OR rec_order_id = 0 THEN
        RAISE EXCEPTION 'Id de encomenda não pode ser vazio';
    ELSIF rec_component_id IS NULL OR rec_component_id = 0 THEN
        RAISE EXCEPTION 'Id de componente não pode ser vazio';
    ELSIF rec_quantity IS NULL OR rec_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantidade inválida';
    ELSIF rec_unit_price IS NULL OR rec_unit_price <= 0 THEN
        RAISE EXCEPTION 'Preço unitário inválido';
    ELSIF rec_supplier_id IS NULL OR rec_supplier_id = 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
    ELSE
        INSERT INTO order_component (order_id, component_id, quantity, unit_price, supplier_id, created_by)
        VALUES (rec_order_id, rec_component_id, rec_quantity, rec_unit_price, rec_supplier_id, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;