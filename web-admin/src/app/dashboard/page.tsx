"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { dashboardService } from "@/services/dashboard.service";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Plus,
  TrendingUp,
  PackageSearch,
  Users,
  AlertTriangle,
  Mic,
  Loader2,
} from "lucide-react";

import type { ApiResponse, PageResponse } from "@/types/api";

export default function DashboardPage() {
  const router = useRouter();
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("accessToken");
    if (!token) {
      router.push("/auth/login");
    } else {
      setIsChecking(false);
    }
  }, [router]);

  // 1. Fetch dữ liệu Sản phẩm
  const { data: productsRes, isLoading: isLoadingProd } = useQuery<
    ApiResponse<PageResponse<any>>
  >({
    queryKey: ["products-all"],
    queryFn: dashboardService.getProducts,
    enabled: !isChecking,
  });

  // 2. Fetch dữ liệu Đơn hàng
  const { data: ordersRes, isLoading: isLoadingOrders } = useQuery<
    ApiResponse<PageResponse<any>>
  >({
    queryKey: ["orders-all"],
    queryFn: dashboardService.getOrders,
    enabled: !isChecking,
  });

  // 3. Logic tính toán - Đã hết gạch đỏ nhờ Interface
  const stats = useMemo(() => {
    const products = productsRes?.result?.content || [];
    const orders = ordersRes?.result?.content || [];

    const totalRevenue = orders
      .filter((o: any) => o.status !== "CANCELLED")
      .reduce((sum: number, o: any) => sum + (o.totalAmount || 0), 0);

    const pendingDebt = orders
      .filter((o: any) => o.status === "UNPAID" || o.status === "PAID_PARTIAL")
      .reduce((sum: number, o: any) => sum + (o.totalAmount || 0), 0);

    const lowStockItems = products.filter((p: any) => {
      const stock = p.stock || 0;
      const limit = p.reorderLevel || 10;
      return stock <= limit;
    });

    return {
      totalRevenue,
      pendingDebt,
      lowStockCount: lowStockItems.length,
      lowStockItems: lowStockItems.slice(0, 5),
    };
  }, [productsRes, ordersRes]);

  if (isChecking || isLoadingProd || isLoadingOrders) {
    return (
      <div className="flex flex-col items-center justify-center h-screen bg-slate-50">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-600 mb-2" />
        <p className="text-slate-500 font-medium">
          Đang tải dữ liệu BizFlow...
        </p>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-8 bg-slate-50 min-h-screen">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">
            Tổng quan BizFlow
          </h1>
          <p className="text-slate-500 text-sm italic">
            Hệ thống đồng bộ dữ liệu lúc {new Date().toLocaleTimeString()}
          </p>
        </div>
        <Button className="bg-indigo-600 hover:bg-indigo-700 shadow-md">
          <Mic className="mr-2 h-4 w-4" /> Trợ lý giọng nói
        </Button>
      </div>

      {/* Thống kê từ dữ liệu thực */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Doanh thu"
          value={`${stats.totalRevenue.toLocaleString()}đ`}
          icon={<TrendingUp className="text-emerald-600" />}
          trend="Tổng các đơn thành công"
        />
        <StatCard
          title="Hàng sắp hết"
          value={stats.lowStockCount}
          icon={<AlertTriangle className="text-amber-500" />}
          trend="Cần nhập hàng ngay"
          alert={stats.lowStockCount > 0}
        />
        <StatCard
          title="Công nợ khách"
          value={`${stats.pendingDebt.toLocaleString()}đ`}
          icon={<Users className="text-blue-600" />}
          trend="Số tiền chưa thu hồi"
        />
        <StatCard
          title="Mã hàng"
          value={productsRes?.result?.totalElements || 0}
          icon={<PackageSearch className="text-purple-600" />}
          trend="Trong danh mục kho"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Bảng sản phẩm tồn kho thấp */}
        <Card className="lg:col-span-2 shadow-sm border-none bg-white">
          <CardHeader className="flex flex-row items-center justify-between border-b pb-4">
            <CardTitle className="text-lg font-bold">
              Cảnh báo tồn kho thấp
            </CardTitle>
            <Badge variant="destructive">{stats.lowStockCount} sản phẩm</Badge>
          </CardHeader>
          <CardContent className="pt-4">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Sản phẩm</TableHead>
                  <TableHead>Tồn kho</TableHead>
                  <TableHead className="text-right">Hành động</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {stats.lowStockItems.length > 0 ? (
                  stats.lowStockItems.map((item: any) => (
                    <TableRow key={item.id}>
                      <TableCell className="font-medium">{item.name}</TableCell>
                      <TableCell className="text-red-600 font-bold">
                        {item.stock} {item.unitName}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="outline"
                          size="sm"
                          className="text-indigo-600"
                        >
                          Nhập hàng
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell
                      colSpan={3}
                      className="text-center py-4 text-slate-400"
                    >
                      Kho hàng an toàn
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* AI Suggestions */}
        <Card className="shadow-sm border-none bg-indigo-900 text-white">
          <CardHeader>
            <CardTitle className="text-lg font-semibold flex items-center">
              <span className="mr-2">✨</span> Phân tích từ AI
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="p-3 bg-white/10 rounded-lg">
              <p className="text-sm italic">
                "
                {stats.lowStockCount > 0
                  ? `Bạn có ${stats.lowStockCount} mặt hàng sắp hết, hãy cân nhắc tạo phiếu nhập hàng sớm.`
                  : "Doanh thu hôm nay ổn định, không có mặt hàng nào cần nhập gấp."}
                "
              </p>
            </div>
            <Button className="w-full bg-white text-indigo-900 hover:bg-slate-100 font-bold">
              Tạo đơn bán lẻ nhanh
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function StatCard({ title, value, icon, trend, alert = false }: any) {
  return (
    <Card
      className={`shadow-sm border-none bg-white ${
        alert ? "ring-2 ring-red-100" : ""
      }`}
    >
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-xs font-bold text-slate-400 uppercase tracking-wider">
          {title}
        </CardTitle>
        <div className="p-2 bg-slate-50 rounded-lg">{icon}</div>
      </CardHeader>
      <CardContent>
        <div
          className={`text-2xl font-black ${
            alert ? "text-red-600" : "text-slate-800"
          }`}
        >
          {value}
        </div>
        <p className="text-[10px] mt-1 text-slate-400 font-medium italic">
          {trend}
        </p>
      </CardContent>
    </Card>
  );
}
