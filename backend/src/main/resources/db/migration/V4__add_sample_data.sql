-- --------------------------------------------------------
-- 1. THÊM DỮ LIỆU MẪU CHO CUSTOMERS (Khách hàng)
-- --------------------------------------------------------
INSERT INTO customers (full_name, phone, email, address, debt_amount, total_purchase_amount, status, customer_type, store_id, created_at, updated_at) VALUES
('Nguyễn Văn An', '0901234567', 'nguyenvana@email.com', '123 Đường Lê Lợi, Quận 1, TP.HCM', 0, 12500000, 'ACTIVE', 'VIP', 1, NOW(), NOW()),
('Trần Thị Bình', '0912345678', 'tranthibinh@email.com', '456 Đường Nguyễn Huệ, Quận 1, TP.HCM', 3500000, 8900000, 'ACTIVE', 'REGULAR', 1, NOW(), NOW()),
('Lê Văn Cường', '0923456789', NULL, '789 Đường Pasteur, Quận 3, TP.HCM', 0, 4560000, 'ACTIVE', 'WHOLESALE', 1, NOW(), NOW()),
('Phạm Thị Dung', '0934567890', 'phamthidung@email.com', '321 Đường Cách Mạng Tháng 8, Quận 10, TP.HCM', 1200000, 3400000, 'ACTIVE', 'REGULAR', 1, NOW(), NOW()),
('Hoàng Văn Em', '0945678901', NULL, '654 Đường Lý Thường Kiệt, Quận 11, TP.HCM', 0, 7800000, 'INACTIVE', 'REGULAR', 1, NOW(), NOW());

-- --------------------------------------------------------
-- 2. THÊM DỮ LIỆU MẪU CHO ORDERS (Đơn hàng)
-- --------------------------------------------------------
INSERT INTO orders (order_number, customer_id, total_amount, paid_amount, remaining_amount, status, payment_method, store_id, created_at, updated_at) VALUES
('DH2024001', 1, 4500000, 4500000, 0, 'COMPLETED', 'CASH', 1, '2024-01-15 09:30:00', '2024-01-15 09:30:00'),
('DH2024002', 2, 8900000, 5400000, 3500000, 'PAID_PARTIAL', 'BANK_TRANSFER', 1, '2024-01-16 14:20:00', '2024-01-16 14:20:00'),
('DH2024003', 3, 2300000, 2300000, 0, 'COMPLETED', 'MOMO', 1, '2024-01-17 11:15:00', '2024-01-17 11:15:00'),
('DH2024004', 1, 8000000, 8000000, 0, 'COMPLETED', 'CASH', 1, '2024-01-18 16:45:00', '2024-01-18 16:45:00'),
('DH2024005', 4, 3400000, 2200000, 1200000, 'PAID_PARTIAL', 'VNPAY', 1, '2024-01-19 10:10:00', '2024-01-19 10:10:00'),
('DH2024006', NULL, 1250000, 1250000, 0, 'COMPLETED', 'CASH', 1, '2024-01-20 13:25:00', '2024-01-20 13:25:00'),
('DH2024007', 3, 2260000, 2260000, 0, 'COMPLETED', 'BANK_TRANSFER', 1, '2024-01-21 15:30:00', '2024-01-21 15:30:00'),
('DH2024008', 2, 0, 0, 0, 'CANCELLED', NULL, 1, '2024-01-22 09:00:00', '2024-01-22 09:15:00');

-- --------------------------------------------------------
-- 3. THÊM DỮ LIỆU MẪU CHO ORDER ITEMS (Chi tiết đơn hàng)
-- --------------------------------------------------------
-- Lưu ý: product_id phải khớp với dữ liệu đã có trong bảng products
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, total_price, created_at) VALUES
(1, 1, 'Xi măng Hà Tiên Đa Dụng', 10, 120000, 1200000, NOW()),
(1, 3, 'Gạch ống 4 lỗ', 100, 3500, 350000, NOW()),
(1, 5, 'Sắt phi 6', 50, 59000, 2950000, NOW()),

(2, 2, 'Cát vàng xây dựng', 5, 450000, 2250000, NOW()),
(2, 4, 'Đá 1x2', 8, 280000, 2240000, NOW()),
(2, 1, 'Xi măng Hà Tiên Đa Dụng', 15, 120000, 1800000, NOW()),
(2, 6, 'Thép Việt Nhật', 20, 130500, 2610000, NOW()),

(3, 3, 'Gạch ống 4 lỗ', 50, 3500, 175000, NOW()),
(3, 7, 'Ống nước PVC Bình Minh', 30, 25000, 750000, NOW()),
(3, 8, 'Dây điện Cadivi', 10, 137500, 1375000, NOW()),

(4, 5, 'Sắt phi 6', 100, 59000, 5900000, NOW()),
(4, 6, 'Thép Việt Nhật', 15, 130500, 1957500, NOW()),
(4, 9, 'Tấm lợp fibro xi măng', 25, 57000, 1425000, NOW()),

(5, 10, 'Gạch men Viglacera 60x60', 40, 85000, 3400000, NOW()),

(6, 1, 'Xi măng Hà Tiên Đa Dụng', 5, 120000, 600000, NOW()),
(6, 3, 'Gạch ống 4 lỗ', 30, 3500, 105000, NOW()),
(6, 7, 'Ống nước PVC Bình Minh', 10, 25000, 250000, NOW()),
(6, 8, 'Dây điện Cadivi', 2, 137500, 275000, NOW()),

(7, 2, 'Cát vàng xây dựng', 2, 450000, 900000, NOW()),
(7, 4, 'Đá 1x2', 3, 280000, 840000, NOW()),
(7, 9, 'Tấm lợp fibro xi măng', 10, 57000, 570000, NOW());

-- --------------------------------------------------------
-- 4. CẬP NHẬT TOTAL_PURCHASE_AMOUNT CHO CUSTOMERS
-- --------------------------------------------------------
UPDATE customers c
SET total_purchase_amount = (
    SELECT COALESCE(SUM(total_amount), 0)
    FROM orders o
    WHERE o.customer_id = c.id AND o.status != 'CANCELLED'
)
WHERE c.id IN (1, 2, 3, 4, 5);

-- --------------------------------------------------------
-- 5. CẬP NHẬT DEBT_AMOUNT CHO CUSTOMERS
-- --------------------------------------------------------
UPDATE customers c
SET debt_amount = (
    SELECT COALESCE(SUM(remaining_amount), 0)
    FROM orders o
    WHERE o.customer_id = c.id AND o.status IN ('UNPAID', 'PAID_PARTIAL')
)
WHERE c.id IN (1, 2, 3, 4, 5);

-- --------------------------------------------------------
-- 6. THÊM DỮ LIỆU MẪU CHO USERS (Người dùng/Nhân viên)
-- Password mặc định: password123
-- --------------------------------------------------------
INSERT INTO users (username, password, full_name, email, phone, role, status, store_id, created_at, updated_at) VALUES
('owner01', '$2a$10$r.z.y.x.w.v.u.t.s.r.q.p.o.n.m.l.k.j.i.h.g.f.e.d.c.b.a', 'Lê Trọng Phúc', 'phucle@bizflow.com', '0901111222', 'OWNER', 'ACTIVE', 1, NOW(), NOW()),
('admin01', '$2a$10$r.z.y.x.w.v.u.t.s.r.q.p.o.n.m.l.k.j.i.h.g.f.e.d.c.b.a', 'Nguyễn Thanh', 'thanhnguyen@bizflow.com', '0902222333', 'ADMIN', 'ACTIVE', 1, NOW(), NOW()),
('employee01', '$2a$10$r.z.y.x.w.v.u.t.s.r.q.p.o.n.m.l.k.j.i.h.g.f.e.d.c.b.a', 'Phạm Tùng', 'tungpham@bizflow.com', '0903333444', 'EMPLOYEE', 'ACTIVE', 1, NOW(), NOW()),
('employee02', '$2a$10$r.z.y.x.w.v.u.t.s.r.q.p.o.n.m.l.k.j.i.h.g.f.e.d.c.b.a', 'Trần Văn Nam', 'namtran@bizflow.com', '0904444555', 'EMPLOYEE', 'INACTIVE', 1, NOW(), NOW());

-- --------------------------------------------------------
-- 7. CẬP NHẬT PRODUCT STOCK (Tồn kho sản phẩm)
-- --------------------------------------------------------
-- Giả định sản phẩm ID 1-10 đã tồn tại từ V2
UPDATE products
SET stock_quantity = CASE id
    WHEN 1 THEN 85   -- Xi măng: 100 - (10+15+5) = 70
    WHEN 2 THEN 93   -- Cát: 100 - (5+2) = 93
    WHEN 3 THEN 820  -- Gạch: 1000 - (100+50+30) = 820
    WHEN 4 THEN 89   -- Đá: 100 - (8+3) = 89
    WHEN 5 THEN -50  -- Sắt phi 6: 0 - (50+100) = -150 (âm = hết hàng)
    WHEN 6 THEN 65   -- Thép: 100 - (20+15) = 65
    WHEN 7 THEN 60   -- Ống nước: 100 - (30+10) = 60
    WHEN 8 THEN 88   -- Dây điện: 100 - (10+2) = 88
    WHEN 9 THEN 65   -- Tấm lợp: 100 - (25+10) = 65
    WHEN 10 THEN 60  -- Gạch men: 100 - 40 = 60
    ELSE stock_quantity
END
WHERE id BETWEEN 1 AND 10;
