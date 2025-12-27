CREATE OR REPLACE VIEW viewGetComponents AS
SELECT component.id AS component_id,
	component.designation AS designation,
	component.price AS price,
	STRING_AGG(supplier.name, ', '
												ORDER BY supplier.name),
	component.created_on AS created_on
FROM component
LEFT JOIN supplier_component ON component.id = supplier_component.component_id
LEFT JOIN supplier ON supplier_component.supplier_id = supplier.id
GROUP BY component.id
ORDER BY component.id;


CREATE OR REPLACE VIEW viewGetComponentsToOrder AS
SELECT supplier_component.id AS supplier_component_id,
	component.price AS price,
	supplier_component.supplier_id AS supplier_id,
	supplier_component.component_id AS component_id,
	supplier.name AS supplier_name,
	component.designation AS component_designation,
	component.price AS component_price
FROM supplier_component
JOIN supplier ON supplier_component.supplier_id = supplier.id
JOIN component ON supplier_component.component_id = component.id
WHERE component.is_active = TRUE;


CREATE OR REPLACE FUNCTION fnGetComponentByComponentAndSupplier(filter_component_id INT, filter_supplier_id INT) RETURNS TABLE ( component_id INT, component_designation VARCHAR, supplier_id INT, supplier_name VARCHAR, component_price DECIMAL) AS $$
BEGIN
    RETURN QUERY
	SELECT component.id AS component_id,
		component.designation AS component_designation,
		supplier.id AS supplier_id,
		supplier.name AS supplier_name,
		component.price AS component_price
	FROM supplier_component
		JOIN component ON supplier_component.component_id = component.id
		JOIN supplier ON supplier_component.supplier_id = supplier.id
	WHERE component.id = filter_component_id AND supplier.id = filter_supplier_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spCreateComponent( rec_designation VARCHAR(100), rec_price DECIMAL, rec_created_by INT) AS $$
BEGIN
    IF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_price IS NULL OR rec_price <= 0 THEN
        RAISE EXCEPTION 'Preço inválido';
    ELSIF EXISTS(SELECT designation FROM component WHERE designation = rec_designation AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        INSERT INTO component(designation, price, created_by)
        VALUES (rec_designation, rec_price, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spUpdateComponent( component_id INT, rec_designation VARCHAR(100), rec_price DECIMAL) AS $$
BEGIN
	IF component_id IS NULL OR component_id = 0 THEN
        RAISE EXCEPTION 'Id de componente não pode ser vazio';
    ELSIF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_price IS NULL OR rec_price <= 0 THEN
        RAISE EXCEPTION 'Preço inválido';
    ELSIF EXISTS(SELECT designation FROM component WHERE designation = rec_designation AND id <> component_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        UPDATE component
		SET designation = rec_designation, price = rec_price
		WHERE id = component_id;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spSoftDeleteComponent(component_id INT) AS $$
BEGIN
    IF component_id IS NULL OR component_id = 0 THEN
        RAISE EXCEPTION 'Id de componente não pode ser vazio';
    ELSE
        UPDATE component
		SET is_active = FALSE
		WHERE id = component_id;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spImportComponents_JSON(json JSON, imported_by INT) AS $$
DECLARE
    json_component_data JSON;
    json_component_designation TEXT;
    json_component_price DECIMAL;
    json_component_supplier_name TEXT;
	existing_supplier_id INT;
	existing_component_id INT;
	created_component_id INT;
BEGIN
    FOR json_component_data IN (SELECT * FROM json_array_elements(json))
    LOOP
        json_component_designation := json_component_data->>'designation';
		json_component_price := (json_component_data->>'price')::DECIMAL;
		json_component_supplier_name := json_component_data->>'supplier_name';

		IF json_component_designation IS NULL OR json_component_price IS NULL OR json_component_supplier_name IS NULL THEN
			RAISE EXCEPTION 'O JSON fornecido para importar componentes é inválido';
		ELSIF json_component_price IS NULL OR json_component_price <= 0 THEN
            RAISE EXCEPTION 'O Preço "%" é inválido', json_component_price;
		ELSIF NOT EXISTS (SELECT 1 FROM supplier WHERE name = json_component_supplier_name) THEN
			RAISE EXCEPTION 'O Fornecedor "%" é inválido', json_component_supplier_name;
        ELSE
			SELECT supplier.id
			INTO existing_supplier_id
			FROM supplier
			WHERE supplier.name = json_component_supplier_name;

			IF EXISTS(
				SELECT 1
				FROM component
					JOIN supplier_component ON component.id = supplier_component.component_id
				WHERE component.designation = json_component_designation AND supplier_component.supplier_id = existing_supplier_id
			) THEN
            	RAISE EXCEPTION 'O Fornecedor "%" já possui o Componente "%"', json_component_supplier_name, json_component_designation;
			ELSE
				IF EXISTS(
					SELECT 1
					FROM component
					WHERE designation = json_component_designation
				) THEN
					SELECT component.id
					INTO existing_component_id
					FROM component
					WHERE component.designation = json_component_designation;

					INSERT INTO supplier_component(supplier_id, component_id, created_by)
					VALUES(existing_supplier_id, existing_component_id, imported_by);
				ELSE
					INSERT INTO component(designation, price, created_by)
					VALUES(json_component_designation, json_component_price, imported_by)
					RETURNING id INTO created_component_id;

					INSERT INTO supplier_component(supplier_id, component_id, created_by)
					VALUES(existing_supplier_id, created_component_id, imported_by);
				END IF;
        	END IF;
		END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fnExportComponents_JSON() RETURNS JSON AS $$
DECLARE components_json JSON;
BEGIN
	SELECT JSON_AGG(JSON_BUILD_OBJECT(
		'designation', viewGetComponentsToOrder.component_designation,
		'price', viewGetComponentsToOrder.component_price,
		'supplier_name', viewGetComponentsToOrder.supplier_name
	))
	INTO components_json
	FROM viewGetComponentsToOrder;

	RETURN components_json;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spImportComponents_XML(xml_data XML, imported_by INT) AS $$
DECLARE
    xml_component_data XML;
    xml_component_designation TEXT;
    xml_component_price DECIMAL;
    xml_component_supplier_name TEXT;
	existing_supplier_id INT;
	existing_component_id INT;
	created_component_id INT;
BEGIN
    FOR xml_component_data IN (SELECT unnest(xpath('/components/component', xml_data)))
    LOOP
		xml_component_designation := (xpath('./component/designation/text()', xml_component_data))[1]::TEXT;
        xml_component_price := (xpath('./component/price/text()', xml_component_data))[1]::TEXT::DECIMAL;
        xml_component_supplier_name := (xpath('./component/supplier_name/text()', xml_component_data))[1]::TEXT;

        IF xml_component_designation IS NULL OR xml_component_price IS NULL OR xml_component_supplier_name IS NULL THEN
			RAISE EXCEPTION 'O XML fornecido para importar componentes é inválido';
		ELSIF xml_component_price IS NULL OR xml_component_price <= 0 THEN
            RAISE EXCEPTION 'O Preço "%" é inválido', xml_component_price;
		ELSIF NOT EXISTS (SELECT 1 FROM supplier WHERE name = xml_component_supplier_name) THEN
			RAISE EXCEPTION 'O Fornecedor "%" é inválido', xml_component_supplier_name;
        ELSE
			SELECT supplier.id
			INTO existing_supplier_id
			FROM supplier
			WHERE supplier.name = xml_component_supplier_name;

			IF EXISTS(
				SELECT 1
				FROM component
					JOIN supplier_component ON component.id = supplier_component.component_id
				WHERE component.designation = xml_component_designation AND supplier_component.supplier_id = existing_supplier_id
			) THEN
            	RAISE EXCEPTION 'O Fornecedor "%" já possui o Componente "%"', xml_component_supplier_name, xml_component_designation;
			ELSE
				IF EXISTS(
					SELECT 1
					FROM component
					WHERE designation = xml_component_designation
				) THEN
					SELECT component.id
					INTO existing_component_id
					FROM component
					WHERE component.designation = xml_component_designation;

					INSERT INTO supplier_component(supplier_id, component_id, created_by)
					VALUES(existing_supplier_id, existing_component_id, imported_by);
				ELSE
					INSERT INTO component(designation, price, created_by)
					VALUES(xml_component_designation, xml_component_price, imported_by)
					RETURNING id INTO created_component_id;

					INSERT INTO supplier_component(supplier_id, component_id, created_by)
					VALUES(existing_supplier_id, created_component_id, imported_by);
				END IF;
        	END IF;
		END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fnExportComponents_XML() RETURNS XML AS $$
DECLARE components_xml XML;
BEGIN
	SELECT XMLELEMENT(
        NAME "components",
        XMLAGG(
            XMLELEMENT(
                NAME "component",
                XMLFOREST(
                    viewGetComponentsToOrder.component_designation AS "designation",
                    viewGetComponentsToOrder.component_price AS "price",
                    viewGetComponentsToOrder.supplier_name AS "supplier_name"
                )
            )
        )
    )
	INTO components_xml
	FROM viewGetComponentsToOrder;

	RETURN components_xml;
END;
$$ LANGUAGE plpgsql;