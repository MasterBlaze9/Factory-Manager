CREATE OR REPLACE PROCEDURE spCreateEquipmentProduction_Component(
    rec_equipment_production_id INT,
	rec_component_id INT,
	rec_supplier_id INT,
	rec_warehouse_id INT,
	rec_quantity INT,
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_equipment_production_id IS NULL OR rec_equipment_production_id = 0 THEN
        RAISE EXCEPTION 'Id de equipamento não pode ser vazio';
    ELSIF rec_component_id IS NULL OR rec_component_id = 0 THEN
        RAISE EXCEPTION 'Id de tipo de mão de obra não pode ser vazio';
    ELSIF rec_supplier_id IS NULL OR rec_supplier_id <= 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
    ELSIF rec_warehouse_id IS NULL OR rec_warehouse_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém não pode ser vazio';
    ELSIF rec_quantity IS NULL OR rec_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantidade inválida';
    ELSE
        INSERT INTO equipmentproduction_component(equipment_production_id, component_id, supplier_id, warehouse_id, quantity, created_by)
        VALUES(rec_equipment_production_id, rec_component_id, rec_supplier_id, rec_warehouse_id, rec_quantity, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnTriggerUpdateWarehouseComponentStock()
RETURNS TRIGGER
AS $$
DECLARE
	inserted_component_id INT;
	inserted_supplier_id INT;
	inserted_warehouse_id INT;
	inserted_quantity INT;
	to_update_warehouse_component_id INT;
	existing_stock INT;
BEGIN
	SELECT component_id, supplier_id, warehouse_id, quantity
	INTO inserted_component_id, inserted_supplier_id, inserted_warehouse_id, inserted_quantity
	FROM equipmentproduction_component
	WHERE id = NEW.id;
	
	SELECT id, stock
	INTO to_update_warehouse_component_id, existing_stock
	FROM warehouse_component
	WHERE component_id = inserted_component_id AND supplier_id = inserted_supplier_id AND warehouse_id = inserted_warehouse_id;
	
	IF existing_stock IS NULL THEN
		DELETE FROM equipmentproduction_component
		WHERE id = NEW.id;
		
		RAISE EXCEPTION 'Registo não encontrado. Algo correu mal';
	ELSE
		UPDATE warehouse_component
		SET stock = existing_stock - inserted_quantity
		WHERE id = to_update_warehouse_component_id;
	END IF;
		
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER equipmentproduction_component_INSERT
AFTER INSERT
ON equipmentproduction_component
FOR EACH ROW
EXECUTE FUNCTION fnTriggerUpdateWarehouseComponentStock();