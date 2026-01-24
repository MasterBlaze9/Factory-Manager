-- Function: fnCreateEquipment
-- Inserts a new equipment and returns the new equipment's id

CREATE OR REPLACE FUNCTION fnCreateEquipment(
    p_designation VARCHAR,
    p_description VARCHAR,
    p_equipmenttype_id INTEGER,
    p_price NUMERIC,
    p_created_by INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO equipment (designation, description, equipmenttype_id, price, created_by)
    VALUES (p_designation, p_description, p_equipmenttype_id, p_price, p_created_by)
    RETURNING id INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
