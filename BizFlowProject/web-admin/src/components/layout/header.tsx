import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";

export function Header() {
  return (
    <header className="h-16 border-b bg-white flex items-center justify-between px-6 sticky top-0 z-10">
      {/* Bên trái: Breadcrumb hoặc Tiêu đề (Để trống tạm) */}
      <div className="font-semibold text-slate-700">Trang quản trị</div>

      {/* Bên phải: User info */}
      <div className="flex items-center gap-4">
        <div className="text-right hidden md:block">
          <p className="text-sm font-medium">Lê Trọng Phúc</p>
          <p className="text-xs text-slate-500">Chủ cửa hàng</p>
        </div>
        <Avatar>
          <AvatarImage src="https://github.com/shadcn.png" />
          <AvatarFallback>AD</AvatarFallback>
        </Avatar>
      </div>
    </header>
  );
}
