
-- NOTE: MySQL 8+ clean database does not require duplicate-index cleanup.
-- This migration is intentionally a no-op to remain compatible across MySQL/H2.
-- If future cleanup is needed, add MySQL-specific ALTER TABLE ... DROP INDEX statements here.

SELECT 1;
