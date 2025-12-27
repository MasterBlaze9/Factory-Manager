CREATE OR REPLACE VIEW viewGetWarehouses AS
SELECT warehouse.id AS warehouse_id,
    warehouse.designation AS warehouse_designation,
    warehouse.address AS warehouse_address
FROM warehouse
WHERE warehouse.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetWarehouseById(filter_warehouse_id INT)
RETURNS TABLE (
	warehouse_id INT,
	designation VARCHAR(100),
	address VARCHAR(100)
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetWarehouses
	WHERE viewGetWarehouses.warehouse_id = filter_warehouse_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateWarehouse(
    rec_designation VARCHAR(100),
    rec_address VARCHAR(100),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_address IS NULL OR rec_address = '' THEN
        RAISE EXCEPTION 'Morada não pode ser vazia';
    ELSIF EXISTS(SELECT designation FROM warehouse WHERE designation = rec_designation AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        INSERT INTO warehouse(designation, address, created_by)
        VALUES(rec_designation, rec_address, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spUpdateWarehouse(
    warehouse_id INT,
    rec_designation VARCHAR(100),
    rec_address VARCHAR(100)
)
AS $$
BEGIN
    IF warehouse_id IS NULL OR warehouse_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém não pode ser vazio';
    ELSIF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_address IS NULL OR rec_address = '' THEN
        RAISE EXCEPTION 'Morada não pode ser vazia';
    ELSIF EXISTS(SELECT designation FROM warehouse WHERE designation = rec_designation) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        UPDATE warehouse
        SET designation = rec_designation,
            address = rec_address
        WHERE warehouse.id = warehouse_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spSoftDeleteWarehouse(
    warehouse_id INT
)
AS $$
BEGIN
    IF warehouse_id IS NULL OR warehouse_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém não pode ser vazio';
    ELSE
        UPDATE warehouse
        SET is_active = FALSE
        WHERE warehouse.id = warehouse_id;
    END IF;
END
$$ LANGUAGE plpgsql;

-- Test calls
-- Call to spCreateWarehouse (succeeds)
CALL spCreateWarehouse('Designation 1', 'Address 1', 1);

-- Call to spCreateWarehouse (fails)
CALL spCreateWarehouse('', 'Address 2', 1);

-- Call to spUpdateWarehouse (succeeds)
CALL spUpdateWarehouse(1, 'New Designation', 'New Address');

-- Call to spUpdateWarehouse (fails)
CALL spUpdateWarehouse(0, 'New Designation', 'New Address');

-- Call to spSoftDeleteWarehouse (succeeds)
CALL spSoftDeleteWarehouse(1);

-- Call to spSoftDeleteWarehouse (fails)
CALL spSoftDeleteWarehouse(0);