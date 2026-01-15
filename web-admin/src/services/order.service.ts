import axios from "@/lib/axios-client";

/** * KHỚP 100% VỚI DATABASE ENUM: 'CASH', 'BANK_TRANSFER', 'CREDIT_CARD'
 */
export type PaymentType = 'CASH' | 'BANK_TRANSFER' | 'CREDIT_CARD'; 

/** * KHỚP VỚI OrderStatus.java TRONG BACKEND
 */
export type OrderStatus = 'PENDING' | 'CONFIRMED' | 'PAID' | 'PAID_PARTIAL' | 'UNPAID' | 'CANCELLED';

/**
 * Interface cho tham số lọc - Khớp hoàn toàn với OrderController.java
 */
export interface OrderFilterParams {
  page?: number;
  size?: number;
  status?: string;     
  startDate?: string;  // Định dạng chuẩn: yyyy-MM-dd
  endDate?: string;    // Định dạng chuẩn: yyyy-MM-dd
  customerId?: number; 
  sort?: string;       // Thêm sort để linh hoạt (ví dụ: 'createdAt,desc')
}

export interface OrderItemDTO {
  id?: number;
  productId: number;
  quantity: number;
  unitPrice: number;
  totalAmount: number;
  productName?: string; 
}

export interface OrderDTO {
  id: number;
  orderNumber: string;
  customerId: number;
  customerName?: string;
  subtotal: number;
  discountAmount: number;
  totalAmount: number;
  paymentType: PaymentType;
  status: OrderStatus;
  notes?: string;
  createdAt: string;
  items: OrderItemDTO[];
}

/**
 * CẬP NHẬT: Interface tạo đơn hàng cần có unitPrice cho từng item
 */
export interface CreateOrderRequest {
  customerId: number;
  items: { 
    productId: number; 
    quantity: number; 
    unitPrice: number; // TRƯỜNG MỚI: Bắt buộc để Backend tính toán
  }[];
  discountAmount: number;
  paymentType: PaymentType; 
  status: OrderStatus; 
  notes?: string;
}

export interface PageResponse<T> {
  content: T[]; 
  totalElements: number;
  totalPages: number;
  size: number;
  number: number; 
}

export interface ApiResponse<T> {
  code: number;
  message: string;
  result: T; 
}



export const orderService = {
  /**
   * Lấy danh sách đơn hàng có phân trang và bộ lọc
   */
  getAllOrders: async (params: OrderFilterParams): Promise<ApiResponse<PageResponse<OrderDTO>>> => {
    const cleanParams: Record<string, any> = {};

    // 1. CHUẨN HÓA THAM SỐ GỬI LÊN
    Object.entries(params).forEach(([key, value]) => {
      // LOẠI BỎ: null, undefined, chuỗi rỗng
      if (value !== undefined && value !== null && value !== "") {
        // Nếu là trạng thái 'ALL', không gửi tham số này để Backend dùng default (null)
        if (key === 'status' && value === 'ALL') return;
        
        cleanParams[key] = value;
      }
    });

    // 2. MẶC ĐỊNH SẮP XẾP NẾU CHƯA CÓ
    if (!cleanParams.sort) {
      cleanParams.sort = 'createdAt,desc';
    }
    
    const response = await axios.get("/v1/orders", { params: cleanParams });
    return response.data;
  },

  /**
   * Lấy chi tiết đơn hàng
   */
  getOrderById: async (id: number): Promise<ApiResponse<OrderDTO>> => {
    const response = await axios.get(`/v1/orders/${id}`);
    return response.data;
  },

  /**
   * Tạo đơn hàng mới
   */
  createOrder: async (data: CreateOrderRequest): Promise<ApiResponse<OrderDTO>> => {
    // Ép kiểu dữ liệu số để tránh lỗi string từ input form
    const formattedData = {
      ...data,
      customerId: Number(data.customerId),
      discountAmount: Number(data.discountAmount || 0),
      items: data.items
        .filter(item => Number(item.productId) > 0 && Number(item.quantity) > 0)
        .map(item => ({
          productId: Number(item.productId),
          quantity: Number(item.quantity),    // Cho phép số thập phân (ví dụ: 1.5kg)
          unitPrice: Number(item.unitPrice)   // CẬP NHẬT: Gửi giá bán đã chỉnh sửa lên backend
        }))
    };

    if (formattedData.items.length === 0) {
      throw new Error("Vui lòng chọn ít nhất một sản phẩm hợp lệ.");
    }

    const response = await axios.post("/v1/orders", formattedData);
    return response.data;
  }
};