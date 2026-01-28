"use client";

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

// Menu items - Đã chọn giữ lại các đường dẫn có /dashboard/...
const menuItems = [
  { title: "Tổng quan", icon: LayoutDashboard, href: "/dashboard" },
  { title: "Sản phẩm", icon: Package, href: "/dashboard/products" },
  { title: "Đơn hàng", icon: ShoppingCart, href: "/dashboard/orders" },
  { title: "Khách hàng", icon: Users, href: "/dashboard/customers" },
  { title: "Báo cáo", icon: BarChart3, href: "/dashboard/reports" },
  { title: "Cấu hình", icon: Settings, href: "/dashboard/settings" },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  // Hàm xử lý Đăng xuất ngay tại Sidebar
  const handleLogout = () => {
    // 1. Xóa token
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    // 2. Chuyển hướng về trang login
    router.push("/auth/login");
  };

  return (
    <aside className="w-64 bg-white border-r border-slate-100 flex flex-col fixed inset-y-0 left-0 z-50 shadow-[4px_0_24px_-12px_rgba(0,0,0,0.1)]">
      {/* 1. LOGO SECTION */}
      <div className="h-20 flex items-center px-6 border-b border-slate-50">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 bg-indigo-600 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-200">
            <Store className="text-white h-5 w-5" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-slate-800 tracking-tight leading-none">
              BizFlow
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

      {/* 3. FOOTER ACCOUNT (Tích hợp Logout tại đây) */}
      <div className="p-4 border-t border-slate-50">
        <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 border border-slate-100 transition-all hover:bg-white hover:shadow-md group">
          {/* Avatar Shadcn */}
          <Avatar className="h-9 w-9 border-2 border-white shadow-sm">
            <AvatarImage src="https://github.com/shadcn.png" />
            <AvatarFallback className="bg-indigo-600 text-white font-bold">
              LP
            </AvatarFallback>
          </Avatar>

          {/* User Info */}
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-slate-700 truncate">
              Lê Trọng Phúc
            </p>
            <p className="text-xs text-slate-500 truncate">Chủ cửa hàng</p>
          </div>

          {/* Nút Logout */}
          <button
            onClick={handleLogout}
            className="p-1.5 rounded-lg text-slate-400 hover:bg-red-50 hover:text-red-500 transition-colors"
            title="Đăng xuất"
          >
            <LogOut size={18} />
          </button>
        </div>
      </div>
    </aside>
  );
}
