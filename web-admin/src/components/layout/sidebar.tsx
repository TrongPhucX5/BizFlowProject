"use client";

import React, { useEffect, useState, useCallback } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard, Users, ShoppingCart, Package, 
  BarChart3, Settings, Store, LogOut, Info 
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

const menuItems = [

  { title: "Tổng quan", icon: LayoutDashboard, href: "/dashboard" },
  { title: "Sản phẩm", icon: Package, href: "/dashboard/products" },
  { title: "Đơn hàng", icon: ShoppingCart, href: "/orders" },
  { title: "Khách hàng", icon: Users, href: "/customers" },
  { title: "Báo cáo", icon: BarChart3, href: "/dashboard/reports" },
  { title: "Cấu hình", icon: Settings, href: "/dashboard/settings/security" },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const [userData, setUserData] = useState({
    fullName: "Người dùng",
    storeName: "BizFlow Store",
    role: "EMPLOYEE",
  });

  const loadUserData = useCallback(() => {
    if (typeof window !== "undefined") {
      // Ưu tiên lấy Họ Tên, nếu không có thì lấy Tên đăng nhập
      const storedName = localStorage.getItem("userFullName");
      const storedUser = localStorage.getItem("username"); 
      const storedStore = localStorage.getItem("storeName");
      const storedRole = localStorage.getItem("userRole");

      setUserData({
        fullName: storedName || storedUser || "Người dùng",
        storeName: storedStore || "BizFlow Store",
        role: (storedRole || "EMPLOYEE").toUpperCase(),
      });
    }
  }, []);

  useEffect(() => {
    loadUserData();
    window.addEventListener("storage", loadUserData);
    
    // Kiểm tra liên tục mỗi 1 giây để sửa lỗi "kẹt" tên cũ VanLong
    const intervalId = setInterval(loadUserData, 1000);

    return () => {
      window.removeEventListener("storage", loadUserData);
      clearInterval(intervalId);
    };
  }, [loadUserData]);

  const handleLogout = () => {
    localStorage.clear();
    router.push("/auth/login");
    router.refresh();
  };

  return (
    <aside className="w-64 bg-white border-r border-slate-100 flex flex-col fixed inset-y-0 left-0 z-50 shadow-[4px_0_24px_-12px_rgba(0,0,0,0.1)]">
      <div className="h-20 flex items-center px-6 border-b border-slate-50">
        <div className="flex items-center gap-3 overflow-hidden">
          <div className="h-9 w-9 bg-blue-700 rounded-xl flex-shrink-0 flex items-center justify-center shadow-lg shadow-blue-200">
            <Store className="text-white h-5 w-5" />
          </div>
          <div className="min-w-0">
            <h1 className="text-lg font-bold text-slate-800 truncate">
              {userData.storeName}
            </h1>
            <p className="text-[10px] text-slate-400 font-semibold uppercase tracking-wider mt-1">
              Admin Portal
            </p>
          </div>
        </div>
      </div>

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
                "flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all group relative",
                isActive ? "bg-blue-50 text-blue-700 shadow-sm" : "text-slate-500 hover:bg-slate-50 hover:text-slate-900"
              )}
            >
              {isActive && <div className="absolute left-0 top-1/2 -translate-y-1/2 h-6 w-1 rounded-r-full bg-blue-700"></div>}
              <item.icon size={20} className={cn(isActive ? "text-blue-700" : "text-slate-400 group-hover:text-slate-600")} />
              <span className="flex-1">{item.title}</span>
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-slate-50">
        <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 border border-slate-100 group transition-all hover:bg-white hover:shadow-md">
          <Avatar className="h-9 w-9 border-2 border-white shadow-sm flex-shrink-0">
            <AvatarImage src="https://github.com/shadcn.png" />
            <AvatarFallback className="bg-blue-700 text-white font-bold text-xs">
              {userData.fullName.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase()}
            </AvatarFallback>
          </Avatar>

          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-slate-700 truncate leading-none">
              {userData.fullName}
            </p>
            <p className="text-[10px] text-blue-600 font-black mt-1.5 bg-blue-50 w-fit px-1.5 py-0.5 rounded border border-blue-100 uppercase">
              {userData.role}
            </p>
          </div>

          <button onClick={handleLogout} className="p-1.5 rounded-lg text-slate-400 hover:bg-red-50 hover:text-red-500 transition-colors">
            <LogOut size={16} />
          </button>
        </div>
      </div>
    </aside>
  );
}