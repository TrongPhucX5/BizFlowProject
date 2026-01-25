"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { reportsService } from "@/services/reports.service";
import { dashboardService } from "@/services/dashboard.service";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  BarChart3,
  TrendingUp,
  DollarSign,
  Package,
  Users,
  Download,
  Filter,
  RefreshCw,
  AlertTriangle,
  Loader2,
  CreditCard,
  Sparkles,
} from "lucide-react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart as RechartsPieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
} from "recharts";
import { format } from "date-fns";
import { vi } from "date-fns/locale";
import axiosClient from "@/lib/axios-client";

// Dữ liệu mẫu cho PieChart (vì API chưa trả về cái này, giữ lại để UI không bị trống)
const customerTypeData = [
  { name: "Khách thường", value: 65, color: "#3b82f6" },
  { name: "Khách VIP", value: 20, color: "#8b5cf6" },
  { name: "Khách sỉ", value: 15, color: "#10b981" },
];

const paymentMethodData = [
  { name: "Tiền mặt", value: 60, color: "#10b981" },
  { name: "Chuyển khoản", value: 25, color: "#3b82f6" },
  { name: "VNPAY", value: 10, color: "#8b5cf6" },
  { name: "MoMo", value: 5, color: "#f59e0b" },
];

// Dữ liệu mẫu cảnh báo tồn kho (giữ lại nếu API chưa trả về list này)
const inventoryAlertData = [
  { product: "Sắt phi 6", current: 5, min: 20, unit: "cây" },
  { product: "Gạch men 60x60", current: 15, min: 30, unit: "thùng" },
];

export default function ReportsPage() {
  const queryClient = useQueryClient();
  const [period, setPeriod] = useState("week");

  // State cho thanh toán nợ
  const [isPayDebtDialogOpen, setIsPayDebtDialogOpen] = useState(false);
  const [selectedDebt, setSelectedDebt] = useState<any>(null);
  const [payDebtAmount, setPayDebtAmount] = useState(0);
  const [payDebtMethod, setPayDebtMethod] = useState("CASH");
  const [payDebtNote, setPayDebtNote] = useState("");

  // --- 1. GỌI API THỐNG KÊ TỔNG QUAN ---
  const { data: dashboardStats } = useQuery({
    queryKey: ["dashboard-stats"],
    queryFn: reportsService.getDashboardStats,
  });

  // --- 2. GỌI API BIỂU ĐỒ DOANH THU ---
  const { data: revenueReport } = useQuery({
    queryKey: ["revenue-report", period],
    queryFn: () => reportsService.getRevenueReport({ period: period as any }),
  });

  // --- 3. GỌI API TOP SẢN PHẨM ---
  const { data: bestSelling } = useQuery({
    queryKey: ["best-selling"],
    queryFn: () => reportsService.getBestSellingProducts(),
  });

  // --- 4. GỌI API DANH SÁCH NỢ ---
  const { data: debtsData, refetch: refetchDebts } = useQuery({
    queryKey: ["debts-list"],
    queryFn: dashboardService.getDebts,
  });

  // --- 5. GỌI AI PHÂN TÍCH ---
  const { data: aiInsight, isLoading: isLoadingAi } = useQuery({
    queryKey: ["ai-insight", period],
    queryFn: async () => {
      try {
        const res = await axiosClient.post("/api/v1/ai/chat", {
          message: `Hãy phân tích tình hình kinh doanh (Doanh thu, Tồn kho) trong ${period} vừa qua và đưa ra lời khuyên ngắn gọn.`,
          history: [],
        });
        return res.data?.reply || "Không có dữ liệu phân tích.";
      } catch (e) {
        return "AI đang bận, vui lòng thử lại sau.";
      }
    },
    enabled: !!revenueReport,
  });

  // --- MAP DỮ LIỆU ---

  // Doanh thu
  const realRevenueData =
    revenueReport?.map((item: any) => ({
      date: format(new Date(item.date), "dd/MM"),
      revenue: item.totalAmount,
      orders: item.orderCount,
    })) || [];

  // Top sản phẩm
  const realProductData =
    bestSelling?.map((item: any) => ({
      name: item.name || `SP #${item.productId}`,
      sales: item.sales,
      revenue: item.revenue,
    })) || [];

  // Stats tổng quan
  const stats = dashboardStats || {
    revenueToday: 0,
    ordersToday: 0,
    totalDebt: 0,
    warningProducts: 0,
  };

  // Danh sách nợ
  const debts = (debtsData as any)?.result?.content || [];

  // Mutation trả nợ
  const payDebtMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      dashboardService.payDebt(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["debts-list"] });
      refetchDebts();
      setIsPayDebtDialogOpen(false);
      alert("Thanh toán nợ thành công!");
    },
    onError: (error) => {
      console.error(error);
      alert("Có lỗi xảy ra khi thanh toán nợ.");
    },
  });

  const [isRefreshing, setIsRefreshing] = useState(false);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await queryClient.invalidateQueries({
      queryKey: ["dashboard-stats"],
    });
    await queryClient.invalidateQueries({
      queryKey: ["revenue-report"],
    });
    await queryClient.invalidateQueries({
      queryKey: ["best-selling"],
    });
    refetchDebts();
    
    // Giả lập delay một chút để người dùng thấy hiệu ứng xoay (nếu mạng quá nhanh)
    setTimeout(() => setIsRefreshing(false), 800);
  };

  const handleOpenPayDebt = (debt: any) => {
    setSelectedDebt(debt);
    setPayDebtAmount(debt.unpaidAmount);
    setPayDebtMethod("CASH");
    setPayDebtNote("Trả nợ");
    setIsPayDebtDialogOpen(true);
  };

  const handlePayDebt = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedDebt) return;
    payDebtMutation.mutate({
      id: selectedDebt.id,
      data: {
        amount: payDebtAmount,
        paymentMethod: payDebtMethod,
        note: payDebtNote,
      },
    });
  };

  const handleExport = async () => {
    try {
      const blob = await reportsService.exportGeneralReport();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `bao-cao-tong-quan-${format(new Date(), "dd-MM-yyyy")}.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    } catch (error) {
      console.error("Export failed:", error);
      alert("Xuất báo cáo thất bại.");
    }
  };

  return (
    <div className="p-8 space-y-8 bg-slate-50/50 min-h-screen">
      {/* HEADER */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">
            Báo cáo & Thống kê
          </h1>
          <p className="text-slate-500 mt-1">
            Phân tích dữ liệu kinh doanh theo thời gian thực
          </p>
        </div>
        <div className="flex gap-3">
          <Button
            variant="outline"
            onClick={handleRefresh}
            className="bg-white"
            disabled={isRefreshing}
          >
            <RefreshCw className={`mr-2 h-4 w-4 ${isRefreshing ? "animate-spin" : ""}`} /> 
            {isRefreshing ? "Đang tải..." : "Làm mới"}
          </Button>
          <Button 
            className="bg-indigo-600 hover:bg-indigo-700"
            onClick={handleExport}
          >
            <Download className="mr-2 h-4 w-4" /> Xuất báo cáo
          </Button>
        </div>
      </div>

      {/* FILTERS */}
      <div className="bg-white p-4 rounded-xl border shadow-sm">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <Filter className="h-4 w-4 text-slate-500" />
            <span className="text-sm font-medium text-slate-700">Bộ lọc:</span>
          </div>
          <Select value={period} onValueChange={setPeriod}>
            <SelectTrigger className="w-[150px]">
              <SelectValue placeholder="Chọn kỳ" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="today">Hôm nay</SelectItem>
              <SelectItem value="week">Tuần này</SelectItem>
              <SelectItem value="month">Tháng này</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* QUICK STATS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Doanh thu */}
        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500 mb-1">Doanh thu hôm nay</p>
                <p className="text-2xl font-bold text-emerald-600">
                  {stats.revenueToday?.toLocaleString()}đ
                </p>
              </div>
              <div className="p-3 bg-emerald-50 rounded-full">
                <DollarSign className="h-6 w-6 text-emerald-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Tổng đơn */}
        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500 mb-1">Tổng đơn hôm nay</p>
                <p className="text-2xl font-bold text-blue-600">
                  {stats.ordersToday}
                </p>
              </div>
              <div className="p-3 bg-blue-50 rounded-full">
                <TrendingUp className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Công nợ */}
        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500 mb-1">Tổng công nợ</p>
                <p className="text-2xl font-bold text-amber-600">
                  {stats.totalDebt?.toLocaleString() || "0"}đ
                </p>
                <p className="text-xs text-slate-400 mt-1">
                  {debts.length} khách hàng nợ
                </p>
              </div>
              <div className="p-3 bg-amber-50 rounded-full">
                <Users className="h-6 w-6 text-amber-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Cảnh báo */}
        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500 mb-1">Cảnh báo tồn kho</p>
                <p className="text-2xl font-bold text-red-600">
                  {inventoryAlertData.length}
                </p>
                <p className="text-xs text-slate-400 mt-1">Mặt hàng sắp hết</p>
              </div>
              <div className="p-3 bg-red-50 rounded-full">
                <AlertTriangle className="h-6 w-6 text-red-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* CHARTS & DETAILS */}
      <Tabs defaultValue="revenue" className="space-y-6">
        <TabsList>
          <TabsTrigger value="revenue">Doanh thu</TabsTrigger>
          <TabsTrigger value="inventory">Tồn kho</TabsTrigger>
          <TabsTrigger value="debt">Công nợ</TabsTrigger>
        </TabsList>

        {/* TAB 1: REVENUE */}
        <TabsContent value="revenue" className="space-y-6">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <Card className="lg:col-span-2">
              <CardHeader>
                <CardTitle>Biểu đồ doanh thu</CardTitle>
                <CardDescription>Dữ liệu thực tế từ hệ thống</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="h-[300px]">
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={realRevenueData}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                      <XAxis dataKey="date" stroke="#6b7280" />
                      <YAxis stroke="#6b7280" />
                      <Tooltip
                        formatter={(value) => [
                          `${Number(value).toLocaleString()}đ`,
                          "Doanh thu",
                        ]}
                      />
                      <Area
                        type="monotone"
                        dataKey="revenue"
                        stroke="#10b981"
                        fill="#10b981"
                        fillOpacity={0.2}
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Top Sản Phẩm</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="h-[300px]">
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={realProductData} layout="vertical">
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis type="number" />
                      <YAxis
                        type="category"
                        dataKey="name"
                        width={80}
                        style={{ fontSize: "11px" }}
                      />
                      <Tooltip />
                      <Bar dataKey="sales" fill="#3b82f6" name="Số lượng" />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* TAB 2: INVENTORY */}
        <TabsContent value="inventory" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Phân loại tồn kho theo Top bán chạy</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-[350px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={realProductData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                    <XAxis
                      dataKey="name"
                      stroke="#6b7280"
                      style={{ fontSize: "11px" }}
                    />
                    <YAxis stroke="#6b7280" />
                    <Tooltip formatter={(value) => [value, "Đã bán"]} />
                    <Bar dataKey="sales" fill="#8b5cf6" name="Số lượng bán" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* TAB 3: DEBT - Đã khôi phục bảng */}
        <TabsContent value="debt">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>Danh sách công nợ</CardTitle>
                  <CardDescription>
                    Hiện có {debts.length} khách hàng đang nợ
                  </CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b">
                      <th className="text-left py-3 px-4 font-medium text-slate-700">
                        Khách hàng
                      </th>
                      <th className="text-left py-3 px-4 font-medium text-slate-700">
                        SĐT
                      </th>
                      <th className="text-left py-3 px-4 font-medium text-slate-700">
                        Nợ hiện tại
                      </th>
                      <th className="text-left py-3 px-4 font-medium text-slate-700">
                        Hành động
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {debts.length > 0 ? (
                      debts.map((item: any, index: number) => (
                        <tr key={index} className="border-b hover:bg-slate-50">
                          <td className="py-3 px-4 font-medium">
                            {item.customerName}
                          </td>
                          <td className="py-3 px-4">{item.customerPhone}</td>
                          <td className="py-3 px-4 font-bold text-amber-600">
                            {item.unpaidAmount.toLocaleString()}đ
                          </td>
                          <td className="py-3 px-4">
                            <Button
                              size="sm"
                              className="bg-green-600 hover:bg-green-700"
                              onClick={() => handleOpenPayDebt(item)}
                            >
                              <CreditCard className="mr-2 h-4 w-4" /> Trả nợ
                            </Button>
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td
                          colSpan={4}
                          className="text-center py-8 text-slate-500"
                        >
                          Tuyệt vời! Không có công nợ nào.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* AI INSIGHTS */}
      <Card className="bg-gradient-to-r from-indigo-50 to-blue-50 border-indigo-200 shadow-md">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-indigo-800">
            <Sparkles className="h-5 w-5 text-indigo-600 animate-pulse" />
            Trợ lý AI Phân tích & Đề xuất
          </CardTitle>
        </CardHeader>
        <CardContent>
          {isLoadingAi ? (
            <div className="space-y-2 animate-pulse">
              <div className="h-4 bg-indigo-200 rounded w-3/4"></div>
              <div className="h-4 bg-indigo-200 rounded w-1/2"></div>
            </div>
          ) : (
            <div className="p-4 bg-white/90 rounded-xl border border-indigo-100 shadow-sm text-slate-700 whitespace-pre-line leading-relaxed">
              {aiInsight}
            </div>
          )}
        </CardContent>
      </Card>

      {/* DIALOG THANH TOÁN */}
      <Dialog open={isPayDebtDialogOpen} onOpenChange={setIsPayDebtDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Thanh toán nợ</DialogTitle>
            <DialogDescription>
              Ghi nhận thanh toán công nợ cho khách hàng.
            </DialogDescription>
          </DialogHeader>
          {selectedDebt && (
            <form onSubmit={handlePayDebt} className="space-y-4 py-4">
              <div className="p-4 bg-slate-50 rounded-lg space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-600">Khách hàng:</span>
                  <span className="font-bold">{selectedDebt.customerName}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-600">Tổng nợ:</span>
                  <span className="font-bold text-red-600">
                    {selectedDebt.unpaidAmount.toLocaleString()}đ
                  </span>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="payAmount">Số tiền trả (VNĐ)</Label>
                <Input
                  id="payAmount"
                  type="number"
                  value={payDebtAmount}
                  onChange={(e) => setPayDebtAmount(Number(e.target.value))}
                  required
                  className="font-bold text-lg"
                />
              </div>

              <div className="space-y-2">
                <Label>Phương thức thanh toán</Label>
                <Select value={payDebtMethod} onValueChange={setPayDebtMethod}>
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn phương thức" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="CASH">Tiền mặt</SelectItem>
                    <SelectItem value="TRANSFER">Chuyển khoản</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="payNote">Ghi chú</Label>
                <Input
                  id="payNote"
                  value={payDebtNote}
                  onChange={(e) => setPayDebtNote(e.target.value)}
                />
              </div>

              <DialogFooter>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsPayDebtDialogOpen(false)}
                >
                  Hủy
                </Button>
                <Button
                  type="submit"
                  className="bg-green-600 hover:bg-green-700"
                  disabled={payDebtMutation.isPending}
                >
                  {payDebtMutation.isPending ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang xử
                      lý
                    </>
                  ) : (
                    "Xác nhận thanh toán"
                  )}
                </Button>
              </DialogFooter>
            </form>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
