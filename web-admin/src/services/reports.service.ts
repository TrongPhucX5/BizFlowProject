import axiosClient from "@/lib/axios-client";

export const reportsService = {
  // Báo cáo doanh thu theo thời gian
  getRevenueReport: async (params: {
    period: "daily" | "weekly" | "monthly" | "yearly";
    startDate?: string;
    endDate?: string;
  }) => {
    const response = await axiosClient.get("/reports/revenue", { params });
    return response.data;
  },

  // Báo cáo tồn kho
  getInventoryReport: async () => {
    const response = await axiosClient.get("/reports/inventory");
    return response.data;
  },

  // Báo cáo công nợ
  getDebtReport: async () => {
    const response = await axiosClient.get("/reports/debt");
    return response.data;
  },

  // Báo cáo sản phẩm bán chạy
  getBestSellingProducts: async (params?: {
    limit?: number;
    startDate?: string;
    endDate?: string;
  }) => {
    const response = await axiosClient.get("/reports/best-selling", {
      params,
    });
    return response.data;
  },

  // Thống kê tổng quan
  getDashboardStats: async () => {
    const response = await axiosClient.get("/reports/dashboard-stats");
    return response.data;
  },

  // Xuất báo cáo PDF
  exportReport: async (
    reportType: string,
    format: "pdf" | "excel",
    params?: any
  ) => {
    const response = await axiosClient.get(`/reports/export/${reportType}`, {
      params: { ...params, format },
      responseType: "blob",
    });
    return response.data;
  },
};
