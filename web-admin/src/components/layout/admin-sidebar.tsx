"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutGrid,
  Store,
  CreditCard,
  ShieldAlert,
  Activity,
  LogOut
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";

// Menu cho SaaS Super Admin
const adminMenuItems = [
  { title: "Dashboard SaaS", icon: LayoutGrid, href: "/admin/dashboard" },
  { title: "Quản lý Tenant", icon: Store, href: "/admin/stores" },
  { title: "Gói dịch vụ", icon: CreditCard, href: "/admin/plans" },
  { title: "Phân quyền Global", icon: ShieldAlert, href: "/admin/roles" },
  { title: "System Logs", icon: Activity, href: "/admin/logs" },
];

export function AdminSidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = () => {
    // Xóa token khỏi localStorage
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    // Chuyển hướng về trang Login
    router.push("/auth/login");
  };

  return (
    <aside className="w-64 bg-slate-900 text-slate-300 border-r border-slate-800 flex flex-col fixed inset-y-0 left-0 z-50">
      {/* 1. LOGO SaaS */}
      <div className="h-20 flex items-center px-6 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 bg-blue-600 rounded-xl flex items-center justify-center shadow-lg shadow-blue-900/50">
            <ShieldAlert className="text-white h-5 w-5" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-white tracking-tight">
              BizFlow <span className="text-blue-500">Master</span>
            </h1>
            <p className="text-[10px] text-slate-500 font-semibold uppercase tracking-wider">
              Super Admin
            </p>
          </div>
        </div>
      </div>

      {/* 2. MENU */}
      <nav className="flex-1 px-4 py-6 space-y-1">
        <p className="px-4 text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-3">
          System Management
        </p>
        {adminMenuItems.map((item) => {
          const isActive = pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200",
                isActive
                  ? "bg-blue-600 text-white shadow-md shadow-blue-900/20"
                  : "hover:bg-slate-800 hover:text-white"
              )}
            >
              <item.icon size={20} />
              <span>{item.title}</span>
            </Link>
          );
        })}
      </nav>

      {/* 3. FOOTER */}
      <div className="p-4 border-t border-slate-800">
        <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-800/50 border border-slate-700">
          <Avatar className="h-9 w-9 border border-slate-600">
            <AvatarFallback className="bg-slate-700 text-white">SA</AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-white truncate">Super Admin</p>
            <p className="text-xs text-slate-400 truncate">System Owner</p>
          </div>
          <button onClick={handleLogout} className="text-slate-400 hover:text-red-400">
            <LogOut size={18} />
          </button>
        </div>
      </div>
    </aside>
  );
}
