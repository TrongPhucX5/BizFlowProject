import axiosClient from "./axios-client";

export interface LoginResponse {
  userId: number;
  username: string;
  accessToken: string;
  refreshToken: string;
  role: string;
}

export async function loginAsAdmin(): Promise<LoginResponse> {
  const response = await axiosClient.post<any>("/v1/auth/login", {
    username: "tpzz",
    password: "123456",
  });

  const data = response.data.result;

  // Lưu token vào localStorage
  if (data.token) {
    localStorage.setItem("accessToken", data.token);
  }

  return {
    userId: data.userId,
    username: data.username,
    accessToken: data.token,
    refreshToken: data.refreshToken || "",
    role: data.role,
  };
}

export function getAccessToken(): string | null {
  if (typeof window !== "undefined") {
    return localStorage.getItem("accessToken");
  }
  return null;
}

export function logout(): void {
  if (typeof window !== "undefined") {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
  }
}

