CREATE OR REPLACE VIEW viewGetClientOrderEquipments
AS
	SELECT InnerQuery.equipment_id,
		InnerQuery.equipment,
		InnerQuery.quantity_ordered,
		InnerQuery.delivered_quantity,
		InnerQuery.quantity_ordered - InnerQuery.delivered_quantity AS remaining_quantity,
		InnerQuery.unit_price,
		InnerQuery.equipment_total_price,
		InnerQuery.equipment_calculated_client_order_delivery_status,
		InnerQuery.client_order_id,
		InnerQuery.client_order_equipment_id,
		InnerQuery.equipment_production_id,
		InnerQuery.client_id,
		InnerQuery.client_name
	FROM (
		SELECT DISTINCT 
			equipment.id AS equipment_id,
			equipment.designation AS equipment,
			co_e.quantity AS quantity_ordered,
			COALESCE((
				SELECT SUM(cod_e.delivered_quantity) AS total_delivered_quantity
				FROM clientorderdelivery_equipment cod_e
					JOIN clientorderdelivery cod ON cod_e.client_order_delivery_id = cod.id
				WHERE cod.client_order_id = co_e.client_order_id
					AND cod_e.equipment_id = equipment.id
					AND cod_e.equipment_production_id = equipmentproduction.id
			)::INT, 0) AS delivered_quantity,
			co_e.unit_price AS unit_price,
			co_e.quantity * co_e.unit_price AS equipment_total_price,
			fnCalculateEquipmentClientOrderDeliveryStatus(
				co_e.client_order_id,
				co_e.equipment_id
			) AS equipment_calculated_client_order_delivery_status,
			co_e.client_order_id AS client_order_id,
			co_e.id AS client_order_equipment_id,
			co_e.equipment_production_id AS equipment_production_id,
			client.id AS client_id,
			client.name AS client_name
		FROM clientorder_equipment co_e
			JOIN equipment ON co_e.equipment_id = equipment.id
			JOIN clientorder ON co_e.client_order_id = clientorder.id
			JOIN client ON clientorder.client_id = client.id
			JOIN clientorderdelivery ON co_e.client_order_id = clientorderdelivery.client_order_id
			LEFT JOIN clientorderdelivery_equipment ON clientorderdelivery.id = clientorderdelivery_equipment.client_order_delivery_id AND co_e.equipment_id = clientorderdelivery_equipment.equipment_id
			JOIN equipmentproduction ON co_e.equipment_production_id = equipmentproduction.id
		WHERE equipment.is_active = TRUE
	) InnerQuery;

CREATE OR REPLACE FUNCTION fnGetClientOrderEquipmentsByClientOrderId(filter_client_order_id INT)
RETURNS TABLE (
	equipment_id INT,
	equipment VARCHAR(100),
	quantity_ordered INT,
	delivered_quantity INT,
	remaining_quantity INT,
	unit_price DECIMAL,
	equipment_total_price DECIMAL,
	equipment_calculated_client_order_delivery_status TEXT,
	client_order_id INT,
	client_order_equipment_id INT,
	equipment_production_id INT,
	client_id INT,
	client_name VARCHAR(100)
)
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetClientOrderEquipments
	WHERE viewGetClientOrderEquipments.client_order_id = filter_client_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetClientOrderEquipmentsToDeliver(ids TEXT)
RETURNS TABLE (
	equipment_id INT,
	equipment VARCHAR(100),
	quantity_ordered INT,
	delivered_quantity INT,
	remaining_quantity INT,
	unit_price DECIMAL,
	equipment_total_price DECIMAL,
	equipment_calculated_client_order_delivery_status TEXT,
	client_order_id INT,
	client_order_equipment_id INT,
	equipment_production_id INT,
	client_id INT,
	client_name VARCHAR(100)
)
AS $$
DECLARE
    id_list INT[];
BEGIN
    id_list := string_to_array(ids, ','::TEXT)::INT[];
	
    RETURN QUERY
	SELECT *
    FROM viewGetClientOrderEquipments
	WHERE viewGetClientOrderEquipments.client_order_equipment_id = ANY(id_list);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetClientOrderEquipmentById(filter_client_order_equipment_id INT)
RETURNS TABLE (
	equipment_id INT,
	equipment VARCHAR(100),
	quantity_ordered INT,
	delivered_quantity INT,
	remaining_quantity INT,
	unit_price DECIMAL,
	equipment_total_price DECIMAL,
	equipment_calculated_client_order_delivery_status TEXT,
	client_order_id INT,
	client_order_equipment_id INT,
	equipment_production_id INT,
	client_id INT,
	client_name VARCHAR(100)
)
AS $$
BEGIN
	RETURN QUERY
	SELECT *
	FROM viewGetClientOrderEquipments
	WHERE viewGetClientOrderEquipments.client_order_equipment_id = filter_client_order_equipment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateClientOrderEquipment(
    rec_client_order_id INT,
    rec_equipment_id INT,
    rec_equipment_production_id INT,
    rec_quantity INT,
    rec_unit_price DECIMAL,
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_client_order_id IS NULL OR rec_client_order_id = 0 THEN
        RAISE EXCEPTION 'Id de encomenda não pode ser vazio';
    ELSIF rec_equipment_id IS NULL OR rec_equipment_id = 0 THEN
        RAISE EXCEPTION 'Id de equipamento não pode ser vazio';
    ELSIF rec_equipment_production_id IS NULL OR rec_equipment_production_id = 0 THEN
        RAISE EXCEPTION 'Id de produção de equipamento não pode ser vazio';
    ELSIF rec_quantity IS NULL OR rec_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantidade inválida';
    ELSIF rec_unit_price IS NULL OR rec_unit_price <= 0 THEN
        RAISE EXCEPTION 'Preço unitário inválido';
    ELSE
        INSERT INTO clientorder_equipment (client_order_id, equipment_id, equipment_production_id, quantity, unit_price, created_by)
        VALUES (rec_client_order_id, rec_equipment_id, rec_equipment_production_id, rec_quantity, rec_unit_price, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION spTriggerUpdateEquipmentProductionComponentStock()
RETURNS TRIGGER
AS $$
DECLARE
	inserted_equipment_production_id INT;
	inserted_quantity INT;
	to_update_equipment_production_id INT;
	existing_stock INT;
BEGIN
	SELECT equipment_production_id, quantity
	INTO inserted_equipment_production_id, inserted_quantity
	FROM clientorder_equipment
	WHERE id = NEW.id;
	
	SELECT id, quantity
	INTO to_update_equipment_production_id, existing_stock
	FROM equipmentproduction
	WHERE id = inserted_equipment_production_id;
	
	IF existing_stock IS NULL THEN
		DELETE FROM clientorder_equipment
		WHERE id = NEW.id;
		
		RAISE EXCEPTION 'Registo não encontrado. Algo correu mal';
	ELSE
		UPDATE equipmentproduction
		SET quantity = existing_stock - inserted_quantity
		WHERE id = to_update_equipment_production_id;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER clientOrder_Equipment_INSERT
AFTER INSERT
ON clientorder_equipment
FOR EACH ROW
EXECUTE FUNCTION spTriggerUpdateEquipmentProductionComponentStock();