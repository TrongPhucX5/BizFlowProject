-- V2_H2__add_seed_data_h2.sql
-- Seed data for H2 test database

-- Insert stores
INSERT INTO stores (id, name, description, address, phone, email, timezone, is_active)
VALUES (1, 'Cửa Hàng Bền Bỉ', 'Demo Store', '123 Main Street', '0912345678', 'info@benbi.com', 'Asia/Ho_Chi_Minh', TRUE);

-- Insert roles
INSERT INTO roles (id, name, description)
VALUES 
(1, 'ADMIN', 'System Administrator'),
(2, 'OWNER', 'Store Owner'),
(3, 'EMPLOYEE', 'Store Employee');

-- Insert permissions
INSERT INTO permissions (id, name, description)
VALUES 
(1, 'MANAGE_PRODUCTS', 'Create, read, update, delete products'),
(2, 'MANAGE_ORDERS', 'Create and manage orders'),
(3, 'MANAGE_USERS', 'Manage store users'),
(4, 'VIEW_REPORTS', 'View business reports'),
(5, 'MANAGE_INVENTORY', 'Manage stock levels'),
(6, 'MANAGE_PAYMENTS', 'Record and manage payments');

-- Insert role_permissions
INSERT INTO role_permissions (role_id, permission_id)
VALUES 
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6),
(3, 1), (3, 2), (3, 4), (3, 5);

-- Insert users
-- Password: admin123 (BCrypt hashed)
INSERT INTO users (id, store_id, username, password, full_name, email, phone, role_id, status, created_at, updated_at)
VALUES 
(1, 1, 'admin', '$2a$10$QCYR5L0T.5VeV8PW8MwImuRNVOt7lO4cB8K6v5k5GdZF8pKJ4fgXW', 'Admin User', 'admin@bizflow.com', '0912345678', 1, 'ACTIVE', NOW(), NOW()),
(2, 1, 'owner1', '$2a$10$QCYR5L0T.5VeV8PW8MwImuRNVOt7lO4cB8K6v5k5GdZF8pKJ4fgXW', 'Phạm Văn A', 'owner@benbi.com', '0987654321', 2, 'ACTIVE', NOW(), NOW()),
(3, 1, 'employee1', '$2a$10$QCYR5L0T.5VeV8PW8MwImuRNVOt7lO4cB8K6v5k5GdZF8pKJ4fgXW', 'Trần Thị B', 'employee1@benbi.com', '0909123456', 3, 'ACTIVE', NOW(), NOW());

-- Insert products
INSERT INTO products (id, store_id, name, sku, description, cost, selling_price, status, created_at, updated_at)
VALUES 
(1, 1, 'Áo Phông Nam', 'TSHIRT-001', 'Áo phông nam cotton 100%', 50000.00, 120000.00, 'ACTIVE', NOW(), NOW()),
(2, 1, 'Quần Jeans', 'JEANS-001', 'Quần jeans nam slim fit', 100000.00, 250000.00, 'ACTIVE', NOW(), NOW()),
(3, 1, 'Giày Thể Thao', 'SHOE-001', 'Giày thể thao nam thoáng khí', 200000.00, 450000.00, 'ACTIVE', NOW(), NOW()),
(4, 1, 'Mũ Lưỡi Trai', 'CAP-001', 'Mũ lưỡi trai cotton', 30000.00, 80000.00, 'ACTIVE', NOW(), NOW());

-- Insert customers
INSERT INTO customers (id, store_id, name, phone, email, address, segment, status, created_at, updated_at)
VALUES 
(1, 1, 'Nguyễn Văn C', '0912111111', 'customer1@email.com', '123 Nguyễn Huệ, HCM', 'VIP', 'ACTIVE', NOW(), NOW()),
(2, 1, 'Phạm Thị D', '0912222222', 'customer2@email.com', '456 Lê Thánh Tôn, HCM', 'REGULAR', 'ACTIVE', NOW(), NOW()),
(3, 1, 'Trương Văn E', '0912333333', 'customer3@email.com', '789 Nguyễn Huy Tưởng, HCM', 'NEW', 'ACTIVE', NOW(), NOW());

-- Insert inventory
INSERT INTO inventory (id, store_id, product_id, quantity, reserved_quantity, minimum_stock, created_at, updated_at)
VALUES 
(1, 1, 1, 50, 0, 10, NOW(), NOW()),
(2, 1, 2, 30, 0, 5, NOW(), NOW()),
(3, 1, 3, 20, 0, 3, NOW(), NOW()),
(4, 1, 4, 100, 0, 20, NOW(), NOW());

-- Insert orders
INSERT INTO orders (id, store_id, order_number, customer_id, total_amount, paid_amount, payment_status, order_status, created_at, updated_at)
VALUES 
(1, 1, 'ORD-001', 1, 350000.00, 0, 'UNPAID', 'PENDING', NOW(), NOW()),
(2, 1, 'ORD-002', 2, 200000.00, 200000.00, 'PAID', 'COMPLETED', NOW(), NOW());

-- Insert order_items
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price, subtotal, created_at)
VALUES 
(1, 1, 1, 2, 120000.00, 240000.00, NOW()),
(2, 1, 4, 1, 80000.00, 80000.00, NOW()),
(3, 2, 3, 1, 450000.00, 450000.00, NOW());

-- Insert debts
INSERT INTO debts (id, store_id, order_id, customer_id, amount, paid_amount, due_date, status, created_at, updated_at)
VALUES 
(1, 1, 1, 1, 350000.00, 0, '2025-12-20', 'UNPAID', NOW(), NOW());
