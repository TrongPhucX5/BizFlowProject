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
    
    // 1. Xác định vị trí mảng content (Dựa trên JSON bạn gửi là data.result.content)
    const rawContent = data?.result?.content || data?.content || data?.data?.content || [];
    
    // 2. Định dạng lại dữ liệu số để tránh lỗi hiển thị "0" do sai kiểu dữ liệu
    const formattedContent = Array.isArray(rawContent) 
      ? rawContent.map((item: any) => ({
          ...item,
          // Đảm bảo các trường này luôn là Number để Frontend tính được tổng (reduce)
          totalDebt: Number(item.totalDebt || 0),
          totalPurchaseAmount: Number(item.totalPurchaseAmount || 0),
          totalOrders: Number(item.totalOrders || 0)
        }))
      : [];

    // 3. Trả về cấu trúc phẳng để CustomerPage.tsx dễ xử lý
    return {
      content: formattedContent,
      totalElements: data?.result?.page?.totalElements || data?.page?.totalElements || 0,
      totalPages: data?.result?.page?.totalPages || data?.page?.totalPages || 1
    };
  },

  getTotalActiveCount: async (): Promise<number> => {
    try {
      const response = await axiosClient.get(BASE_URL, {
        params: { size: 1, page: 0, status: "ACTIVE" }
      });
      const res = response.data as any;
      // Kiểm tra tất cả các lớp bọc của Backend
      return res?.result?.page?.totalElements ?? res?.page?.totalElements ?? 0;
    } catch (error) {
      return 0;
    }
  },

  createCustomer: async (data: Partial<Customer>): Promise<ApiResponse<Customer>> => {
    const payload = {
      ...data,
      // Đảm bảo gửi lên Backend đúng kiểu số
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
    // Sử dụng Number(id) để tránh lỗi URL nếu id truyền vào là string
    return (await axiosClient.put<ApiResponse<Customer>>(`${BASE_URL}/${Number(id)}`, payload)).data;
  },

  deleteCustomer: async (id: number | string): Promise<ApiResponse<void>> => {
    return (await axiosClient.delete<ApiResponse<void>>(`${BASE_URL}/${Number(id)}`)).data;
  }
};