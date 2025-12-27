CREATE OR REPLACE FUNCTION fnGetComponentsToBeSelected_SupplierBySupplierId(filter_supplier_id INT)
RETURNS TABLE (
    component_id INT,
    component_designation VARCHAR(100),
    is_selected BOOLEAN
)
AS $$
BEGIN
    RETURN QUERY
	SELECT comp.id AS component_id,
		comp.designation AS component_designation,
		EXISTS (
			SELECT supplier_component.component_id
			FROM supplier_component
			WHERE supplier_component.component_id = comp.id AND supplier_component.supplier_id = filter_supplier_id
		) AS is_selected
    FROM component comp
    WHERE comp.is_active = TRUE
	ORDER BY comp.designation;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateSupplierComponent(
    rec_supplier_id INT,
    rec_component_id INT,
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_supplier_id IS NULL OR rec_supplier_id = 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
    ELSIF rec_component_id IS NULL OR rec_component_id = 0 THEN
        RAISE EXCEPTION 'Id de componente não pode ser vazio';
    ELSE
        INSERT INTO supplier_component (supplier_id, component_id, created_by)
        VALUES (rec_supplier_id, rec_component_id, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spDeleteSupplierComponentsBySupplierId(
    filter_supplier_id INT
)
AS $$
BEGIN
    IF filter_supplier_id IS NULL OR filter_supplier_id = 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
    ELSE
        DELETE FROM supplier_component
        WHERE supplier_component.supplier_id = filter_supplier_id;
    END IF;
END
$$ LANGUAGE plpgsql;