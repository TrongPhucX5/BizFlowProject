import axiosClient from "@/lib/axios-client";
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
   * Lấy danh sách khách hàng
   * Generics <ApiResponse<PageResponse<Customer>>> giúp sửa lỗi gạch đỏ .last ở Page
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

  createCustomer: async (data: Partial<Customer>): Promise<ApiResponse<Customer>> => {
    const response = await axiosClient.post<ApiResponse<Customer>>(BASE_URL, data);
    return response.data;
  },

  updateCustomer: async (id: number | string, data: Partial<Customer>): Promise<ApiResponse<Customer>> => {
    // Ép kiểu Number(id) để tránh lỗi 400 Bad Request
    const response = await axiosClient.put<ApiResponse<Customer>>(`${BASE_URL}/${Number(id)}`, data);
    return response.data;
  },

  deleteCustomer: async (id: number | string): Promise<ApiResponse<void>> => {
    const response = await axiosClient.delete<ApiResponse<void>>(`${BASE_URL}/${Number(id)}`);
    return response.data;
  }
};