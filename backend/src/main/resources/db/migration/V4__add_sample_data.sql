-- ============================================================================
-- BizFlow Backend - Migration V4
-- NOTE:
-- The previous V4 content referenced columns that do not exist in the current
-- schema defined by V1__init_schema.sql (e.g. customers.full_name, orders.paid_amount,
-- order_items.product_name, products.stock_quantity).
--
-- Sample data seeding has been moved to V5__reload_sample_data.sql to keep V4
-- schema-safe.
-- ============================================================================

-- Ensure the session uses UTF-8
SET NAMES utf8mb4;

-- No-op on purpose.
SELECT 1;