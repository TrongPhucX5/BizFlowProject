"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  ShoppingCart,
  Package,
  BarChart3,
  Settings,
  Store,
  LogOut,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

const menuItems = [
  { title: "Giới thiệu", icon: LayoutDashboard, href: "/about" },
  { title: "Tổng quan", icon: LayoutDashboard, href: "/dashboard" },
  { title: "Sản phẩm", icon: Package, href: "/dashboard/products" },
  { title: "Đơn hàng", icon: ShoppingCart, href: "/orders" },
  { title: "Khách hàng", icon: Users, href: "/customers" },
  { title: "Báo cáo", icon: BarChart3, href: "/dashboard/reports" },
  { title: "Cấu hình", icon: Settings, href: "/dashboard/settings" },
  
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  // Khởi tạo state với giá trị mặc định
  const [userData, setUserData] = useState({
    fullName: "Lê Trọng Phúc",
    email: "demo@bizflow.vn",
    storeName: "BizFlow",
    role: "Chủ cửa hàng"
  });

  // Lấy dữ liệu từ localStorage khi trang web load xong (Client-side)
  useEffect(() => {
    const storedName = localStorage.getItem("userFullName");
    const storedStore = localStorage.getItem("storeName");
    const storedRole = localStorage.getItem("userRole");

    if (storedName || storedStore) {
      setUserData(prev => ({
        ...prev,
        fullName: storedName || prev.fullName,
        storeName: storedStore || prev.storeName,
        role: storedRole || prev.role
      }));
    }
  }, []);

  const handleLogout = () => {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    // Nếu bạn muốn xóa cả thông tin demo khi logout:
    // localStorage.removeItem("userFullName");
    router.push("/auth/login");
  };

  return (
    <aside className="w-64 bg-white border-r border-slate-100 flex flex-col fixed inset-y-0 left-0 z-50 shadow-[4px_0_24px_-12px_rgba(0,0,0,0.1)]">
      {/* 1. LOGO SECTION - Cập nhật theo Store Name */}
      <div className="h-20 flex items-center px-6 border-b border-slate-50">
        <div className="flex items-center gap-3 overflow-hidden">
          <div className="h-9 w-9 bg-indigo-600 rounded-xl flex-shrink-0 flex items-center justify-center shadow-lg shadow-indigo-200">
            <Store className="text-white h-5 w-5" />
          </div>
          <div className="min-w-0">
            <h1 className="text-lg font-bold text-slate-800 tracking-tight leading-none truncate">
              {userData.storeName}
            </h1>
            <p className="text-[10px] text-slate-400 font-semibold uppercase tracking-wider mt-1">
              Admin Portal
            </p>
          </div>
        </div>
      </div>

      {/* 2. MENU LIST */}
      <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
        <p className="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-3">
          Main Menu
        </p>

        {menuItems.map((item) => {
          const isActive = pathname === item.href;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200 group relative",
                isActive
                  ? "bg-indigo-50 text-indigo-600 shadow-sm"
                  : "text-slate-500 hover:bg-slate-50 hover:text-slate-900",
              )}
            >
              {isActive && (
                <div className="absolute left-0 top-1/2 -translate-y-1/2 h-6 w-1 rounded-r-full bg-indigo-600"></div>
              )}

              <item.icon
                size={20}
                strokeWidth={isActive ? 2.5 : 2}
                className={cn(
                  "transition-colors",
                  isActive
                    ? "text-indigo-600"
                    : "text-slate-400 group-hover:text-slate-600",
                )}
              />
              <span className="flex-1">{item.title}</span>
            </Link>
          );
        })}
      </nav>

      {/* 3. FOOTER ACCOUNT - Giữ Avatar cũ, cập nhật tên và vai trò */}
      <div className="p-4 border-t border-slate-50">
        <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 border border-slate-100 transition-all hover:bg-white hover:shadow-md group">
          {/* Giữ nguyên Avatar cũ từ Shadcn */}
          <Avatar className="h-9 w-9 border-2 border-white shadow-sm flex-shrink-0">
            <AvatarImage src="https://github.com/shadcn.png" />
            <AvatarFallback className="bg-indigo-600 text-white font-bold">
              {userData.fullName.substring(0, 2).toUpperCase()}
            </AvatarFallback>
          </Avatar>

          {/* Cập nhật thông tin thực tế từ Form */}
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-slate-700 truncate">
              {userData.fullName}
            </p>
            <p className="text-xs text-slate-500 truncate">{userData.role}</p>
          </div>

          <button
            onClick={handleLogout}
            className="p-1.5 rounded-lg text-slate-400 hover:bg-red-50 hover:text-red-500 transition-colors flex-shrink-0"
            title="Đăng xuất"
          >
            <LogOut size={18} />
          </button>
        </div>
      </div>
    </aside>
  );
}