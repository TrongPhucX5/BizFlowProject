"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { dashboardService } from "@/services/dashboard.service";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Wallet,
  FileText,
  Bell,
  AlertOctagon,
  PackageMinus,
  Loader2,
  ChevronRight,
} from "lucide-react";
// Import thư viện biểu đồ
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

import type { ApiResponse, PageResponse } from "@/types/api";

export default function DashboardPage() {
  const router = useRouter();
  const [isChecking, setIsChecking] = useState(true);

  // --- AUTH CHECK ---
  useEffect(() => {
    const token = localStorage.getItem("accessToken");
    if (!token) router.push("/auth/login");
    else setIsChecking(false);
  }, [router]);

  // --- DATA FETCHING (DỮ LIỆU THẬT) ---
  const { data: productsRes, isLoading: isLoadingProd } = useQuery<
    ApiResponse<PageResponse<any>>
  >({
    queryKey: ["products-all"],
    queryFn: dashboardService.getProducts,
    enabled: !isChecking,
  });

  const { data: ordersRes, isLoading: isLoadingOrders } = useQuery<
    ApiResponse<PageResponse<any>>
  >({
    queryKey: ["orders-all"],
    queryFn: dashboardService.getOrders,
    enabled: !isChecking,
  });

  // --- LOGIC TÍNH TOÁN (XỬ LÝ DỮ LIỆU THẬT) ---
  const stats = useMemo(() => {
    const products = productsRes?.result?.content || [];
    const orders = ordersRes?.result?.content || [];

    // 1. Tổng tiền (Total Payment)
    const totalRevenue = orders
      .filter((o: any) => o.status !== "CANCELLED")
      .reduce((sum: number, o: any) => sum + (o.totalAmount || 0), 0);

    // 2. Tổng đơn (Total Transaction)
    const totalOrders = orders.length;

    // 3. Công nợ (Overdue)
    const pendingDebt = orders
      .filter((o: any) => o.status === "UNPAID" || o.status === "PAID_PARTIAL")
      .reduce((sum: number, o: any) => sum + (o.totalAmount || 0), 0);

    // 4. Hàng sắp hết (Unpaid/Alert)
    const lowStockItems = products.filter(
      (p: any) => (p.stock || 0) <= (p.reorderLevel || 10),
    );

    // 5. XỬ LÝ BIỂU ĐỒ TỪ DỮ LIỆU ĐƠN HÀNG THẬT
    // Tạo khung 6 tháng gần nhất
    const last6Months = Array.from({ length: 6 }, (_, i) => {
      const d = new Date();
      d.setMonth(d.getMonth() - i);
      return {
        month: d.getMonth() + 1,
        year: d.getFullYear(),
        name: `T${d.getMonth() + 1}`, // Nhãn: T1, T2...
        revenue: 0,
        expense: 0,
      };
    }).reverse(); // Đảo ngược để tháng cũ bên trái, tháng mới bên phải

    // Duyệt qua đơn hàng thật để cộng dồn tiền vào từng tháng
    orders.forEach((order: any) => {
      if (order.status === "CANCELLED") return;

      const d = new Date(order.createdAt); // Lấy ngày tạo đơn
      const monthIndex = last6Months.findIndex(
        (m) => m.month === d.getMonth() + 1 && m.year === d.getFullYear(),
      );

      if (monthIndex !== -1) {
        const amount = order.totalAmount || 0;
        last6Months[monthIndex].revenue += amount;
        // Giả lập chi phí = 70% doanh thu (vì chưa có API chi phí riêng)
        last6Months[monthIndex].expense += amount * 0.7;
      }
    });

    return {
      totalRevenue,
      totalOrders,
      pendingDebt,
      lowStockCount: lowStockItems.length,
      lowStockItems: lowStockItems.slice(0, 5),
      chartData: last6Months, // <--- Dữ liệu biểu đồ THẬT
    };
  }, [productsRes, ordersRes]);

  if (isChecking) {
    return (
      <div className="flex h-screen items-center justify-center bg-[#F8F9FC]">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-600" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* TITLE */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Tổng quan</h1>
          <p className="text-sm text-slate-500 mt-1">
            Chào mừng quay trở lại, Phúc!
          </p>
        </div>

        {/* Nút thông báo nằm gọn ở đây */}
        <Button
          variant="outline"
          size="icon"
          className="rounded-full bg-white border-slate-200 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 relative shadow-sm h-10 w-10"
        >
          <Bell size={20} />
          {/* Chấm đỏ báo hiệu có tin mới */}
          <span className="absolute top-2.5 right-2.5 h-2 w-2 bg-red-500 rounded-full border-2 border-white"></span>
        </Button>
      </div>

      {/* 1. TOP STATS CARDS (DATA THẬT + GIAO DIỆN MỚI) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCardNew
          label="Tổng Doanh Thu"
          value={
            isLoadingOrders ? "..." : `${stats.totalRevenue.toLocaleString()}đ`
          }
          icon={Wallet}
          theme="green"
        />
        <StatCardNew
          label="Tổng Đơn Hàng"
          value={isLoadingOrders ? "..." : stats.totalOrders.toString()}
          icon={FileText}
          theme="purple"
        />
        <StatCardNew
          label="Công Nợ Khách"
          value={
            isLoadingOrders ? "..." : `${stats.pendingDebt.toLocaleString()}đ`
          }
          icon={AlertOctagon}
          theme="orange"
        />
        <StatCardNew
          label="Cảnh Báo Kho"
          value={isLoadingProd ? "..." : `${stats.lowStockCount} SP`}
          icon={PackageMinus}
          theme="red"
        />
      </div>

      {/* 2. MAIN CONTENT GRID */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* CỘT TRÁI: BIỂU ĐỒ (DỮ LIỆU THẬT ĐÃ XỬ LÝ) */}
        <Card className="col-span-1 lg:col-span-2 border-none shadow-sm">
          <CardHeader>
            <CardTitle className="text-lg font-bold text-slate-700">
              Analytics (Doanh thu 6 tháng)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[350px] w-full mt-4">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={stats.chartData} barSize={30}>
                  <CartesianGrid
                    strokeDasharray="3 3"
                    vertical={false}
                    stroke="#E2E8F0"
                  />
                  <XAxis
                    dataKey="name"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#64748B" }}
                    dy={10}
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#64748B" }}
                    tickFormatter={(value) => `${value / 1000}k`} // Rút gọn số tiền
                  />
                  <Tooltip
                    cursor={{ fill: "#F1F5F9" }}
                    formatter={(value: any) => `${value.toLocaleString()}đ`}
                    contentStyle={{
                      borderRadius: "8px",
                      border: "none",
                      boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)",
                    }}
                  />
                  {/* Doanh thu thực tế */}
                  <Bar
                    dataKey="revenue"
                    name="Doanh thu"
                    fill="#6366F1"
                    radius={[4, 4, 0, 0]}
                  />
                  {/* Chi phí ước tính (để biểu đồ đẹp có 2 cột) */}
                  <Bar
                    dataKey="expense"
                    name="Chi phí (Est)"
                    fill="#E2E8F0"
                    radius={[4, 4, 0, 0]}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* CỘT PHẢI: LIST CẢNH BÁO (DỮ LIỆU THẬT) */}
        <Card className="col-span-1 border-none shadow-sm">
          <CardHeader className="pb-2">
            <CardTitle className="text-lg font-bold text-slate-700">
              Cần Nhập Hàng
            </CardTitle>
            <p className="text-xs text-slate-400">Các sản phẩm dưới định mức</p>
          </CardHeader>
          <CardContent className="pt-4">
            <div className="space-y-6">
              {isLoadingProd ? (
                <div className="text-center py-4 text-slate-400">
                  <Loader2 className="h-6 w-6 animate-spin mx-auto" />
                </div>
              ) : stats.lowStockItems.length === 0 ? (
                <div className="text-center py-10 flex flex-col items-center text-slate-400">
                  <div className="h-12 w-12 bg-green-50 rounded-full flex items-center justify-center mb-3">
                    <PackageMinus className="text-green-500" />
                  </div>
                  <span className="text-sm">Kho hàng ổn định</span>
                </div>
              ) : (
                stats.lowStockItems.map((item: any) => (
                  <div
                    key={item.id}
                    className="flex items-center justify-between group"
                  >
                    <div className="flex items-center gap-3">
                      {/* Avatar hiển thị 2 chữ cái đầu của tên SP */}
                      <Avatar className="h-10 w-10 bg-red-50 text-red-500 border border-red-100">
                        <AvatarImage src={item.image} />
                        <AvatarFallback className="font-bold text-xs">
                          {item.name
                            ? item.name.substring(0, 2).toUpperCase()
                            : "SP"}
                        </AvatarFallback>
                      </Avatar>

                      <div className="flex flex-col">
                        <span className="font-semibold text-sm text-slate-700 group-hover:text-indigo-600 transition-colors line-clamp-1 max-w-[120px]">
                          {item.name}
                        </span>
                        <span className="text-xs text-slate-400">
                          Còn:{" "}
                          <span className="text-red-500 font-bold">
                            {item.stock}
                          </span>{" "}
                          {item.unitName}
                        </span>
                      </div>
                    </div>

                    <Button
                      variant="ghost"
                      size="sm"
                      className="text-xs font-semibold text-slate-400 hover:text-indigo-600 underline h-auto p-0"
                    >
                      Chi tiết
                    </Button>
                  </div>
                ))
              )}
            </div>

            <div className="mt-6 pt-4 border-t border-slate-100 text-center">
              <Button
                variant="link"
                className="text-indigo-600 font-bold text-sm"
                onClick={() => router.push("/dashboard/products")}
              >
                Quản lý kho <ChevronRight size={16} />
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

// --- COMPONENT THẺ STAT MỚI (STYLE CLEAN UI) ---
function StatCardNew({ label, value, icon: Icon, theme }: any) {
  const themes: any = {
    green: {
      bg: "bg-emerald-50",
      text: "text-emerald-600",
      iconBg: "bg-emerald-100",
    },
    purple: {
      bg: "bg-indigo-50",
      text: "text-indigo-600",
      iconBg: "bg-indigo-100",
    },
    orange: {
      bg: "bg-orange-50",
      text: "text-orange-600",
      iconBg: "bg-orange-100",
    },
    red: { bg: "bg-rose-50", text: "text-rose-600", iconBg: "bg-rose-100" },
  };

  const t = themes[theme] || themes.green;

  return (
    <Card className="border-none shadow-sm hover:shadow-md transition-shadow duration-200">
      <CardContent className="p-6 flex items-center gap-4">
        <div
          className={`h-12 w-12 rounded-xl flex items-center justify-center ${t.iconBg} ${t.text}`}
        >
          <Icon size={24} strokeWidth={2.5} />
        </div>

        <div>
          <p className="text-xs font-medium text-slate-400 mb-1">{label}</p>
          <h3 className="text-xl font-bold text-slate-800">{value}</h3>
        </div>
      </CardContent>
    </Card>
  );
}
