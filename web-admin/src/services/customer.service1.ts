import axiosClient from "@/lib/axios-client";
// Đảm bảo các type này đã được định nghĩa chính xác trong @/types/api
import type { ApiResponse, PageResponse } from "@/types/api";

export interface Customer {
  id: number;
  fullName: string; 
  phone: string;    
  email: string;
  address: string;
  type: "RETAIL" | "WHOLESALE" | "CORPORATE"; 
  taxCode: string | null; 
  status: "ACTIVE" | "INACTIVE"; 
  contactPerson: string | null;
  notes: string | null;
  totalDebt: number;
  totalPurchaseAmount: number;
  totalOrders: number;
  createdAt: string;
  updatedAt: string;
}

export interface GetCustomersParams {
  page?: number;
  size?: number;
  search?: string;
  sort?: string;
}

const BASE_URL = "/v1/customers"; 

export const customerService = {
  /**
   * Lấy danh sách khách hàng phân trang
   * Đã bổ sung kiểu Generic đầy đủ để Component có thể truy cập .totalElements, .last, .numberOfElements
   */
  getCustomers: async (params: GetCustomersParams): Promise<ApiResponse<PageResponse<Customer>>> => {
    const response = await axiosClient.get<ApiResponse<PageResponse<Customer>>>(BASE_URL, { 
      params: {
        page: params.page ?? 0,
        size: params.size ?? 10,
        search: params.search?.trim() || "",
        sort: params.sort || 'createdAt,desc'
      } 
    });
    return response.data;
  },

  /**
   * Tạo mới khách hàng
   */
  createCustomer: async (data: Partial<Customer>): Promise<ApiResponse<Customer>> => {
    const response = await axiosClient.post<ApiResponse<Customer>>(BASE_URL, data);
    return response.data;
  },

  /**
   * Cập nhật thông tin khách hàng
   * Sử dụng Number(id) để đảm bảo ID đúng định dạng số khi gửi lên API
   */
  updateCustomer: async (id: number | string, data: Partial<Customer>): Promise<ApiResponse<Customer>> => {
    const response = await axiosClient.put<ApiResponse<Customer>>(`${BASE_URL}/${Number(id)}`, data);
    return response.data;
  },

  /**
   * Xóa khách hàng
   */
  deleteCustomer: async (id: number | string): Promise<ApiResponse<void>> => {
    const response = await axiosClient.delete<ApiResponse<void>>(`${BASE_URL}/${Number(id)}`);
    return response.data;
  },

  /**
   * Lấy chi tiết một khách hàng (Nên có để dùng cho CustomerDetailModal)
   */
  getCustomerById: async (id: number | string): Promise<ApiResponse<Customer>> => {
    const response = await axiosClient.get<ApiResponse<Customer>>(`${BASE_URL}/${Number(id)}`);
    return response.data;
  }
};