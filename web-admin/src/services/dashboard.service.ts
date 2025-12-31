import axiosClient from "@/lib/axios-client";

export const dashboardService = {
  getProducts: async () => {
    const response = await axiosClient.get("/v1/products?size=100");
    return response.data;
  },

  getOrders: async () => {
    const response = await axiosClient.get("/v1/orders?size=50");
    return response.data;
  }
};