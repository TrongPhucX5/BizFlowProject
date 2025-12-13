-- ============================================================================
-- BizFlow Backend - Database Migration
-- Version: 1.0.0
-- Created: 2025-01-01
-- Database: MySQL 8.0
-- ============================================================================

-- ============================================================================
-- PHASE 1: Core Tables (Users, Roles, Permissions)
-- ============================================================================

-- Table: stores
CREATE TABLE IF NOT EXISTS stores (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT 'Tên cửa hàng',
    address VARCHAR(255) COMMENT 'Địa chỉ',
    phone VARCHAR(15) COMMENT 'Số điện thoại',
    email VARCHAR(100) COMMENT 'Email',
    tax_code VARCHAR(20) COMMENT 'Mã số thuế',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT 'Trạng thái',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_tax_code (tax_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cửa hàng / Store';

-- Table: roles
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Tên vai trò (ADMIN, OWNER, EMPLOYEE)',
    description VARCHAR(255) COMMENT 'Mô tả',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_role_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Vai trò (Role)';

-- Table: permissions
CREATE TABLE IF NOT EXISTS permissions (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Tên quyền (PRODUCT_CREATE, ORDER_VIEW, etc)',
    description VARCHAR(255) COMMENT 'Mô tả',
    module VARCHAR(50) COMMENT 'Module (USER, PRODUCT, ORDER, etc)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_permission_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Quyền (Permission)';

-- Table: role_permissions (Junction table)
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ánh xạ Vai trò - Quyền';

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT COMMENT 'Cửa hàng (NULL nếu ADMIN)',
    username VARCHAR(30) NOT NULL UNIQUE COMMENT 'Tên đăng nhập',
    password VARCHAR(255) NOT NULL COMMENT 'Mật khẩu (BCrypt hash)',
    full_name VARCHAR(100) NOT NULL COMMENT 'Họ và tên',
    email VARCHAR(100) COMMENT 'Email',
    phone VARCHAR(15) COMMENT 'Điện thoại',
    role ENUM('ADMIN', 'OWNER', 'EMPLOYEE') NOT NULL COMMENT 'Vai trò chính',
    status ENUM('ACTIVE', 'INACTIVE', 'LOCKED') DEFAULT 'ACTIVE' COMMENT 'Trạng thái',
    last_login_at TIMESTAMP NULL COMMENT 'Lần đăng nhập cuối',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email),
    KEY idx_role (role),
    KEY idx_store_id (store_id),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Người dùng (User)';

-- ============================================================================
-- PHASE 2: Product Management Tables
-- ============================================================================

-- Table: product_categories
CREATE TABLE IF NOT EXISTS product_categories (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT 'Tên danh mục',
    description VARCHAR(255) COMMENT 'Mô tả',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_store_id (store_id),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh mục sản phẩm';

-- Table: product_units
CREATE TABLE IF NOT EXISTS product_units (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Tên đơn vị (bao, cái, kg, lít, etc)',
    symbol VARCHAR(10) COMMENT 'Ký hiệu',
    is_default BOOLEAN DEFAULT FALSE COMMENT 'Đơn vị mặc định',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn vị tính sản phẩm';

-- Table: products
CREATE TABLE IF NOT EXISTS products (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    category_id BIGINT COMMENT 'Danh mục',
    name VARCHAR(100) NOT NULL COMMENT 'Tên sản phẩm',
    sku VARCHAR(50) NOT NULL COMMENT 'Mã SKU (unique per store)',
    description VARCHAR(500) COMMENT 'Mô tả',
    unit_id BIGINT COMMENT 'Đơn vị tính',
    unit_name VARCHAR(50) COMMENT 'Tên đơn vị (denormalized)',
    price DECIMAL(15, 0) NOT NULL COMMENT 'Giá bán (VND)',
    cost_price DECIMAL(15, 0) COMMENT 'Giá vốn (VND)',
    reorder_level INT DEFAULT 0 COMMENT 'Mức tồn kho tối thiểu',
    image_url VARCHAR(500) COMMENT 'URL ảnh sản phẩm',
    status ENUM('ACTIVE', 'INACTIVE', 'DISCONTINUED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(30) COMMENT 'Người tạo',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by VARCHAR(30) COMMENT 'Người cập nhật',
    UNIQUE KEY uk_store_sku (store_id, sku),
    KEY idx_name (name),
    KEY idx_category_id (category_id),
    KEY idx_status (status),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (unit_id) REFERENCES product_units(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sản phẩm (Product)';

-- Table: product_price_history
CREATE TABLE IF NOT EXISTS product_price_history (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    old_price DECIMAL(15, 0) COMMENT 'Giá cũ',
    new_price DECIMAL(15, 0) NOT NULL COMMENT 'Giá mới',
    changed_by VARCHAR(30) COMMENT 'Người thay đổi',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_product_id (product_id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử giá sản phẩm';

-- ============================================================================
-- PHASE 3: Inventory Management Tables
-- ============================================================================

-- Table: inventory
CREATE TABLE IF NOT EXISTS inventory (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 0 COMMENT 'Tồn kho hiện tại',
    reserved_quantity INT DEFAULT 0 COMMENT 'Số lượng đặt hàng',
    available_quantity INT COMMENT 'Tồn kho có sẵn',
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_store_product (store_id, product_id),
    KEY idx_quantity (quantity),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tồn kho (Inventory)';

-- Table: stock_movements
CREATE TABLE IF NOT EXISTS stock_movements (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    type ENUM('SALE', 'STOCK_IN', 'STOCK_ADJUST', 'RETURN') COMMENT 'Loại biến động',
    quantity INT NOT NULL COMMENT 'Số lượng thay đổi (có dấu)',
    reference_id BIGINT COMMENT 'ID order / stock-in (nếu có)',
    reference_type VARCHAR(50) COMMENT 'Loại reference (ORDER, STOCK_IN, ADJUSTMENT)',
    unit_price DECIMAL(15, 0) COMMENT 'Giá đơn vị tại thời điểm',
    supplier_name VARCHAR(100) COMMENT 'Tên nhà cung cấp (nếu stock-in)',
    notes VARCHAR(500) COMMENT 'Ghi chú',
    created_by VARCHAR(30) COMMENT 'Người thực hiện',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_store_product (store_id, product_id),
    KEY idx_type (type),
    KEY idx_created_at (created_at),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử biến động tồn kho (Stock Movement)';

-- ============================================================================
-- PHASE 4: Customer Management Tables
-- ============================================================================

-- Table: customers
CREATE TABLE IF NOT EXISTS customers (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT 'Tên khách hàng',
    phone VARCHAR(15) COMMENT 'Số điện thoại',
    email VARCHAR(100) COMMENT 'Email',
    address VARCHAR(255) COMMENT 'Địa chỉ',
    type ENUM('RETAIL', 'WHOLESALE', 'CORPORATE') DEFAULT 'RETAIL' COMMENT 'Loại khách',
    tax_code VARCHAR(20) COMMENT 'Mã số thuế',
    contact_person VARCHAR(100) COMMENT 'Người đại diện',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    notes VARCHAR(500) COMMENT 'Ghi chú',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_store_id (store_id),
    KEY idx_name (name),
    KEY idx_phone (phone),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Khách hàng (Customer)';

-- ============================================================================
-- PHASE 5: Order Management Tables
-- ============================================================================

-- Table: orders
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE COMMENT 'Số đơn hàng',
    customer_id BIGINT NOT NULL COMMENT 'Khách hàng',
    employee_id BIGINT COMMENT 'Nhân viên tạo đơn',
    subtotal DECIMAL(15, 0) NOT NULL DEFAULT 0 COMMENT 'Cộng tiền hàng',
    discount_amount DECIMAL(15, 0) DEFAULT 0 COMMENT 'Tiền chiết khấu',
    total_amount DECIMAL(15, 0) NOT NULL COMMENT 'Tổng tiền',
    payment_type ENUM('CASH', 'CREDIT', 'TRANSFER') DEFAULT 'CASH' COMMENT 'Hình thức thanh toán',
    status ENUM('CONFIRMED', 'PAID', 'PAID_PARTIAL', 'UNPAID', 'CANCELLED') DEFAULT 'CONFIRMED' COMMENT 'Trạng thái',
    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(30) COMMENT 'Người tạo',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_store_id (store_id),
    KEY idx_customer_id (customer_id),
    KEY idx_status (status),
    KEY idx_created_at (created_at),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn hàng (Order)';

-- Table: order_items
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL COMMENT 'Số lượng',
    unit_price DECIMAL(15, 0) NOT NULL COMMENT 'Giá đơn vị tại thời điểm',
    total_amount DECIMAL(15, 0) NOT NULL COMMENT 'Thành tiền',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_order_id (order_id),
    KEY idx_product_id (product_id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết đơn hàng (Order Item)';

-- ============================================================================
-- PHASE 6: Debt & Payment Tables
-- ============================================================================

-- Table: debts (Sổ nợ - Receivables)
CREATE TABLE IF NOT EXISTS debts (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    order_id BIGINT COMMENT 'Đơn hàng liên quan',
    customer_id BIGINT NOT NULL,
    original_amount DECIMAL(15, 0) NOT NULL COMMENT 'Số tiền nợ ban đầu',
    paid_amount DECIMAL(15, 0) DEFAULT 0 COMMENT 'Số tiền đã thanh toán',
    unpaid_amount DECIMAL(15, 0) COMMENT 'Số tiền còn nợ',
    status ENUM('UNPAID', 'PAID', 'PAID_PARTIAL', 'OVERDUE', 'CANCELLED') DEFAULT 'UNPAID',
    due_date DATE COMMENT 'Hạn thanh toán',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_store_id (store_id),
    KEY idx_customer_id (customer_id),
    KEY idx_status (status),
    KEY idx_due_date (due_date),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sổ nợ (Debt/Receivable)';

-- Table: payments
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    debt_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    amount DECIMAL(15, 0) NOT NULL COMMENT 'Số tiền thanh toán',
    payment_method ENUM('CASH', 'BANK_TRANSFER', 'CHEQUE', 'OTHER') DEFAULT 'CASH',
    reference_number VARCHAR(50) COMMENT 'Mã tham chiếu (cheque, transfer)',
    notes VARCHAR(500),
    created_by VARCHAR(30) COMMENT 'Người ghi nhận',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_store_id (store_id),
    KEY idx_debt_id (debt_id),
    KEY idx_customer_id (customer_id),
    KEY idx_created_at (created_at),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (debt_id) REFERENCES debts(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Phiếu thu (Payment)';

-- ============================================================================
-- PHASE 7: AI & Draft Order Tables
-- ============================================================================

-- Table: draft_orders
CREATE TABLE IF NOT EXISTS draft_orders (
    id VARCHAR(50) NOT NULL PRIMARY KEY COMMENT 'ID format: DRAFT-YYYYMMDD-XXX',
    store_id BIGINT NOT NULL,
    customer_id BIGINT,
    employee_id BIGINT NOT NULL COMMENT 'Nhân viên tạo draft',
    subtotal DECIMAL(15, 0) DEFAULT 0,
    total_amount DECIMAL(15, 0),
    payment_type ENUM('CASH', 'CREDIT') DEFAULT 'CASH',
    status ENUM('DRAFT', 'CONFIRMED', 'REJECTED', 'EXPIRED') DEFAULT 'DRAFT',
    related_order_id BIGINT COMMENT 'Order ID nếu đã confirm',
    ai_confidence DECIMAL(3, 2) COMMENT 'Độ tin cậy AI (0.00 - 1.00)',
    ai_parsed_data JSON COMMENT 'Dữ liệu parse từ AI (JSON)',
    ai_request_text VARCHAR(1000) COMMENT 'Input ban đầu từ người dùng',
    rejection_reason VARCHAR(500) COMMENT 'Lý do từ chối',
    expires_at TIMESTAMP COMMENT 'Hết hạn lúc',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(30),
    confirmed_at TIMESTAMP NULL COMMENT 'Thời điểm xác nhận',
    KEY idx_store_id (store_id),
    KEY idx_customer_id (customer_id),
    KEY idx_status (status),
    KEY idx_created_at (created_at),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (related_order_id) REFERENCES orders(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn nháp AI (Draft Order)';

-- Table: draft_order_items
CREATE TABLE IF NOT EXISTS draft_order_items (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    draft_id VARCHAR(50) NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 0),
    total_amount DECIMAL(15, 0),
    KEY idx_draft_id (draft_id),
    KEY idx_product_id (product_id),
    FOREIGN KEY (draft_id) REFERENCES draft_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết đơn nháp AI';

-- ============================================================================
-- PHASE 8: Subscription Management Tables
-- ============================================================================

-- Table: subscription_plans
CREATE TABLE IF NOT EXISTS subscription_plans (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Tên gói (Free, Starter, Professional)',
    description VARCHAR(255),
    price DECIMAL(15, 0) DEFAULT 0 COMMENT 'Giá tiền (VND/tháng)',
    duration_months INT DEFAULT 1 COMMENT 'Kỳ hạn (tháng)',
    features JSON COMMENT 'Danh sách features (JSON)',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_plan_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Gói dịch vụ (Subscription Plan)';

-- Table: subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
    id VARCHAR(50) NOT NULL PRIMARY KEY COMMENT 'Format: SUB-YYYYMMDD-XXX',
    store_id BIGINT NOT NULL,
    plan_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('ACTIVE', 'EXPIRED', 'CANCELLED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(30) COMMENT 'Admin tạo',
    KEY idx_store_id (store_id),
    KEY idx_status (status),
    KEY idx_end_date (end_date),
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Gói đăng ký (Subscription)';

-- ============================================================================
-- PHASE 9: Notification Tables
-- ============================================================================

-- Table: notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    type ENUM('ORDER_CREATED', 'PAYMENT_RECEIVED', 'DRAFT_READY', 'STOCK_LOW', 'DEBT_OVERDUE', 'SYSTEM') COMMENT 'Loại thông báo',
    title VARCHAR(100),
    message VARCHAR(500),
    reference_id BIGINT COMMENT 'ID của object liên quan (order, draft, etc)',
    reference_type VARCHAR(50) COMMENT 'Loại object (ORDER, DRAFT, DEBT)',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_user_id (user_id),
    KEY idx_is_read (is_read),
    KEY idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông báo (Notification)';

-- ============================================================================
-- PHASE 10: Audit & Logging Tables
-- ============================================================================

-- Table: audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT COMMENT 'Người thực hiện',
    action VARCHAR(50) COMMENT 'CREATE, READ, UPDATE, DELETE',
    entity_type VARCHAR(50) COMMENT 'User, Product, Order, etc',
    entity_id BIGINT COMMENT 'ID của entity bị tác động',
    old_value JSON COMMENT 'Giá trị cũ (update)',
    new_value JSON COMMENT 'Giá trị mới (create/update)',
    ip_address VARCHAR(45) COMMENT 'IP address',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_user_id (user_id),
    KEY idx_action (action),
    KEY idx_entity_type (entity_type),
    KEY idx_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sổ audit (Audit Log)';

-- ============================================================================
-- INDEXES (Performance Optimization)
-- ============================================================================

-- Additional indexes for frequently queried fields
CREATE INDEX idx_order_status_created ON orders(status, created_at);
CREATE INDEX idx_debt_status_due_date ON debts(status, due_date);
CREATE INDEX idx_product_name_store ON products(name, store_id);
CREATE INDEX idx_customer_name_store ON customers(name, store_id);
CREATE INDEX idx_stock_movement_created_store ON stock_movements(created_at, store_id);

-- ============================================================================
-- INITIAL DATA (Sample Data for Development)
-- ============================================================================

-- Insert default roles
INSERT INTO roles (name, description) VALUES
('ADMIN', 'Administrator - Manage whole system'),
('OWNER', 'Store owner - Manage store and employees'),
('EMPLOYEE', 'Employee - Create orders and manage sales');

-- Insert default permissions
INSERT INTO permissions (name, module, description) VALUES
('PRODUCT_CREATE', 'PRODUCT', 'Create product'),
('PRODUCT_READ', 'PRODUCT', 'View products'),
('PRODUCT_UPDATE', 'PRODUCT', 'Update product'),
('PRODUCT_DELETE', 'PRODUCT', 'Delete product'),
('ORDER_CREATE', 'ORDER', 'Create order'),
('ORDER_READ', 'ORDER', 'View order'),
('ORDER_CANCEL', 'ORDER', 'Cancel order'),
('CUSTOMER_CREATE', 'CUSTOMER', 'Create customer'),
('CUSTOMER_READ', 'CUSTOMER', 'View customer'),
('DEBT_READ', 'DEBT', 'View debt'),
('PAYMENT_CREATE', 'PAYMENT', 'Record payment'),
('REPORT_READ', 'REPORT', 'View reports'),
('USER_CREATE', 'USER', 'Create user'),
('USER_MANAGE', 'USER', 'Manage users'),
('SUBSCRIPTION_MANAGE', 'SUBSCRIPTION', 'Manage subscriptions'),
('SETTINGS_MANAGE', 'SETTINGS', 'Manage system settings');

-- Insert role-permission mappings
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p WHERE r.name = 'ADMIN'; -- Admin has all permissions

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'OWNER' AND p.name IN (
    'PRODUCT_CREATE', 'PRODUCT_READ', 'PRODUCT_UPDATE', 'PRODUCT_DELETE',
    'ORDER_CREATE', 'ORDER_READ', 'ORDER_CANCEL',
    'CUSTOMER_CREATE', 'CUSTOMER_READ',
    'DEBT_READ', 'PAYMENT_CREATE',
    'REPORT_READ', 'USER_CREATE', 'USER_MANAGE'
);

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'EMPLOYEE' AND p.name IN (
    'PRODUCT_READ', 'ORDER_CREATE', 'ORDER_READ',
    'CUSTOMER_READ', 'DEBT_READ', 'PAYMENT_CREATE',
    'REPORT_READ'
);

-- Insert sample data: Store
INSERT INTO stores (name, address, phone, email, tax_code) VALUES
('Cửa hàng Vật Liệu Demo', '123 Đường Lý Thái Tổ, Hà Nội', '0901234567', 'demo@bizflow.vn', '0123456789');

-- Insert sample data: Products Units
INSERT INTO product_units (name, symbol, is_default) VALUES
('bao', 'bao', 1),
('cái', 'cái', 0),
('bộ', 'bộ', 0),
('kg', 'kg', 0),
('lít', 'L', 0),
('m²', 'm²', 0),
('m³', 'm³', 0);

-- Insert sample data: Product Categories
INSERT INTO product_categories (store_id, name, description)
SELECT id, 'Vật liệu xây dựng', 'Xi măng, cát, sỏi, gạch' FROM stores LIMIT 1;

-- Insert sample data: Products
INSERT INTO products (store_id, category_id, name, sku, unit_id, unit_name, price, cost_price, reorder_level, created_by)
SELECT s.id, pc.id, 'Xi măng Portland 40kg', 'XM-PORT-40', pu.id, pu.name, 150000, 130000, 50, 'admin'
FROM stores s, product_categories pc, product_units pu 
WHERE pu.name = 'bao' LIMIT 1;

-- Insert sample data: Inventory
INSERT INTO inventory (store_id, product_id, quantity, reserved_quantity, available_quantity)
SELECT s.id, p.id, 100, 0, 100
FROM stores s, products p WHERE p.sku = 'XM-PORT-40' LIMIT 1;

-- Insert sample data: Subscription Plans
INSERT INTO subscription_plans (name, description, price, duration_months, features) VALUES
('Free', 'Gói miễn phí',  0, 1, JSON_OBJECT('maxProducts', 100, 'maxEmployees', 3, 'maxCustomers', 500, 'hasAI', FALSE, 'hasReports', FALSE)),
('Starter', 'Gói khởi đầu', 99000, 1, JSON_OBJECT('maxProducts', 500, 'maxEmployees', 10, 'maxCustomers', 2000, 'hasAI', TRUE, 'hasReports', TRUE)),
('Professional', 'Gói chuyên nghiệp', 299000, 1, JSON_OBJECT('maxProducts', 5000, 'maxEmployees', 50, 'maxCustomers', 10000, 'hasAI', TRUE, 'hasReports', TRUE, 'hasWebSocket', TRUE));

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
