"use client";

import React from "react";
import { 
  LayoutDashboard, 
  Box, 
  ShoppingCart, 
  Users, 
  BarChart3, 
  Settings, 
  LogOut,
  Mic
} from "lucide-react";
import { useRouter, usePathname } from "next/navigation";

export default function CustomerLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();

  const menuItems = [
    { icon: <LayoutDashboard size={20} />, label: "Tổng quan", path: "/dashboard" },
    { icon: <Box size={20} />, label: "Sản phẩm", path: "/products" },
    { icon: <ShoppingCart size={20} />, label: "Đơn hàng", path: "/orders" },
    { icon: <Users size={20} />, label: "Khách hàng", path: "/customers" },
    { icon: <BarChart3 size={20} />, label: "Báo cáo", path: "/reports" },
    { icon: <Settings size={20} />, label: "Cấu hình", path: "/settings" },
  ];

  const handleLogout = () => {
    localStorage.removeItem("accessToken");
    router.push("/auth/login");
  };

  return (
    <div className="flex min-h-screen bg-slate-50">
      {/* Sidebar - Màu xanh đen đậm theo Dashboard */}
      <aside className="w-64 bg-[#1a2332] text-slate-400 hidden md:flex flex-col">
        <div className="p-6">
          <h2 className="text-2xl font-bold text-blue-500 mb-1">BizFlow</h2>
          <p className="text-xs text-slate-500">Quản lý hộ kinh doanh</p>
        </div>

        <nav className="flex-1 px-3 space-y-1">
          {menuItems.map((item) => (
            <div
              key={item.path}
              onClick={() => router.push(item.path)}
              className={`flex items-center gap-3 px-4 py-3 rounded-lg cursor-pointer transition-all ${
                pathname === item.path 
                  ? "bg-blue-600 text-white shadow-lg shadow-blue-900/20" 
                  : "hover:bg-slate-800 hover:text-slate-200"
              }`}
            >
              {item.icon}
              <span className="font-medium text-sm">{item.label}</span>
            </div>
          ))}
        </nav>

        <div className="p-4 border-t border-slate-800">
            <div className="text-[10px] text-slate-600">v1.0.0 by Team BizFlow</div>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col">
        {/* Header - Có thông tin User và Logout */}
        <header className="h-20 bg-white border-b flex items-center justify-between px-8">
          <div className="text-sm font-medium text-slate-500">
            Trang quản trị / <span className="text-slate-900 font-bold">Khách hàng</span>
          </div>
          
          <div className="flex items-center gap-6">
            <button className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2 rounded-xl text-sm font-medium hover:bg-indigo-700 transition-all shadow-sm">
                <Mic size={18} /> Trợ lý giọng nói
            </button>

            <div className="flex items-center gap-3 border-l pl-6">
              <div className="text-right">
                <div className="text-sm font-bold text-slate-800">Lê Trọng Phúc</div>
                <div className="text-[10px] text-slate-500 font-medium">Chủ cửa hàng</div>
              </div>
              <img 
                src="https://api.dicebear.com/7.x/avataaars/svg?seed=Felix" 
                className="h-10 w-10 rounded-xl border-2 border-slate-100 object-cover" 
                alt="Avatar" 
              />
              <button 
                onClick={handleLogout}
                className="ml-2 p-2 text-rose-500 hover:bg-rose-50 rounded-lg transition-colors flex items-center gap-1 text-sm font-bold"
              >
                <LogOut size={18} />
                <span className="hidden lg:inline">Đăng xuất</span>
              </button>
            </div>
          </div>
        </header>

        {/* Nội dung trang List Khách hàng */}
        <div className="flex-1 overflow-auto p-8">
          {children}
        </div>
      </div>
    </div>
  );
}