-- Create customer_groups table if not exists
CREATE TABLE IF NOT EXISTS customer_groups (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_store_id (store_id),
    CONSTRAINT fk_customer_groups_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Nhóm khách hàng (Customer Groups)';

-- Add missing columns to products table
ALTER TABLE products
ADD COLUMN IF NOT EXISTS stock_quantity INT DEFAULT 0 COMMENT 'Tồn kho (Denormalized)';

ALTER TABLE products
ADD COLUMN IF NOT EXISTS track_stock BOOLEAN DEFAULT TRUE NOT NULL COMMENT 'Có theo dõi tồn kho không';

-- Add missing columns to customers table (Safe check)
ALTER TABLE customers
ADD COLUMN IF NOT EXISTS total_purchase_amount DECIMAL(19, 2) DEFAULT 0;

ALTER TABLE customers
ADD COLUMN IF NOT EXISTS total_orders INT DEFAULT 0;

ALTER TABLE customers
ADD COLUMN IF NOT EXISTS total_debt DECIMAL(19, 2) DEFAULT 0;