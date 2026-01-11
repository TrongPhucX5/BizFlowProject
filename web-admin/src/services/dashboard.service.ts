import axiosClient from "@/lib/axios-client";

export const dashboardService = {
  // --- PRODUCTS (/v1/products) ---
  getProducts: async () => {
    // Thêm /v1 vào trước
    const response = await axiosClient.get("/v1/products?size=100");
    return response.data;
  },

  createProduct: async (data: any) => {
    const response = await axiosClient.post("/v1/products", data);
    return response.data;
  },

  updateProduct: async (id: number, data: any) => {
    const response = await axiosClient.put(`/v1/products/${id}`, data);
    return response.data;
  },

  deleteProduct: async (id: number) => {
    const response = await axiosClient.delete(`/v1/products/${id}`);
    return response.data;
  },

  // --- ORDERS (/v1/orders) ---
  getOrders: async () => {
    const response = await axiosClient.get("/v1/orders?size=50");
    return response.data;
  },

  // --- INVENTORY (/v1/inventory) ---
  importInventory: async (data: any) => {
    const response = await axiosClient.post("/v1/inventory/import", data);
    return response.data;
  },

  getInventory: async (productId: number) => {
    const response = await axiosClient.get(`/v1/inventory/${productId}`);
    return response.data;
  },

  // --- DEBTS (/v1/debts) ---
  getDebts: async () => {
    const response = await axiosClient.get("/v1/debts");
    return response.data;
  },

  payDebt: async (id: number, data: any) => {
    const response = await axiosClient.post(`/v1/debts/${id}/pay`, data);
    return response.data;
  },
};
