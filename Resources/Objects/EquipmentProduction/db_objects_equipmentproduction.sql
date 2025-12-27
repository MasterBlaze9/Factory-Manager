CREATE OR REPLACE VIEW viewGetEquipmentProductions
AS
    SELECT equipmentproduction.id AS equipment_production_id,
		  equipment.id AS equipment_id,
		  equipment.designation AS equipment_designation,
		  worktype.id AS work_type_id,
		  worktype.designation AS work_type_designation,
		  warehouse.id AS warehouse_id,
		  warehouse.designation AS warehouse_designation,
		  equipmentproduction.quantity,
		  equipmentproduction.cost,
		  STRING_AGG(component.designation, ', ' ORDER BY component.designation) AS components
    FROM equipmentproduction
        JOIN equipment ON equipmentproduction.equipment_id = equipment.id
        JOIN equipmenttype ON equipment.equipment_type_id = equipmenttype.id
		JOIN warehouse ON equipmentproduction.warehouse_id = warehouse.id
		JOIN worktype ON equipmentproduction.work_type_id = worktype.id
		JOIN equipmentproduction_component ON equipmentproduction.id = equipmentproduction_component.equipment_production_id
        JOIN component ON equipmentproduction_component.component_id = component.id
	GROUP BY equipmentproduction.id, equipment.id, worktype.id, warehouse.id;

CREATE OR REPLACE FUNCTION fnGetEquipmentProductionsByEquipmentId(filter_equipment_id INT)
RETURNS TABLE (
    equipment_production_id INT,
    equipment_id INT,
    equipment_designation VARCHAR,
    work_type_id INT,
    work_type_designation VARCHAR,
    warehouse_id INT,
    warehouse_designation VARCHAR,
    quantity INT,
    cost DECIMAL,
    components TEXT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT viewGetEquipmentProductions.*
    FROM viewGetEquipmentProductions
    WHERE viewGetEquipmentProductions.equipment_id = filter_equipment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateEquipmentProduction(
    rec_equipment_id INT,
	rec_worktype_id INT,
	rec_warehouse_id INT,
	rec_quantity INT,
    rec_start_date DATE,
    rec_end_date DATE,
    rec_cost DECIMAL(10, 2),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_equipment_id IS NULL OR rec_equipment_id = 0 THEN
        RAISE EXCEPTION 'Id de equipamento não pode ser vazio';
    ELSIF rec_worktype_id IS NULL OR rec_worktype_id = 0 THEN
        RAISE EXCEPTION 'Id de tipo de mão de obra não pode ser vazio';
    ELSIF rec_warehouse_id IS NULL OR rec_warehouse_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém não pode ser vazio';
    ELSIF rec_quantity IS NULL OR rec_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantidade inválida';
    ELSIF rec_start_date IS NULL THEN
        RAISE EXCEPTION 'Data de início não pode ser vazia';
    ELSIF rec_end_date IS NULL THEN
        RAISE EXCEPTION 'Data de fim não pode ser vazia';
    ELSIF rec_start_date > rec_end_date IS NULL THEN
        RAISE EXCEPTION 'Data de início não pode ser posterior à data de fim';
    ELSE
        INSERT INTO equipmentproduction(equipment_id, work_type_id, warehouse_id, quantity, start_date, end_date, cost, created_by)
        VALUES(rec_equipment_id, rec_worktype_id, rec_warehouse_id, rec_quantity, rec_start_date, rec_end_date, rec_cost, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetLastEquipmentProductionId()
RETURNS INT
AS $$
BEGIN
    RETURN (SELECT currval('equipment_production_id_seq'));
END;
$$ LANGUAGE plpgsql;