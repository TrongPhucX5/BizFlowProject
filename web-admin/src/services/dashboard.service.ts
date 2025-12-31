import axiosClient from "@/lib/axios-client";

export const dashboardService = {
  getProducts: async () => {
    const response = await axiosClient.get("/v1/products?size=100");
    return response.data;
  },

  // 1. Tạo mới sản phẩm
  createProduct: async (data: any) => {
    const response = await axiosClient.post("/v1/products", data);
    return response.data;
  },

  // 2. Cập nhật sản phẩm
  updateProduct: async (id: number, data: any) => {
    const response = await axiosClient.put(`/v1/products/${id}`, data);
    return response.data;
  },

  // 3. Xóa sản phẩm (Nếu cần)
  deleteProduct: async (id: number) => {
    const response = await axiosClient.delete(`/v1/products/${id}`);
    return response.data;
  },

  getOrders: async () => {
    const response = await axiosClient.get("/v1/orders?size=50");
    return response.data;
  },
};
