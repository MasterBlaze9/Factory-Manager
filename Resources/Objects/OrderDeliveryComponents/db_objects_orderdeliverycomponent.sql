CREATE OR REPLACE PROCEDURE spCreateOrderDelivery_Component(
	filter_order_id INT,
	filter_order_component_id INT,
	rec_warehouse_id INT,
	rec_delivered_quantity INT,
	rec_delivered_date DATE,
	rec_order_invoice_id INT,
    rec_created_by INT
)
AS $$
DECLARE quantity_ordered INT;
	quantity_already_received INT;
	to_register_orderdelivery_id INT;
	to_register_component_id INT;
	to_register_supplier_id INT;
BEGIN
	SELECT order_component.quantity
	INTO quantity_ordered
	FROM order_component
	WHERE order_component.id = filter_order_component_id;

    SELECT orderdelivery.id
    INTO to_register_orderdelivery_id
    FROM orderdelivery
    WHERE orderdelivery.order_id = filter_order_id;

    SELECT order_component.component_id, order_component.supplier_id
    INTO to_register_component_id, to_register_supplier_id
    FROM order_component
    WHERE order_component.id = filter_order_component_id;
	
    IF to_register_orderdelivery_id IS NULL OR to_register_orderdelivery_id = 0 THEN
        RAISE EXCEPTION 'Id de entrega de encomenda não pode ser vazio';
	ELSIF to_register_component_id IS NULL OR to_register_component_id = 0 THEN
        RAISE EXCEPTION 'Id de componente não pode ser vazio';
	ELSIF to_register_supplier_id IS NULL OR to_register_supplier_id = 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
	END IF;
	
	SELECT orderdelivery_component.delivered_quantity
	INTO quantity_already_received
	FROM orderdelivery_component
	WHERE orderdelivery_component.order_delivery_id = to_register_orderdelivery_id
		AND orderdelivery_component.component_id = to_register_component_id
		AND orderdelivery_component.supplier_id = to_register_supplier_id;
	
	IF rec_warehouse_id IS NULL OR rec_warehouse_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém não pode ser vazio';
	ELSIF rec_order_invoice_id IS NULL OR rec_order_invoice_id = 0 THEN
        RAISE EXCEPTION 'Id de fatura não pode ser vazio';
	ELSIF rec_delivered_quantity IS NULL OR rec_delivered_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantidade entregue inválida';
	ELSIF rec_delivered_quantity > quantity_ordered THEN
        RAISE EXCEPTION 'A quantidade entregue tem de ser menor ou igual à quantidade encomendada';
	ELSIF rec_delivered_quantity + quantity_already_received > quantity_ordered THEN
        RAISE EXCEPTION 'A quantidade entregue tem de ser menor ou igual à quantidade encomendada';
	ELSIF rec_delivered_date IS NULL THEN
        RAISE EXCEPTION 'Data da entrega não pode ser vazia';
    ELSIF rec_created_by IS NULL OR rec_created_by = 0 THEN
        RAISE EXCEPTION 'Id de quem encomendou não pode ser vazio';
    ELSE
        INSERT INTO orderdelivery_component(order_delivery_id, component_id, supplier_id, warehouse_id, delivered_quantity, delivered_date, order_invoice_id, created_by)
        VALUES(to_register_orderdelivery_id, to_register_component_id, to_register_supplier_id, rec_warehouse_id, rec_delivered_quantity, rec_delivered_date, rec_order_invoice_id, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;