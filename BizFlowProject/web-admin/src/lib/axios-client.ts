import axios from "axios";

const axiosClient = axios.create({
  baseURL: "http://localhost:8080/api/v1", // Cổng Backend của ông
  headers: {
    "Content-Type": "application/json",
  },
});

// Interceptor: Tự động gắn Token lấy từ LocalStorage
axiosClient.interceptors.request.use((config) => {
  if (typeof window !== "undefined") {
    const token = localStorage.getItem("accessToken");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }
  return config;
});

export default axiosClient;
