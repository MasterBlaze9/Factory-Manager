INSERT INTO Component (designation, price, created_by)
VALUES
    ('Component X', 50.00, 1),
    ('Component Y', 75.00, 2),
    ('Component Z', 100.00, 7);

INSERT INTO Supplier (name, address, fiscal_number, created_by)
VALUES
    ('Supplier 1', '101 Supplier St', '123-456-789', 1),
    ('Supplier 2', '202 Provider Ave', '987-654-321', 2),
    ('Supplier 3', '303 Vendor Blvd', '456-789-123', 7);

INSERT INTO Supplier_Component (supplier_id, component_id, created_by)
VALUES
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 7);