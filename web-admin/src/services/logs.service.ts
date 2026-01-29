import axiosClient from "@/lib/axios-client";

export interface AuditLog {
  id: number;
  userId: number;
  userName: string;
  userFullName: string;
  action: string;
  entityType: string;
  entityId: number;
  oldValue: string | null;
  newValue: string | null;
  ipAddress: string;
  createdAt: string;
}

export interface AuditLogResponse {
  result: AuditLog[];
  currentPage: number;
  totalItems: number;
  totalPages: number;
}

export const logsService = {
  /**
   * Get all audit logs with pagination
   * @param page Page number (0-indexed)
   * @param size Number of items per page
   */
  getLogs: async (page: number = 0, size: number = 50): Promise<AuditLogResponse> => {
    const response = await axiosClient.get(`/v1/audit-logs?page=${page}&size=${size}`);
    return response.data;
  },

  /**
   * Get audit logs filtered by action
   * @param action Action type (CREATE, UPDATE, DELETE, LOGIN)
   * @param page Page number
   * @param size Page size
   */
  getLogsByAction: async (action: string, page: number = 0, size: number = 50): Promise<AuditLogResponse> => {
    const response = await axiosClient.get(`/v1/audit-logs/by-action?action=${action}&page=${page}&size=${size}`);
    return response.data;
  },

  /**
   * Get audit logs filtered by entity type
   * @param entityType Entity type (PRODUCT, CUSTOMER, USER, ORDER, etc.)
   * @param page Page number
   * @param size Page size
   */
  getLogsByEntity: async (entityType: string, page: number = 0, size: number = 50): Promise<AuditLogResponse> => {
    const response = await axiosClient.get(`/v1/audit-logs/by-entity?entityType=${entityType}&page=${page}&size=${size}`);
    return response.data;
  },

  /**
   * Get audit logs filtered by user ID
   * @param userId User ID
   * @param page Page number
   * @param size Page size
   */
  getLogsByUser: async (userId: number, page: number = 0, size: number = 50): Promise<AuditLogResponse> => {
    const response = await axiosClient.get(`/v1/audit-logs/by-user?userId=${userId}&page=${page}&size=${size}`);
    return response.data;
  },

  /**
   * Get specific audit log by ID
   * @param id Audit log ID
   */
  getLogById: async (id: number): Promise<{ result: AuditLog }> => {
    const response = await axiosClient.get(`/v1/audit-logs/${id}`);
    return response.data;
  },
};
