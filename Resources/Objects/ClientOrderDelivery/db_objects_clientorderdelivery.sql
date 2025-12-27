CREATE OR REPLACE FUNCTION fnCalculateClientOrderDeliveryStatus(filter_client_order_id INT)
RETURNS TEXT
AS $$
DECLARE count_PorEntregar INT := 0;
	count_ParcialmenteEntregue INT := 0;
	count_Entregue INT := 0;
	rec RECORD;
BEGIN
	FOR rec IN (
		SELECT status_info.calculated_status
		FROM (
			WITH client_order_info AS (
				SELECT
					co_e.id AS client_order_equipment_id,
					EXISTS (
						SELECT clientorder_equipment.id
						FROM clientorder_equipment
							JOIN clientorderdelivery           ON clientorder_equipment.client_order_id = clientorderdelivery.client_order_id
							JOIN clientorderdelivery_equipment ON clientorderdelivery.id = clientorderdelivery_equipment.client_order_delivery_id 
						WHERE clientorderdelivery_equipment.equipment_id = co_e.equipment_id
							AND clientorderdelivery_equipment.client_order_delivery_id = cod.id
					) AS has_been_delivered,
					co_e.quantity AS ordered_quantity,
					(
						SELECT SUM(codc.delivered_quantity) AS total_delivered_quantity
						FROM clientorderdelivery_equipment codc
							JOIN clientorderdelivery ON codc.client_order_delivery_id = cod.id
						WHERE clientorderdelivery.client_order_id = cod.client_order_id
							AND codc.equipment_id = co_e.equipment_id
					)::INT AS delivered_quantity
				FROM clientorder_equipment co_e
					LEFT JOIN clientorderdelivery cod             ON co_e.client_order_id = cod.client_order_id
					LEFT JOIN clientorderdelivery_equipment cod_e ON cod.id = cod_e.client_order_delivery_id
					LEFT JOIN equipment ON cod_e.equipment_id = equipment.id
				WHERE equipment.is_active = TRUE
			)
			SELECT DISTINCT ON (clientorder_equipment.equipment_id)
				(
					CASE
						WHEN client_order_info.has_been_delivered = TRUE AND client_order_info.ordered_quantity <= client_order_info.delivered_quantity THEN 'Entregue'
						WHEN client_order_info.has_been_delivered = TRUE AND client_order_info.ordered_quantity > client_order_info.delivered_quantity THEN 'Parcialmente entregue'
						ELSE 'Por entregar'
					END
				) AS calculated_status
 			FROM clientorder_equipment
				LEFT JOIN client_order_info ON clientorder_equipment.id = client_order_info.client_order_equipment_id
			WHERE clientorder_equipment.client_order_id = filter_client_order_id
		) status_info
	) LOOP
		RAISE INFO '%', rec.calculated_status;
		
		IF rec.calculated_status = 'Entregue' THEN
			count_Entregue := count_Entregue + 1;
		ELSIF rec.calculated_status = 'Parcialmente entregue' THEN
			count_ParcialmenteEntregue := count_ParcialmenteEntregue + 1;
		ELSE
			count_PorEntregar := count_PorEntregar + 1;
		END IF;
	END LOOP;
	
	IF count_PorEntregar > 0 AND count_ParcialmenteEntregue = 0 AND count_Entregue = 0 THEN
		RETURN 'Por entregar';
	ELSEIF count_ParcialmenteEntregue > 0 THEN
		RETURN 'Parcialmente entregue';
	ELSIF count_PorEntregar > 0 AND count_Entregue > 0 THEN
		RETURN 'Parcialmente entregue';
	ELSE
		RETURN 'Entregue';
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnCalculateEquipmentClientOrderDeliveryStatus(filter_client_order_id INT, filter_equipment_id INT)
RETURNS TABLE (
	calculated_status TEXT
)
AS $$
BEGIN
    RETURN QUERY (
		SELECT status_info.calculated_status
		FROM (
			WITH client_order_info AS (
				SELECT DISTINCT ON (co_e.id)
					co_e.id AS client_order_equipment_id,
					EXISTS (
						SELECT clientorder_equipment.id
						FROM clientorder_equipment
							JOIN clientorderdelivery           ON clientorder_equipment.client_order_id = clientorderdelivery.client_order_id
							JOIN clientorderdelivery_equipment ON clientorderdelivery.id = clientorderdelivery_equipment.client_order_delivery_id 
						WHERE clientorderdelivery_equipment.equipment_id = co_e.equipment_id
							AND clientorderdelivery_equipment.client_order_delivery_id = cod.id
					) AS has_been_delivered,
					co_e.quantity AS ordered_quantity,
					(
						SELECT SUM(codc.delivered_quantity) AS total_delivered_quantity
						FROM clientorderdelivery_equipment codc
							JOIN clientorderdelivery ON codc.client_order_delivery_id = cod.id
						WHERE clientorderdelivery.client_order_id = cod.client_order_id
							AND codc.equipment_id = co_e.equipment_id
					)::INT AS delivered_quantity
				FROM clientorder_equipment co_e
					LEFT JOIN clientorderdelivery cod             ON co_e.client_order_id = cod.client_order_id
					LEFT JOIN clientorderdelivery_equipment cod_e ON cod.id = cod_e.client_order_delivery_id
					LEFT JOIN equipment ON cod_e.equipment_id = equipment.id
				WHERE equipment.is_active = TRUE
			)
			SELECT
				(
					CASE
						WHEN client_order_info.has_been_delivered = TRUE AND client_order_info.ordered_quantity <= client_order_info.delivered_quantity THEN 'Entregue'
						WHEN client_order_info.has_been_delivered = TRUE AND client_order_info.ordered_quantity > client_order_info.delivered_quantity THEN 'Parcialmente entregue'
						ELSE 'Por entregar'
					END
				) AS calculated_status
 			FROM clientorder_equipment
				LEFT JOIN client_order_info ON clientorder_equipment.id = client_order_info.client_order_equipment_id
			WHERE clientorder_equipment.client_order_id = filter_client_order_id AND clientorder_equipment.equipment_id = filter_equipment_id
		) status_info
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateClientOrderDelivery(
    rec_client_order_id INT,
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_client_order_id IS NULL OR rec_client_order_id = 0 THEN
        RAISE EXCEPTION 'Id de encomenda não pode ser vazio';
    ELSIF rec_created_by IS NULL OR rec_created_by = 0 THEN
        RAISE EXCEPTION 'Id de quem encomendou não pode ser vazio';
    ELSE
        INSERT INTO clientorderdelivery(client_order_id, created_by)
        VALUES(rec_client_order_id, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;