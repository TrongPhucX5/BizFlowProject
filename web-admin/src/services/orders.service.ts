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
      // Loại bỏ các giá trị null/undefined hoặc chuỗi rỗng
      if (value !== undefined && value !== null && value !== "") {
        // Nếu status là 'ALL', không gửi lên backend để lấy tất cả
        if (key === 'status' && value === 'ALL') return;
        cleanParams[key] = value;
      }
    });

    // Mặc định sắp xếp theo ngày mới nhất nếu không truyền sort
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
   * Cập nhật đơn hàng (PUT)
   */
  updateOrder: async (id: number, data: CreateOrderRequest): Promise<ApiResponse<OrderDTO>> => {
    const formattedData = formatOrderRequest(data);
    const response = await axios.put(`/v1/orders/${id}`, formattedData);
    return response.data;
  },

  /**
   * Hủy/Xóa đơn hàng (DELETE)
   */
  deleteOrder: async (id: number): Promise<ApiResponse<void>> => {
    const response = await axios.delete(`/v1/orders/${id}`);
    return response.data;
  },

  /**
   * Cập nhật nhanh trạng thái đơn hàng (PATCH)
   */
  updateOrderStatus: async (id: number, status: OrderStatus): Promise<ApiResponse<OrderDTO>> => {
    const response = await axios.patch(`/v1/orders/${id}/status`, null, {
      params: { status }
    });
    return response.data;
  },

  /**
   * Thanh toán đơn hàng
   */
  makePayment: async (id: number, data: { amount: number; paymentMethod: string; transactionId?: string; note?: string }): Promise<ApiResponse<OrderDTO>> => {
    const response = await axios.post(`/v1/orders/${id}/payment`, data);
    return response.data;
  }
};

/**
 * Hàm chuẩn hóa dữ liệu: Đảm bảo dữ liệu gửi lên là kiểu Number
 * Giúp tránh lỗi 400 Bad Request từ Spring Boot/Backend.
 */
const formatOrderRequest = (data: CreateOrderRequest) => {
  if (!data.items || data.items.filter(i => Number(i.productId) > 0).length === 0) {
    throw new Error("Đơn hàng phải có ít nhất một sản phẩm hợp lệ.");
  }

  return {
    customerId: Number(data.customerId),
    discountAmount: Number(data.discountAmount || 0),
    paymentType: data.paymentType,
    status: data.status || 'PAID',
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