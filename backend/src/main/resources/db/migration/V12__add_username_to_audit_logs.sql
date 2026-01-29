-- Add user_name column to audit_logs table
ALTER TABLE audit_logs ADD COLUMN user_name VARCHAR(100);
