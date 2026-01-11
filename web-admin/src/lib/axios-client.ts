import axios from "axios";

const axiosClient = axios.create({
    // QUAN TRỌNG: Trỏ thẳng về cổng Backend Spring Boot (8080)
    // Không dùng "/api" nữa để tránh lỗi 404 trên Next.js
    baseURL: "http://localhost:8080/api",
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

// Interceptor: Xử lý lỗi response
axiosClient.interceptors.response.use(
    (response) => response,
    (error) => {
        // Nếu lỗi 401 (Unauthorized), có thể xử lý logout tại đây
        if (error.response && error.response.status === 401) {
            // console.log("Hết hạn token hoặc không có quyền truy cập");
        }
        return Promise.reject(error);
    }
);

export default axiosClient;