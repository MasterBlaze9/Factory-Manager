-- #region Warehouse
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
-- #endregion

-- #region Component
    -- Call to spCreateComponent (succeeds)
    CALL spCreateComponent('Component A', 9.99, 'Supplier A');

    -- Call to spCreateComponent (fails)
    CALL spCreateComponent(NULL, 9.99, 'Supplier A');

    -- Call to spUpdateComponent (succeeds)
    CALL spUpdateComponent(1, 'Updated Component A', 19.99);

    -- Call to spUpdateComponent (fails)
    CALL spUpdateComponent(0, 'Updated Component A', 19.99);

    -- Call to spSoftDeleteComponent (succeeds)
    CALL spSoftDeleteComponent(1);

    -- Call to spSoftDeleteComponent (fails)
    CALL spSoftDeleteComponent(0);

    -- Call to fnImportComponents_JSON
    SELECT fnImportComponents_JSON('{"components": [{"designation": "Component A", "price": 9.99, "supplier_name": "Supplier A"}, {"designation": "Component B", "price": 19.99, "supplier_name": "Supplier B"}]}');

    -- Call to fnImportComponents_XML
    SELECT fnImportComponents_XML('<components><component><designation>Component A</designation><price>9.99</price><supplier_name>Supplier A</supplier_name></component><component><designation>Component B</designation><price>19.99</price><supplier_name>Supplier B</supplier_name></component></components>');
-- #endregion

-- #region Supplier
    -- Call to spCreateSupplier (succeeds)
    CALL spCreateSupplier('Supplier Name', 'Supplier Address', '123456789', 1);

    -- Call to spCreateSupplier (fails)
    CALL spCreateSupplier(NULL, 'Supplier Address', '123456789', 1);

    -- Call to spUpdateSupplier (succeeds)
    CALL spUpdateSupplier(1, 'Updated Supplier Name', 'Updated Supplier Address', '987654321');

    -- Call to spUpdateSupplier (fails)
    CALL spUpdateSupplier(0, 'Updated Supplier Name', 'Updated Supplier Address', '987654321');

    -- Call to spSoftDeleteSupplier (succeeds)
    CALL spSoftDeleteSupplier(1);

    -- Call to spSoftDeleteSupplier (fails)
    CALL spSoftDeleteSupplier(0);
-- #endregion

-- #region Supplier_Component
    -- Call to spCreateSupplierComponent (succeeds)
    CALL spCreateSupplierComponent(1, 1, 1);

    -- Call to spCreateSupplierComponent (fails)
    CALL spCreateSupplierComponent(NULL, 1, 1);

    -- Call to spDeleteSupplierComponentsBySupplierId (succeeds)
    CALL spDeleteSupplierComponentsBySupplierId(1);

    -- Call to spDeleteSupplierComponentsBySupplierId (fails)
    CALL spDeleteSupplierComponentsBySupplierId(0);
-- #endregion

-- #region Warehouse_Component
    -- Call to spCreateWarehouseComponent (succeeds)
    CALL spCreateWarehouseComponent(1, 1, 1, 10);

    -- Call to spCreateWarehouseComponent (fails)
    CALL spCreateWarehouseComponent(NULL, 1, 1, 10);

    -- Call to spUpdateWarehouseComponent (succeeds)
    CALL spUpdateWarehouseComponent(1, 1, 1, 20);

    -- Call to spUpdateWarehouseComponent (fails)
    CALL spUpdateWarehouseComponent(0, 1, 1, 20);

    -- Call to spDeleteWarehouseComponentsByWarehouseId (succeeds)
    CALL spDeleteWarehouseComponentsByWarehouseId(1);

    -- Call to spDeleteWarehouseComponentsByWarehouseId (fails)
    CALL spDeleteWarehouseComponentsByWarehouseId(0);
-- #endregion

-- #region Orders
    -- Call to spCreateOrder (succeeds)
    CALL spCreateOrder(1, 1);

    -- Call to spCreateOrder (fails)
    CALL spCreateOrder(NULL, 1);
-- #endregion

-- #region Order_Component
    -- Call to spCreateOrderComponent (succeeds)
    CALL spCreateOrderComponent(1, 1, 1, 9.99, 1, 1);

    -- Call to spCreateOrderComponent (fails)
    CALL spCreateOrderComponent(NULL, 1, 1, 9.99, 1, 1);

    -- Call to spUpdateOrderComponentStock (succeeds)
    CALL spUpdateOrderComponentStock(1, 5);

    -- Call to spUpdateOrderComponentStock (fails)
    CALL spUpdateOrderComponentStock(0, 5);

    -- Call to spDeleteOrderComponent (succeeds)
    CALL spDeleteOrderComponent(1);

    -- Call to spDeleteOrderComponent (fails)
    CALL spDeleteOrderComponent(0);
-- #endregion

-- #region OrderDelivery
    -- Call to spCreateOrderDelivery (succeeds)
    CALL spCreateOrderDelivery(1, 1);

    -- Call to spCreateOrderDelivery (fails)
    CALL spCreateOrderDelivery(NULL, 1);
-- #endregion

-- #region OrderInvoice
    -- Call to spCreateOrderInvoice (succeeds)
    CALL spCreateOrderInvoice('2022-01-01', 1);

    -- Call to spCreateOrderInvoice (fails)
    CALL spCreateOrderInvoice(NULL, 1);
-- #endregion

-- #region OrderDelivery_Component
    -- Call to spCreateOrderDelivery_Component (succeeds)
    CALL spCreateOrderDelivery_Component(1, 1, 1, 10, '2022-01-01', 1, 1);

    -- Call to spCreateOrderDelivery_Component (fails)
    CALL spCreateOrderDelivery_Component(NULL, 1, 1, 10, '2022-01-01', 1, 1);

    -- Call to spUpdateOrderDelivery_Component (succeeds)
    CALL spUpdateOrderDelivery_Component(1, 5);

    -- Call to spUpdateOrderDelivery_Component (fails)
    CALL spUpdateOrderDelivery_Component(0, 5);

    -- Call to spDeleteOrderDelivery_Component (succeeds)
    CALL spDeleteOrderDelivery_Component(1);

    -- Call to spDeleteOrderDelivery_Component (fails)
    CALL spDeleteOrderDelivery_Component(0);
-- #endregion

-- #region EquipmentType
    -- Call to spCreateEquipmentType (succeeds)
    CALL spCreateEquipmentType('Test Equipment Type', 1);

    -- Call to spCreateEquipmentType (fails)
    CALL spCreateEquipmentType(NULL, 1);

    -- Call to spUpdateEquipmentType (succeeds)
    CALL spUpdateEquipmentType(1, 'Updated Equipment Type');

    -- Call to spUpdateEquipmentType (fails)
    CALL spUpdateEquipmentType(0, 'Updated Equipment Type');

    -- Call to spSoftDeleteEquipmentType (succeeds)
    CALL spSoftDeleteEquipmentType(1);

    -- Call to spSoftDeleteEquipmentType (fails)
    CALL spSoftDeleteEquipmentType(0);
-- #endregion

-- #region Equipment
    -- Call to spCreateEquipment (succeeds)
    CALL spCreateEquipment('Equipment 1', 'Description 1', 1, 9.99, 1);

    -- Call to spCreateEquipment (fails)
    CALL spCreateEquipment(NULL, 'Description 2', 1, 9.99, 1);

    -- Call to spUpdateEquipment (succeeds)
    CALL spUpdateEquipment(1, 'Updated Equipment', 'Updated Description', 2, 19.99);

    -- Call to spUpdateEquipment (fails)
    CALL spUpdateEquipment(0, 'Updated Equipment', 'Updated Description', 2, 19.99);

    -- Call to spSoftDeleteEquipment (succeeds)
    CALL spSoftDeleteEquipment(1);

    -- Call to spSoftDeleteEquipment (fails)
    CALL spSoftDeleteEquipment(0);
-- #endregion

-- #region WorkType
    -- Call to spCreateWorkType (succeeds)
    CALL spCreateWorkType('Designation 1', 10.99, 1);

    -- Call to spCreateWorkType (fails)
    CALL spCreateWorkType('', 0, 1);

    -- Call to spUpdateWorkType (succeeds)
    CALL spUpdateWorkType(1, 'New Designation', 15.99);

    -- Call to spUpdateWorkType (fails)
    CALL spUpdateWorkType(0, 'New Designation', 15.99);

    -- Call to spSoftDeleteWorkType (succeeds)
    CALL spSoftDeleteWorkType(1);

    -- Call to spSoftDeleteWorkType (fails)
    CALL spSoftDeleteWorkType(0);
-- #endregion

-- #region EquipmentProduction
    -- Call to spCreateEquipmentProduction (succeeds)
    CALL spCreateEquipmentProduction(1, 1, 1, 10, '2022-01-01', '2022-01-10', 9.99, 1);

    -- Call to spCreateEquipmentProduction (fails)
    CALL spCreateEquipmentProduction(NULL, 1, 1, 10, '2022-01-01', '2022-01-10', 9.99, 1);
-- #endregion

-- #region EquipmentProduction_Component
    -- Call to spCreateEquipmentProduction_Component (succeeds)
    CALL spCreateEquipmentProduction_Component(1, 1, 1, 1, 10, 1);

    -- Call to spCreateEquipmentProduction_Component (fails)
    CALL spCreateEquipmentProduction_Component(NULL, 1, 1, 1, 10, 1);
-- #endregion

-- #region Client
    -- Call to spCreateClient (succeeds)
    CALL spCreateClient('John Doe', '123 Main St', 1);

    -- Call to spCreateClient (fails)
    CALL spCreateClient(NULL, '123 Main St', 1);

    -- Call to spUpdateClient (succeeds)
    CALL spUpdateClient(1, 'Jane Smith', '456 Elm St');

    -- Call to spUpdateClient (fails)
    CALL spUpdateClient(NULL, 'Jane Smith', '456 Elm St');

    -- Call to spSoftDeleteClient (succeeds)
    CALL spSoftDeleteClient(1);

    -- Call to spSoftDeleteClient (fails)
    CALL spSoftDeleteClient(NULL);
-- #endregion

-- #region ClientOrder
    -- Call to spCreateClientOrder (succeeds)
    CALL spCreateClientOrder(1, 1, 1);

    -- Call to spCreateClientOrder (fails)
    CALL spCreateClientOrder(NULL, 1, 1);
-- #endregion

-- #region ClientOrder_Equipment
    -- Call to spCreateClientOrderEquipment (succeeds)
    CALL spCreateClientOrderEquipment(1, 1, 1, 10, 9.99, 1);

    -- Call to spCreateClientOrderEquipment (fails)
    CALL spCreateClientOrderEquipment(NULL, 1, 1, 10, 9.99, 1);
-- #endregion

-- #region ClientOrderDelivery
    -- Call to spCreateClientOrderDelivery (succeeds)
    CALL spCreateClientOrderDelivery(1, 1);

    -- Call to spCreateClientOrderDelivery (fails)
    CALL spCreateClientOrderDelivery(NULL, 1);
-- #endregion

-- #region ClientOrderInvoice
    -- Call to spCreateClientOrderInvoice (succeeds)
    CALL spCreateClientOrderInvoice('2022-01-01', 1);

    -- Call to spCreateClientOrderInvoice (fails)
    CALL spCreateClientOrderInvoice(NULL, 1);
-- #endregion

-- #region ClientOrderDelivery_Equipment
    -- Call to spCreateClientOrderDelivery_Equipment (succeeds)
    CALL spCreateClientOrderDelivery_Equipment(1, 1, 5, '2022-01-01', 1, 1);

    -- Call to spCreateClientOrderDelivery_Equipment (fails)
    CALL spCreateClientOrderDelivery_Equipment(NULL, 1, 5, '2022-01-01', 1, 1);
-- #endregion