BEGIN;

-- Merge duplicate suppliers by name: keep the lowest id and remap FKs
DO $$
DECLARE
  r RECORD;
  dup_id INT;
BEGIN
  FOR r IN
    SELECT name, min(id) AS keep_id, array_agg(id ORDER BY id) AS ids
    FROM supplier
    GROUP BY name
    HAVING count(*) > 1
  LOOP
    FOREACH dup_id IN ARRAY r.ids LOOP
      IF dup_id <> r.keep_id THEN
        RAISE NOTICE 'Remapping supplier % -> % for fk references', dup_id, r.keep_id;
        UPDATE supplier_component SET supplier_id = r.keep_id WHERE supplier_id = dup_id;
        UPDATE warehouse_component SET supplier_id = r.keep_id WHERE supplier_id = dup_id;
        UPDATE order_component SET supplier_id = r.keep_id WHERE supplier_id = dup_id;
        UPDATE orderdelivery_component SET supplier_id = r.keep_id WHERE supplier_id = dup_id;
        UPDATE equipmentproduction_component SET supplier_id = r.keep_id WHERE supplier_id = dup_id;
        DELETE FROM supplier WHERE id = dup_id;
      END IF;
    END LOOP;
  END LOOP;
END$$;

-- Merge duplicate components by designation: keep the lowest id and remap FKs
DO $$
DECLARE
  r RECORD;
  dup_id INT;
BEGIN
  FOR r IN
    SELECT designation, min(id) AS keep_id, array_agg(id ORDER BY id) AS ids
    FROM component
    GROUP BY designation
    HAVING count(*) > 1
  LOOP
    FOREACH dup_id IN ARRAY r.ids LOOP
      IF dup_id <> r.keep_id THEN
        RAISE NOTICE 'Remapping component % -> % for fk references', dup_id, r.keep_id;
        UPDATE supplier_component SET component_id = r.keep_id WHERE component_id = dup_id;
        UPDATE warehouse_component SET component_id = r.keep_id WHERE component_id = dup_id;
        UPDATE order_component SET component_id = r.keep_id WHERE component_id = dup_id;
        UPDATE orderdelivery_component SET component_id = r.keep_id WHERE component_id = dup_id;
        UPDATE equipmentproduction_component SET component_id = r.keep_id WHERE component_id = dup_id;
        DELETE FROM component WHERE id = dup_id;
      END IF;
    END LOOP;
  END LOOP;
END$$;

-- Remove duplicate rows in supplier_component (same supplier_id & component_id)
DELETE FROM supplier_component a
USING supplier_component b
WHERE a.ctid < b.ctid
  AND a.supplier_id = b.supplier_id
  AND a.component_id = b.component_id;

COMMIT;
