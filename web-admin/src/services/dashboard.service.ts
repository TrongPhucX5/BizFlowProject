import axiosClient from "@/lib/axios-client";

export const dashboardService = {
  // --- UPLOAD (/v1/upload) ---
  uploadImage: async (file: File) => {
    const formData = new FormData();
    formData.append("file", file);
    const response = await axiosClient.post("/v1/upload/image", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
    return response.data;
  },

  // --- UNITS (/v1/units) ---
  getUnits: async () => {
    const response = await axiosClient.get("/v1/units");
    return response.data;
  },

  // --- PRODUCTS (/v1/products) ---
  getProducts: async (params: any = {}) => {
    const response = await axiosClient.get("/v1/products", { params });
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

  // --- DASHBOARD ANALYTICS ---
  getDashboardSummary: async () => {
    const response = await axiosClient.get("/v1/dashboard/orders/summary");
    return response.data;
  },

  getStatusChart: async () => {
    const response = await axiosClient.get("/v1/dashboard/orders/status-chart");
    return response.data;
  },

  getRevenueChart: async (range: string = "7d") => {
    const response = await axiosClient.get(`/v1/dashboard/orders/revenue-chart?range=${range}`);
    return response.data;
  },

  getDailyCountChart: async (range: string = "30d") => {
    const response = await axiosClient.get(`/v1/dashboard/orders/daily-count-chart?range=${range}`);
    return response.data;
  },

  getRecentOrders: async () => {
    const response = await axiosClient.get("/v1/dashboard/orders/recent");
    return response?.data?.result || [];
  },

  getOrdersByDate: async (date: string) => {
    const response = await axiosClient.get(`/v1/dashboard/orders/by-date?date=${date}`);
    return response?.data?.result || [];
  },

  getTopCustomers: async (range: string = "30d") => {
    const response = await axiosClient.get(`/v1/dashboard/customers/top?range=${range}`);
    return response?.data?.result || [];
  },

  getLowStockProducts: async () => {
    const response = await axiosClient.get("/v1/dashboard/products/low-stock");
    return response?.data?.result || [];
  },
};
