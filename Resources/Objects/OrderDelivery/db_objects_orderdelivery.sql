CREATE OR REPLACE FUNCTION fnCalculateOrderDeliveryStatus(filter_order_id INT)
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
			WITH order_info AS (
				SELECT
					oc.id AS order_component_id,
					EXISTS (
						SELECT order_component.id
						FROM order_component
							JOIN orderdelivery           ON order_component.order_id = orderdelivery.order_id
							JOIN orderdelivery_component ON orderdelivery.id = orderdelivery_component.order_delivery_id 
						WHERE orderdelivery_component.component_id = oc.component_id
							AND orderdelivery_component.supplier_id = oc.supplier_id
							AND orderdelivery_component.order_delivery_id = od.id
					) AS has_been_delivered,
					oc.quantity AS ordered_quantity,
					(
						SELECT SUM(odc.delivered_quantity) AS total_delivered_quantity
						FROM orderdelivery_component odc
							JOIN orderdelivery ON odc.order_delivery_id = od.id
						WHERE orderdelivery.order_id = od.order_id
							AND odc.component_id = oc.component_id
							AND odc.supplier_id = oc.supplier_id
					)::INT AS delivered_quantity
				FROM order_component oc
					LEFT JOIN orderdelivery od             ON oc.order_id = od.order_id
					LEFT JOIN orderdelivery_component od_c ON od.id = od_c.order_delivery_id
					LEFT JOIN component ON od_c.component_id = component.id
					LEFT JOIN supplier ON od_c.supplier_id = supplier.id
				WHERE component.is_active = TRUE AND supplier.is_active = TRUE
			)
			SELECT DISTINCT ON (order_component.component_id)
				(
					CASE
						WHEN order_info.has_been_delivered = TRUE AND order_info.ordered_quantity <= order_info.delivered_quantity THEN 'Entregue'
						WHEN order_info.has_been_delivered = TRUE AND order_info.ordered_quantity > order_info.delivered_quantity THEN 'Parcialmente entregue'
						ELSE 'Por entregar'
					END
				) AS calculated_status
 			FROM order_component
				LEFT JOIN order_info ON order_component.id = order_info.order_component_id
			WHERE order_component.order_id = filter_order_id
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

CREATE OR REPLACE FUNCTION fnCalculateComponentOrderDeliveryStatus(filter_order_id INT, filter_component_id INT, filter_supplier_id INT)
RETURNS TABLE (
	calculated_status TEXT
)
AS $$
BEGIN
    RETURN QUERY (
		SELECT status_info.calculated_status
		FROM (
			WITH order_info AS (
				SELECT DISTINCT ON (oc.id)
					oc.id AS order_component_id,
					EXISTS (
						SELECT order_component.id
						FROM order_component
							JOIN orderdelivery           ON order_component.order_id = orderdelivery.order_id
							JOIN orderdelivery_component ON orderdelivery.id = orderdelivery_component.order_delivery_id 
						WHERE orderdelivery_component.component_id = oc.component_id
							AND orderdelivery_component.supplier_id = oc.supplier_id
							AND orderdelivery_component.order_delivery_id = od.id
					) AS has_been_delivered,
					oc.quantity AS ordered_quantity,
					(
						SELECT SUM(odc.delivered_quantity) AS total_delivered_quantity
						FROM orderdelivery_component odc
							JOIN orderdelivery ON odc.order_delivery_id = od.id
						WHERE orderdelivery.order_id = od.order_id
							AND odc.component_id = oc.component_id
							AND odc.supplier_id = oc.supplier_id
					)::INT AS delivered_quantity
				FROM order_component oc
					LEFT JOIN orderdelivery od             ON oc.order_id = od.order_id
					LEFT JOIN orderdelivery_component od_c ON od.id = od_c.order_delivery_id
					LEFT JOIN component ON od_c.component_id = component.id
					LEFT JOIN supplier ON od_c.supplier_id = supplier.id
				WHERE component.is_active = TRUE AND supplier.is_active = TRUE
				ORDER BY oc.id
			)
			SELECT
				(
					CASE
						WHEN order_info.has_been_delivered = TRUE AND order_info.ordered_quantity <= order_info.delivered_quantity THEN 'Entregue'
						WHEN order_info.has_been_delivered = TRUE AND order_info.ordered_quantity > order_info.delivered_quantity THEN 'Parcialmente entregue'
						ELSE 'Por entregar'
					END
				) AS calculated_status
 			FROM order_component
				LEFT JOIN order_info ON order_component.id = order_info.order_component_id
			WHERE order_component.order_id = filter_order_id
				AND order_component.component_id = filter_component_id
				AND order_component.supplier_id = filter_supplier_id
		) status_info
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateOrderDelivery(
    rec_order_id INT,
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_order_id IS NULL OR rec_order_id = 0 THEN
        RAISE EXCEPTION 'Id de encomenda não pode ser vazio';
    ELSIF rec_created_by IS NULL OR rec_created_by = 0 THEN
        RAISE EXCEPTION 'Id de quem encomendou não pode ser vazio';
    ELSE
        INSERT INTO orderdelivery(order_id, created_by)
        VALUES(rec_order_id, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;