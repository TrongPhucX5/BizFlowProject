import { Button } from "@/components/ui/button";
import { Bell, Search } from "lucide-react";

export function Header() {
  return (
    <header className="h-20 bg-white/80 backdrop-blur-md border-b border-slate-100 flex items-center justify-between px-8 sticky top-0 z-40">
      {/* 1. THANH TÌM KIẾM (Giữ nguyên) */}
      <div className="flex items-center gap-4 flex-1">
        <div className="relative w-full max-w-md hidden md:block">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <input
            type="text"
            placeholder="Tìm kiếm đơn hàng, sản phẩm, khách hàng..."
            className="w-full h-10 pl-10 pr-4 rounded-full bg-slate-50 border-none text-sm focus:ring-2 focus:ring-indigo-100 focus:bg-white transition-all outline-none placeholder:text-slate-400"
          />
        </div>
      </div>

      {/* 2. ACTIONS (Chỉ còn nút thông báo) */}
      <div className="flex items-center gap-4">
        <Button
          variant="ghost"
          size="icon"
          className="rounded-full text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 relative"
        >
          <Bell size={20} />
          {/* Chấm đỏ thông báo */}
          <span className="absolute top-2 right-2.5 h-2 w-2 bg-red-500 rounded-full border-2 border-white"></span>
        </Button>
      </div>
    </header>
  );
}
