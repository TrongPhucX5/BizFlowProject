import axiosClient from "@/lib/axios-client";
import type { ApiResponse } from "@/types/api";

export interface Customer {
  id: number;
  fullName: string; 
  phone: string;    
  email: string;
  address: string;
  type: "RETAIL" | "WHOLESALE" | "CORPORATE"; 
  status: "ACTIVE" | "INACTIVE"; 
  totalDebt: number;           
  totalPurchaseAmount: number; 
  totalOrders: number;         
  taxCode?: string;
  notes?: string;
  contactPerson?: string;
  createdAt: string;
  updatedAt: string;
}

export interface GetCustomersParams {
  page?: number;
  size?: number;
  search?: string;
  sort?: string;
  status?: "ACTIVE" | "INACTIVE";
}

const BASE_URL = "/v1/customers"; 

export const customerService = {
  getCustomers: async (params: GetCustomersParams): Promise<any> => {
    const response = await axiosClient.get(BASE_URL, { 
      params: {
        page: params.page ?? 0,
        size: params.size ?? 10,
        search: params.search?.trim() || "",
        sort: params.sort || 'createdAt,desc',
        status: params.status
      } 
    });

    const data = response.data;
    
    // 1. Xác định vị trí mảng content linh hoạt hơn
    const rawContent = data?.result?.content || data?.content || data?.data || [];
    
    // 2. Định dạng dữ liệu: Ép kiểu nghiêm ngặt và kiểm tra đa dạng tên biến
    const formattedContent = Array.isArray(rawContent) 
      ? rawContent.map((item: any) => ({
          ...item,
          // Kiểm tra tất cả các trường có thể chứa giá trị nợ từ Backend
          totalDebt: Number(item.totalDebt ?? item.debt ?? item.currentDebt ?? item.balance ?? 0),
          totalPurchaseAmount: Number(item.totalPurchaseAmount ?? item.purchaseAmount ?? item.totalSpent ?? 0),
          totalOrders: Number(item.totalOrders ?? item.orderCount ?? item.numOrders ?? 0)
        }))
      : [];

    // 3. Trả về cấu trúc chuẩn để đồng bộ với logic phân trang của UI
    return {
      content: formattedContent,
      totalElements: data?.result?.page?.totalElements || data?.page?.totalElements || data?.totalElements || formattedContent.length,
      totalPages: data?.result?.page?.totalPages || data?.page?.totalPages || 1
    };
  },

  // Lấy chi tiết 1 khách hàng (Cần thiết khi cập nhật đơn hàng xong phải load lại nợ)
  getCustomerById: async (id: number | string): Promise<Customer> => {
    const response = await axiosClient.get(`${BASE_URL}/${id}`);
    const item = response.data?.result || response.data?.data || response.data;
    return {
      ...item,
      totalDebt: Number(item.totalDebt ?? item.debt ?? 0),
      totalPurchaseAmount: Number(item.totalPurchaseAmount ?? item.purchaseAmount ?? 0),
    };
  },

  createCustomer: async (data: Partial<Customer>): Promise<ApiResponse<Customer>> => {
    const payload = {
      ...data,
      totalOrders: Number(data.totalOrders || 0),
      totalPurchaseAmount: Number(data.totalPurchaseAmount || 0),
      totalDebt: Number(data.totalDebt || 0),
    };
    return (await axiosClient.post<ApiResponse<Customer>>(BASE_URL, payload)).data;
  },

  updateCustomer: async (id: number | string, data: Partial<Customer>): Promise<ApiResponse<Customer>> => {
    const payload = {
      ...data,
      totalOrders: Number(data.totalOrders || 0),
      totalPurchaseAmount: Number(data.totalPurchaseAmount || 0),
      totalDebt: Number(data.totalDebt || 0),
    };
    return (await axiosClient.put<ApiResponse<Customer>>(`${BASE_URL}/${Number(id)}`, payload)).data;
  },

  deleteCustomer: async (id: number | string): Promise<ApiResponse<void>> => {
    return (await axiosClient.delete<ApiResponse<void>>(`${BASE_URL}/${Number(id)}`)).data;
  }
};