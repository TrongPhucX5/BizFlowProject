import axiosClient from "@/lib/axios-client";
import { ApiResponse } from "@/services/store.service";

export interface RevenueChartData {
  name: string;
  total: number;
}

export interface RecentTenant {
  id: number;
  name: string;
  email: string;
  status: string;
  createdAt: string;
  amount?: number;
}

export interface AdminDashboardStats {
  revenue: number;
  newStores: number;
  activeTenants: number;
  totalOrders: number;
  recentTenants: RecentTenant[];
  revenueData: RevenueChartData[];
}

export const adminDashboardService = {
  getStats: async (period: string = "this-month") => {
    const response = await axiosClient.get<ApiResponse<AdminDashboardStats>>("/v1/admin/dashboard/stats", {
      params: { period }
    });
    return response.data;
  },
};
