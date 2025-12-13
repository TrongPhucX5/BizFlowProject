"use client";

import { Button } from "@/components/ui/button";
import { userService } from "@/services/user.service";
import { useQuery } from "@tanstack/react-query";

export default function Home() {
  // Dùng TanStack Query để gọi API
  const { data, isLoading, error } = useQuery({
    queryKey: ["users"],
    queryFn: userService.getUsers,
  });

  return (
    <div className="p-10">
      <h1 className="text-3xl font-bold text-blue-600 mb-5">
        👋 Chào mừng đến BizFlow Admin
      </h1>

      <div className="flex gap-4 mb-8">
        <Button>Nút Shadcn Mặc định</Button>
        <Button variant="destructive">Nút Xóa (Shadcn)</Button>
        <Button variant="outline">Nút Viền (Shadcn)</Button>
      </div>

      <div className="border p-5 rounded-lg shadow bg-white">
        <h2 className="text-xl font-semibold mb-3">Test kết nối Backend:</h2>

        {isLoading && <p>Đang tải dữ liệu...</p>}
        {error && (
          <p className="text-red-500">Lỗi: Không kết nối được Backend</p>
        )}

        {data && (
          <pre className="bg-slate-100 p-4 rounded overflow-auto">
            {JSON.stringify(data, null, 2)}
          </pre>
        )}
      </div>
    </div>
  );
}
