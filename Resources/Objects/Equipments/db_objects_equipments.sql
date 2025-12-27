CREATE OR REPLACE VIEW viewGetEquipments
AS
	SELECT equipment.id AS equipment_id,
		equipment.designation AS equipment_designation,
		equipment.description AS equipment_description,
		equipmenttype.id AS equipment_type_id,
		equipmenttype.designation AS equipment_type,
		equipment.price AS equipment_price
	FROM equipment
		JOIN equipmenttype ON equipment.equipment_type_id = equipmenttype.id
	WHERE equipment.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetEquipmentById(filter_equipment_id INT)
RETURNS TABLE (
	equipment_id INT,
	designation VARCHAR(100),
	description VARCHAR(500),
	equipment_type_id INT,
	equipment_type VARCHAR(100),
    price DECIMAL
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetEquipments
	WHERE viewGetEquipments.equipment_id = filter_equipment_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW viewGetEquipmentsToOrder
AS
    SELECT equipment.id AS equipment_id,
        equipment.designation AS equipment_designation,
        equipment.description AS equipment_description,
        equipmenttype.id AS equipment_type_id,
        equipmenttype.designation AS equipment_type,
        equipment.price AS equipment_price,
        equipmentproduction.id AS equipment_production_id,
        equipmentproduction.quantity AS equipment_quantity,
        STRING_AGG(component.designation, ', ' ORDER BY component.designation) AS components
    FROM equipment
        JOIN equipmenttype ON equipment.equipment_type_id = equipmenttype.id
        JOIN equipmentproduction ON equipment.id = equipmentproduction.equipment_id
		JOIN equipmentproduction_component ON equipmentproduction.id = equipmentproduction_component.equipment_production_id
        JOIN component ON equipmentproduction_component.component_id = component.id
    WHERE equipment.is_active = TRUE AND equipmentproduction.quantity > 0
	GROUP BY equipment.id, equipmenttype.id, equipmentproduction.id, equipmentproduction.quantity;

CREATE OR REPLACE FUNCTION fnGetEquipmentsByProductionIdsList(ids TEXT)
RETURNS TABLE (
    equipment_id INT,
    designation VARCHAR(100),
    description VARCHAR(500),
    equipment_type_id INT,
    equipment_type VARCHAR(100),
    price DECIMAL,
    equipment_production_id INT,
    equipment_quantity INT,
    components TEXT
) 
AS $$
DECLARE
    id_list INT[];
BEGIN
    id_list := string_to_array(ids, ','::TEXT)::INT[];
	
    RETURN QUERY
	SELECT *
    FROM viewGetEquipmentsToOrder
	WHERE viewGetEquipmentsToOrder.equipment_production_id = ANY(id_list);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateEquipment(
    rec_designation VARCHAR(100),
	rec_description VARCHAR(500),
	rec_equipment_type_id INT,
    rec_price DECIMAL(10, 2),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_description IS NULL OR rec_description = '' THEN
        RAISE EXCEPTION 'Descrição não pode ser vazia';
    ELSIF rec_equipment_type_id IS NULL OR rec_equipment_type_id = 0 THEN
        RAISE EXCEPTION 'Tipo de equipamento não pode ser vazio';
    ELSIF rec_price IS NULL OR rec_price <= 0 THEN
        RAISE EXCEPTION 'Preço inválido';
    ELSIF EXISTS(SELECT designation FROM equipment WHERE designation = rec_designation AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        INSERT INTO equipment(designation, description, equipment_type_id, price, created_by)
        VALUES(rec_designation, rec_description, rec_equipment_type_id, rec_price, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spUpdateEquipment(
    equipment_id INT,
    rec_designation VARCHAR(100),
	rec_description VARCHAR(500),
	rec_equipment_type_id INT,
    rec_price DECIMAL(10, 2)
)
AS $$
BEGIN
    IF equipment_id IS NULL OR equipment_id = 0 THEN
        RAISE EXCEPTION 'Id de equipamento não pode ser vazio';
    ELSIF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_description IS NULL OR rec_description = '' THEN
        RAISE EXCEPTION 'Descrição não pode ser vazia';
    ELSIF rec_equipment_type_id IS NULL OR rec_equipment_type_id = 0 THEN
        RAISE EXCEPTION 'Tipo de equipamento não pode ser vazio';
    ELSIF rec_price IS NULL OR rec_price <= 0 THEN
        RAISE EXCEPTION 'Preço inválido';
    ELSIF EXISTS(SELECT designation FROM equipment WHERE designation = rec_designation AND id <> equipment_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        UPDATE equipment
        SET designation = rec_designation,
            description = rec_description,
            equipment_type_id = rec_equipment_type_id,
            price = rec_price
        WHERE equipment.id = equipment_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spSoftDeleteEquipment(
    equipment_id INT
)
AS $$
BEGIN
    IF equipment_id IS NULL OR equipment_id = 0 THEN
        RAISE EXCEPTION 'Id de equipamento não pode ser vazio';
    ELSE
        UPDATE equipment
        SET is_active = FALSE
        WHERE equipment.id = equipment_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetLastEquipmentId()
RETURNS INT
AS $$
BEGIN
    RETURN (SELECT currval('equipment_id_seq'));
END;
$$ LANGUAGE plpgsql;