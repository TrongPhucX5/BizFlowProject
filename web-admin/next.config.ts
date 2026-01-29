import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // 1. Chuyển hướng người dùng từ "/" sang "/about" ngay khi vào web
  async redirects() {
    return [
      {
        source: "/",
        destination: "/about",
        permanent: true, // Lưu cache trình duyệt để các lần sau vào thẳng /about
      },
    ];
  },

  // 2. Giữ nguyên cấu hình API Proxy của bạn
  async rewrites() {
    return [
      // Trường hợp 1: Backend không có prefix /api
      {
        source: "/api/v1/:path*",
        destination: "http://localhost:8080/v1/:path*",
      },
      // Trường hợp 2: Backend có prefix /api (dự phòng)
      {
        source: "/api/api/v1/:path*",
        destination: "http://localhost:8080/api/v1/:path*",
      },
      // Fallback cho các API khác
      {
        source: "/api/:path*",
        destination: "http://localhost:8080/:path*",
      },
    ];
  },
};

export default nextConfig;