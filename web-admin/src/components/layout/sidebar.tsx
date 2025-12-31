"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  ShoppingCart,
  Package,
  BarChart3,
  Settings,
} from "lucide-react";
import { cn } from "@/lib/utils";

// --- SỬA LẠI ĐOẠN NÀY ---
const menuItems = [
  // Đổi href="/" thành "/dashboard"
  { title: "Tổng quan", icon: LayoutDashboard, href: "/dashboard" },

  // Đổi href="/products" thành "/dashboard/products"
  { title: "Sản phẩm", icon: Package, href: "/dashboard/products" },

  // Các cái dưới cũng nên sửa luôn để sau này làm cho tiện
  { title: "Đơn hàng", icon: ShoppingCart, href: "/dashboard/orders" },
  { title: "Khách hàng", icon: Users, href: "/dashboard/customers" },
  { title: "Báo cáo", icon: BarChart3, href: "/dashboard/reports" },
  { title: "Cấu hình", icon: Settings, href: "/dashboard/settings" },
];
// -------------------------

export function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="h-screen w-64 bg-slate-900 text-white flex flex-col fixed left-0 top-0 border-r border-slate-800 z-50">
      {/* Logo */}
      <div className="p-6 border-b border-slate-800">
        <h1 className="text-2xl font-bold text-blue-500">BizFlow</h1>
        <p className="text-xs text-slate-400">Quản lý hộ kinh doanh</p>
      </div>

      {/* Menu */}
      <nav className="flex-1 p-4 space-y-2">
        {menuItems.map((item) => {
          // Logic này giúp nút sáng lên khi đang ở đúng trang
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 px-4 py-3 rounded-lg transition-colors",
                isActive
                  ? "bg-blue-600 text-white shadow-lg shadow-blue-900/20"
                  : "text-slate-400 hover:bg-slate-800 hover:text-white"
              )}
            >
              <item.icon size={20} />
              <span className="font-medium">{item.title}</span>
            </Link>
          );
        })}
      </nav>

      {/* Footer Sidebar */}
      <div className="p-4 border-t border-slate-800 text-xs text-slate-500 text-center">
        v1.0.0 by Team BizFlow
      </div>
    </div>
  );
}
