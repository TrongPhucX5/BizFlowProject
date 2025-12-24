"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function RootPage() {
  const router = useRouter();

  useEffect(() => {
    // Kiểm tra token có tồn tại không
    const token = localStorage.getItem("accessToken");
    
    // Nếu có token, redirect đến dashboard, ngược lại redirect đến login
    if (token) {
      router.push("/dashboard");
    } else {
      router.push("/auth/login");
    }
  }, [router]);

  return (
    <div className="flex items-center justify-center h-screen">
      <p className="text-slate-500 text-lg">Đang chuyển hướng...</p>
    </div>
  );
}

