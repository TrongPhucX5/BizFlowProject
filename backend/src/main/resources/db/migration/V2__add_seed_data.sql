-- ============================================================================
-- BizFlow Backend - Database Migration V2
-- Version: 2.0.0
-- Purpose: Add constraints, enhance indexes, and seed more test data
-- ============================================================================

-- ============================================================================
-- SEED DATA: Users (Admin, Sample Owners, Employees)
-- ============================================================================

-- Insert admin user (password hashed: admin123 -> BCrypt)
-- Note: In real application, passwords are hashed via BCrypt in Java
INSERT INTO users (username, password, full_name, email, phone, role, status)
VALUES (
    'admin',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWdeS86E36DH7G7m', -- BCrypt hash of 'admin123'
    'Quản trị viên',
    'admin@bizflow.vn',
    '0900000001',
    'ADMIN',
    'ACTIVE'
);

-- Insert sample store owner (password: owner123)
INSERT INTO stores (name, address, phone, email, tax_code) VALUES
('Cửa hàng Bền Bỉ', '456 Đường Hoàng Diệu, TP.HCM', '0902345678', 'benbi@bizflow.vn', '0987654321');

INSERT INTO users (store_id, username, password, full_name, email, phone, role, status, created_at)
SELECT id, 'owner1', '$2a$10$Dy.prgBWW.W1uQHqPn2eMO5hqKqfT5qz.n4HS5s3GNPmPBV.u7FTK', 'Trần Văn Chủ', 'owner1@bizflow.vn', '0902345678', 'OWNER', 'ACTIVE', NOW()
FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1;

-- Insert sample employees (password: emp123)
INSERT INTO users (store_id, username, password, full_name, email, phone, role, status, created_at)
SELECT id, 'emp1', '$2a$10$G6RYApWXhp.4kXBwfzKvP.5KUV4bBmcDvLKBKWYo/0p9Qjy2SFIYW', 'Nguyễn Thị Hoa', 'emp1@bizflow.vn', '0903456789', 'EMPLOYEE', 'ACTIVE', NOW()
FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1;

INSERT INTO users (store_id, username, password, full_name, email, phone, role, status, created_at)
SELECT id, 'emp2', '$2a$10$G6RYApWXhp.4kXBwfzKvP.5KUV4bBmcDvLKBKWYo/0p9Qjy2SFIYW', 'Phạm Văn Minh', 'emp2@bizflow.vn', '0904567890', 'EMPLOYEE', 'ACTIVE', NOW()
FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1;

-- ============================================================================
-- SEED DATA: More Products
-- ============================================================================

INSERT INTO product_categories (store_id, name, description) VALUES
((SELECT id FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1), 'Sơn', 'Sơn nước, sơn dầu, sơn phủ'),
((SELECT id FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1), 'Thiết bị', 'Máy khoan, máy cắt, dụng cụ cầm tay'),
((SELECT id FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1), 'Chắn chắn', 'Ván ép, gỗ xẻ, khung gỗ');

-- Insert products for Cửa hàng Bền Bỉ
INSERT INTO products (store_id, category_id, name, sku, unit_id, unit_name, price, cost_price, reorder_level, created_by)
SELECT 
    s.id,
    pc.id,
    'Sơn nước bề mặt 18L',
    'SN-BM-18L',
    pu.id,
    pu.name,
    850000,
    700000,
    10,
    'admin'
FROM stores s
CROSS JOIN product_categories pc
CROSS JOIN product_units pu
WHERE s.name = 'Cửa hàng Bền Bỉ' AND pc.name = 'Sơn' AND pu.name = 'lít'
LIMIT 1;

INSERT INTO products (store_id, category_id, name, sku, unit_id, unit_name, price, cost_price, reorder_level, created_by)
SELECT 
    s.id,
    pc.id,
    'Máy khoan Bosch 550W',
    'MK-BOSCH-550',
    pu.id,
    pu.name,
    2500000,
    2000000,
    5,
    'admin'
FROM stores s
CROSS JOIN product_categories pc
CROSS JOIN product_units pu
WHERE s.name = 'Cửa hàng Bền Bỉ' AND pc.name = 'Thiết bị' AND pu.name = 'cái'
LIMIT 1;

INSERT INTO products (store_id, category_id, name, sku, unit_id, unit_name, price, cost_price, reorder_level, created_by)
SELECT 
    s.id,
    pc.id,
    'Ván ép 12mm 1.2x2.4m',
    'VP-12MM-1.2x2.4',
    pu.id,
    pu.name,
    450000,
    380000,
    15,
    'admin'
FROM stores s
CROSS JOIN product_categories pc
CROSS JOIN product_units pu
WHERE s.name = 'Cửa hàng Bền Bỉ' AND pc.name = 'Chắn chắn' AND pu.name = 'm²'
LIMIT 1;

-- ============================================================================
-- SEED DATA: Customers
-- ============================================================================

INSERT INTO customers (store_id, name, phone, email, address, type, status, created_at) VALUES
((SELECT id FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1), 'Công ty Xây dựng ABC', '0905111111', 'abc@xaydung.vn', '789 Lê Văn Sỹ, Quận 3', 'CORPORATE', 'ACTIVE', NOW()),
((SELECT id FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1), 'Thầu Phạm Văn A', '0905222222', 'thau.a@gmail.com', '321 Nguyễn Huệ, Quận 1', 'WHOLESALE', 'ACTIVE', NOW()),
((SELECT id FROM stores WHERE name = 'Cửa hàng Bền Bỉ' LIMIT 1), 'Gia đình Trần', '0905333333', 'tran.family@gmail.com', '654 Võ Văn Kiệt, Quận 5', 'RETAIL', 'ACTIVE', NOW());

-- ============================================================================
-- SEED DATA: Inventory
-- ============================================================================

INSERT INTO inventory (store_id, product_id, quantity, reserved_quantity, available_quantity)
SELECT s.id, p.id, 50, 0, 50
FROM stores s, products p 
WHERE s.name = 'Cửa hàng Bền Bỉ' AND p.sku IN ('SN-BM-18L', 'MK-BOSCH-550', 'VP-12MM-1.2x2.4')
AND NOT EXISTS (SELECT 1 FROM inventory WHERE product_id = p.id);

-- ============================================================================
-- SEED DATA: Orders & Order Items
-- ============================================================================

-- Insert sample orders
INSERT INTO orders (store_id, order_number, customer_id, employee_id, subtotal, discount_amount, total_amount, payment_type, status, created_by)
SELECT 
    s.id,
    CONCAT('ORD-', DATE_FORMAT(NOW(), '%Y%m%d'), '-001'),
    c.id,
    u.id,
    2550000,
    50000,
    2500000,
    'CASH',
    'PAID',
    'admin'
FROM stores s
CROSS JOIN customers c
CROSS JOIN users u
WHERE s.name = 'Cửa hàng Bền Bỉ' AND c.name = 'Gia đình Trần' AND u.username = 'emp1'
LIMIT 1;

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_amount)
SELECT 
    o.id,
    p.id,
    3,
    p.price,
    p.price * 3
FROM orders o
CROSS JOIN products p
WHERE o.order_number LIKE 'ORD-%' AND p.sku = 'SN-BM-18L'
LIMIT 1;

-- ============================================================================
-- SEED DATA: Debts & Payments
-- ============================================================================

-- Insert sample debt
INSERT INTO debts (store_id, order_id, customer_id, original_amount, paid_amount, unpaid_amount, status, due_date)
SELECT 
    s.id,
    o.id,
    c.id,
    o.total_amount,
    0,
    o.total_amount,
    'UNPAID',
    DATE_ADD(NOW(), INTERVAL 30 DAY)
FROM stores s
CROSS JOIN orders o
CROSS JOIN customers c
WHERE s.name = 'Cửa hàng Bền Bỉ' AND c.name = 'Công ty Xây dựng ABC' 
AND o.order_number LIKE 'ORD-%'
LIMIT 1;

-- ============================================================================
-- SEED DATA: Subscription (Assign Free plan to demo store)
-- ============================================================================

INSERT INTO subscriptions (id, store_id, plan_id, start_date, end_date, status, created_by)
SELECT 
    CONCAT('SUB-', DATE_FORMAT(NOW(), '%Y%m%d'), '-001'),
    s.id,
    sp.id,
    CURDATE(),
    DATE_ADD(CURDATE(), INTERVAL 1 MONTH),
    'ACTIVE',
    'admin'
FROM stores s
CROSS JOIN subscription_plans sp
WHERE s.name = 'Cửa hàng Bền Bỉ' AND sp.name = 'Free'
LIMIT 1;

-- ============================================================================
-- VERIFICATION QUERIES (for testing - can be deleted)
-- ============================================================================

-- Verify stores
-- SELECT 'Stores' as entity, COUNT(*) as count FROM stores;

-- Verify users
-- SELECT 'Users' as entity, COUNT(*) as count FROM users;

-- Verify products
-- SELECT 'Products' as entity, COUNT(*) as count FROM products;

-- Verify customers
-- SELECT 'Customers' as entity, COUNT(*) as count FROM customers;

-- Verify orders
-- SELECT 'Orders' as entity, COUNT(*) as count FROM orders;

-- Verify inventory
-- SELECT 'Inventory' as entity, COUNT(*) as count FROM inventory;

-- ============================================================================
-- END OF V2 MIGRATION
-- ============================================================================
