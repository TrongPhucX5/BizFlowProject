-- ============================================================================
-- BizFlow Backend - Reload Sample Data
-- Version: 5
-- Notes:
-- - This migration is designed to be SAFE in dev environments.
-- - It only removes rows created by this migration (SAMPLE-* order numbers,
--   sample customer phones/emails) and sample products by SKU.
-- - It matches the schema defined in V1__init_schema.sql.
-- ============================================================================

-- Ensure the session uses UTF-8
SET NAMES utf8mb4;

-- Pick a store to seed into (create one if none exists)
INSERT INTO stores (name, address, phone, email, tax_code, status)
SELECT 'BizFlow Demo Store', 'Demo address', '0900000000', 'demo@bizflow.local', 'DEMO-TAX-0001', 'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM stores);

SET @store_id := (SELECT id FROM stores ORDER BY id LIMIT 1);

-- Ensure common product units exist
INSERT IGNORE INTO product_units (name, symbol, is_default) VALUES
('bao', 'bao', TRUE),
('m3', 'm³', FALSE),
('viên', 'viên', FALSE),
('kg', 'kg', FALSE),
('cây', 'cây', FALSE),
('mét', 'm', FALSE),
('tấm', 'tấm', FALSE),
('cuộn', 'cuộn', FALSE),
('cái', 'cái', FALSE);

-- Ensure a default category exists
INSERT INTO product_categories (store_id, name, description)
SELECT @store_id, 'Vật liệu xây dựng', 'Danh mục mẫu'
WHERE NOT EXISTS (
	SELECT 1 FROM product_categories WHERE store_id = @store_id AND name = 'Vật liệu xây dựng'
);

SET @category_id := (
	SELECT id FROM product_categories
	WHERE store_id = @store_id AND name = 'Vật liệu xây dựng'
	ORDER BY id
	LIMIT 1
);

SET @unit_bao_id := (SELECT id FROM product_units WHERE name = 'bao' LIMIT 1);
SET @unit_m3_id := (SELECT id FROM product_units WHERE name = 'm3' LIMIT 1);
SET @unit_vien_id := (SELECT id FROM product_units WHERE name = 'viên' LIMIT 1);
SET @unit_kg_id := (SELECT id FROM product_units WHERE name = 'kg' LIMIT 1);
SET @unit_cay_id := (SELECT id FROM product_units WHERE name = 'cây' LIMIT 1);
SET @unit_met_id := (SELECT id FROM product_units WHERE name = 'mét' LIMIT 1);
SET @unit_tam_id := (SELECT id FROM product_units WHERE name = 'tấm' LIMIT 1);
SET @unit_cai_id := (SELECT id FROM product_units WHERE name = 'cái' LIMIT 1);

-- ---------------------------------------------------------------------------
-- 1) CLEANUP ONLY SAMPLE ROWS
-- ---------------------------------------------------------------------------

DELETE oi
FROM order_items oi
JOIN orders o ON o.id = oi.order_id
WHERE o.store_id = @store_id AND o.order_number LIKE 'SAMPLE-%';

DELETE FROM orders
WHERE store_id = @store_id AND order_number LIKE 'SAMPLE-%';

DELETE FROM customers
WHERE store_id = @store_id
  AND (
	  phone LIKE '0900000%'
	  OR email LIKE '%@sample.bizflow.local'
  );

DELETE i
FROM inventory i
JOIN products p ON p.id = i.product_id
WHERE p.store_id = @store_id
  AND p.sku IN (
	  'XM-HT-001',
	  'CAT-VANG-001',
	  'GACH-ONG-001',
	  'DA-1X2-001',
	  'SAT-PHI6-001',
	  'THEP-VN-001',
	  'ONG-PVC-001',
	  'DAY-DIEN-001',
	  'TAM-LOP-001',
	  'GACH-MEN-001'
  );

DELETE FROM products
WHERE store_id = @store_id
  AND sku IN (
	  'XM-HT-001',
	  'CAT-VANG-001',
	  'GACH-ONG-001',
	  'DA-1X2-001',
	  'SAT-PHI6-001',
	  'THEP-VN-001',
	  'ONG-PVC-001',
	  'DAY-DIEN-001',
	  'TAM-LOP-001',
	  'GACH-MEN-001'
  );

-- ---------------------------------------------------------------------------
-- 2) INSERT / UPSERT SAMPLE PRODUCTS + INVENTORY
-- ---------------------------------------------------------------------------

INSERT INTO products (
	store_id, category_id, name, sku, description,
	unit_id, unit_name,
	price, cost_price, reorder_level,
	image_url, status,
	created_by, updated_by
) VALUES
(@store_id, @category_id, 'Xi măng Hà Tiên đa dụng', 'XM-HT-001', 'Xi măng đa dụng', @unit_bao_id, 'bao', 120000, 100000, 20, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Cát vàng xây dựng', 'CAT-VANG-001', 'Cát vàng', @unit_m3_id, 'm3', 450000, 380000, 5, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Gạch ống 4 lỗ', 'GACH-ONG-001', 'Gạch ống', @unit_vien_id, 'viên', 3500, 2800, 200, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Đá 1x2', 'DA-1X2-001', 'Đá xây dựng', @unit_m3_id, 'm3', 280000, 240000, 5, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Sắt phi 6', 'SAT-PHI6-001', 'Sắt xây dựng', @unit_kg_id, 'kg', 59000, 52000, 50, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Thép Việt Nhật', 'THEP-VN-001', 'Thép xây dựng', @unit_cay_id, 'cây', 130500, 118000, 20, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Ống nước PVC Bình Minh', 'ONG-PVC-001', 'Ống PVC', @unit_met_id, 'mét', 25000, 20000, 30, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Dây điện Cadivi', 'DAY-DIEN-001', 'Dây điện', @unit_met_id, 'mét', 137500, 120000, 20, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Tấm lợp fibro xi măng', 'TAM-LOP-001', 'Tấm lợp', @unit_tam_id, 'tấm', 57000, 48000, 20, NULL, 'ACTIVE', 'system', 'system'),
(@store_id, @category_id, 'Gạch men Viglacera 60x60', 'GACH-MEN-001', 'Gạch men', @unit_cai_id, 'cái', 85000, 72000, 30, NULL, 'ACTIVE', 'system', 'system')
ON DUPLICATE KEY UPDATE
	name = VALUES(name),
	description = VALUES(description),
	category_id = VALUES(category_id),
	unit_id = VALUES(unit_id),
	unit_name = VALUES(unit_name),
	price = VALUES(price),
	cost_price = VALUES(cost_price),
	reorder_level = VALUES(reorder_level),
	status = VALUES(status),
	updated_by = VALUES(updated_by);

INSERT INTO inventory (store_id, product_id, quantity, reserved_quantity, available_quantity)
SELECT @store_id, p.id, 100, 0, 100
FROM products p
WHERE p.store_id = @store_id
  AND p.sku IN (
	  'XM-HT-001','CAT-VANG-001','GACH-ONG-001','DA-1X2-001','SAT-PHI6-001',
	  'THEP-VN-001','ONG-PVC-001','DAY-DIEN-001','TAM-LOP-001','GACH-MEN-001'
  )
ON DUPLICATE KEY UPDATE
	quantity = VALUES(quantity),
	reserved_quantity = VALUES(reserved_quantity),
	available_quantity = VALUES(available_quantity);

-- ---------------------------------------------------------------------------
-- 3) INSERT SAMPLE CUSTOMERS + ORDERS + ORDER ITEMS (schema-correct)
-- ---------------------------------------------------------------------------

INSERT INTO customers (store_id, name, phone, email, address, type, status, notes)
VALUES
(@store_id, 'Nguyễn Văn An', '0900000001', 'an@sample.bizflow.local', '123 Lê Lợi, Q1, TP.HCM', 'RETAIL', 'ACTIVE', 'Sample customer'),
(@store_id, 'Trần Thị Bình', '0900000002', 'binh@sample.bizflow.local', '456 Nguyễn Huệ, Q1, TP.HCM', 'RETAIL', 'ACTIVE', 'Sample customer'),
(@store_id, 'Lê Văn Cường', '0900000003', 'cuong@sample.bizflow.local', '789 Pasteur, Q3, TP.HCM', 'WHOLESALE', 'ACTIVE', 'Sample customer');

SET @cust_an_id := (SELECT id FROM customers WHERE store_id=@store_id AND phone='0900000001' ORDER BY id LIMIT 1);
SET @cust_binh_id := (SELECT id FROM customers WHERE store_id=@store_id AND phone='0900000002' ORDER BY id LIMIT 1);

INSERT IGNORE INTO orders (
	store_id, order_number, customer_id,
	subtotal, discount_amount, total_amount,
	payment_type, status,
	notes, created_at, created_by
) VALUES
(@store_id, 'SAMPLE-2026-0001', @cust_an_id, 1550000, 0, 1550000, 'CASH', 'PAID', 'Sample order', NOW(), 'system'),
(@store_id, 'SAMPLE-2026-0002', @cust_binh_id, 4500000, 0, 4500000, 'TRANSFER', 'PAID_PARTIAL', 'Sample order', NOW(), 'system');

SET @order_1_id := (SELECT id FROM orders WHERE store_id=@store_id AND order_number='SAMPLE-2026-0001' LIMIT 1);
SET @order_2_id := (SELECT id FROM orders WHERE store_id=@store_id AND order_number='SAMPLE-2026-0002' LIMIT 1);

SET @p_xm_id := (SELECT id FROM products WHERE store_id=@store_id AND sku='XM-HT-001' LIMIT 1);
SET @p_gach_id := (SELECT id FROM products WHERE store_id=@store_id AND sku='GACH-ONG-001' LIMIT 1);
SET @p_cat_id := (SELECT id FROM products WHERE store_id=@store_id AND sku='CAT-VANG-001' LIMIT 1);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_amount)
VALUES
(@order_1_id, @p_xm_id, 10, 120000, 1200000),
(@order_1_id, @p_gach_id, 100, 3500, 350000),
(@order_2_id, @p_cat_id, 5, 450000, 2250000);