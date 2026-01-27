"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AdminSidebar } from "@/components/layout/admin-sidebar";
import axiosClient from "@/lib/axios-client";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthorized, setIsAuthorized] = useState(false);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        // Gọi API /me để lấy thông tin user hiện tại và role
        // Endpoint này yêu cầu token trong header (axiosClient tự gắn)
        const response = await axiosClient.get("/v1/auth/me");
        const user = response.data.result;

        if (user && user.role === "ADMIN") {
          setIsAuthorized(true);
        } else {
          // Nếu đã đăng nhập nhưng không phải ADMIN
          console.warn("User is not ADMIN, access denied.");
           // Sử dụng alert hoặc toast notification ở đây
          alert("Bạn không có quyền truy cập trang quản trị hệ thống (Super Admin Only)!");
          // Về trang dashboard thông thường
          router.push("/dashboard");
        }
      } catch (error) {
        // Nếu lỗi 401 hoặc token không hợp lệ -> về trang login
        console.error("Auth check failed:", error);
        router.push("/auth/login");
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();
  }, [router]);

  // Hiển thị loading trong khi đang check quyền
  if (isLoading) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-slate-50">
        <div className="flex flex-col items-center gap-4">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
          <p className="text-sm text-slate-500">System Admin Guard: Loading...</p>
        </div>
      </div>
    );
  }

  // Nếu không authorized thì return null (đã redirect ở trên)
  if (!isAuthorized) {
    return null;
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <AdminSidebar />
      <main className="pl-64 min-h-screen">
        {children}
      </main>
    </div>
  );
}
