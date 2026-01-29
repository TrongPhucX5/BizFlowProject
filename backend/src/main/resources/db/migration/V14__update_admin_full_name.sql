-- Cập nhập tên cho các log của admin bị thiếu
UPDATE users SET full_name = 'Admin Hệ Thống' WHERE username = 'admin' AND (full_name IS NULL OR full_name = '');

-- Đồng bộ tên đầy đủ và username cho các hành động đăng nhập cũ (thường targeting chính user đó)
UPDATE audit_logs al
JOIN users u ON al.user_id = u.id OR al.entity_id = u.id
SET al.user_name = u.username,
    al.user_full_name = u.full_name
WHERE (al.user_name IS NULL OR al.user_name = '') 
   OR (al.user_full_name IS NULL OR al.user_full_name = '');
