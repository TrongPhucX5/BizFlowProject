"use client";

import * as XLSX from "xlsx";
import { saveAs } from "file-saver";
import { useState, useRef, useEffect } from "react";
import { useRouter } from "next/navigation";
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
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
  Calendar,
  Printer,

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

import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Calendar as CalendarComponent } from "@/components/ui/calendar";
import { DateRange } from "react-day-picker";
import { addDays, format, subDays } from "date-fns";
import { cn } from "@/lib/utils";
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

import { toast } from "sonner";

import { VoucherDialog } from "@/components/reports/voucher-dialog";

export default function ReportsPage() {
  const [voucherType, setVoucherType] = useState<"receipt" | "payment">("receipt");
  const [isVoucherDialogOpen, setIsVoucherDialogOpen] = useState(false);

  const router = useRouter();
  const queryClient = useQueryClient();
  const [period, setPeriod] = useState("week");

  // --- WEBSOCKET CONNECTION ---
  useEffect(() => {
    // Try to connect to WebSocket
    // Note: Adjust URL if backend is on different port/host
    const ws = new WebSocket("ws://localhost:8080/ws/notifications");

    ws.onopen = () => {
      console.log("Connected to Real-time Notification Server");
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        console.log("WS Message:", data);

        // Show notification
        toast(data.title || "Thông báo mới", {
          description: data.body,
          action: {
            label: "Xem ngay",
            onClick: () => {
              queryClient.invalidateQueries();
              // Navigate to orders page with viewId if available
              if (data.orderId) {
                router.push(`/dashboard/orders?viewId=${data.orderId}`);
              } else {
                router.push("/dashboard/orders");
              }
            },
          },
        });

        // Auto refresh data
        queryClient.invalidateQueries();
      } catch (e) {
        console.error("Error parsing WS message", e);
      }
    };

    ws.onclose = () => {
      console.log("Disconnected from Notification Server");
    };

    return () => {
      if (ws.readyState === 1) ws.close();
    };
  }, [queryClient]);

  const [activeTab, setActiveTab] = useState("revenue"); // Control tabs
  const [dateRange, setDateRange] = useState<DateRange | undefined>({
    from: subDays(new Date(), 7),
    to: new Date(),
  });

  // State cho thanh toán nợ
  const [isPayDebtDialogOpen, setIsPayDebtDialogOpen] = useState(false);
  const [selectedDebt, setSelectedDebt] = useState<any>(null);
  const [payDebtAmount, setPayDebtAmount] = useState(0);
  const [payDebtMethod, setPayDebtMethod] = useState("CASH");
  const [payDebtNote, setPayDebtNote] = useState("");

  // State cho AI Chat
  const [chatHistory, setChatHistory] = useState<any[]>([]);
  const [chatInput, setChatInput] = useState("");
  const [isChatSending, setIsChatSending] = useState(false);
  const messagesEndRef = useRef<null | HTMLDivElement>(null);

  // Drill-down state
  const [selectedDrillDate, setSelectedDrillDate] = useState<string | null>(
    null,
  );

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [chatHistory, isChatSending]);

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

  // --- 4.5. GỌI API ĐƠN HÀNG GẦN ĐÂY ---
  const { data: recentOrders } = useQuery({
    queryKey: ["recent-orders"],
    queryFn: dashboardService.getRecentOrders,
  });

  // --- 4.5.2 GỌI API SẢN PHẨM SẮP HẾT HÀNG ---
  const { data: lowStockProducts } = useQuery({
    queryKey: ["low-stock-products"],
    queryFn: dashboardService.getLowStockProducts,
  });

  // --- 4.5.1 GỌI API ĐƠN HÀNG THEO NGÀY (DRILL-DOWN) ---
  const { data: ordersByDate, refetch: refetchOrdersByDate } = useQuery({
    queryKey: ["orders-by-date", selectedDrillDate],
    queryFn: () =>
      selectedDrillDate
        ? dashboardService.getOrdersByDate(selectedDrillDate)
        : Promise.resolve([]),
    enabled: !!selectedDrillDate,
  });

  // Determine which list of orders to show
  const displayOrders = selectedDrillDate ? ordersByDate : recentOrders;

  // --- 4.6. GỌI API TOP KHÁCH HÀNG ---
  const { data: topCustomers } = useQuery({
    queryKey: ["top-customers", period],
    queryFn: () => dashboardService.getTopCustomers(period),
  });

  // --- 5. GỌI AI PHÂN TÍCH ---
  const { data: aiInsight, isLoading: isLoadingAi } = useQuery({
    queryKey: ["ai-insight", period],
    queryFn: async () => {
      try {
        const data = await reportsService.getAiInsight(period);
        const reply = data?.reply || "Không có dữ liệu phân tích.";
        // Tự động thêm vào lịch sử chat
        setChatHistory([{ role: "model", content: reply }]);
        return reply;
      } catch (e) {
        return "AI đang bận, vui lòng thử lại sau.";
      }
    },
    enabled: !!revenueReport,
  });

  // Xử lý gửi tin nhắn
  const handleSendChat = async () => {
    if (!chatInput.trim()) return;

    const userMsg = chatInput;
    setChatInput("");
    setChatHistory((prev) => [...prev, { role: "user", content: userMsg }]);
    setIsChatSending(true);

    try {
      // Gửi kèm lịch sử để AI hiểu ngữ cảnh
      const apiHistory = chatHistory.map((msg) => ({
        role: msg.role === "model" ? "model" : "user",
        content: msg.content,
      }));

      const data = await reportsService.chatWithAi(userMsg, apiHistory);
      const reply = data?.reply || "Xin lỗi, tôi không hiểu ý bạn.";

      setChatHistory((prev) => [...prev, { role: "model", content: reply }]);
    } catch (error) {
      setChatHistory((prev) => [
        ...prev,
        { role: "model", content: "Lỗi kết nối tới AI Service." },
      ]);
    } finally {
      setIsChatSending(false);
    }
  };

  // --- MAP DỮ LIỆU ---

  // Doanh thu
  const realRevenueData =
    revenueReport?.map((item: any) => ({
      date: format(new Date(item.date), "dd/MM"),
      revenue: item.totalAmount,
      profit: item.profit || 0, // Map profit
      orders: item.orderCount,
      fullDate: format(new Date(item.date), "yyyy-MM-dd"), // Store full date for drill-down
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

  const handleExport = () => {
    try {
      // lấy dữ liệu đang có trên dashboard (ví dụ: revenue)
      const data = realRevenueData.map((r: any) => ({
        Ngày: r.date,
        "Doanh thu": r.revenue,
        "Lợi nhuận": r.profit,
        "Số đơn": r.orders,
      }));

      const worksheet = XLSX.utils.json_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, "BaoCao");

      const excelBuffer = XLSX.write(workbook, {
        bookType: "xlsx",
        type: "array",
      });

      const blob = new Blob([excelBuffer], {
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      });

      saveAs(
        blob,
        `bao-cao-tong-quan-${format(new Date(), "dd-MM-yyyy")}.xlsx`,
      );
    } catch (error) {
      console.error("Export failed:", error);
      alert("Xuất Excel thất bại.");
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
            <RefreshCw
              className={`mr-2 h-4 w-4 ${isRefreshing ? "animate-spin" : ""}`}
            />
            {isRefreshing ? "Đang tải..." : "Làm mới"}
          </Button>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" className="bg-white">
                <Printer className="mr-2 h-4 w-4" /> In phiếu
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem
                onClick={() => {
                  setVoucherType("receipt");
                  setIsVoucherDialogOpen(true);
                }}
              >
                In Phiếu Thu (Mẫu 01)
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => {
                  setVoucherType("payment");
                  setIsVoucherDialogOpen(true);
                }}
              >
                In Phiếu Chi (Mẫu 02)
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <VoucherDialog
            open={isVoucherDialogOpen}
            onOpenChange={setIsVoucherDialogOpen}
            type={voucherType}
          />

          <Button
            className="bg-indigo-600 hover:bg-indigo-700"
            onClick={handleExport}
          >
            <Download className="mr-2 h-4 w-4" /> Xuất báo cáo
          </Button>
        </div>
      </div>

      {/* FILTERS */}
      <div className="bg-white p-1.5 rounded-xl border shadow-sm inline-flex items-center">
        {[
          { id: "today", label: "Hôm nay" },
          { id: "week", label: "Tuần này" },
          { id: "month", label: "Tháng này" },
        ].map((p) => (
          <button
            key={p.id}
            onClick={() => setPeriod(p.id)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${period === p.id
              ? "bg-indigo-600 text-white shadow-sm"
              : "text-slate-600 hover:bg-slate-50 hover:text-indigo-600"
              }`}
          >
            {p.label}
          </button>
        ))}
        <div className="w-px h-5 bg-slate-200 mx-2"></div>
        <Popover>
          <PopoverTrigger asChild>
            <button
              className={cn(
                "px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-all",
                period.startsWith("custom")
                  ? "bg-indigo-600 text-white shadow-sm"
                  : "text-slate-600 hover:bg-slate-50 hover:text-indigo-600",
              )}
            >
              <Calendar className="h-4 w-4" />
              <span>
                {dateRange?.from ? (
                  dateRange.to ? (
                    <>
                      {format(dateRange.from, "dd/MM")} -{" "}
                      {format(dateRange.to, "dd/MM")}
                    </>
                  ) : (
                    format(dateRange.from, "dd/MM")
                  )
                ) : (
                  "Tùy chọn"
                )}
              </span>
            </button>
          </PopoverTrigger>
          <PopoverContent className="w-auto p-0" align="end">
            <CalendarComponent
              initialFocus
              mode="range"
              defaultMonth={dateRange?.from}
              selected={dateRange}
              onSelect={(range) => {
                setDateRange(range);
                if (range?.from && range?.to) {
                  setPeriod(
                    `custom:${format(range.from, "yyyy-MM-dd")}:${format(
                      range.to,
                      "yyyy-MM-dd",
                    )}`,
                  );
                }
              }}
              numberOfMonths={2}
            />
          </PopoverContent>
        </Popover>
      </div>

      {/* QUICK STATS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Doanh thu */}
        <Card className="bg-emerald-50 border-emerald-100 shadow-sm transition-all hover:shadow-md">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-emerald-800 mb-1">
                  Doanh thu hôm nay
                </p>
                <p className="text-3xl font-bold text-emerald-700">
                  {stats.revenueToday?.toLocaleString()}đ
                </p>
                <div className="flex items-center mt-2 gap-1 text-xs font-semibold text-emerald-600 bg-emerald-100/50 w-fit px-2 py-1 rounded-full">
                  <TrendingUp className="h-3 w-3" />
                  <span>+12% so với hôm qua</span>
                </div>
              </div>
              <div className="p-3 bg-white rounded-xl shadow-sm">
                <DollarSign className="h-6 w-6 text-emerald-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Tổng đơn */}
        <Card
          className="bg-blue-50 border-blue-100 shadow-sm transition-all hover:shadow-md cursor-pointer hover:bg-blue-100"
          onClick={() => router.push("/dashboard/orders")}
        >
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-blue-800 mb-1">
                  Tổng đơn hôm nay
                </p>
                <p className="text-3xl font-bold text-blue-700">
                  {stats.ordersToday}
                </p>
                <div className="flex items-center mt-2 gap-1 text-xs font-semibold text-blue-600 bg-blue-100/50 w-fit px-2 py-1 rounded-full">
                  <TrendingUp className="h-3 w-3" />
                  <span>+5% so với hôm qua</span>
                </div>
              </div>
              <div className="p-3 bg-white rounded-xl shadow-sm">
                <Package className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Công nợ */}
        <Card className="bg-amber-50 border-amber-100 shadow-sm transition-all hover:shadow-md">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-amber-800 mb-1">
                  Tổng công nợ
                </p>
                <p className="text-3xl font-bold text-amber-700">
                  {stats.totalDebt?.toLocaleString()}đ
                </p>
                <div className="flex items-center mt-2 gap-1 text-xs font-semibold text-amber-600 bg-amber-100/50 w-fit px-2 py-1 rounded-full">
                  <AlertTriangle className="h-3 w-3" />
                  <span>Cần thu hồi sớm</span>
                </div>
              </div>
              <div className="p-3 bg-white rounded-xl shadow-sm">
                <Users className="h-6 w-6 text-amber-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Cảnh báo tồn kho */}
        <Card
          className="bg-red-50 border-red-100 shadow-sm transition-all hover:shadow-md cursor-pointer hover:bg-red-100"
          onClick={() => setActiveTab("inventory")}
        >
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-red-800 mb-1">
                  Sắp hết hàng
                </p>
                <p className="text-3xl font-bold text-red-700">
                  {stats.warningProducts}{" "}
                  <span className="text-lg font-normal text-red-600">sp</span>
                </p>
                <div className="flex items-center mt-2 gap-1 text-xs font-semibold text-red-600 bg-red-100/50 w-fit px-2 py-1 rounded-full">
                  <AlertTriangle className="h-3 w-3" />
                  <span>Cần nhập thêm</span>
                </div>
              </div>
              <div className="p-3 bg-white rounded-xl shadow-sm">
                <AlertTriangle className="h-6 w-6 text-red-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* TABS CONTENT */}
      <Tabs
        value={activeTab}
        onValueChange={setActiveTab}
        className="space-y-6"
      >
        <TabsList className="bg-white p-1 rounded-xl shadow-sm border">
          <TabsTrigger
            value="revenue"
            className="rounded-lg data-[state=active]:bg-indigo-600 data-[state=active]:text-white"
          >
            <BarChart3 className="mr-2 h-4 w-4" /> Doanh thu & Lợi nhuận
          </TabsTrigger>
          <TabsTrigger
            value="inventory"
            className="rounded-lg data-[state=active]:bg-indigo-600 data-[state=active]:text-white"
          >
            <Package className="mr-2 h-4 w-4" /> Tồn kho & Sản phẩm
          </TabsTrigger>
          <TabsTrigger
            value="debt"
            className="rounded-lg data-[state=active]:bg-indigo-600 data-[state=active]:text-white"
          >
            <DollarSign className="mr-2 h-4 w-4" /> Công nợ khách hàng
          </TabsTrigger>
        </TabsList>

        {/* TAB 1: REVENUE */}
        <TabsContent value="revenue" className="space-y-6">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* CHART */}
            <Card className="lg:col-span-3 shadow-md border-indigo-100">
              <CardHeader>
                <CardTitle>Biểu đồ doanh thu</CardTitle>
                <CardDescription>
                  Theo dõi doanh thu và lợi nhuận theo thời gian
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="h-[350px] w-full">
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart
                      data={realRevenueData}
                      margin={{ top: 10, right: 30, left: 0, bottom: 0 }}
                      onClick={(data: any) => {
                        if (
                          data &&
                          data.activePayload &&
                          data.activePayload.length > 0
                        ) {
                          const payload = data.activePayload[0].payload;
                          if (payload && payload.fullDate) {
                            setSelectedDrillDate(payload.fullDate);
                            // Scroll to orders section gently
                            const element =
                              document.getElementById("orders-section");
                            if (element) {
                              element.scrollIntoView({ behavior: "smooth" });
                            }
                          }
                        }
                      }}
                      className="cursor-pointer"
                    >
                      <defs>
                        <linearGradient
                          id="colorRevenue"
                          x1="0"
                          y1="0"
                          x2="0"
                          y2="1"
                        >
                          <stop
                            offset="5%"
                            stopColor="#10b981"
                            stopOpacity={0.8}
                          />
                          <stop
                            offset="95%"
                            stopColor="#10b981"
                            stopOpacity={0}
                          />
                        </linearGradient>
                        <linearGradient
                          id="colorProfit"
                          x1="0"
                          y1="0"
                          x2="0"
                          y2="1"
                        >
                          <stop
                            offset="5%"
                            stopColor="#f59e0b"
                            stopOpacity={0.8}
                          />
                          <stop
                            offset="95%"
                            stopColor="#f59e0b"
                            stopOpacity={0}
                          />
                        </linearGradient>
                      </defs>
                      <CartesianGrid
                        strokeDasharray="3 3"
                        vertical={false}
                        stroke="#e2e8f0"
                      />
                      <XAxis
                        dataKey="date"
                        stroke="#94a3b8"
                        fontSize={12}
                        tickLine={false}
                        axisLine={false}
                        dy={10}
                      />
                      <YAxis
                        stroke="#94a3b8"
                        fontSize={12}
                        tickLine={false}
                        axisLine={false}
                        tickFormatter={(value) => `${value / 1000}k`}
                        dx={-10}
                      />
                      <Tooltip
                        contentStyle={{
                          backgroundColor: "#fff",
                          borderRadius: "8px",
                          border: "none",
                          boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)",
                        }}
                        formatter={(value, name) => [
                          `${Number(value).toLocaleString()}đ`,
                          name === "revenue" ? "Doanh thu" : "Lợi nhuận",
                        ]}
                      />
                      <Area
                        type="monotone"
                        dataKey="revenue"
                        stroke="#10b981"
                        strokeWidth={3}
                        fill="url(#colorRevenue)"
                        activeDot={{ r: 6, strokeWidth: 0 }}
                        dot={{
                          r: 4,
                          fill: "#10b981",
                          strokeWidth: 2,
                          stroke: "#fff",
                        }}
                      />
                      <Area
                        type="monotone"
                        dataKey="profit"
                        stroke="#f59e0b"
                        strokeWidth={3}
                        fill="url(#colorProfit)"
                        activeDot={{ r: 6, strokeWidth: 0 }}
                        dot={{
                          r: 4,
                          fill: "#f59e0b",
                          strokeWidth: 2,
                          stroke: "#fff",
                        }}
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* RECENT ORDERS */}
            {/* RECENT ORDERS */}
            <Card className="lg:col-span-2 shadow-sm" id="orders-section">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle>
                    {selectedDrillDate
                      ? `Đơn hàng ngày ${format(new Date(selectedDrillDate), "dd/MM/yyyy")}`
                      : "Đơn hàng vừa phát sinh"}
                  </CardTitle>
                  <CardDescription>
                    {selectedDrillDate
                      ? `Danh sách đơn hàng cụ thể trong ngày`
                      : "5 giao dịch mới nhất trên hệ thống"}
                  </CardDescription>
                </div>
                {selectedDrillDate && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setSelectedDrillDate(null)}
                    className="text-red-500 hover:text-red-700 hover:bg-red-50"
                  >
                    Xóa lọc
                  </Button>
                )}
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b text-slate-500">
                        <th className="text-left font-medium py-3">Mã đơn</th>
                        <th className="text-left font-medium py-3">
                          Khách hàng
                        </th>
                        <th className="text-left font-medium py-3">
                          Tổng tiền
                        </th>
                        <th className="text-left font-medium py-3">
                          Trạng thái
                        </th>
                        <th className="text-left font-medium py-3">
                          Thời gian
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y">
                      {displayOrders && displayOrders.length > 0 ? (
                        displayOrders.map((order: any) => (
                          <tr key={order.id} className="hover:bg-slate-50">
                            <td className="py-3 font-medium text-slate-900">
                              {order.orderCode}
                            </td>
                            <td className="py-3 text-slate-600">
                              {order.customerName}
                            </td>
                            <td className="py-3 font-semibold text-slate-900">
                              {order.totalAmount?.toLocaleString()}đ
                            </td>
                            <td className="py-3">
                              <Badge
                                variant={
                                  order.status === "PAID"
                                    ? "default"
                                    : order.status === "UNPAID"
                                      ? "destructive"
                                      : "secondary"
                                }
                                className={
                                  order.status === "PAID"
                                    ? "bg-emerald-100 text-emerald-700 hover:bg-emerald-100 border-emerald-200"
                                    : order.status === "UNPAID"
                                      ? "bg-red-100 text-red-700 hover:bg-red-100 border-red-200"
                                      : "bg-slate-100 text-slate-700 hover:bg-slate-100 border-slate-200"
                                }
                              >
                                {order.status === "PAID"
                                  ? "Đã thanh toán"
                                  : order.status === "UNPAID"
                                    ? "Chưa thanh toán"
                                    : order.status}
                              </Badge>
                            </td>
                            <td className="py-3 text-slate-500 text-xs">
                              {format(new Date(order.createdAt), "HH:mm dd/MM")}
                            </td>
                          </tr>
                        ))
                      ) : (
                        <tr>
                          <td
                            colSpan={5}
                            className="text-center py-8 text-slate-400"
                          >
                            Chưa có đơn hàng nào
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </CardContent>
            </Card>

            {/* TOP CUSTOMERS */}
            <Card className="shadow-sm">
              <CardHeader>
                <CardTitle>Khách hàng VIP</CardTitle>
                <CardDescription>Top chi tiêu cao nhất</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {topCustomers && topCustomers.length > 0 ? (
                    topCustomers.map((customer: any, index: number) => (
                      <div
                        key={index}
                        className="flex items-center justify-between p-3 bg-slate-50 rounded-lg"
                      >
                        <div className="flex items-center gap-3">
                          <div
                            className={`
                            w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs
                            ${index === 0
                                ? "bg-yellow-100 text-yellow-700 ring-2 ring-yellow-200"
                                : index === 1
                                  ? "bg-slate-200 text-slate-700"
                                  : index === 2
                                    ? "bg-orange-100 text-orange-800"
                                    : "bg-slate-100 text-slate-600"
                              }
                          `}
                          >
                            {index + 1}
                          </div>
                          <div>
                            <p
                              className="font-medium text-sm text-slate-900 truncate w-[100px] sm:w-auto"
                              title={customer.name}
                            >
                              {customer.name}
                            </p>
                            <p className="text-xs text-slate-500">
                              {customer.orderCount} đơn hàng
                            </p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="font-bold text-sm text-indigo-600">
                            {customer.totalSpent?.toLocaleString()}đ
                          </p>
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="text-center text-slate-400 py-8">
                      Chưa có dữ liệu khách hàng
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* TAB 2: INVENTORY */}
        {/* TAB 2: INVENTORY */}
        <TabsContent value="inventory" className="space-y-6">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* LOW STOCK TABLE */}
            <Card className="shadow-sm border-red-100">
              <CardHeader>
                <CardTitle className="text-red-700 flex items-center gap-2">
                  <AlertTriangle className="h-5 w-5" />
                  Sản phẩm cần nhập thêm
                </CardTitle>
                <CardDescription>
                  Danh sách sản phẩm dưới định mức tồn kho
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b text-slate-500">
                        <th className="text-left font-medium py-2">Sản phẩm</th>
                        <th className="text-left font-medium py-2">Tồn kho</th>
                        <th className="text-left font-medium py-2">Giá nhập</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y">
                      {lowStockProducts && lowStockProducts.length > 0 ? (
                        lowStockProducts.map((p: any) => (
                          <tr key={p.id} className="hover:bg-red-50/50">
                            <td className="py-2 text-slate-900 font-medium">
                              {p.name}
                            </td>
                            <td className="py-2 text-red-600 font-bold">
                              {p.stockQuantity}
                            </td>
                            <td className="py-2 text-slate-600">
                              {p.costPrice?.toLocaleString()}đ
                            </td>
                          </tr>
                        ))
                      ) : (
                        <tr>
                          <td
                            colSpan={3}
                            className="text-center py-4 text-slate-400"
                          >
                            Tồn kho ổn định
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </CardContent>
            </Card>

            {/* TOP SELLING CHART */}
            <Card className="shadow-sm">
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
          </div>
        </TabsContent>

        {/* TAB 3: DEBT */}
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

      {/* DIALOG THANH TOÁN NỢ */}
      <Dialog open={isPayDebtDialogOpen} onOpenChange={setIsPayDebtDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Thanh toán nợ</DialogTitle>
            <DialogDescription>
              Cập nhật thanh toán cho khách hàng {selectedDebt?.customerName}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handlePayDebt} className="space-y-4">
            <div className="grid gap-2">
              <Label>Số tiền thanh toán</Label>
              <Input
                type="number"
                value={payDebtAmount}
                onChange={(e) => setPayDebtAmount(Number(e.target.value))}
                min={0}
                required
              />
            </div>
            <div className="grid gap-2">
              <Label>Phương thức</Label>
              <Select
                value={payDebtMethod}
                onValueChange={(val) => setPayDebtMethod(val)}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="CASH">Tiền mặt</SelectItem>
                  <SelectItem value="TRANSFER">Chuyển khoản</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="grid gap-2">
              <Label>Ghi chú</Label>
              <Input
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
              <Button type="submit">Xác nhận thanh toán</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div >
  );
}
