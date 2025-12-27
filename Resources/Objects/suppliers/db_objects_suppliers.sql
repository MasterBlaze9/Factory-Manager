CREATE OR REPLACE VIEW viewGetSuppliers AS
SELECT supplier.id AS supplier_id,
    supplier.name AS supplier_name,
    supplier.address AS supplier_address,
    supplier.fiscal_number AS supplier_fiscal_number
FROM supplier
WHERE supplier.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetSupplierById(filter_supplier_id INT)
RETURNS TABLE (
	supplier_id INT,
	name VARCHAR(100),
	address VARCHAR(100),
	fiscal_number VARCHAR(9)
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetSuppliers
	WHERE viewGetSuppliers.supplier_id = filter_supplier_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateSupplier(
    rec_name VARCHAR(100),
    rec_address VARCHAR(100),
    rec_fiscal_number VARCHAR(9),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_name IS NULL OR rec_name = '' THEN
        RAISE EXCEPTION 'Nome não pode ser vazio';
    ELSIF rec_address IS NULL OR rec_address = '' THEN
        RAISE EXCEPTION 'Morada não pode ser vazia';
    ELSIF rec_fiscal_number IS NULL OR rec_fiscal_number = '' OR LENGTH(rec_fiscal_number) <> 9 THEN
        RAISE EXCEPTION 'NIF não pode ser nulo e tem de ter exatamente 9 dígitos';
    ELSIF EXISTS(SELECT name FROM supplier WHERE name = rec_name AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Nome "%" já existente', rec_name;
    ELSIF EXISTS(SELECT fiscal_number FROM supplier WHERE fiscal_number = rec_fiscal_number AND is_active = TRUE) THEN
        RAISE EXCEPTION 'NIF "%" já existente', rec_fiscal_number;
    ELSE
        INSERT INTO supplier(name, address, fiscal_number, created_by)
        VALUES(rec_name, rec_address, rec_fiscal_number, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spUpdateSupplier(
    supplier_id INT,
    rec_name VARCHAR(100),
    rec_address VARCHAR(100),
    rec_fiscal_number VARCHAR(9)
)
AS $$
BEGIN
    IF supplier_id IS NULL OR supplier_id = 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
    ELSIF rec_name IS NULL OR rec_name = '' THEN
        RAISE EXCEPTION 'Nome não pode ser vazio';
    ELSIF rec_address IS NULL OR rec_address = '' THEN
        RAISE EXCEPTION 'Morada não pode ser vazia';
    ELSIF rec_fiscal_number IS NULL OR rec_fiscal_number = '' OR LENGTH(rec_fiscal_number) <> 9 THEN
        RAISE EXCEPTION 'NIF não pode ser nulo e tem de ter exatamente 9 dígitos';
    ELSIF EXISTS(SELECT name FROM supplier WHERE name = rec_name AND id <> supplier_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Nome "%" já existente', rec_name;
    ELSIF EXISTS(SELECT fiscal_number FROM supplier WHERE fiscal_number = rec_fiscal_number AND id <> supplier_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'NIF "%" já existente', rec_fiscal_number;
    ELSE
        UPDATE supplier
        SET name = rec_name,
            address = rec_address,
            fiscal_number = rec_fiscal_number
        WHERE supplier.id = supplier_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spSoftDeleteSupplier(
    supplier_id INT
)
AS $$
BEGIN
    IF supplier_id IS NULL OR supplier_id = 0 THEN
        RAISE EXCEPTION 'Id de fornecedor não pode ser vazio';
    ELSE
        UPDATE supplier
        SET is_active = FALSE
        WHERE supplier.id = supplier_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnGetLastSupplierId()
RETURNS INT
AS $$
BEGIN
    RETURN (SELECT currval('supplier_id_seq'));
END;
$$ LANGUAGE plpgsql;