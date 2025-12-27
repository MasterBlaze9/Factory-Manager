/*--* Users
CREATE SEQUENCE user_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE UserType (
    id INT DEFAULT NEXTVAL('user_type_id_seq') NOT NULL,
    designation VARCHAR(50) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE UserType
    ADD CONSTRAINT PK_UserType PRIMARY KEY (id);

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Users (
    id INT DEFAULT NEXTVAL('users_id_seq') NOT NULL,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(64) NOT NULL, -- 64 chars because of sha256 encryption
    user_type_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE Users
    ADD CONSTRAINT PK_Users PRIMARY KEY (id);

ALTER TABLE Users
    ADD CONSTRAINT FK_Users_UserType FOREIGN KEY (user_type_id) REFERENCES UserType(id);
--* End Users*/

--* Warehouse
CREATE SEQUENCE warehouse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Warehouse (
    id INT DEFAULT NEXTVAL('warehouse_id_seq') NOT NULL,
    designation VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL    
);

ALTER TABLE Warehouse
    ADD CONSTRAINT PK_Warehouse PRIMARY KEY (id);

ALTER TABLE Warehouse
    ADD CONSTRAINT FK_Warehouse_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
--* End Warehouse

--* Component
CREATE SEQUENCE component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Component (
    id INT DEFAULT NEXTVAL('component_id_seq') NOT NULL,
    designation VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Component
    ADD CONSTRAINT PK_Component PRIMARY KEY (id);

ALTER TABLE Component
    ADD CONSTRAINT FK_Component_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
--* End Component

--* Warehouse_Component
CREATE SEQUENCE warehouse_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Warehouse_Component (
    id INT DEFAULT NEXTVAL('warehouse_component_id_seq') NOT NULL,
    component_id INT NOT NULL,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    stock INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL    
);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT PK_Warehouse_Component PRIMARY KEY (id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_Component FOREIGN KEY (component_id) REFERENCES Component(id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_Supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_Warehouse FOREIGN KEY (warehouse_id) REFERENCES Warehouse(id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
--* End Warehouse Component

--* Supplier
CREATE SEQUENCE supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Supplier (
    id INT DEFAULT NEXTVAL('supplier_id_seq') NOT NULL,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    fiscal_number VARCHAR(9) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Supplier
    ADD CONSTRAINT PK_Supplier PRIMARY KEY (id);

ALTER TABLE Supplier
    ADD CONSTRAINT FK_Supplier_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE supplier_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Supplier_Component (
    id INT DEFAULT NEXTVAL('supplier_component_id_seq') NOT NULL,
    supplier_id INT NOT NULL,
    component_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Supplier_Component
    ADD CONSTRAINT PK_Supplier_Component PRIMARY KEY (id);

ALTER TABLE Supplier_Component
    ADD CONSTRAINT FK_Supplier_Component_Supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(id);

ALTER TABLE Supplier_Component
    ADD CONSTRAINT FK_Supplier_Component_Component FOREIGN KEY (component_id) REFERENCES Component(id);

ALTER TABLE Supplier_Component
    ADD CONSTRAINT FK_Supplier_Component_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
--* End Supplier

--* Order
/*CREATE SEQUENCE order_delivery_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE OrderDeliveryStatus (
    id INT DEFAULT NEXTVAL('order_delivery_status_id_seq') NOT NULL,
    designation VARCHAR(100) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE OrderDeliveryStatus
    ADD CONSTRAINT PK_OrderDeliveryStatus PRIMARY KEY (id);

ALTER TABLE OrderDeliveryStatus
    ADD CONSTRAINT FK_OrderDeliveryStatus_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);*/

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Orders (
    id INT DEFAULT NEXTVAL('orders_id_seq') NOT NULL,
    order_number VARCHAR(100) NOT NULL,
    ordered_by INT NOT NULL,
    ordered_on TIMESTAMP NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Orders
    ADD CONSTRAINT PK_Orders PRIMARY KEY (id);

ALTER TABLE Orders
    ADD CONSTRAINT FK_Orders_auth_user_OrderedBy FOREIGN KEY (ordered_by) REFERENCES auth_user(id);

ALTER TABLE Orders
    ADD CONSTRAINT FK_Orders_auth_user_CreatedBy FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE order_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Order_Component (
    id INT DEFAULT NEXTVAL('order_component_id_seq') NOT NULL,
    order_id INT NOT NULL,
    component_id INT NOT NULL,
    supplier_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Order_Component
    ADD CONSTRAINT PK_Order_Component PRIMARY KEY (id);

ALTER TABLE Order_Component
    ADD CONSTRAINT FK_Order_Component_Orders FOREIGN KEY (order_id) REFERENCES Orders(id);

ALTER TABLE Order_Component
    ADD CONSTRAINT FK_Order_Component_Component FOREIGN KEY (component_id) REFERENCES Component(id);

ALTER TABLE Order_Component
    ADD CONSTRAINT FK_Order_Component_Supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(id);

ALTER TABLE Order_Component
    ADD CONSTRAINT FK_Order_Component_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE order_delivery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE OrderDelivery (
    id INT DEFAULT NEXTVAL('order_delivery_id_seq') NOT NULL,
    order_id INT NOT NULL,
    --order_delivery_status_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE OrderDelivery
    ADD CONSTRAINT PK_OrderDelivery PRIMARY KEY (id);

ALTER TABLE OrderDelivery
    ADD CONSTRAINT FK_OrderDelivery_Orders FOREIGN KEY (order_id) REFERENCES Orders(id);

--ALTER TABLE OrderDelivery
    --ADD CONSTRAINT FK_OrderDelivery_OrderDeliveryStatus FOREIGN KEY (order_delivery_status_id) REFERENCES OrderDeliveryStatus(id);

ALTER TABLE OrderDelivery
    ADD CONSTRAINT FK_OrderDelivery_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

-- Order Invoice
CREATE SEQUENCE order_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE OrderInvoice (
    id INT DEFAULT NEXTVAL('order_invoice_id_seq') NOT NULL,
    invoice_number VARCHAR(100) NOT NULL,
    invoice_date TIMESTAMP NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE OrderInvoice
    ADD CONSTRAINT PK_OrderInvoice PRIMARY KEY (id);

ALTER TABLE OrderInvoice
    ADD CONSTRAINT FK_OrderInvoice_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

-- CREATE SEQUENCE order_invoice_detail_id_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;

-- CREATE TABLE OrderInvoiceDetail (
--     id INT DEFAULT NEXTVAL('order_invoice_detail_id_seq') NOT NULL,
--     order_id INT NOT NULL,
--     order_invoice_id INT NOT NULL,
--     component_id INT NOT NULL,
--     supplier_id INT NOT NULL,
--     delivered_quantity INT NOT NULL,
--     unit_price DECIMAL(10,2) NOT NULL,
--     created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     created_by INT NOT NULL
-- );

-- ALTER TABLE OrderInvoiceDetail
--     ADD CONSTRAINT PK_OrderInvoiceDetail PRIMARY KEY (id);

-- ALTER TABLE OrderInvoiceDetail
--     ADD CONSTRAINT FK_OrderInvoiceDetail_Orders FOREIGN KEY (order_id) REFERENCES Orders(id);

-- ALTER TABLE OrderInvoiceDetail
--     ADD CONSTRAINT FK_OrderInvoiceDetail_OrderInvoice FOREIGN KEY (order_invoice_id) REFERENCES OrderInvoice(id);

-- ALTER TABLE OrderInvoiceDetail
--     ADD CONSTRAINT FK_OrderInvoiceDetail_Component FOREIGN KEY (component_id) REFERENCES Component(id);

-- ALTER TABLE OrderInvoiceDetail
--     ADD CONSTRAINT FK_OrderInvoiceDetail_Supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(id);

-- ALTER TABLE OrderInvoiceDetail
--     ADD CONSTRAINT FK_OrderInvoiceDetail_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
-- End Order Invoice

CREATE SEQUENCE order_delivery_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE OrderDelivery_Component (
    id INT DEFAULT NEXTVAL('order_delivery_component_id_seq') NOT NULL,
    order_delivery_id INT NOT NULL,
    component_id INT NOT NULL,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    order_invoice_id INT NOT NULL,
    delivered_quantity INT NOT NULL,
    delivered_date TIMESTAMP NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE OrderDelivery_Component
    ADD CONSTRAINT PK_OrderDelivery_Component PRIMARY KEY (id);

ALTER TABLE OrderDelivery_Component
    ADD CONSTRAINT FK_OrderDelivery_Component_OrderDelivery FOREIGN KEY (order_delivery_id) REFERENCES OrderDelivery(id);

ALTER TABLE OrderDelivery_Component
    ADD CONSTRAINT FK_OrderDelivery_Component_Component FOREIGN KEY (component_id) REFERENCES Component(id);

ALTER TABLE OrderDelivery_Component
    ADD CONSTRAINT FK_OrderDelivery_Component_Supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(id);

ALTER TABLE OrderDelivery_Component
    ADD CONSTRAINT FK_OrderDelivery_Component_Warehouse FOREIGN KEY (warehouse_id) REFERENCES Warehouse(id);

ALTER TABLE OrderDelivery_Component
    ADD CONSTRAINT FK_OrderDelivery_Component_OrderInvoice FOREIGN KEY (order_invoice_id) REFERENCES OrderInvoice(id);

ALTER TABLE OrderDelivery_Component
    ADD CONSTRAINT FK_OrderDelivery_Component_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
--* End Order

--* Warehouse Component
CREATE SEQUENCE warehouse_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Warehouse_Component (
    id INT DEFAULT NEXTVAL('warehouse_component_id_seq') NOT NULL,
    component_id INT NOT NULL,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    stock INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT PK_Warehouse_Component PRIMARY KEY (id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_Component FOREIGN KEY (component_id) REFERENCES Component(id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_Supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_Warehouse FOREIGN KEY (warehouse_id) REFERENCES Warehouse(id);

ALTER TABLE Warehouse_Component
    ADD CONSTRAINT FK_Warehouse_Component_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
--* End Warehouse Component

--* Equipment
CREATE SEQUENCE equipment_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE EquipmentType (
    id INT DEFAULT NEXTVAL('equipment_type_id_seq') NOT NULL,
    designation VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE EquipmentType
    ADD CONSTRAINT PK_EquipmentType PRIMARY KEY (id);

ALTER TABLE EquipmentType
    ADD CONSTRAINT FK_EquipmentType_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Equipment (
    id INT DEFAULT NEXTVAL('equipment_id_seq') NOT NULL,
    designation VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    equipment_type_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Equipment
    ADD CONSTRAINT PK_Equipment PRIMARY KEY (id);

ALTER TABLE Equipment
    ADD CONSTRAINT FK_Equipment_EquipmentType FOREIGN KEY (equipment_type_id) REFERENCES EquipmentType(id);

ALTER TABLE Equipment
    ADD CONSTRAINT FK_Equipment_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

-- WorkType
CREATE SEQUENCE work_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE WorkType (
    id INT DEFAULT NEXTVAL('work_type_id_seq') NOT NULL,
    designation VARCHAR(100) NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE WorkType
    ADD CONSTRAINT PK_WorkType PRIMARY KEY (id);

ALTER TABLE WorkType
    ADD CONSTRAINT FK_WorkType_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
-- End WorkType

CREATE SEQUENCE equipment_production_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE EquipmentProduction (
    id INT DEFAULT NEXTVAL('equipment_production_id_seq') NOT NULL,
    equipment_id INT NOT NULL,
    work_type_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE EquipmentProduction
    ADD CONSTRAINT PK_EquipmentProduction PRIMARY KEY (id);

ALTER TABLE EquipmentProduction
    ADD CONSTRAINT FK_EquipmentProduction_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(id);

ALTER TABLE EquipmentProduction
    ADD CONSTRAINT FK_EquipmentProduction_WorkType FOREIGN KEY (work_type_id) REFERENCES WorkType(id);

ALTER TABLE EquipmentProduction
    ADD CONSTRAINT FK_EquipmentProduction_Warehouse FOREIGN KEY (warehouse_id) REFERENCES Warehouse(id);

ALTER TABLE EquipmentProduction
    ADD CONSTRAINT FK_EquipmentProduction_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE equipment_production_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE EquipmentProduction_Component (
    id INT DEFAULT NEXTVAL('equipment_production_component_id_seq') NOT NULL,
    equipment_production_id INT NOT NULL,
    component_id INT NOT NULL,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE EquipmentProduction_Component
    ADD CONSTRAINT PK_EquipmentProduction_Component PRIMARY KEY (id);

ALTER TABLE EquipmentProduction_Component
    ADD CONSTRAINT FK_EquipmentProduction_Component_EquipmentProduction FOREIGN KEY (equipment_production_id) REFERENCES EquipmentProduction(id);

ALTER TABLE EquipmentProduction_Component
    ADD CONSTRAINT FK_EquipmentProduction_Component_Component FOREIGN KEY (component_id) REFERENCES Component(id);

ALTER TABLE EquipmentProduction_Component
    ADD CONSTRAINT FK_EquipmentProduction_Component_Supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(id);

ALTER TABLE EquipmentProduction_Component
    ADD CONSTRAINT FK_EquipmentProduction_Component_Warehouse FOREIGN KEY (warehouse_id) REFERENCES Warehouse(id);

ALTER TABLE EquipmentProduction_Component
    ADD CONSTRAINT FK_EquipmentProduction_Component_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
--* End Equipment

--* Client
CREATE SEQUENCE client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE Client (
    id INT DEFAULT NEXTVAL('client_id_seq') NOT NULL,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE Client
    ADD CONSTRAINT PK_Client PRIMARY KEY (id);

ALTER TABLE Client
    ADD CONSTRAINT FK_Client_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE client_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE ClientOrder (
    id INT DEFAULT NEXTVAL('client_order_id_seq') NOT NULL,
    client_order_number VARCHAR(100) NOT NULL,
    client_id INT NOT NULL,
    ordered_by INT NOT NULL,
    ordered_on TIMESTAMP NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE ClientOrder
    ADD CONSTRAINT PK_ClientOrder PRIMARY KEY (id);

ALTER TABLE ClientOrder
    ADD CONSTRAINT FK_ClientOrder_Client FOREIGN KEY (client_id) REFERENCES Client(id);

ALTER TABLE ClientOrder
    ADD CONSTRAINT FK_ClientOrder_auth_user_OrderedBy FOREIGN KEY (ordered_by) REFERENCES auth_user(id);

ALTER TABLE ClientOrder
    ADD CONSTRAINT FK_ClientOrder_auth_user_CreatedBy FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE client_order_equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE ClientOrder_Equipment (
    id INT DEFAULT NEXTVAL('client_order_equipment_id_seq') NOT NULL,
    client_order_id INT NOT NULL,
    equipment_id INT NOT NULL,
    equipment_production_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE ClientOrder_Equipment
    ADD CONSTRAINT PK_ClientOrder_Equipment PRIMARY KEY (id);

ALTER TABLE ClientOrder_Equipment
    ADD CONSTRAINT FK_ClientOrder_Equipment_ClientOrder FOREIGN KEY (client_order_id) REFERENCES ClientOrder(id);

ALTER TABLE ClientOrder_Equipment
    ADD CONSTRAINT FK_ClientOrder_Equipment_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(id);

ALTER TABLE ClientOrder_Equipment
    ADD CONSTRAINT FK_ClientOrder_Equipment_EquipmentProdution FOREIGN KEY (equipment_production_id) REFERENCES EquipmentProduction(id);

ALTER TABLE ClientOrder_Equipment
    ADD CONSTRAINT FK_ClientOrder_Equipment_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

CREATE SEQUENCE client_order_delivery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE ClientOrderDelivery (
    id INT DEFAULT NEXTVAL('client_order_delivery_id_seq') NOT NULL,
    client_order_id INT NOT NULL,
    --order_delivery_status_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE ClientOrderDelivery
    ADD CONSTRAINT PK_ClientOrderDelivery PRIMARY KEY (id);

ALTER TABLE ClientOrderDelivery
    ADD CONSTRAINT FK_ClientOrderDelivery_ClientOrder FOREIGN KEY (client_order_id) REFERENCES ClientOrder(id);

--ALTER TABLE ClientOrderDelivery
    --ADD CONSTRAINT FK_ClientOrderDelivery_OrderDeliveryStatus FOREIGN KEY (order_delivery_status_id) REFERENCES OrderDeliveryStatus(id);

ALTER TABLE ClientOrderDelivery
    ADD CONSTRAINT FK_ClientOrderDelivery_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

-- Client Order Invoice
CREATE SEQUENCE client_order_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE ClientOrderInvoice (
    id INT DEFAULT NEXTVAL('client_order_invoice_id_seq') NOT NULL,
    invoice_number VARCHAR(100) NOT NULL,
    invoice_date TIMESTAMP NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE ClientOrderInvoice
    ADD CONSTRAINT PK_ClientOrderInvoice PRIMARY KEY (id);

ALTER TABLE ClientOrderInvoice
    ADD CONSTRAINT FK_ClientOrderInvoice_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);

-- CREATE SEQUENCE client_order_invoice_detail_id_seq
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;

-- CREATE TABLE ClientOrderInvoiceDetail (
--     id INT DEFAULT NEXTVAL('client_order_invoice_detail_id_seq') NOT NULL,
--     client_order_id INT NOT NULL,
--     client_order_invoice_id INT NOT NULL,
--     component_id INT NOT NULL,
--     quantity INT NOT NULL,
--     unit_price DECIMAL(10,2) NOT NULL,
--     created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     created_by INT NOT NULL
-- );

-- ALTER TABLE ClientOrderInvoiceDetail
--     ADD CONSTRAINT PK_ClientOrderInvoiceDetail PRIMARY KEY (id);

-- ALTER TABLE ClientOrderInvoiceDetail
--     ADD CONSTRAINT FK_ClientOrderInvoiceDetail_ClientOrder FOREIGN KEY (client_order_id) REFERENCES Orders(id);

-- ALTER TABLE ClientOrderInvoiceDetail
--     ADD CONSTRAINT FK_ClientOrderInvoiceDetail_ClientOrderInvoice FOREIGN KEY (client_order_invoice_id) REFERENCES OrderInvoice(id);

-- ALTER TABLE ClientOrderInvoiceDetail
--     ADD CONSTRAINT FK_ClientOrderInvoiceDetail_Component FOREIGN KEY (component_id) REFERENCES Component(id);

-- ALTER TABLE ClientOrderInvoiceDetail
--     ADD CONSTRAINT FK_ClientOrderInvoiceDetail_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
-- End Client Order Invoice

CREATE SEQUENCE client_order_delivery_equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE ClientOrderDelivery_Equipment (
    id INT DEFAULT NEXTVAL('client_order_delivery_equipment_id_seq') NOT NULL,
    client_order_delivery_id INT NOT NULL,
    equipment_id INT NOT NULL,
    equipment_production_id INT NOT NULL,
    client_order_invoice_id INT NOT NULL,
    delivered_quantity INT NOT NULL,
    delivered_date TIMESTAMP NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL
);

ALTER TABLE ClientOrderDelivery_Equipment
    ADD CONSTRAINT PK_ClientOrderDelivery_Equipment PRIMARY KEY (id);

ALTER TABLE ClientOrderDelivery_Equipment
    ADD CONSTRAINT FK_ClientOrderDelivery_Equipment_ClientOrderDelivery FOREIGN KEY (client_order_delivery_id) REFERENCES ClientOrderDelivery(id);

ALTER TABLE ClientOrderDelivery_Equipment
    ADD CONSTRAINT FK_ClientOrderDelivery_Equipment_Equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(id);

ALTER TABLE ClientOrderDelivery_Equipment
    ADD CONSTRAINT FK_ClientOrderDelivery_Equipment_EquipmentProduction FOREIGN KEY (equipment_production_id) REFERENCES EquipmentProduction(id);

ALTER TABLE ClientOrderDelivery_Equipment
    ADD CONSTRAINT FK_ClientOrderDelivery_Equipment_ClientOrderInvoice FOREIGN KEY (client_order_invoice_id) REFERENCES ClientOrderInvoice(id);

ALTER TABLE ClientOrderDelivery_Equipment
    ADD CONSTRAINT FK_ClientOrderDelivery_Equipment_auth_user FOREIGN KEY (created_by) REFERENCES auth_user(id);
