-- V11__add_fresh_demo_data.sql
-- Fixed & Idempotent Version: Checks existence before inserting
-- Supports multiple stores (specifically ID 1 and 2 found in system)
-- -----------------------------------------------------------------------------

SET NAMES utf8mb4;

-- 1. STORES: Ensure specific stores exist (optional, but good for consistency)
-- (Assuming stores 1 and 2 exist from V5/V6, but let's be safe)

-- 2. CATEGORIES: Ensure 'Mặc định' category exists for Store 1 and 2
INSERT INTO
    product_categories (store_id, name, description)
SELECT id, 'Mặc định', 'Danh mục chung'
FROM stores
WHERE
    id IN (1, 2)
    AND NOT EXISTS (
        SELECT 1
        FROM product_categories pc
        WHERE
            pc.store_id = stores.id
            AND pc.name = 'Mặc định'
    );

-- 3. PRODUCTS: Ensure sample products exist for Store 1 and 2
-- Store 1 Products
INSERT INTO
    products (
        store_id,
        category_id,
        name,
        sku,
        price,
        stock_quantity,
        unit_name,
        status,
        created_by,
        description
    )
SELECT 1, (
        SELECT id
        FROM product_categories
        WHERE
            store_id = 1
        LIMIT 1
    ), 'Xi măng Hà Tiên (Demo)', 'XM-DEMO-1', 92000, 500, 'bao', 'ACTIVE', 'system', 'Demo Product'
FROM DUAL
WHERE
    NOT EXISTS (
        SELECT 1
        FROM products
        WHERE
            store_id = 1
            AND sku = 'XM-DEMO-1'
    )
    AND EXISTS (
        SELECT 1
        FROM stores
        WHERE
            id = 1
    );

INSERT INTO
    products (
        store_id,
        category_id,
        name,
        sku,
        price,
        stock_quantity,
        unit_name,
        status,
        created_by,
        description
    )
SELECT 1, (
        SELECT id
        FROM product_categories
        WHERE
            store_id = 1
        LIMIT 1
    ), 'Sắt phi 10 (Demo)', 'SAT-DEMO-1', 115000, 200, 'cây', 'ACTIVE', 'system', 'Demo Product'
FROM DUAL
WHERE
    NOT EXISTS (
        SELECT 1
        FROM products
        WHERE
            store_id = 1
            AND sku = 'SAT-DEMO-1'
    )
    AND EXISTS (
        SELECT 1
        FROM stores
        WHERE
            id = 1
    );

-- Store 2 Products
INSERT INTO
    products (
        store_id,
        category_id,
        name,
        sku,
        price,
        stock_quantity,
        unit_name,
        status,
        created_by,
        description
    )
SELECT 2, (
        SELECT id
        FROM product_categories
        WHERE
            store_id = 2
        LIMIT 1
    ), 'Xi măng Hà Tiên (Demo)', 'XM-DEMO-2', 95000, 500, 'bao', 'ACTIVE', 'system', 'Demo Product'
FROM DUAL
WHERE
    NOT EXISTS (
        SELECT 1
        FROM products
        WHERE
            store_id = 2
            AND sku = 'XM-DEMO-2'
    )
    AND EXISTS (
        SELECT 1
        FROM stores
        WHERE
            id = 2
    );

INSERT INTO
    products (
        store_id,
        category_id,
        name,
        sku,
        price,
        stock_quantity,
        unit_name,
        status,
        created_by,
        description
    )
SELECT 2, (
        SELECT id
        FROM product_categories
        WHERE
            store_id = 2
        LIMIT 1
    ), 'Sắt phi 10 (Demo)', 'SAT-DEMO-2', 118000, 200, 'cây', 'ACTIVE', 'system', 'Demo Product'
FROM DUAL
WHERE
    NOT EXISTS (
        SELECT 1
        FROM products
        WHERE
            store_id = 2
            AND sku = 'SAT-DEMO-2'
    )
    AND EXISTS (
        SELECT 1
        FROM stores
        WHERE
            id = 2
    );

-- 4. CUSTOMERS: Ensure sample customers
-- Store 1
INSERT INTO
    customers (
        store_id,
        name,
        phone,
        address,
        type,
        status
    )
SELECT 1, 'Khách Vãng Lai (Demo)', '0990000001', 'HCM', 'RETAIL', 'ACTIVE'
FROM DUAL
WHERE
    NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE
            store_id = 1
            AND phone = '0990000001'
    )
    AND EXISTS (
        SELECT 1
        FROM stores
        WHERE
            id = 1
    );

-- Store 2
INSERT INTO
    customers (
        store_id,
        name,
        phone,
        address,
        type,
        status
    )
SELECT 2, 'Khách Vãng Lai (Demo)', '0990000002', 'HCM', 'RETAIL', 'ACTIVE'
FROM DUAL
WHERE
    NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE
            store_id = 2
            AND phone = '0990000002'
    )
    AND EXISTS (
        SELECT 1
        FROM stores
        WHERE
            id = 2
    );

-- 5. ORDERS: Insert fresh orders for Today (Idempotent: Check if 'Today' orders exist for this specific demo setup)
-- We use a specific comment or reference (e.g., via unique order number prefix if possible, but UUID makes it hard).
-- BETTER STRATEGY: Delete today's demo orders first? No, risky.
-- STRATEGY: Check if we have created orders *today* for the *demo customer*. If 0, insert.

-- STORE 1 ORDERS
-- Variables
SET @s1_id = 1;

SET
    @c1_id = (
        SELECT id
        FROM customers
        WHERE
            store_id = 1
            AND phone = '0990000001'
        LIMIT 1
    );

SET
    @p1_id = (
        SELECT id
        FROM products
        WHERE
            store_id = 1
            AND sku = 'XM-DEMO-1'
        LIMIT 1
    );

-- Insert Order 1 (Paid) if no orders for this customer today
INSERT INTO
    orders (
        store_id,
        order_number,
        customer_id,
        subtotal,
        discount_amount,
        total_amount,
        payment_type,
        status,
        created_at,
        updated_at,
        created_by
    )
SELECT 1, CONCAT('S1-TD-', UUID()), @c1_id, 920000, 0, 920000, 'CASH', 'PAID', NOW(), NOW(), 'system'
FROM DUAL
WHERE
    @c1_id IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM orders
        WHERE
            customer_id = @c1_id
            AND DATE(created_at) = DATE(NOW())
    );

-- Insert Order Item (Link by finding the latest order for this customer created just now)
-- This is tricky in strict set-based SQL. Using INTO variable or LAST_INSERT_ID is safer.
-- But standard SQL doesn't do variables easily across statements without procedures.
-- MySQL/TiDB allows LAST_INSERT_ID().

INSERT INTO
    order_items (
        order_id,
        product_id,
        quantity,
        unit_price,
        total_amount,
        created_at
    )
SELECT id, @p1_id, 10, 92000, 920000, NOW()
FROM orders
WHERE
    customer_id = @c1_id
    AND created_by = 'system'
    AND DATE(created_at) = DATE(NOW())
ORDER BY id DESC
LIMIT 1;

-- STORE 2 ORDERS (Owner1)
SET @s2_id = 2;

SET
    @c2_id = (
        SELECT id
        FROM customers
        WHERE
            store_id = 2
            AND phone = '0990000002'
        LIMIT 1
    );

SET
    @p2_id = (
        SELECT id
        FROM products
        WHERE
            store_id = 2
            AND sku = 'XM-DEMO-2'
        LIMIT 1
    );

-- Insert Order (Paid)
INSERT INTO
    orders (
        store_id,
        order_number,
        customer_id,
        subtotal,
        discount_amount,
        total_amount,
        payment_type,
        status,
        created_at,
        updated_at,
        created_by
    )
SELECT 2, CONCAT('S2-TD-', UUID()), @c2_id, 1900000, 0, 1900000, 'CASH', 'PAID', NOW(), NOW(), 'system'
FROM DUAL
WHERE
    @c2_id IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM orders
        WHERE
            customer_id = @c2_id
            AND DATE(created_at) = DATE(NOW())
    );

INSERT INTO
    order_items (
        order_id,
        product_id,
        quantity,
        unit_price,
        total_amount,
        created_at
    )
SELECT id, @p2_id, 20, 95000, 1900000, NOW()
FROM orders
WHERE
    customer_id = @c2_id
    AND created_by = 'system'
    AND DATE(created_at) = DATE(NOW())
ORDER BY id DESC
LIMIT 1;

-- 6. HISTORY ORDERS (Yesterday)
-- Store 2 Yesterday
INSERT INTO
    orders (
        store_id,
        order_number,
        customer_id,
        subtotal,
        discount_amount,
        total_amount,
        payment_type,
        status,
        created_at,
        updated_at,
        created_by
    )
SELECT 2, CONCAT('S2-YEST-', UUID()), @c2_id, 475000, 0, 475000, 'CASH', 'PAID', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), 'system'
FROM DUAL
WHERE
    @c2_id IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM orders
        WHERE
            customer_id = @c2_id
            AND DATE(created_at) = DATE(
                DATE_SUB(NOW(), INTERVAL 1 DAY)
            )
    );

INSERT INTO
    order_items (
        order_id,
        product_id,
        quantity,
        unit_price,
        total_amount,
        created_at
    )
SELECT id, @p2_id, 5, 95000, 475000, DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM orders
WHERE
    customer_id = @c2_id
    AND created_by = 'system'
    AND DATE(created_at) = DATE(
        DATE_SUB(NOW(), INTERVAL 1 DAY)
    )
ORDER BY id DESC
LIMIT 1;

-- 7. Update Inventory (Safe Idempotent)
UPDATE inventory i
JOIN products p ON i.product_id = p.id
SET
    i.quantity = 100,
    i.available_quantity = 100
WHERE
    p.sku IN (
        'XM-DEMO-1',
        'SAT-DEMO-1',
        'XM-DEMO-2',
        'SAT-DEMO-2'
    );

-- Ensure inventory exists if update missed
INSERT INTO
    inventory (
        store_id,
        product_id,
        quantity,
        available_quantity
    )
SELECT p.store_id, p.id, 100, 100
FROM products p
WHERE
    p.sku IN (
        'XM-DEMO-1',
        'SAT-DEMO-1',
        'XM-DEMO-2',
        'SAT-DEMO-2'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM inventory
        WHERE
            product_id = p.id
    );