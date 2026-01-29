import axiosClient from "@/lib/axios-client";

export interface Permission {
  id: number;
  name: string;
  description: string;
  module: string;
}

export interface Role {
  id: number;
  name: string;
  description: string;
  permissions: string[]; // List of permission names
  createdAt: string;
}

export interface ApiResponse<T> {
    code: number;
    message: string;
    result: T;
}

export const roleService = {
  getRoles: async () => {
    const response = await axiosClient.get<ApiResponse<Role[]>>("/v1/roles");
    return response.data;
  },

  createRole: async (data: Partial<Role>) => {
    const response = await axiosClient.post<ApiResponse<Role>>("/v1/roles", data);
    return response.data;
  },

  updateRole: async (id: number, data: Partial<Role>) => {
    const response = await axiosClient.put<ApiResponse<Role>>(`/v1/roles/${id}`, data);
    return response.data;
  },

  deleteRole: async (id: number) => {
    const response = await axiosClient.delete<ApiResponse<void>>(`/v1/roles/${id}`);
    return response.data;
  },

  getPermissions: async () => {
    const response = await axiosClient.get<ApiResponse<Permission[]>>("/v1/permissions");
    return response.data;
  }
};
