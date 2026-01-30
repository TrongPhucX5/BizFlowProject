import axiosClient from "@/lib/axios-client";

export const reportsService = {
  // Báo cáo doanh thu theo thời gian
  getRevenueReport: async (params: {
    period: "daily" | "weekly" | "monthly" | "yearly";
    startDate?: string;
    endDate?: string;
  }) => {
    const response = await axiosClient.get("/v1/reports/revenue", { params });
    return response.data;
  },

  // Báo cáo tồn kho
  getInventoryReport: async () => {
    const response = await axiosClient.get("/v1/reports/inventory");
    return response.data;
  },

  // Báo cáo công nợ
  getDebtReport: async () => {
    const response = await axiosClient.get("/v1/reports/debt");
    return response.data;
  },

  // Báo cáo sản phẩm bán chạy
  getBestSellingProducts: async (params?: {
    limit?: number;
    startDate?: string;
    endDate?: string;
  }) => {
    const response = await axiosClient.get("/v1/reports/best-selling", {
      params,
    });
    return response.data;
  },

  // Thống kê tổng quan
  getDashboardStats: async () => {
    const response = await axiosClient.get("/v1/reports/dashboard-stats");
    return response.data;
  },

  // Xuất báo cáo CSV
  exportGeneralReport: async () => {
    const response = await axiosClient.get("/v1/reports/export/general", {
      responseType: "blob",
    });
    return response.data;
  },

  // --- TT88 EXPORTS ---
  exportTT88Revenue: async (from: string, to: string) => {
    const response = await axiosClient.get("/v1/reports/tt88/revenue", {
      params: { from, to },
      responseType: "blob",
    });
    return response.data;
  },

  exportTT88Debt: async (from: string, to: string) => {
    const response = await axiosClient.get("/v1/reports/tt88/debt", {
      params: { from, to },
      responseType: "blob",
    });
    return response.data;
  },

  exportTT88Stock: async (from: string, to: string) => {
    const response = await axiosClient.get("/v1/reports/tt88/stock", {
      params: { from, to },
      responseType: "blob",
    });
    return response.data;
  },

  // Gọi AI Phân tích (tự động theo kỳ)
  getAiInsight: async (period: string) => {
    return reportsService.chatWithAi(
      `Hãy phân tích tình hình kinh doanh (Doanh thu, Tồn kho) trong ${period} vừa qua và đưa ra lời khuyên ngắn gọn.`,
      []
    );
  },

  // Chat trực tiếp với AI
  chatWithAi: async (message: string, history: any[]) => {
    const response = await axiosClient.post("/v1/ai/chat", {
      message,
      history,
    });
    return response.data;
  },
};
