import axiosClient from "@/lib/axios-client";

export interface Store {
  id: number;
  name: string;
  address?: string;
  phone?: string;
  email?: string;
  taxCode?: string;
  status: "ACTIVE" | "INACTIVE" | "LOCKED";
  createdAt: string;
  updatedAt: string;
}

export interface ApiResponse<T> {
  code: number;
  message: string;
  result: T;
}

export interface Page<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  size: number;
  number: number;
}

export const storeService = {
  // Lấy danh sách store (phân trang & tìm kiếm)
  getStores: async (params: { page: number; size: number; search?: string }) => {
    const response = await axiosClient.get<ApiResponse<Page<Store>>>("/v1/stores", {
      params,
    });
    return response.data;
  },

  // Cập nhật trạng thái store
  updateStoreStatus: async (id: number, status: "ACTIVE" | "INACTIVE" | "LOCKED") => {
    const response = await axiosClient.patch<ApiResponse<Store>>(`/v1/stores/${id}/status`, {
      status,
    });
    return response.data;
  },

  // Lấy chi tiết store
  getStoreById: async (id: number) => {
    const response = await axiosClient.get<ApiResponse<Store>>(`/v1/stores/${id}`);
    return response.data;
  },
};
