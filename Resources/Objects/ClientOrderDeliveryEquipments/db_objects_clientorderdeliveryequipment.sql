CREATE OR REPLACE PROCEDURE spCreateClientOrderDelivery_Equipment(
	filter_client_order_id INT,
	filter_client_order_equipment_id INT,
	rec_delivered_quantity INT,
	rec_delivered_date DATE,
	rec_client_order_invoice_id INT,
    rec_created_by INT
)
AS $$
DECLARE quantity_ordered INT;
	quantity_already_received INT;
	to_register_clientorderdelivery_id INT;
	to_register_equipment_id INT;
	to_register_equipment_production_id INT;
BEGIN
	SELECT clientorder_equipment.quantity
	INTO quantity_ordered
	FROM clientorder_equipment
	WHERE clientorder_equipment.id = filter_client_order_equipment_id;

    SELECT clientorderdelivery.id
    INTO to_register_clientorderdelivery_id
    FROM clientorderdelivery
    WHERE clientorderdelivery.client_order_id = filter_client_order_id;

    SELECT clientorder_equipment.equipment_id, clientorder_equipment.equipment_production_id
    INTO to_register_equipment_id, to_register_equipment_production_id
    FROM clientorder_equipment
    WHERE clientorder_equipment.id = filter_client_order_equipment_id;
	
    IF to_register_clientorderdelivery_id IS NULL OR to_register_clientorderdelivery_id = 0 THEN
        RAISE EXCEPTION 'Id de entrega de encomenda não pode ser vazio';
	ELSIF to_register_equipment_id IS NULL OR to_register_equipment_id = 0 THEN
        RAISE EXCEPTION 'Id de equipamento não pode ser vazio';
	END IF;
	
	SELECT clientorderdelivery_equipment.delivered_quantity
	INTO quantity_already_received
	FROM clientorderdelivery_equipment
	WHERE clientorderdelivery_equipment.client_order_delivery_id = to_register_clientorderdelivery_id
		AND clientorderdelivery_equipment.equipment_id = to_register_equipment_id;
	
	IF rec_client_order_invoice_id IS NULL OR rec_client_order_invoice_id = 0 THEN
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
        INSERT INTO clientorderdelivery_equipment(client_order_delivery_id, equipment_id, equipment_production_id, delivered_quantity, delivered_date, client_order_invoice_id, created_by)
        VALUES(to_register_clientorderdelivery_id, to_register_equipment_id, to_register_equipment_production_id, rec_delivered_quantity, rec_delivered_date, rec_client_order_invoice_id, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;