"use client";

import React, { useEffect, useState } from "react";
import { Mic, Search, Bell } from "lucide-react";
// CHÚ Ý: Kiểm tra chính xác đường dẫn đến file Sidebar.tsx (File 2) của bạn
// Nếu File 2 nằm ở src/components/sidebar.tsx, hãy dùng:
import { Sidebar } from "@/components/layout/sidebar";

export default function CustomerLayout({ children }: { children: React.ReactNode }) {
  const [userData, setUserData] = useState({
    fullName: "Lê Trọng Phúc",
    role: "Chủ cửa hàng"
  });

  // Đồng bộ thông tin từ localStorage giống như Sidebar
  useEffect(() => {
    const storedName = localStorage.getItem("userFullName");
    const storedRole = localStorage.getItem("userRole");
    if (storedName) {
      setUserData(prev => ({
        ...prev,
        fullName: storedName,
        role: storedRole || prev.role
      }));
    }
  }, []);

  return (
    <div className="flex min-h-screen bg-slate-50/50">
      {/* Gọi Sidebar chuẩn từ File 2 */}
      <Sidebar />

      {/* Main Content: md:pl-64 để đẩy nội dung sang phải không bị Sidebar che */}
      <div className="flex-1 flex flex-col md:pl-64">
        
        {/* Header hiện đại đồng bộ màu Indigo của Sidebar */}
        <header className="h-20 bg-white border-b border-slate-100 flex items-center justify-between px-8 sticky top-0 z-40">
          <div className="flex flex-col">
            <p className="text-[10px] text-slate-400 font-bold uppercase tracking-wider">
              Trang quản trị
            </p>
            <h1 className="text-sm font-bold text-slate-900">
              Quản lý khách hàng
            </h1>
          </div>
          
          <div className="flex items-center gap-4">
            {/* Thanh tìm kiếm nhanh */}
            <div className="hidden lg:flex items-center gap-2 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100 focus-within:bg-white focus-within:ring-2 focus-within:ring-indigo-50 transition-all">
              <Search size={16} className="text-slate-400" />
              <input 
                type="text" 
                placeholder="Tìm khách hàng..." 
                className="bg-transparent border-none outline-none text-sm w-48"
              />
            </div>

            {/* Nút Trợ lý AI - Màu Indigo đồng bộ với File 2 */}
            <button className="flex items-center gap-2 bg-indigo-600 text-white px-5 py-2.5 rounded-xl text-sm font-semibold hover:bg-indigo-700 transition-all shadow-lg shadow-indigo-100">
                <Mic size={18} /> 
                <span>Trợ lý AI</span>
            </button>

            <div className="h-8 w-[1px] bg-slate-100 mx-2" />

            <button className="p-2 text-slate-400 hover:bg-slate-50 rounded-lg relative">
              <Bell size={20} />
              <span className="absolute top-2 right-2 w-2 h-2 bg-rose-500 rounded-full border-2 border-white"></span>
            </button>
          </div>
        </header>

        {/* Nội dung chính */}
        <main className="flex-1 p-8">
          {children}
        </main>
      </div>
    </div>
  );
}