export interface Product {
  id: number;
  sku: string;
  name: string;
  unitId?: number;
  unitName?: string; // <--- Thêm dòng này
  costPrice?: number;
  price: number;
  description?: string;
  status?: "ACTIVE" | "INACTIVE" | "DISCONTINUED"; // Hoặc string
  imageUrl?: string;
  categoryId?: number;
  stock?: number; // <--- Thêm dòng này
  reorderLevel?: number; // <--- Thêm dòng này
  storeId?: number;
}

// Khớp với ApiResponse bên Java
export interface ApiResponse<T> {
  code: number;
  message: string;
  result: T;
  timestamp: string;
}

// Khớp với Page<ProductDTO> bên Java
export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

// Bổ sung vào file types/api.ts hiện có

export interface Order {
  id: number;
  orderCode: string;
  customerId?: number;
  customerName?: string;
  customerPhone?: string;
  totalAmount: number;
  paidAmount: number;
  remainingAmount: number;
  status:
    | "PENDING"
    | "CONFIRMED"
    | "PROCESSING"
    | "COMPLETED"
    | "CANCELLED"
    | "UNPAID"
    | "PAID_PARTIAL"
    | "PAID";
  paymentMethod?: "CASH" | "BANK_TRANSFER" | "MOMO" | "VNPAY";
  storeId: number;
  createdAt: string;
  updatedAt: string;
  items?: OrderItem[];
}

export interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export interface Customer {
  id: number;
  code: string;
  fullName: string;
  phone: string;
  email?: string;
  address?: string;
  totalDebt: number;
  totalPurchaseAmount: number;
  status: "ACTIVE" | "INACTIVE";
  customerType: "REGULAR" | "VIP" | "WHOLESALE";
  storeId: number;
  createdAt: string;
  updatedAt: string;
}

export interface ReportData {
  date: string;
  revenue: number;
  ordersCount: number;
  averageOrderValue: number;
}

export interface StockAlert {
  productId: number;
  productName: string;
  currentStock: number;
  reorderLevel: number;
  unitName: string;
}

export interface DebtReport {
  customerId: number;
  customerName: string;
  totalDebt: number;
  lastPurchaseDate: string;
}
