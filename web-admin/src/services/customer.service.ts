import axiosClient from "@/lib/axios-client";

// Định nghĩa Interface để quản lý dữ liệu đồng bộ
export interface CustomerRequest {
  id?: string | number; // Bổ sung ID để dùng trong danh sách
  name: string;
  phone: string;
  email?: string;
  address?: string;
  type: "RETAIL" | "WHOLESALE" | "CORPORATE";
  status: "ACTIVE" | "INACTIVE";
  storeId?: number;
}

const DEFAULT_STORE_ID = 1;

export const customerService = {
  /**
   * Lấy danh sách khách hàng có phân trang
   */
  getCustomers: async (page = 0, size = 10, storeId = DEFAULT_STORE_ID) => {
    const response = await axiosClient.get(`/v1/customers`, {
      params: { page, size, storeId }
    });
    return response.data;
  },

  /**
   * Tìm kiếm khách hàng (Tên hoặc Số điện thoại)
   */
  searchCustomers: async (query: string, storeId = DEFAULT_STORE_ID) => {
    const response = await axiosClient.get(`/v1/customers/search`, {
      params: { query, storeId }
    });
    return response.data;
  },

  /**
   * Tạo khách hàng mới
   */
  createCustomer: async (customerData: CustomerRequest) => {
    const data = {
      ...customerData,
      storeId: customerData.storeId || DEFAULT_STORE_ID
    };
    const response = await axiosClient.post("/v1/customers", data);
    return response.data;
  },

  /**
   * Cập nhật thông tin khách hàng theo ID
   */
  updateCustomer: async (id: string | number, customerData: Partial<CustomerRequest>) => {
    // Đảm bảo storeId luôn tồn tại nếu backend yêu cầu bắt buộc
    const data = {
      ...customerData,
      storeId: customerData.storeId || DEFAULT_STORE_ID
    };
    const response = await axiosClient.put(`/v1/customers/${id}`, data);
    return response.data;
  },

  /**
   * Lấy chi tiết khách hàng qua SĐT
   */
  getCustomerByPhone: async (phone: string) => {
    const response = await axiosClient.get(`/v1/customers/phone/${phone}`);
    return response.data;
  },

  /**
   * Xóa khách hàng
   */
  deleteCustomer: async (id: string | number) => {
    const response = await axiosClient.delete(`/v1/customers/${id}`);
    return response.data;
  }
};