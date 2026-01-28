"use client";

import { useState, useEffect } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { orderService } from "@/services/orders.service";
import { dashboardService } from "@/services/dashboard.service";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Plus,
  Loader2,
  Search,
  MoreHorizontal,
  Filter,
  Eye,
  FileEdit,
  Trash2,
  Printer,
  DollarSign,
  Calendar,
  User,
  Package,
  Download,
  X,
  AlertCircle,
} from "lucide-react";
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  PieChart,
  Pie,
  Cell,
} from "recharts";
import { format } from "date-fns";
import { vi } from "date-fns/locale";
import { cn } from "@/lib/utils";
import type { Order, ApiResponse, PageResponse, Product } from "@/types/api";

export default function OrdersPage() {
  const queryClient = useQueryClient();
  const searchParams = useSearchParams();
  const router = useRouter();
  const viewId = searchParams.get("viewId");

  // --- STATE ---
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [dateFilter, setDateFilter] = useState("ALL");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false);
  const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
  const [currentOrder, setCurrentOrder] = useState<Order | null>(null);
  const [paymentAmount, setPaymentAmount] = useState(0);

  // State cho form tạo đơn hàng
  const [newOrder, setNewOrder] = useState({
    customerId: 1,
    items: [] as { productId: number; quantity: number; price: number; name: string }[],
    paymentType: "CASH",
    notes: "",
    status: "PENDING",    // Added to satisfy interface
    discountAmount: 0,    // Added to satisfy interface
  });
  const [selectedProduct, setSelectedProduct] = useState<string>("");
  const [quantity, setQuantity] = useState(1);

  // --- DATA FETCHING ---
  const { data, isLoading, isError, refetch } = useQuery<
    ApiResponse<PageResponse<Order>>
  >({
    queryKey: ["orders-list", statusFilter, dateFilter],
    queryFn: async () => {
      const params: any = { size: 50 };
      if (statusFilter !== "ALL") params.status = statusFilter;
      if (dateFilter === "TODAY")
        params.startDate = format(new Date(), "yyyy-MM-dd");

      const res = await orderService.getAllOrders(params);
      return res as unknown as ApiResponse<PageResponse<Order>>;
    },
    retry: 1,
  });

  // Lấy danh sách sản phẩm để chọn khi tạo đơn
  const { data: productsData } = useQuery({
    queryKey: ["products-list-simple"],
    queryFn: dashboardService.getProducts,
  });

  const products = (productsData as any)?.result?.content || [];

  // --- MUTATIONS ---
  const createMutation = useMutation({
    mutationFn: orderService.createOrder,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
      setIsDialogOpen(false);
      setNewOrder({
        customerId: 1,
        items: [],
        paymentType: "CASH",
        notes: "",
        status: "PENDING",
        discountAmount: 0,
      });
      alert("Tạo đơn hàng thành công!");
    },
    onError: (error) => {
      console.error(error);
      alert("Có lỗi xảy ra khi tạo đơn hàng.");
    },
  });

  // --- AUTO OPEN DETAIL ---
  useEffect(() => {
    if (viewId) {
      const fetchAndOpen = async () => {
        try {
          const res = await orderService.getOrderById(Number(viewId));
          if (res?.result) {
            // Need to cast to match existing state type if there are mismatches, 
            // but assuming close enough or strictly mapped
            setCurrentOrder(res.result as unknown as Order);
            setIsViewDialogOpen(true);

            // Clean URL
            router.replace("/dashboard/orders");
          }
        } catch (e) {
          console.error("Failed to load order detail", e);
        }
      };
      fetchAndOpen();
    }
  }, [viewId, router]);

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) =>
      orderService.updateOrderStatus(id, status as any), // Cast to any or OrderStatus
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
      alert("Cập nhật trạng thái thành công!");
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => orderService.deleteOrder(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
      alert("Xóa đơn hàng thành công!");
    },
  });

  const paymentMutation = useMutation({
    mutationFn: ({ id, amount }: { id: number; amount: number }) =>
      orderService.makePayment(id, {
        amount,
        paymentMethod: "CASH",
        transactionId: `TRX-${Date.now()}`,
        note: "Thanh toán từ web admin",
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
      setIsPaymentDialogOpen(false);
      setPaymentAmount(0);
      alert("Thanh toán thành công!");
    },
  });

  // --- ACTIONS ---
  const handleViewOrder = (order: Order) => {
    setCurrentOrder(order);
    setIsViewDialogOpen(true);
  };

  const handleDelete = (id: number) => {
    if (confirm("Bạn có chắc muốn xóa đơn hàng này?")) {
      deleteMutation.mutate(id);
    }
  };

  const handlePayment = (order: Order) => {
    setCurrentOrder(order);
    setPaymentAmount(order.remainingAmount);
    setIsPaymentDialogOpen(true);
  };

  const handleAddNew = () => {
    setCurrentOrder(null);
    setIsDialogOpen(true);
  };

  const handleAddItem = () => {
    if (!selectedProduct) return;
    const product = products.find((p: any) => p.id.toString() === selectedProduct);
    if (!product) return;

    const existingItem = newOrder.items.find((item) => item.productId === product.id);
    if (existingItem) {
      setNewOrder({
        ...newOrder,
        items: newOrder.items.map((item) =>
          item.productId === product.id
            ? { ...item, quantity: item.quantity + quantity }
            : item
        ),
      });
    } else {
      setNewOrder({
        ...newOrder,
        items: [
          ...newOrder.items,
          {
            productId: product.id,
            quantity: quantity,
            price: product.price,
            name: product.name,
          },
        ],
      });
    }
    setSelectedProduct("");
    setQuantity(1);
  };

  const handleRemoveItem = (productId: number) => {
    setNewOrder({
      ...newOrder,
      items: newOrder.items.filter((item) => item.productId !== productId),
    });
  };

  const handleSaveOrder = (e: React.FormEvent) => {
    e.preventDefault();
    if (newOrder.items.length === 0) {
      alert("Vui lòng chọn ít nhất một sản phẩm!");
      return;
    }

    // Convert state to API request format
    const payload: any = {
      ...newOrder,
      items: newOrder.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: item.price
      })),
      status: newOrder.status as any,
      paymentType: newOrder.paymentType as any
    };

    createMutation.mutate(payload);
  };

  const handleProcessPayment = () => {
    if (!currentOrder || paymentAmount <= 0) {
      alert("Vui lòng nhập số tiền hợp lệ!");
      return;
    }
    paymentMutation.mutate({
      id: currentOrder.id,
      amount: paymentAmount,
    });
  };

  // --- FILTER LOGIC ---
  const orders = data?.result?.content || [];
  const filteredOrders = orders.filter((order) => {
    const searchLower = searchTerm.toLowerCase();
    const matchesSearch =
      order.orderCode.toLowerCase().includes(searchLower) ||
      order.customerName?.toLowerCase().includes(searchLower) ||
      order.customerPhone?.includes(searchTerm);

    const matchesStatus =
      statusFilter === "ALL" || order.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  // Lấy dữ liệu thống kê từ cache (Backend Cached)
  const { data: summaryData } = useQuery({
    queryKey: ["dashboard-summary"],
    queryFn: dashboardService.getDashboardSummary,
    refetchInterval: 60000,
  });

  const { data: revenueData } = useQuery({
    queryKey: ["dashboard-revenue", "7d"],
    queryFn: () => dashboardService.getRevenueChart("7d"),
    refetchInterval: 120000,
  });

  const { data: statusData } = useQuery({
    queryKey: ["dashboard-status"],
    queryFn: dashboardService.getStatusChart,
    refetchInterval: 120000,
  });

  // Fetch Daily Count để kích hoạt Caching (Backend Key: dashboard_daily_count_chart)
  useQuery({
    queryKey: ["dashboard-daily-count", "30d"],
    queryFn: () => dashboardService.getDailyCountChart("30d"),
    refetchInterval: 120000,
  });

  const summary = (summaryData as any)?.result || {};
  const revenueList = (revenueData as any)?.result || [];
  const rawStatusList = (statusData as any)?.result || [];

  const statusList = rawStatusList.map((item: any) => ({
    ...item,
    status: STATUS_LABELS[item.status] || item.status,
  }));

  // --- STATS ---
  const stats = {
    totalOrders: summary.totalOrders || 0,
    totalRevenue: summary.totalRevenue || 0,
    pendingPayment: summary.pendingPayment || 0, // Đã tính đúng từ backend
    completedOrders: summary.completedOrders || 0,
  };

  return (
    <div className="p-8 space-y-8 bg-slate-50/50 min-h-screen">
      {/* HEADER */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">
            Quản lý Đơn hàng
          </h1>
          <p className="text-slate-500 mt-1">
            Theo dõi và xử lý tất cả đơn hàng của cửa hàng.
          </p>
        </div>
        <div className="flex gap-3">
          <Button
            variant="outline"
            className="bg-white"
            onClick={() => alert("Xuất Excel - Tính năng đang phát triển")}
          >
            <Download className="mr-2 h-4 w-4" /> Xuất Excel
          </Button>
          <Button
            onClick={handleAddNew}
            className="bg-green-600 hover:bg-green-700 shadow-lg shadow-green-200"
          >
            <Plus className="mr-2 h-4 w-4" /> Tạo đơn mới
          </Button>
        </div>
      </div>

      {/* STATS CARDS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Tổng đơn hàng</p>
                <p className="text-2xl font-bold text-slate-900">
                  {stats.totalOrders}
                </p>
              </div>
              <div className="p-2 bg-blue-50 rounded-lg">
                <Package className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Tổng doanh thu</p>
                <p className="text-2xl font-bold text-emerald-600">
                  {stats.totalRevenue.toLocaleString()}đ
                </p>
              </div>
              <div className="p-2 bg-emerald-50 rounded-lg">
                <DollarSign className="h-6 w-6 text-emerald-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Chờ thanh toán</p>
                <p className="text-2xl font-bold text-amber-600">
                  {stats.pendingPayment.toLocaleString()}đ
                </p>
              </div>
              <div className="p-2 bg-amber-50 rounded-lg">
                <Calendar className="h-6 w-6 text-amber-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Đơn hoàn thành</p>
                <p className="text-2xl font-bold text-slate-900">
                  {stats.completedOrders}
                </p>
              </div>
              <div className="p-2 bg-green-50 rounded-lg">
                <Eye className="h-6 w-6 text-green-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* CHARTS SECTION */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Revenue Chart */}
        <Card className="lg:col-span-2 border-none shadow-sm bg-white">
          <CardContent className="p-6">
            <h3 className="text-lg font-bold mb-4 text-slate-800">
              Doanh thu 7 ngày qua
            </h3>
            <div className="h-[300px] w-full">
              <ResponsiveBarChart data={revenueList} />
            </div>
          </CardContent>
        </Card>

        {/* Status Chart */}
        <Card className="border-none shadow-sm bg-white">
          <CardContent className="p-6">
            <h3 className="text-lg font-bold mb-4 text-slate-800">
              Trạng thái đơn hàng
            </h3>
            <div className="h-[300px] w-full flex items-center justify-center">
              <ResponsivePieChart data={statusList} />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* TOOLBAR */}
      <div className="flex flex-col sm:flex-row gap-4 items-center justify-between bg-white p-4 rounded-xl border shadow-sm">
        <div className="relative w-full sm:w-96">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Tìm theo mã đơn, tên khách, SĐT..."
            className="pl-9 bg-slate-50 border-slate-200 focus-visible:ring-indigo-500"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="flex items-center gap-3 w-full sm:w-auto">
          <Select value={dateFilter} onValueChange={setDateFilter}>
            <SelectTrigger className="w-[140px]">
              <SelectValue placeholder="Thời gian" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">Tất cả thời gian</SelectItem>
              <SelectItem value="TODAY">Hôm nay</SelectItem>
              <SelectItem value="WEEK">Tuần này</SelectItem>
              <SelectItem value="MONTH">Tháng này</SelectItem>
            </SelectContent>
          </Select>

          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-[160px]">
              <SelectValue placeholder="Trạng thái" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">Tất cả trạng thái</SelectItem>
              <SelectItem value="PENDING">Chờ xác nhận</SelectItem>
              <SelectItem value="CONFIRMED">Đã xác nhận</SelectItem>
              <SelectItem value="PROCESSING">Đang xử lý</SelectItem>
              <SelectItem value="COMPLETED">Hoàn thành</SelectItem>
              <SelectItem value="CANCELLED">Đã hủy</SelectItem>
              <SelectItem value="UNPAID">Chưa thanh toán</SelectItem>
              <SelectItem value="PAID_PARTIAL">Thanh toán 1 phần</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* TABLE */}
      <Card className="border shadow-sm overflow-hidden bg-white">
        <CardContent className="p-0">
          <Table>
            <TableHeader className="bg-slate-50/80">
              <TableRow className="hover:bg-slate-50/80">
                <TableHead>Mã đơn</TableHead>
                <TableHead>Khách hàng</TableHead>
                <TableHead>Tổng tiền</TableHead>
                <TableHead>Đã thanh toán</TableHead>
                <TableHead>Trạng thái</TableHead>
                <TableHead>Ngày tạo</TableHead>
                <TableHead className="text-right">Thao tác</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center">
                    <div className="flex flex-col items-center justify-center text-slate-500">
                      <Loader2 className="h-8 w-8 mb-2 animate-spin text-indigo-600" />
                      <p>Đang tải dữ liệu...</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : isError ? (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center">
                    <div className="flex flex-col items-center justify-center text-red-500">
                      <AlertCircle className="h-8 w-8 mb-2" />
                      <p>Không thể kết nối đến server.</p>
                      <Button
                        variant="link"
                        onClick={() => refetch()}
                        className="mt-2"
                      >
                        Thử lại
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ) : filteredOrders.length > 0 ? (
                filteredOrders.map((order) => (
                  <TableRow key={order.id} className="hover:bg-slate-50/50">
                    <TableCell className="font-mono font-bold text-slate-900">
                      {order.orderCode}
                    </TableCell>
                    <TableCell>
                      <div>
                        <div className="font-medium">
                          {order.customerName || "Khách lẻ"}
                        </div>
                        {order.customerPhone && (
                          <div className="text-sm text-slate-500">
                            {order.customerPhone}
                          </div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell className="font-bold text-slate-900">
                      {order.totalAmount.toLocaleString()}đ
                    </TableCell>
                    <TableCell>
                      <div className="space-y-1">
                        <div className="text-emerald-600 font-medium">
                          {order.paidAmount.toLocaleString()}đ
                        </div>
                        {order.remainingAmount > 0 && (
                          <div className="text-xs text-amber-600">
                            Còn: {order.remainingAmount.toLocaleString()}đ
                          </div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <OrderStatusBadge status={order.status} />
                    </TableCell>
                    <TableCell className="text-slate-500 text-sm">
                      {format(new Date(order.createdAt), "dd/MM/yyyy HH:mm", {
                        locale: vi,
                      })}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleViewOrder(order)}
                          className="h-8 px-2"
                        >
                          <Eye className="h-4 w-4 text-blue-500" />
                        </Button>
                        {order.remainingAmount > 0 && (
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handlePayment(order)}
                            className="h-8 px-2 text-green-600 hover:text-green-700"
                          >
                            <DollarSign className="h-4 w-4" />
                          </Button>
                        )}
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuLabel>Hành động</DropdownMenuLabel>
                            <DropdownMenuItem
                              onClick={() => handleViewOrder(order)}
                            >
                              <Eye className="mr-2 h-4 w-4" /> Xem chi tiết
                            </DropdownMenuItem>
                            <DropdownMenuItem>
                              <Printer className="mr-2 h-4 w-4" /> In hóa đơn
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                              className="text-amber-600"
                              onClick={() =>
                                updateStatusMutation.mutate({
                                  id: order.id,
                                  status: "COMPLETED",
                                })
                              }
                            >
                              <FileEdit className="mr-2 h-4 w-4" /> Đánh dấu
                              hoàn thành
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              className="text-red-600"
                              onClick={() => handleDelete(order.id)}
                            >
                              <Trash2 className="mr-2 h-4 w-4" /> Xóa đơn
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center">
                    <div className="flex flex-col items-center justify-center text-slate-500">
                      <Package className="h-8 w-8 mb-2 opacity-20" />
                      <p>Không tìm thấy đơn hàng nào.</p>
                    </div>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* CREATE ORDER DIALOG */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-[800px]">
          <DialogHeader>
            <DialogTitle>Tạo đơn hàng mới</DialogTitle>
            <DialogDescription>
              Chọn sản phẩm và nhập thông tin đơn hàng.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSaveOrder} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Khách hàng</Label>
                <Select
                  value={newOrder.customerId.toString()}
                  onValueChange={(val) =>
                    setNewOrder({ ...newOrder, customerId: Number(val) })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn khách hàng" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="1">Khách lẻ</SelectItem>
                    {/* Thêm danh sách khách hàng từ API nếu cần */}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Hình thức thanh toán</Label>
                <Select
                  value={newOrder.paymentType}
                  onValueChange={(val) =>
                    setNewOrder({ ...newOrder, paymentType: val })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn hình thức" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="CASH">Tiền mặt</SelectItem>
                    <SelectItem value="CREDIT">Ghi nợ</SelectItem>
                    <SelectItem value="TRANSFER">Chuyển khoản</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="border p-4 rounded-lg bg-slate-50 space-y-4">
              <div className="flex gap-2 items-end">
                <div className="flex-1 space-y-2">
                  <Label>Sản phẩm</Label>
                  <Select
                    value={selectedProduct}
                    onValueChange={setSelectedProduct}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Chọn sản phẩm" />
                    </SelectTrigger>
                    <SelectContent>
                      {products.map((p: any) => (
                        <SelectItem key={p.id} value={p.id.toString()}>
                          {p.name} - {p.price.toLocaleString()}đ (Tồn: {p.stock}
                          )
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="w-24 space-y-2">
                  <Label>Số lượng</Label>
                  <Input
                    type="number"
                    min="1"
                    value={quantity}
                    onChange={(e) => setQuantity(Number(e.target.value))}
                  />
                </div>
                <Button type="button" onClick={handleAddItem}>
                  Thêm
                </Button>
              </div>

              {/* Order Items List */}
              <div className="bg-white border rounded-md overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Sản phẩm</TableHead>
                      <TableHead className="text-right">Đơn giá</TableHead>
                      <TableHead className="text-right">SL</TableHead>
                      <TableHead className="text-right">Thành tiền</TableHead>
                      <TableHead className="w-[50px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {newOrder.items.length > 0 ? (
                      newOrder.items.map((item, idx) => (
                        <TableRow key={idx}>
                          <TableCell>{item.name}</TableCell>
                          <TableCell className="text-right">
                            {item.price.toLocaleString()}đ
                          </TableCell>
                          <TableCell className="text-right">
                            {item.quantity}
                          </TableCell>
                          <TableCell className="text-right font-bold">
                            {(item.price * item.quantity).toLocaleString()}đ
                          </TableCell>
                          <TableCell>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleRemoveItem(item.productId)}
                              className="text-red-500 hover:text-red-700"
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))
                    ) : (
                      <TableRow>
                        <TableCell
                          colSpan={5}
                          className="text-center text-slate-500 py-4"
                        >
                          Chưa có sản phẩm nào
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </div>

              <div className="flex justify-between items-center pt-2">
                <span className="font-bold text-lg">Tổng cộng:</span>
                <span className="font-bold text-xl text-indigo-600">
                  {newOrder.items
                    .reduce((sum, item) => sum + item.price * item.quantity, 0)
                    .toLocaleString()}
                  đ
                </span>
              </div>
            </div>

            <div className="space-y-2">
              <Label>Ghi chú</Label>
              <Input
                value={newOrder.notes}
                onChange={(e) =>
                  setNewOrder({ ...newOrder, notes: e.target.value })
                }
                placeholder="Ghi chú đơn hàng..."
              />
            </div>

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsDialogOpen(false)}
              >
                Hủy
              </Button>
              <Button
                type="submit"
                className="bg-indigo-600 hover:bg-indigo-700"
                disabled={createMutation.isPending}
              >
                {createMutation.isPending ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang xử lý
                  </>
                ) : (
                  "Tạo đơn hàng"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* VIEW ORDER DIALOG */}
      <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
        <DialogContent className="sm:max-w-[700px]">
          <DialogHeader>
            <DialogTitle>Chi tiết đơn hàng</DialogTitle>
            <DialogDescription>
              Thông tin chi tiết đơn hàng #{currentOrder?.orderCode}
            </DialogDescription>
          </DialogHeader>
          {currentOrder && (
            <div className="space-y-6">
              {/* Order Info */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label className="text-slate-500">Mã đơn hàng</Label>
                  <p className="font-bold">{currentOrder.orderCode}</p>
                </div>
                <div>
                  <Label className="text-slate-500">Trạng thái</Label>
                  <div className="mt-1">
                    <OrderStatusBadge status={currentOrder.status} />
                  </div>
                </div>
                <div>
                  <Label className="text-slate-500">Khách hàng</Label>
                  <p className="font-medium">
                    {currentOrder.customerName || "Khách lẻ"}
                  </p>
                  {currentOrder.customerPhone && (
                    <p className="text-sm text-slate-500">
                      {currentOrder.customerPhone}
                    </p>
                  )}
                </div>
                <div>
                  <Label className="text-slate-500">Ngày tạo</Label>
                  <p>
                    {format(
                      new Date(currentOrder.createdAt),
                      "dd/MM/yyyy HH:mm",
                      {
                        locale: vi,
                      }
                    )}
                  </p>
                </div>
              </div>

              {/* Order Items */}
              <div>
                <Label className="text-slate-500 mb-2 block">Sản phẩm</Label>
                <div className="border rounded-lg">
                  <div className="grid grid-cols-12 gap-2 p-3 bg-slate-50 border-b font-medium text-sm">
                    <div className="col-span-6">Sản phẩm</div>
                    <div className="col-span-2 text-right">Đơn giá</div>
                    <div className="col-span-2 text-right">Số lượng</div>
                    <div className="col-span-2 text-right">Thành tiền</div>
                  </div>
                  {(currentOrder.items || []).map((item, index) => (
                    <div
                      key={index}
                      className="grid grid-cols-12 gap-2 p-3 border-b last:border-0"
                    >
                      <div className="col-span-6">{item.productName}</div>
                      <div className="col-span-2 text-right">
                        {item.unitPrice.toLocaleString()}đ
                      </div>
                      <div className="col-span-2 text-right">
                        {item.quantity}
                      </div>
                      <div className="col-span-2 text-right font-medium">
                        {item.totalPrice.toLocaleString()}đ
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Summary */}
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-600">Tổng tiền hàng:</span>
                  <span className="font-bold">
                    {currentOrder.totalAmount.toLocaleString()}đ
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-600">Đã thanh toán:</span>
                  <span className="text-emerald-600 font-bold">
                    {currentOrder.paidAmount.toLocaleString()}đ
                  </span>
                </div>
                {currentOrder.remainingAmount > 0 && (
                  <div className="flex justify-between">
                    <span className="text-slate-600">Còn lại:</span>
                    <span className="text-amber-600 font-bold">
                      {currentOrder.remainingAmount.toLocaleString()}đ
                    </span>
                  </div>
                )}
                <div className="pt-2 border-t">
                  <div className="flex justify-between text-lg font-bold">
                    <span>Tổng cộng:</span>
                    <span>{currentOrder.totalAmount.toLocaleString()}đ</span>
                  </div>
                </div>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsViewDialogOpen(false)}
            >
              Đóng
            </Button>
            <Button className="bg-blue-600 hover:bg-blue-700">
              <Printer className="mr-2 h-4 w-4" /> In hóa đơn
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* PAYMENT DIALOG */}
      <Dialog open={isPaymentDialogOpen} onOpenChange={setIsPaymentDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Thanh toán đơn hàng</DialogTitle>
            <DialogDescription>
              Nhập số tiền thanh toán cho đơn #{currentOrder?.orderCode}
            </DialogDescription>
          </DialogHeader>
          {currentOrder && (
            <div className="space-y-4">
              <div className="bg-slate-50 p-4 rounded-lg">
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span className="text-slate-600">Tổng tiền:</span>
                    <span className="font-bold">
                      {currentOrder.totalAmount.toLocaleString()}đ
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-600">Đã thanh toán:</span>
                    <span className="text-emerald-600">
                      {currentOrder.paidAmount.toLocaleString()}đ
                    </span>
                  </div>
                  <div className="flex justify-between text-lg font-bold pt-2 border-t">
                    <span>Còn lại:</span>
                    <span className="text-amber-600">
                      {currentOrder.remainingAmount.toLocaleString()}đ
                    </span>
                  </div>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="amount">Số tiền thanh toán (VNĐ)</Label>
                <Input
                  id="amount"
                  type="number"
                  value={paymentAmount}
                  onChange={(e) => setPaymentAmount(Number(e.target.value))}
                  placeholder="Nhập số tiền"
                  className="text-lg font-bold"
                />
                <div className="flex gap-2">
                  {[currentOrder.remainingAmount, 1000000, 500000].map(
                    (amount) => (
                      <Button
                        key={amount}
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => setPaymentAmount(amount)}
                      >
                        {amount.toLocaleString()}đ
                      </Button>
                    )
                  )}
                </div>
              </div>

              <div className="space-y-2">
                <Label>Phương thức thanh toán</Label>
                <Select defaultValue="CASH">
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn phương thức" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="CASH">Tiền mặt</SelectItem>
                    <SelectItem value="BANK_TRANSFER">Chuyển khoản</SelectItem>
                    <SelectItem value="MOMO">Ví MoMo</SelectItem>
                    <SelectItem value="VNPAY">VNPAY</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsPaymentDialogOpen(false)}
            >
              Hủy
            </Button>
            <Button
              onClick={handleProcessPayment}
              className="bg-green-600 hover:bg-green-700"
              disabled={paymentMutation.isPending}
            >
              {paymentMutation.isPending ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang xử lý
                </>
              ) : (
                <>
                  <DollarSign className="mr-2 h-4 w-4" /> Xác nhận thanh toán
                </>
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

const STATUS_LABELS: Record<string, string> = {
  PENDING: "Chờ xác nhận",
  CONFIRMED: "Đã xác nhận",
  PROCESSING: "Đang xử lý",
  COMPLETED: "Hoàn thành",
  CANCELLED: "Đã hủy",
  UNPAID: "Chưa thanh toán",
  PAID_PARTIAL: "Thanh toán 1 phần",
  PAID: "Đã thanh toán",
};

const COLORS = ["#0088FE", "#00C49F", "#FFBB28", "#FF8042", "#8884d8"];

const ResponsiveBarChart = ({ data }: { data: any[] }) => {
  if (!data || data.length === 0)
    return <div className="flex h-full items-center justify-center text-slate-400">Chưa có dữ liệu</div>;

  return (
    <ResponsiveContainer width="100%" height="100%">
      <BarChart data={data}>
        <XAxis
          dataKey="date"
          fontSize={12}
          tickLine={false}
          axisLine={false}
          tickFormatter={(value) => format(new Date(value), "dd/MM")}
        />
        <YAxis
          fontSize={12}
          tickLine={false}
          axisLine={false}
          tickFormatter={(value) => `${value / 1000}k`}
        />
        <Tooltip
          formatter={(value: any) => [`${value.toLocaleString()}đ`, "Doanh thu"]}
          labelFormatter={(label) => format(new Date(label), "dd/MM/yyyy")}
        />
        <Bar dataKey="revenue" fill="#4f46e5" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
};

const ResponsivePieChart = ({ data }: { data: any[] }) => {
  if (!data || data.length === 0)
    return <div className="flex h-full items-center justify-center text-slate-400">Chưa có dữ liệu</div>;

  return (
    <ResponsiveContainer width="100%" height="100%">
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          innerRadius={60}
          outerRadius={80}
          fill="#8884d8"
          paddingAngle={5}
          dataKey="count"
          nameKey="status"
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip />
        <Legend verticalAlign="bottom" height={36} />
      </PieChart>
    </ResponsiveContainer>
  );
};

function OrderStatusBadge({ status }: { status: string }) {
  const getStatusConfig = (status: string) => {
    switch (status) {
      case "PENDING":
        return {
          label: "Chờ xác nhận",
          className: "bg-amber-100 text-amber-700 border-amber-200",
        };
      case "CONFIRMED":
        return {
          label: "Đã xác nhận",
          className: "bg-blue-100 text-blue-700 border-blue-200",
        };
      case "PROCESSING":
        return {
          label: "Đang xử lý",
          className: "bg-indigo-100 text-indigo-700 border-indigo-200",
        };
      case "COMPLETED":
        return {
          label: "Hoàn thành",
          className: "bg-emerald-100 text-emerald-700 border-emerald-200",
        };
      case "CANCELLED":
        return {
          label: "Đã hủy",
          className: "bg-red-100 text-red-700 border-red-200",
        };
      case "UNPAID":
        return {
          label: "Chưa thanh toán",
          className: "bg-red-100 text-red-700 border-red-200",
        };
      case "PAID_PARTIAL":
        return {
          label: "Thanh toán 1 phần",
          className: "bg-amber-100 text-amber-700 border-amber-200",
        };
      case "PAID":
        return {
          label: "Đã thanh toán",
          className: "bg-emerald-100 text-emerald-700 border-emerald-200",
        };
      default:
        return {
          label: status,
          className: "bg-slate-100 text-slate-700 border-slate-200",
        };
    }
  };

  const config = getStatusConfig(status);
  return (
    <Badge className={cn("px-2 py-1 text-xs font-medium", config.className)}>
      {config.label}
    </Badge>
  );
}
