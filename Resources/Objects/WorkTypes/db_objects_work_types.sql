CREATE OR REPLACE VIEW viewGetWorkTypes AS
SELECT worktype.id AS work_type_id,
    worktype.designation AS worktype_designation,
    worktype.cost AS worktype_cost
FROM worktype
WHERE worktype.is_active = TRUE;

CREATE OR REPLACE FUNCTION fnGetWorkTypeById(filter_work_type_id INT)
RETURNS TABLE (
	work_type_id INT,
	designation VARCHAR(100),
    cost DECIMAL(10, 2)
) 
AS $$
BEGIN
    RETURN QUERY
	SELECT *
    FROM viewGetWorkTypes
	WHERE viewGetWorkTypes.work_type_id = filter_work_type_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spCreateWorkType(
    rec_designation VARCHAR(100),
    rec_cost DECIMAL(10, 2),
    rec_created_by INT
)
AS $$
BEGIN
    IF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_cost IS NULL OR rec_cost = 0 THEN
        RAISE EXCEPTION 'Custo não pode ser vazio';
    ELSIF EXISTS(SELECT designation FROM worktype WHERE designation = rec_designation AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        INSERT INTO worktype(designation, cost, created_by)
        VALUES(rec_designation, rec_cost, rec_created_by);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spUpdateWorkType(
    work_type_id INT,
    rec_designation VARCHAR(100),
    rec_cost DECIMAL(10, 2)
)
AS $$
BEGIN
    IF work_type_id IS NULL OR work_type_id = 0 THEN
        RAISE EXCEPTION 'Id de mão de obra não pode ser vazio';
    ELSIF rec_designation IS NULL OR rec_designation = '' THEN
        RAISE EXCEPTION 'Designação não pode ser vazia';
    ELSIF rec_cost IS NULL OR rec_cost = 0 THEN
        RAISE EXCEPTION 'Custo não pode ser vazio';
    ELSIF EXISTS(SELECT designation FROM worktype WHERE designation = rec_designation AND id <> work_type_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Designação "%" já existente', rec_designation;
    ELSE
        UPDATE worktype
        SET designation = rec_designation,
            cost = rec_cost
        WHERE worktype.id = work_type_id;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE spSoftDeleteWorkType(
    work_type_id INT
)
AS $$
BEGIN
    IF work_type_id IS NULL OR work_type_id = 0 THEN
        RAISE EXCEPTION 'Id de mão de obra não pode ser vazio';
    ELSE
        UPDATE worktype
        SET is_active = FALSE
        WHERE worktype.id = work_type_id;
    END IF;
END
$$ LANGUAGE plpgsql;