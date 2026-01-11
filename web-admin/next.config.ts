import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      // Trường hợp 1: Backend không có prefix /api (như bạn mô tả)
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
