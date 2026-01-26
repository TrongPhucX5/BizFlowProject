import axios from "@/lib/axios-client";

/** * KHỚP 100% VỚI DATABASE ENUM
 */
export type PaymentType = 'CASH' | 'CREDIT' | 'TRANSFER'; 

/** * KHỚP VỚI OrderStatus.java TRONG BACKEND
 */
export type OrderStatus = 'CONFIRMED' | 'PAID' | 'PAID_PARTIAL' | 'UNPAID' | 'CANCELLED';

export interface OrderFilterParams {
  page?: number;
  size?: number;
  status?: string;     
  startDate?: string;  
  endDate?: string;    
  customerId?: number; 
  sort?: string;       
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

export interface CreateOrderRequest {
  customerId: number;
  items: { 
    productId: number; 
    quantity: number; 
    unitPrice: number; 
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

    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== "") {
        if (key === 'status' && value === 'ALL') return;
        cleanParams[key] = value;
      }
    });

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
    const formattedData = formatOrderRequest(data);
    const response = await axios.post("/v1/orders", formattedData);
    return response.data;
  },

  /**
   * CẬP NHẬT ĐƠN HÀNG (MỚI)
   * Gọi đến @PutMapping("/{id}") trong Backend
   */
  updateOrder: async (id: number, data: CreateOrderRequest): Promise<ApiResponse<OrderDTO>> => {
    const formattedData = formatOrderRequest(data);
    const response = await axios.put(`/v1/orders/${id}`, formattedData);
    return response.data;
  },

  /**
   * HỦY ĐƠN HÀNG (MỚI)
   * Gọi đến @DeleteMapping("/{id}") trong Backend
   */
  deleteOrder: async (id: number): Promise<ApiResponse<void>> => {
    const response = await axios.delete(`/v1/orders/${id}`);
    return response.data;
  },

  /**
   * Cập nhật nhanh trạng thái đơn hàng (Dùng PATCH nếu backend có hỗ trợ)
   */
  updateOrderStatus: async (id: number, status: OrderStatus): Promise<ApiResponse<OrderDTO>> => {
    const response = await axios.patch(`/v1/orders/${id}/status`, null, {
      params: { status }
    });
    return response.data;
  }
};

/**
 * Hàm phụ trợ chuẩn hóa dữ liệu gửi lên Backend
 */
const formatOrderRequest = (data: CreateOrderRequest) => {
  if (!data.items || data.items.length === 0) {
    throw new Error("Vui lòng chọn ít nhất một sản phẩm.");
  }

  return {
    customerId: Number(data.customerId),
    discountAmount: Number(data.discountAmount || 0),
    paymentType: data.paymentType,
    status: data.status,
    notes: data.notes?.trim() || "",
    items: data.items
      .filter(item => Number(item.productId) > 0 && Number(item.quantity) > 0)
      .map(item => ({
        productId: Number(item.productId),
        quantity: Number(item.quantity),
        unitPrice: Number(item.unitPrice)
      }))
  };
};