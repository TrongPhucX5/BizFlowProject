import axiosClient from "@/lib/axios-client";

export const ordersService = {
  // Lấy danh sách đơn hàng
  getOrders: async (params?: {
    page?: number;
    size?: number;
    status?: string;
    startDate?: string;
    endDate?: string;
  }) => {
    const response = await axiosClient.get("/orders", { params });
    return response.data;
  },

  // Tạo đơn hàng mới
  createOrder: async (data: any) => {
    const response = await axiosClient.post("/orders", data);
    return response.data;
  },

  // Lấy chi tiết đơn hàng
  getOrderById: async (id: number) => {
    const response = await axiosClient.get(`/orders/${id}`);
    return response.data;
  },

  // Cập nhật đơn hàng
  updateOrder: async (id: number, data: any) => {
    const response = await axiosClient.put(`/orders/${id}`, data);
    return response.data;
  },

  // Xóa đơn hàng
  deleteOrder: async (id: number) => {
    const response = await axiosClient.delete(`/orders/${id}`);
    return response.data;
  },

  // Cập nhật trạng thái đơn hàng
  updateOrderStatus: async (id: number, status: string) => {
    const response = await axiosClient.patch(`/orders/${id}/status`, {
      status,
    });
    return response.data;
  },

  // Thanh toán đơn hàng
  makePayment: async (id: number, paymentData: any) => {
    const response = await axiosClient.post(
      `/orders/${id}/pay`,
      paymentData
    );
    return response.data;
  },
};
