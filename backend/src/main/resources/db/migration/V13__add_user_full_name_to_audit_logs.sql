-- Add user_full_name column to audit_logs table
ALTER TABLE audit_logs ADD COLUMN user_full_name VARCHAR(100);
