# 📚 BizFlow Backend API Documentation

**Base URL**: `http://localhost:8080/api/v1`  
**Version**: 1.0.0  
**Last Updated**: December 13, 2025

---

## Table of Contents

1. [Authentication APIs](#1-authentication-apis)
2. [Product Management APIs](#2-product-management-apis)
3. [Customer Management APIs](#3-customer-management-apis)
4. [Order Management APIs](#4-order-management-apis)
5. [Inventory APIs](#5-inventory-apis)
6. [Debt & Payment APIs](#6-debt--payment-apis)
7. [Report APIs](#7-report-apis)
8. [AI Gateway APIs](#8-ai-gateway-apis)
9. [Subscription APIs](#9-subscription-apis)
10. [Error Codes Reference](#10-error-codes-reference)

---

## 1. Authentication APIs

### 1.1 User Login

**Endpoint**: `POST /auth/login`

**Description**: Authenticate user and receive JWT tokens

**Request**:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "owner01",
    "password": "SecurePassword123"
  }'
```

**Request Body**:
```json
{
  "username": "owner01",
  "password": "SecurePassword123"
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| username | string | ✓ | Length: 3-30, alphanumeric |
| password | string | ✓ | Length: 8+, must have numbers & special chars |

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Login successful",
  "result": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "owner01",
      "fullName": "Nguyễn Văn A",
      "role": "OWNER",
      "email": "owner@email.com",
      "storeId": 1,
      "storeName": "Cửa hàng Vật Liệu A"
    }
  },
  "timestamp": "2025-01-01T10:30:00Z"
}
```

**Error** (401 Unauthorized):
```json
{
  "code": 4010,
  "message": "Invalid username or password",
  "result": null,
  "timestamp": "2025-01-01T10:30:00Z"
}
```

**Status Codes**:
- `200 OK` - Login successful
- `400 Bad Request` - Missing fields
- `401 Unauthorized` - Invalid credentials
- `429 Too Many Requests` - Too many failed login attempts

---

### 1.2 Token Refresh

**Endpoint**: `POST /auth/refresh`

**Description**: Get new access token using refresh token

**Request**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Token refreshed",
  "result": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600
  }
}
```

---

### 1.3 User Register (Admin only)

**Endpoint**: `POST /auth/register`

**Description**: Create new user account

**Authorization**: Requires `Authorization: Bearer <ADMIN_TOKEN>`

**Request**:
```json
{
  "username": "newuser01",
  "password": "SecurePass123",
  "fullName": "Trần Thị B",
  "role": "EMPLOYEE",
  "email": "b@email.com",
  "storeId": 1
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| username | string | ✓ | Unique, 3-30 chars |
| password | string | ✓ | 8+ chars, complexity required |
| fullName | string | ✓ | Max 100 chars |
| role | enum | ✓ | ADMIN, OWNER, or EMPLOYEE |
| email | string | ✓ | Valid email format |
| storeId | number | ○ | Required if role != ADMIN |

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "User created successfully",
  "result": {
    "id": 5,
    "username": "newuser01",
    "fullName": "Trần Thị B",
    "role": "EMPLOYEE",
    "email": "b@email.com",
    "createdAt": "2025-01-01T10:30:00Z"
  }
}
```

---

### 1.4 Change Password

**Endpoint**: `PUT /users/change-password`

**Authorization**: Required (any authenticated user)

**Request**:
```json
{
  "oldPassword": "OldSecurePass123",
  "newPassword": "NewSecurePass456"
}
```

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Password changed successfully",
  "result": null
}
```

---

## 2. Product Management APIs

### 2.1 Create Product

**Endpoint**: `POST /products`

**Authorization**: Requires `Role: OWNER` or `ADMIN`

**Request**:
```bash
curl -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "name": "Xi măng Portland 40kg",
    "sku": "XM-PORT-40",
    "description": "Xi măng chất lượng cao",
    "price": 150000,
    "unit": "bao",
    "categoryId": 1,
    "reorderLevel": 50,
    "imageUrl": "https://..."
  }'
```

**Request Body**:
```json
{
  "name": "Xi măng Portland 40kg",
  "sku": "XM-PORT-40",
  "description": "Xi măng chất lượng cao",
  "price": 150000,
  "unit": "bao",
  "categoryId": 1,
  "reorderLevel": 50,
  "imageUrl": null
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | ✓ | Max 100 chars |
| sku | string | ✓ | Unique within store |
| description | string | ○ | Max 500 chars |
| price | decimal | ✓ | Minimum 1,000 VND |
| unit | enum | ✓ | bao, cái, bộ, kg, lít, m², m³, etc. |
| categoryId | number | ✓ | Must exist |
| reorderLevel | number | ○ | Default 0 |
| imageUrl | string | ○ | URL to product image |

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "Product created successfully",
  "result": {
    "id": 101,
    "storeId": 1,
    "name": "Xi măng Portland 40kg",
    "sku": "XM-PORT-40",
    "price": 150000,
    "unit": "bao",
    "categoryId": 1,
    "reorderLevel": 50,
    "imageUrl": null,
    "createdAt": "2025-01-01T10:35:00Z",
    "createdBy": "owner01"
  }
}
```

**Error** (400 Bad Request):
```json
{
  "code": 4000,
  "message": "Validation error",
  "result": null,
  "errors": [
    {
      "field": "sku",
      "message": "SKU 'XM-PORT-40' already exists in your store"
    },
    {
      "field": "price",
      "message": "Price must be >= 1000"
    }
  ]
}
```

---

### 2.2 List Products (with Pagination & Filter)

**Endpoint**: `GET /products`

**Authorization**: Optional (public list if no auth)

**Query Parameters**:

| Parameter | Type | Default | Notes |
|-----------|------|---------|-------|
| page | number | 1 | Page number (1-indexed) |
| size | number | 20 | Items per page (max 100) |
| search | string | - | Search by name/sku (case-insensitive) |
| categoryId | number | - | Filter by category |
| sort | string | createdAt,desc | Sort by field (name,price,createdAt) & direction (asc/desc) |

**Request**:
```bash
curl "http://localhost:8080/api/v1/products?page=1&size=20&search=xi+mang&sort=price,asc" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Products retrieved successfully",
  "result": {
    "items": [
      {
        "id": 101,
        "storeId": 1,
        "name": "Xi măng Portland 40kg",
        "sku": "XM-PORT-40",
        "price": 150000,
        "unit": "bao",
        "categoryId": 1,
        "categoryName": "Vật liệu xây dựng",
        "currentStock": 245,
        "reorderLevel": 50,
        "imageUrl": null,
        "createdAt": "2025-01-01T10:35:00Z"
      },
      {
        "id": 102,
        "storeId": 1,
        "name": "Xi măng Hải Long",
        "sku": "XM-HL-50",
        "price": 160000,
        "unit": "bao",
        "categoryId": 1,
        "categoryName": "Vật liệu xây dựng",
        "currentStock": 180,
        "reorderLevel": 50,
        "imageUrl": null,
        "createdAt": "2025-01-02T09:15:00Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "pageSize": 20,
      "totalElements": 102,
      "totalPages": 6,
      "hasNext": true,
      "hasPrevious": false
    }
  }
}
```

---

### 2.3 Get Product Detail

**Endpoint**: `GET /products/{id}`

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Product details retrieved",
  "result": {
    "id": 101,
    "storeId": 1,
    "name": "Xi măng Portland 40kg",
    "sku": "XM-PORT-40",
    "description": "Xi măng chất lượng cao",
    "price": 150000,
    "unit": "bao",
    "categoryId": 1,
    "categoryName": "Vật liệu xây dựng",
    "currentStock": 245,
    "reorderLevel": 50,
    "imageUrl": null,
    "createdAt": "2025-01-01T10:35:00Z",
    "createdBy": "owner01",
    "updatedAt": "2025-01-01T10:35:00Z",
    "updatedBy": "owner01",
    "priceHistory": [
      {
        "price": 150000,
        "changedAt": "2025-01-01T10:35:00Z",
        "changedBy": "owner01"
      }
    ]
  }
}
```

---

### 2.4 Update Product

**Endpoint**: `PUT /products/{id}`

**Authorization**: Requires `Role: OWNER`

**Request**: Same body as POST /products (only modified fields)

**Response** (200 OK): Updated product details

---

### 2.5 Delete Product

**Endpoint**: `DELETE /products/{id}`

**Authorization**: Requires `Role: OWNER`

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Product deleted successfully",
  "result": null
}
```

**Error** (400 Bad Request):
```json
{
  "code": 4000,
  "message": "Cannot delete product: already sold in 5 orders",
  "result": null
}
```

---

## 3. Customer Management APIs

### 3.1 Create Customer

**Endpoint**: `POST /customers`

**Authorization**: Required (`OWNER` or `EMPLOYEE`)

**Request**:
```json
{
  "name": "Công ty Vật Liệu A",
  "phone": "0901234567",
  "email": "a@email.com",
  "address": "123 Đường Lý Thái Tổ, Hà Nội",
  "type": "RETAIL",
  "taxCode": "0123456789",
  "contactPerson": "Anh Hòa"
}
```

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "Customer created successfully",
  "result": {
    "id": 1,
    "name": "Công ty Vật Liệu A",
    "phone": "0901234567",
    "email": "a@email.com",
    "address": "123 Đường Lý Thái Tổ, Hà Nội",
    "type": "RETAIL",
    "taxCode": "0123456789",
    "contactPerson": "Anh Hòa",
    "createdAt": "2025-01-01T10:40:00Z"
  }
}
```

---

### 3.2 List Customers

**Endpoint**: `GET /customers`

**Query Parameters**: page, size, search (by name/phone), sort

**Response**: Paginated customer list

---

### 3.3 Get Customer Detail with Debt Info

**Endpoint**: `GET /customers/{id}`

**Response**:
```json
{
  "code": 1000,
  "message": "Customer details retrieved",
  "result": {
    "id": 1,
    "name": "Công ty Vật Liệu A",
    "phone": "0901234567",
    "email": "a@email.com",
    "address": "123 Đường Lý Thái Tổ, Hà Nội",
    "type": "RETAIL",
    "createdAt": "2025-01-01T10:40:00Z",
    "debtSummary": {
      "totalDebt": 5000000,
      "paidAmount": 3000000,
      "unpaidAmount": 2000000,
      "overdueAmount": 500000,
      "lastPaymentDate": "2025-01-15T14:30:00Z",
      "nextDueDate": "2025-02-01T00:00:00Z"
    },
    "orderStatistics": {
      "totalOrders": 25,
      "totalAmount": 50000000,
      "averageOrder": 2000000,
      "lastOrderDate": "2025-01-18T11:20:00Z"
    }
  }
}
```

---

## 4. Order Management APIs

### 4.1 Create Order (POS)

**Endpoint**: `POST /orders`

**Authorization**: Required (`EMPLOYEE` or `OWNER`)

**Request**:
```json
{
  "customerId": 1,
  "items": [
    {
      "productId": 101,
      "quantity": 10,
      "unitPrice": 150000
    },
    {
      "productId": 102,
      "quantity": 5,
      "unitPrice": 160000
    }
  ],
  "paymentType": "CASH",
  "discountAmount": 50000,
  "notes": "Giao hàng ngày mai"
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| customerId | number | ✓ | Must exist |
| items | array | ✓ | At least 1 item, productId & quantity required |
| paymentType | enum | ✓ | CASH or CREDIT |
| discountAmount | decimal | ○ | Default 0, max 50% of total |
| notes | string | ○ | Max 500 chars |

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "Order created successfully",
  "result": {
    "id": 1001,
    "orderNumber": "ORD-20250101-001",
    "customerId": 1,
    "customerName": "Công ty Vật Liệu A",
    "items": [
      {
        "productId": 101,
        "productName": "Xi măng Portland 40kg",
        "quantity": 10,
        "unitPrice": 150000,
        "totalAmount": 1500000
      },
      {
        "productId": 102,
        "productName": "Xi măng Hải Long",
        "quantity": 5,
        "unitPrice": 160000,
        "totalAmount": 800000
      }
    ],
    "subtotal": 2300000,
    "discountAmount": 50000,
    "totalAmount": 2250000,
    "paymentType": "CASH",
    "status": "CONFIRMED",
    "notes": "Giao hàng ngày mai",
    "createdAt": "2025-01-01T10:45:00Z",
    "createdBy": "employee01"
  }
}
```

---

### 4.2 List Orders

**Endpoint**: `GET /orders`

**Query Parameters**:
- page, size
- customerId
- status (CONFIRMED, PAID, PAID_PARTIAL, CANCELLED)
- from (date), to (date)
- sort (createdAt, totalAmount)

**Response**: Paginated order list

---

### 4.3 Get Order Detail

**Endpoint**: `GET /orders/{id}`

**Response**: Full order with items, customer, payment history

---

### 4.4 Cancel Order

**Endpoint**: `POST /orders/{id}/cancel`

**Authorization**: Requires `OWNER` role

**Request**:
```json
{
  "reason": "Khách hàng hủy"
}
```

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Order cancelled successfully",
  "result": {
    "id": 1001,
    "status": "CANCELLED",
    "cancelledAt": "2025-01-02T09:20:00Z",
    "cancelledBy": "owner01",
    "reason": "Khách hàng hủy",
    "stockRestored": [
      {
        "productId": 101,
        "quantity": 10
      },
      {
        "productId": 102,
        "quantity": 5
      }
    ]
  }
}
```

---

### 4.5 Print/Export Order (Invoice)

**Endpoint**: `GET /orders/{id}/print`

**Query Parameters**: format (pdf|html)

**Response**: PDF or HTML file download

---

## 5. Inventory APIs

### 5.1 Get Current Stock

**Endpoint**: `GET /inventory`

**Query Parameters**: productId (filter by product)

**Response**:
```json
{
  "code": 1000,
  "message": "Stock levels retrieved",
  "result": [
    {
      "productId": 101,
      "productName": "Xi măng Portland 40kg",
      "sku": "XM-PORT-40",
      "quantity": 245,
      "reorderLevel": 50,
      "status": "NORMAL"
    },
    {
      "productId": 102,
      "productName": "Xi măng Hải Long",
      "sku": "XM-HL-50",
      "quantity": 30,
      "reorderLevel": 50,
      "status": "LOW"
    }
  ]
}
```

---

### 5.2 Stock In (Add Stock)

**Endpoint**: `POST /inventory/stock-in`

**Authorization**: Requires `OWNER` role

**Request**:
```json
{
  "productId": 101,
  "quantity": 100,
  "unitCost": 130000,
  "supplierName": "Công ty Xi Măng X",
  "referenceNumber": "PO-20250101-001"
}
```

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "Stock added successfully",
  "result": {
    "movementId": "SM-20250101-001",
    "productId": 101,
    "productName": "Xi măng Portland 40kg",
    "type": "STOCK_IN",
    "quantity": 100,
    "unitCost": 130000,
    "totalCost": 13000000,
    "supplierName": "Công ty Xi Măng X",
    "referenceNumber": "PO-20250101-001",
    "newBalance": 345,
    "createdAt": "2025-01-02T09:30:00Z",
    "createdBy": "owner01"
  }
}
```

---

### 5.3 Stock Adjustment

**Endpoint**: `POST /inventory/adjust`

**Authorization**: Requires `OWNER` role

**Request**:
```json
{
  "productId": 101,
  "newQuantity": 240,
  "reason": "Hàng hỏng, loại bỏ 5 bao"
}
```

**Response** (200 OK): Stock movement record

---

### 5.4 Stock Movement History

**Endpoint**: `GET /inventory/movements`

**Query Parameters**:
- productId
- type (SALE, STOCK_IN, STOCK_ADJUST)
- from, to (date range)
- sort

**Response**: List of stock movements

---

### 5.5 Low Stock Alert

**Endpoint**: `GET /inventory/low-stock`

**Response**:
```json
{
  "code": 1000,
  "message": "Low stock products",
  "result": [
    {
      "productId": 102,
      "productName": "Xi măng Hải Long",
      "sku": "XM-HL-50",
      "currentStock": 30,
      "reorderLevel": 50,
      "deficit": 20,
      "recommendedOrder": 100
    }
  ]
}
```

---

## 6. Debt & Payment APIs

### 6.1 List Outstanding Debts

**Endpoint**: `GET /debts`

**Query Parameters**:
- status (UNPAID, PAID_PARTIAL, OVERDUE)
- customerId
- from, to
- sort (createdAt, amount, dueDate)

**Response**:
```json
{
  "code": 1000,
  "message": "Debts retrieved",
  "result": {
    "items": [
      {
        "id": 1,
        "orderId": 1001,
        "customerId": 1,
        "customerName": "Công ty Vật Liệu A",
        "originalAmount": 2250000,
        "paidAmount": 1000000,
        "unpaidAmount": 1250000,
        "status": "PAID_PARTIAL",
        "createdAt": "2025-01-01T10:45:00Z",
        "dueAt": "2025-02-01T00:00:00Z",
        "isOverdue": false,
        "overdueDays": 0
      }
    ],
    "pagination": { ... }
  }
}
```

---

### 6.2 Get Customer Debt Summary

**Endpoint**: `GET /debts/customer/{customerId}`

**Response**:
```json
{
  "code": 1000,
  "message": "Customer debt summary",
  "result": {
    "customerId": 1,
    "customerName": "Công ty Vật Liệu A",
    "totalDebt": 5000000,
    "paidAmount": 3000000,
    "unpaidAmount": 2000000,
    "overdueAmount": 500000,
    "overdueCount": 2,
    "lastPaymentDate": "2025-01-15T14:30:00Z",
    "nextDueDate": "2025-02-01T00:00:00Z",
    "debtDetails": [
      {
        "debtId": 1,
        "orderId": 1001,
        "amount": 2250000,
        "status": "PAID_PARTIAL",
        "createdAt": "2025-01-01T10:45:00Z"
      }
    ]
  }
}
```

---

### 6.3 Record Payment

**Endpoint**: `POST /payments`

**Authorization**: Required (`OWNER` or `EMPLOYEE`)

**Request**:
```json
{
  "debtId": 1,
  "amount": 500000,
  "paymentMethod": "CASH",
  "notes": "Thanh toán nợ hàng tháng"
}
```

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "Payment recorded successfully",
  "result": {
    "id": 1,
    "debtId": 1,
    "orderId": 1001,
    "customerId": 1,
    "amount": 500000,
    "paymentMethod": "CASH",
    "notes": "Thanh toán nợ hàng tháng",
    "debtStatus": "PAID_PARTIAL",
    "debtRemainingAmount": 750000,
    "createdAt": "2025-01-16T15:00:00Z",
    "createdBy": "owner01"
  }
}
```

---

### 6.4 Payment History

**Endpoint**: `GET /payments`

**Query Parameters**: customerId, debtId, from, to

**Response**: List of payments

---

## 7. Report APIs

### 7.1 Dashboard Overview

**Endpoint**: `GET /reports/dashboard`

**Query Parameters**:
- from (date, default: 1st day of month)
- to (date, default: today)

**Response**:
```json
{
  "code": 1000,
  "message": "Dashboard data retrieved",
  "result": {
    "period": {
      "from": "2025-01-01",
      "to": "2025-01-31",
      "days": 31
    },
    "revenue": {
      "total": 50000000,
      "cash": 35000000,
      "credit": 15000000,
      "average": 1612903,
      "trend": 12.5
    },
    "orders": {
      "total": 31,
      "completed": 30,
      "cancelled": 1,
      "average": 1612903
    },
    "debt": {
      "outstanding": 15000000,
      "overdue": 2000000,
      "overdueCount": 3
    },
    "inventory": {
      "totalValue": 100000000,
      "lowStockCount": 5,
      "topProducts": [
        {
          "productId": 101,
          "productName": "Xi măng Portland 40kg",
          "quantity": 500,
          "amount": 75000000
        }
      ]
    },
    "dailyRevenue": [
      {
        "date": "2025-01-01",
        "amount": 2000000
      },
      ...
    ]
  }
}
```

---

### 7.2 Sales Report

**Endpoint**: `GET /reports/sales`

**Query Parameters**:
- from, to
- groupBy (DAILY | WEEKLY | MONTHLY)
- productId (filter)

**Response**: Time-series sales data

---

### 7.3 Inventory Report

**Endpoint**: `GET /reports/inventory`

**Response**:
```json
{
  "code": 1000,
  "message": "Inventory report",
  "result": {
    "totalItems": 102,
    "totalValue": 100000000,
    "lowStockCount": 5,
    "products": [
      {
        "productId": 101,
        "productName": "Xi măng Portland 40kg",
        "sku": "XM-PORT-40",
        "unit": "bao",
        "quantity": 245,
        "reorderLevel": 50,
        "unitCost": 130000,
        "totalValue": 31850000,
        "status": "NORMAL"
      }
    ]
  }
}
```

---

### 7.4 Customer Debt Report

**Endpoint**: `GET /reports/debts`

**Query Parameters**: status, sortBy (amount | overdueAmount)

**Response**: List of customers sorted by debt

---

## 8. AI Gateway APIs

### 8.1 Create Draft Order from Text/Voice

**Endpoint**: `POST /ai/draft-order`

**Authorization**: Required (`EMPLOYEE` or `OWNER`)

**Request**:
```json
{
  "input": "bán 10 bao xi măng cho anh Hòa, ghi nợ nha",
  "inputType": "TEXT"
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| input | string | ✓ | Vietnamese text or voice transcription |
| inputType | enum | ✓ | TEXT or VOICE |

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "Draft order created from AI",
  "result": {
    "id": "DRAFT-20250101-001",
    "status": "DRAFT",
    "aiConfidence": 0.95,
    "aiParsedData": {
      "products": [
        {
          "name": "xi măng",
          "quantity": 10,
          "matchedProductId": 101,
          "matchedProductName": "Xi măng Portland 40kg",
          "confidence": 0.98
        }
      ],
      "customer": {
        "name": "anh Hòa",
        "matchedCustomerId": 1,
        "matchedCustomerName": "Công ty Vật Liệu A",
        "confidence": 0.85
      },
      "paymentType": "CREDIT"
    },
    "items": [
      {
        "productId": 101,
        "productName": "Xi măng Portland 40kg",
        "quantity": 10,
        "unitPrice": 150000,
        "totalAmount": 1500000
      }
    ],
    "customerId": 1,
    "customerName": "Công ty Vật Liệu A",
    "subtotal": 1500000,
    "totalAmount": 1500000,
    "paymentType": "CREDIT",
    "assignedTo": "employee01",
    "createdAt": "2025-01-01T10:50:00Z",
    "expiresAt": "2025-01-02T10:50:00Z"
  }
}
```

**Error** (400 Bad Request - Low Confidence):
```json
{
  "code": 4000,
  "message": "Could not parse order clearly enough (confidence: 0.45). Please create order manually.",
  "result": {
    "suggestions": [
      "Be more specific about product names",
      "Ensure customer name is clear"
    ]
  }
}
```

---

### 8.2 Edit Draft Order (Before Confirming)

**Endpoint**: `PUT /ai/draft-order/{draftId}`

**Authorization**: Required (draft creator)

**Request**: (same structure as order create, only modified fields)

**Response** (200 OK): Updated draft order

---

### 8.3 Confirm Draft Order

**Endpoint**: `POST /ai/draft-order/{draftId}/confirm`

**Authorization**: Required (draft creator)

**Response** (201 Created): **Actual Order** (same as POST /orders response)

---

### 8.4 Reject Draft Order

**Endpoint**: `POST /ai/draft-order/{draftId}/reject`

**Authorization**: Required (draft creator)

**Request**:
```json
{
  "reason": "Sản phẩm hết hàng"
}
```

**Response** (200 OK):
```json
{
  "code": 1000,
  "message": "Draft order rejected",
  "result": {
    "id": "DRAFT-20250101-001",
    "status": "REJECTED",
    "reason": "Sản phẩm hết hàng",
    "rejectedAt": "2025-01-01T10:55:00Z",
    "rejectedBy": "employee01"
  }
}
```

---

## 9. Subscription APIs

### 9.1 List Subscription Plans (Admin)

**Endpoint**: `GET /subscriptions/plans`

**Authorization**: Requires `ADMIN` role

**Response**:
```json
{
  "code": 1000,
  "message": "Subscription plans retrieved",
  "result": [
    {
      "id": 1,
      "name": "Free",
      "price": 0,
      "currency": "VND",
      "durationMonths": 1,
      "features": {
        "maxProducts": 100,
        "maxEmployees": 3,
        "maxCustomers": 500,
        "hasAI": false,
        "hasReports": false,
        "hasWebSocket": false
      },
      "createdAt": "2025-01-01T00:00:00Z"
    },
    {
      "id": 2,
      "name": "Starter",
      "price": 99000,
      "currency": "VND",
      "durationMonths": 1,
      "features": {
        "maxProducts": 500,
        "maxEmployees": 10,
        "maxCustomers": 2000,
        "hasAI": true,
        "hasReports": true,
        "hasWebSocket": false
      }
    }
  ]
}
```

---

### 9.2 Create Subscription Plan (Admin)

**Endpoint**: `POST /subscriptions/plans`

**Authorization**: Requires `ADMIN` role

**Request**:
```json
{
  "name": "Professional",
  "price": 299000,
  "durationMonths": 1,
  "features": {
    "maxProducts": 5000,
    "maxEmployees": 50,
    "maxCustomers": 10000,
    "hasAI": true,
    "hasReports": true,
    "hasWebSocket": true
  }
}
```

**Response** (201 Created): Plan details

---

### 9.3 Assign Subscription to Owner (Admin)

**Endpoint**: `POST /subscriptions/assign`

**Authorization**: Requires `ADMIN` role

**Request**:
```json
{
  "ownerId": 1,
  "planId": 2,
  "startDate": "2025-01-01",
  "durationMonths": 12
}
```

**Response** (201 Created):
```json
{
  "code": 1000,
  "message": "Subscription assigned successfully",
  "result": {
    "id": "SUB-20250101-001",
    "ownerId": 1,
    "planId": 2,
    "planName": "Starter",
    "startDate": "2025-01-01",
    "endDate": "2026-01-01",
    "status": "ACTIVE",
    "assignedAt": "2025-01-01T12:00:00Z",
    "assignedBy": "admin01"
  }
}
```

---

### 9.4 Get Owner's Current Subscription

**Endpoint**: `GET /subscriptions/my-subscription`

**Authorization**: Required (OWNER)

**Response**:
```json
{
  "code": 1000,
  "message": "Current subscription",
  "result": {
    "id": "SUB-20250101-001",
    "planId": 2,
    "planName": "Starter",
    "features": {
      "maxProducts": 500,
      "currentProducts": 102,
      "maxEmployees": 10,
      "currentEmployees": 3,
      "maxCustomers": 2000,
      "currentCustomers": 45,
      "hasAI": true,
      "hasReports": true,
      "hasWebSocket": false
    },
    "startDate": "2025-01-01",
    "endDate": "2026-01-01",
    "daysRemaining": 365,
    "status": "ACTIVE"
  }
}
```

---

## 10. Error Codes Reference

| Code | HTTP | Message | Meaning |
|------|------|---------|---------|
| **1000** | 200 | Success | Operation completed successfully |
| **2000** | 204 | No Content | Success but no data to return |
| **4000** | 400 | Validation Error | Invalid input data |
| **4001** | 400 | Missing Required Field | Required field not provided |
| **4002** | 400 | Invalid Format | Data format invalid (email, date, etc) |
| **4010** | 401 | Unauthorized | Missing or invalid token |
| **4011** | 401 | Token Expired | JWT token expired, use refresh token |
| **4012** | 401 | Invalid Credentials | Wrong username/password |
| **4030** | 403 | Forbidden | Authenticated but no permission |
| **4031** | 403 | Insufficient Subscription | Feature not available in current plan |
| **4040** | 404 | Not Found | Resource does not exist |
| **4090** | 409 | Conflict | Resource already exists (unique constraint) |
| **5000** | 500 | Internal Server Error | Unexpected server error |
| **5001** | 500 | Database Error | Database operation failed |
| **5002** | 500 | External API Error | Call to Gemini/Firebase failed |
| **5003** | 503 | Service Unavailable | Service temporarily down |

### 10.1 Example Error Response

```json
{
  "code": 4030,
  "message": "Insufficient permissions",
  "result": null,
  "timestamp": "2025-01-01T10:35:00Z",
  "errors": [
    {
      "field": "role",
      "message": "This feature requires OWNER role. Your role: EMPLOYEE"
    }
  ]
}
```

---

## General Notes

### Authentication Header

All endpoints except `/auth/login`, `/auth/register` require:

```
Authorization: Bearer <access_token>
```

### Timestamp Format

All timestamps in responses are ISO 8601 UTC format:

```
2025-01-01T10:30:00Z
```

### Pagination

Endpoints returning lists use this format:

```json
{
  "items": [...],
  "pagination": {
    "currentPage": 1,
    "pageSize": 20,
    "totalElements": 500,
    "totalPages": 25,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

### CORS

Frontend origin must be whitelisted in `SecurityConfig`:
- Development: `http://localhost:3000`, `http://localhost:3001`
- Production: `https://app.bizflow.vn`, `https://admin.bizflow.vn`

---

**Last Updated**: December 13, 2025  
**API Version**: v1  
**Status**: Production Ready
