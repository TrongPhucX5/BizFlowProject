import axiosClient from "@/lib/axios-client";
import { ApiResponse, SubscriptionPlan } from "@/types/api";

export const plansService = {
  getPlans: async () => {
    const response = await axiosClient.get("/v1/subscription-plans");
    return response.data;
  },

  createPlan: async (data: any) => {
    const response = await axiosClient.post("/v1/subscription-plans", data);
    return response.data;
  },

  updatePlan: async (id: number, data: any) => {
    const response = await axiosClient.put(`/v1/subscription-plans/${id}`, data);
    return response.data;
  },

  deletePlan: (id: number) => 
    axiosClient.delete<ApiResponse<any>>(`/v1/subscription-plans/${id}`),

  getPlanSubscriptions: (id: number) => 
    axiosClient.get<ApiResponse<any[]>>(`/v1/subscription-plans/${id}/subscriptions`),
};
