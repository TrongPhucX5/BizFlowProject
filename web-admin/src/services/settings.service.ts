import axiosClient from "@/lib/axios-client";

export const settingsService = {
  // Lấy danh sách người dùng
  getUsers: async () => {
    const response = await axiosClient.get("/users");
    return response.data;
  },

  // Tạo người dùng mới
  createUser: async (data: any) => {
    const response = await axiosClient.post("/users", data);
    return response.data;
  },

  // Cập nhật người dùng
  updateUser: async (id: number, data: any) => {
    const response = await axiosClient.put(`/users/${id}`, data);
    return response.data;
  },

  // Xóa người dùng
  deleteUser: async (id: number) => {
    const response = await axiosClient.delete(`/users/${id}`);
    return response.data;
  },

  // Lấy thông tin cửa hàng
  getStoreInfo: async () => {
    const response = await axiosClient.get("/settings/store");
    return response.data;
  },

  // Cập nhật thông tin cửa hàng
  updateStoreInfo: async (data: any) => {
    const response = await axiosClient.put("/settings/store", data);
    return response.data;
  },

  // Lấy cấu hình hệ thống
  getSystemSettings: async () => {
    const response = await axiosClient.get("/settings/system");
    return response.data;
  },

  // Cập nhật cấu hình hệ thống
  updateSystemSettings: async (data: any) => {
    const response = await axiosClient.put("/settings/system", data);
    return response.data;
  },
};
