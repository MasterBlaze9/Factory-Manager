CREATE OR REPLACE VIEW viewGetClients AS
SELECT client.id AS client_id,
    client.name AS client_name,
    client.address AS client_address
FROM client
WHERE client.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetClientById(filter_client_id INT)
RETURNS TABLE (
	client_id INT,
	name VARCHAR(100),
	address VARCHAR(100)
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetClients
	WHERE viewGetClients.client_id = filter_client_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateClient(
    rec_name VARCHAR(100),
    rec_address VARCHAR(100),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_name IS NULL OR rec_name = '' THEN
        RAISE EXCEPTION 'Nome não pode ser vazio';
    ELSIF rec_address IS NULL OR rec_address = '' THEN
        RAISE EXCEPTION 'Morada não pode ser vazia';
    ELSIF EXISTS(SELECT name FROM client WHERE name = rec_name AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Nome "%" já existente', rec_name;
    ELSE
        INSERT INTO client(name, address, created_by)
        VALUES(rec_name, rec_address, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE spUpdateClient(
    client_id INT,
    rec_name VARCHAR(100),
    rec_address VARCHAR(100)
)
AS $$
BEGIN
    IF client_id IS NULL OR client_id = 0 THEN
        RAISE EXCEPTION 'Id de cliente não pode ser vazio';
    ELSIF rec_name IS NULL OR rec_name = '' THEN
        RAISE EXCEPTION 'Nome não pode ser vazio';
    ELSIF rec_address IS NULL OR rec_address = '' THEN
        RAISE EXCEPTION 'Morada não pode ser vazia';
    ELSIF EXISTS(SELECT name FROM client WHERE name = rec_name AND id <> client_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Nome "%" já existente', rec_name;
    ELSE
        UPDATE client
        SET name = rec_name,
            address = rec_address
        WHERE client.id = client_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spSoftDeleteClient(
    client_id INT
)
AS $$
BEGIN
    IF client_id IS NULL OR client_id = 0 THEN
        RAISE EXCEPTION 'Id de cliente não pode ser vazio';
    ELSE
        UPDATE client
        SET is_active = FALSE
        WHERE client.id = client_id;
    END IF;
END
$$ LANGUAGE plpgsql;