DELETE FROM ClientOrderDelivery_Equipment;
DELETE FROM ClientOrderInvoice;
DELETE FROM ClientOrderDelivery;
DELETE FROM ClientOrder_Equipment;
DELETE FROM ClientOrder;
DELETE FROM Client;
DELETE FROM EquipmentProduction_Component;
DELETE FROM EquipmentProduction;
DELETE FROM WorkType;
DELETE FROM Equipment;
DELETE FROM EquipmentType;
DELETE FROM OrderDelivery_Component;
DELETE FROM OrderInvoice;
DELETE FROM OrderDelivery;
DELETE FROM Order_Component;
DELETE FROM Orders;
DELETE FROM Warehouse_Component;
DELETE FROM Supplier_Component;
DELETE FROM Supplier;
DELETE FROM Component;
DELETE FROM Warehouse;

ALTER SEQUENCE warehouse_id_seq RESTART WITH 1;
ALTER SEQUENCE component_id_seq RESTART WITH 1;
ALTER SEQUENCE supplier_id_seq RESTART WITH 1;
ALTER SEQUENCE supplier_component_id_seq RESTART WITH 1;
ALTER SEQUENCE warehouse_component_id_seq RESTART WITH 1;
ALTER SEQUENCE orders_id_seq RESTART WITH 1;
ALTER SEQUENCE order_component_id_seq RESTART WITH 1;
ALTER SEQUENCE order_delivery_id_seq RESTART WITH 1;
ALTER SEQUENCE order_invoice_id_seq RESTART WITH 1;
ALTER SEQUENCE order_delivery_component_id_seq RESTART WITH 1;
ALTER SEQUENCE equipment_type_id_seq RESTART WITH 1;
ALTER SEQUENCE equipment_id_seq RESTART WITH 1;
ALTER SEQUENCE work_type_id_seq RESTART WITH 1;
ALTER SEQUENCE equipment_production_id_seq RESTART WITH 1;
ALTER SEQUENCE equipment_production_component_id_seq RESTART WITH 1;
ALTER SEQUENCE client_id_seq RESTART WITH 1;
ALTER SEQUENCE client_order_id_seq RESTART WITH 1;
ALTER SEQUENCE client_order_equipment_id_seq RESTART WITH 1;
ALTER SEQUENCE client_order_delivery_id_seq RESTART WITH 1;
ALTER SEQUENCE client_order_invoice_id_seq RESTART WITH 1;
ALTER SEQUENCE client_order_delivery_equipment_id_seq RESTART WITH 1;

INSERT INTO Warehouse (designation, address, created_by)
VALUES ('Armazém do Norte', 'Rua do Armazém do Norte', 1)
    , ('Armazém do Sul', 'Rua do Armazém do Sul', 1)
    , ('Armazém do Este', 'Rua do Armazém do Este', 1)
    , ('Armazém do Oeste', 'Rua do Armazém do Oeste', 1);

INSERT INTO Component (designation, price, created_by)
VALUES ('SSD Samsung EVO 860 500GB', 100.00, 1)
    , ('SSD Samsung EVO 860 1TB', 200.00, 1)
    , ('Nvidia RTX 2080 6GB', 800.00, 1)
    , ('Processador Intel i9 9900K', 500.00, 1);

INSERT INTO Supplier (name, address, fiscal_number, created_by)
VALUES ('PcComponentes', 'Rua do PcComponentes', '123456789', 1)
    , ('GlobalData', 'Rua do GlobalData', '987654321', 1)
    , ('PcDiga', 'Rua do PcDiga', '123456789', 1)
    , ('PcGuia', 'Rua do PcGuia', '987654321', 1);

INSERT INTO Supplier_Component (supplier_id, component_id, created_by)
VALUES (1, 1, 1)
    , (1, 2, 1)
    , (2, 3, 1)
    , (2, 4, 1);

INSERT INTO Orders (order_number, ordered_by, ordered_on, created_by)
VALUES ('ENCC001', 1, '2024-02-09', 1)
, ('ENCC002', 1, '2024-02-09', 1)
, ('ENCC003', 1, '2024-02-09', 1);

INSERT INTO Order_Component (order_id, component_id, supplier_id, quantity, unit_price, created_by)
VALUES (1, 1, 1, 10, 100.00, 1)
    , (1, 2, 1, 5, 200.00, 1)
    , (2, 3, 2, 2, 800.00, 1)
    , (2, 4, 2, 1, 500.00, 1);

INSERT INTO OrderDelivery (order_id, created_by)
VALUES (1, 1)
    , (2, 1);

INSERT INTO OrderInvoice (invoice_number, invoice_date, created_by)
VALUES ('FAT_ENCC001', '2024-02-09', 1)
    , ('FAT_ENCC002', '2024-02-09', 1);

INSERT INTO OrderDelivery_Component (order_delivery_id, component_id, supplier_id, warehouse_id, order_invoice_id, delivered_quantity, delivered_date, created_by)
VALUES (1, 1, 1, 1, 1, 10, '2024-02-09', 1)
    , (1, 2, 1, 1, 1, 5, '2024-02-09', 1)
    , (2, 3, 2, 2, 2, 2, '2024-02-09', 1)
    , (2, 4, 2, 2, 2, 1, '2024-02-09', 1);

INSERT INTO Warehouse_Component (component_id, supplier_id, warehouse_id, stock, unit_price, created_by)
VALUES (1, 1, 1, 100, 100.00, 1)
    , (2, 1, 1, 50, 200.00, 1)
    , (3, 2, 2, 10, 800.00, 1)
    , (4, 2, 2, 5, 500.00, 1);

INSERT INTO EquipmentType (designation, created_by)
VALUES ('Computador', 1)
    , ('Portátil', 1)
    , ('Telemóvel', 1)
    , ('Tablet', 1);

INSERT INTO Equipment (designation, description, equipment_type_id, price, created_by)
VALUES ('Computador Desktop', 'Computador Desktop', 1, 1000.00, 1)
    , ('Portátil', 'Portátil', 2, 800.00, 1)
    , ('Telemóvel', 'Telemóvel', 3, 500.00, 1)
    , ('Tablet', 'Tablet', 4, 300.00, 1);

INSERT INTO WorkType (designation, cost, created_by)
VALUES ('Montagem', 100.00, 1)
    , ('Manutenção', 50.00, 1)
    , ('Reparação', 75.00, 1)
    , ('Limpeza', 25.00, 1);

INSERT INTO EquipmentProduction (equipment_id, work_type_id, warehouse_id, quantity, cost, start_date, created_by)
VALUES (1, 1, 1, 10, 1000.00, '2024-02-09', 1)
    , (2, 1, 1, 5, 800.00, '2024-02-09', 1)
    , (3, 1, 1, 2, 500.00, '2024-02-09', 1)
    , (4, 1, 1, 1, 300.00, '2024-02-09', 1);

INSERT INTO EquipmentProduction_Component (equipment_production_id, component_id, supplier_id, warehouse_id, quantity, created_by)
VALUES (1, 1, 1, 1, 10, 1)
    , (1, 2, 1, 1, 5, 1)
    , (2, 3, 2, 2, 2, 1)
    , (2, 4, 2, 2, 1, 1);

INSERT INTO Client (name, address, created_by)
VALUES ('Cliente 1', 'Rua do Cliente 1', 1)
    , ('Cliente 2', 'Rua do Cliente 2', 1)
    , ('Cliente 3', 'Rua do Cliente 3', 1)
    , ('Cliente 4', 'Rua do Cliente 4', 1);

INSERT INTO ClientOrder (client_order_number, client_id, ordered_by, ordered_on, created_by)
VALUES ('CLTENCC001', 1, 1, '2024-02-09', 1)
    , ('CLTENCC002', 2, 1, '2024-02-09', 1)
    , ('CLTENCC003', 3, 1, '2024-02-09', 1)
    , ('CLTENCC004', 4, 1, '2024-02-09', 1);

INSERT INTO ClientOrder_Equipment (client_order_id, equipment_id, equipment_production_id, quantity, unit_price, created_by)
VALUES (1, 1, 1, 10, 1000.00, 1)
    , (1, 2, 1, 5, 800.00, 1)
    , (2, 3, 1, 2, 500.00, 1)
    , (2, 4, 1, 1, 300.00, 1);

INSERT INTO ClientOrderDelivery (client_order_id, created_by)
VALUES (1, 1)
    , (2, 1);

INSERT INTO ClientOrderInvoice (invoice_number, invoice_date, created_by)
VALUES ('FAT_CLTENCC001', '2024-02-09', 1)
    , ('FAT_CLTENCC002', '2024-02-09', 1);

INSERT INTO ClientOrderDelivery_Equipment (client_order_delivery_id, equipment_id, equipment_production_id, client_order_invoice_id, delivered_quantity, delivered_date, created_by)
VALUES (1, 1, 1, 1, 10, '2024-02-09', 1)
    , (1, 2, 1, 1, 5, '2024-02-09', 1)
    , (2, 3, 1, 2, 2, '2024-02-09', 1)
    , (2, 4, 1, 2, 1, '2024-02-09', 1);