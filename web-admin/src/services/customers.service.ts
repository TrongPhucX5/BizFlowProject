import axiosClient from "@/lib/axios-client";

export const customersService = {
  // Lấy danh sách khách hàng
  getCustomers: async (params?: {
    page?: number;
    size?: number;
    search?: string;
    type?: string;
  }) => {
    const response = await axiosClient.get("/v1/customers", { params });
    return response.data;
  },

  // Tạo khách hàng mới
  createCustomer: async (data: any) => {
    const response = await axiosClient.post("/v1/customers", data);
    return response.data;
  },

  // Lấy chi tiết khách hàng
  getCustomerById: async (id: number) => {
    const response = await axiosClient.get(`/v1/customers/${id}`);
    return response.data;
  },

  // Cập nhật khách hàng
  updateCustomer: async (id: number, data: any) => {
    const response = await axiosClient.put(`/v1/customers/${id}`, data);
    return response.data;
  },

  // Xóa khách hàng
  deleteCustomer: async (id: number) => {
    const response = await axiosClient.delete(`/v1/customers/${id}`);
    return response.data;
  },

  // Lấy lịch sử mua hàng của khách
  getCustomerOrders: async (customerId: number) => {
    const response = await axiosClient.get(
      `/v1/customers/${customerId}/orders`
    );
    return response.data;
  },

  // Lấy báo cáo công nợ khách hàng
  getCustomerDebtReport: async () => {
    const response = await axiosClient.get("/v1/customers/debt-report");
    return response.data;
  },
};
