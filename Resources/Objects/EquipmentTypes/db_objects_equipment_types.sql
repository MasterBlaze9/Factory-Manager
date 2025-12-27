CREATE OR REPLACE VIEW viewGetEquipmentTypes AS
SELECT equipmenttype.id AS equipment_type_id,
    equipmenttype.designation AS equipmenttype_designation
FROM equipmenttype
WHERE equipmenttype.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetEquipmentTypeById(filter_equipment_type_id INT)
RETURNS TABLE (
	equipment_type_id INT,
	designation VARCHAR(100)
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetEquipmentTypes
	WHERE viewGetEquipmentTypes.equipment_type_id = filter_equipment_type_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateEquipmentType(
    rec_designation VARCHAR(100),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF EXISTS(SELECT designation FROM equipmenttype WHERE designation = rec_designation AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        INSERT INTO equipmenttype(designation, created_by)
        VALUES(rec_designation, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spUpdateEquipmentType(
    equipment_type_id INT,
    rec_designation VARCHAR(100)
)
AS $$
BEGIN
    IF equipment_type_id IS NULL OR equipment_type_id = 0 THEN
        RAISE EXCEPTION 'Id de tipo de equipamento não pode ser vazio';
    ELSIF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF EXISTS(SELECT designation FROM equipmenttype WHERE designation = rec_designation AND id <> equipment_type_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        UPDATE equipmenttype
        SET designation = rec_designation
        WHERE equipmenttype.id = equipment_type_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spSoftDeleteEquipmentType(
    equipment_type_id INT
)
AS $$
BEGIN
    IF equipment_type_id IS NULL OR equipment_type_id = 0 THEN
        RAISE EXCEPTION 'Id de tipo de equipamento não pode ser vazio';
    ELSE
        UPDATE equipmenttype
        SET is_active = FALSE
        WHERE equipmenttype.id = equipment_type_id;
    END IF;
END
$$ LANGUAGE plpgsql;