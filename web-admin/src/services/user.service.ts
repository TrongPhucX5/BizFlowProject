import axiosClient from "@/lib/axios-client";

// Định nghĩa Interface dựa trên UserDTO.java
export interface User {
  id: number;
  storeId?: number;
  username: string;
  fullName: string;
  email?: string;
  phone?: string;
  role: 'ADMIN' | 'OWNER' | 'EMPLOYEE';
  status: 'ACTIVE' | 'INACTIVE' | 'LOCKED';
  createdAt?: string;
  updatedAt?: string;
}

// Định nghĩa Interface cho cấu trúc Response
export interface ApiResponse<T> {
  code: number;
  message?: string;
  result: T;
}

export const userService = {
  // Lấy danh sách tất cả người dùng
  getUsers: async (): Promise<ApiResponse<User[]>> => {
    const response = await axiosClient.get("/v1/users");
    return response.data;
  },

  // Tạo người dùng mới (Dựa trên @PostMapping trong UserController)
  createUser: async (userData: Partial<User>): Promise<ApiResponse<User>> => {
    const response = await axiosClient.post("/v1/users", userData);
    return response.data;
  },

  /**
   * Lấy thông tin người dùng hiện tại
   * Lưu ý: Bạn cần bổ sung endpoint /v1/users/me ở Backend 
   * để trả về thông tin của người dùng đang login dựa trên Token.
   */
  getProfile: async (): Promise<ApiResponse<User>> => {
    const response = await axiosClient.get("/v1/users/me");
    return response.data;
  }
};