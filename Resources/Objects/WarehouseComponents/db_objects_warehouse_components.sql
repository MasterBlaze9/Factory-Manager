CREATE OR REPLACE VIEW viewGetWarehouseComponents
AS
    SELECT warehouse_component.id AS warehouse_component_id,
        component.id AS component_id,
		component.designation AS component_designation,
		supplier.id AS supplier_id,
		supplier.name AS supplier_name,
		warehouse.id AS warehouse_id,
		warehouse.designation AS warehouse_designation,
        warehouse_component.stock AS warehouse_stock,
        warehouse_component.unit_price AS unit_price
    FROM warehouse_component
		JOIN component ON warehouse_component.component_id = component.id
		JOIN supplier ON warehouse_component.supplier_id = supplier.id
		JOIN warehouse ON warehouse_component.warehouse_id = warehouse.id;

CREATE OR REPLACE FUNCTION fnGetWarehouseComponentsById(filter_warehouse_component_id INT)
RETURNS TABLE (
    warehouse_component_id INT,
    component_id INT,
    component_designation VARCHAR(255),
    supplier_id INT,
    supplier_name VARCHAR(255),
    warehouse_id INT,
    warehouse_designation VARCHAR(255),
    warehouse_stock INT,
    unit_price DECIMAL(10, 2)
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetWarehouseComponents
	WHERE viewGetWarehouseComponents.warehouse_component_id = filter_warehouse_component_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetWarehouseComponentsByIdsList(ids TEXT)
RETURNS TABLE (
    warehouse_component_id INT,
    component_id INT,
    component_designation VARCHAR(255),
    supplier_id INT,
    supplier_name VARCHAR(255),
    warehouse_id INT,
    warehouse_designation VARCHAR(255),
    warehouse_stock INT,
    unit_price DECIMAL(10, 2)
) 
AS $$
DECLARE
    id_list INT[];
BEGIN
    id_list := string_to_array(ids, ','::TEXT)::INT[];
	
    RETURN QUERY
	SELECT *
    FROM viewGetWarehouseComponents
	WHERE viewGetWarehouseComponents.warehouse_component_id = ANY(id_list);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetWarehouseComponentsByComponentSupplierAndWarehouse(filter_component_id INT, filter_supplier_id INT, filter_warehouse_id INT)
RETURNS TABLE (
    warehouse_component_id INT,
    component_id INT,
    component_designation VARCHAR(255),
    supplier_id INT,
    supplier_name VARCHAR(255),
    warehouse_id INT,
    warehouse_designation VARCHAR(255),
    warehouse_stock INT,
    unit_price DECIMAL(10, 2)
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetWarehouseComponents
	WHERE viewGetWarehouseComponents.component_id = filter_component_id
        AND viewGetWarehouseComponents.supplier_id = filter_supplier_id
        AND viewGetWarehouseComponents.warehouse_id = filter_warehouse_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateWarehouseComponent(
    rec_component_id INT,
	rec_supplier_id INT,
	rec_warehouse_id INT,
	rec_stock INT,
    rec_unit_price DECIMAL(10, 2),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_component_id IS NULL OR rec_component_id = 0 THEN
        RAISE EXCEPTION 'Id de componente não pode ser vazio';
    ELSIF rec_supplier_id IS NULL OR rec_supplier_id = 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
    ELSIF rec_warehouse_id IS NULL OR rec_warehouse_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém não pode ser vazio';
    ELSIF rec_stock IS NULL OR rec_stock <= 0 THEN
        RAISE EXCEPTION 'Stock não pode ser vazio';
    ELSIF rec_unit_price IS NULL OR rec_unit_price <= 0 THEN
        RAISE EXCEPTION 'Preço unitário não pode ser vazio';
    ELSIF EXISTS(
			SELECT id
			FROM warehouse_component
			WHERE component_id = rec_component_id AND supplier_id = rec_supplier_id AND warehouse_id = rec_warehouse_id
	) THEN
        RAISE EXCEPTION 'Registo já existente';
    ELSE
        INSERT INTO warehouse_component(component_id, supplier_id, warehouse_id, stock, unit_price, created_by)
        VALUES(rec_component_id, rec_supplier_id, rec_warehouse_id, rec_stock, rec_unit_price, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spUpdateWarehouseComponentStock(
	warehouse_component_id INT,
	rec_stock INT
)
AS $$
DECLARE current_stock INT;
BEGIN
	IF warehouse_component_id IS NULL OR warehouse_component_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém_componente não pode ser vazio';
    ELSIF rec_stock IS NULL OR rec_stock <= 0 THEN
        RAISE EXCEPTION 'Stock não pode ser vazio';
    ELSE
        SELECT stock
        INTO current_stock
        FROM warehouse_component
        WHERE id = warehouse_component_id;

        UPDATE warehouse_component
		SET stock = current_stock + rec_stock
        WHERE id = warehouse_component_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spDeleteWarehouseComponent(
    warehouse_component_id INT
)
AS $$
BEGIN
    IF warehouse_component_id IS NULL OR warehouse_component_id = 0 THEN
        RAISE EXCEPTION 'Id de armazém_componente não pode ser vazio';
    ELSE
        DELETE FROM warehouse_component
        WHERE id = warehouse_component_id;
    END IF;
END;
$$ LANGUAGE plpgsql;