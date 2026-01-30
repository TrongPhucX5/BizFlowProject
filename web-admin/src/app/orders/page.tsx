"use client";

import { useState, useEffect, useMemo } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  orderService,
  type OrderDTO,
  type CreateOrderRequest,
  type PaymentType,
  type OrderStatus,
} from "@/services/order.service";
import { reportsService } from "@/services/reports.service";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetFooter,
} from "@/components/ui/sheet";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { customersService } from "@/services/customers.service";
import { dashboardService } from "@/services/dashboard.service";

import {
  Plus,
  FileText,
  Loader2,
  Clock,
  Trash2,
  ShoppingBag,
  Edit3,
  ChevronLeft,
  ChevronRight,
  Search,
  Filter,
  TrendingUp,
  Package,
  AlertCircle,
  WifiOff,
  Eye,
} from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";

// --- Custom Hook useDebounce ---
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(handler);
  }, [value, delay]);
  return debouncedValue;
}

export default function OrderPage() {
  const queryClient = useQueryClient();
  const [mounted, setMounted] = useState(false);
  
  // --- TT88 EXPORT STATES ---
  const [exportFrom, setExportFrom] = useState("");
  const [exportTo, setExportTo] = useState("");
  const [exporting, setExporting] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  // --- UI STATES ---
  const [page, setPage] = useState(0);
  const [isSheetOpen, setIsSheetOpen] = useState(false);
  const [viewingOrder, setViewingOrder] = useState<OrderDTO | null>(null);
  const [editingOrderId, setEditingOrderId] = useState<number | null>(null);
  const [orderToDelete, setOrderToDelete] = useState<number | null>(null);

  // --- FILTER STATES ---
  const [filterStatus, setFilterStatus] = useState<string>("ALL");
  const [filterCustomerId, setFilterCustomerId] = useState<string>("");
  const debouncedCustomerId = useDebounce(filterCustomerId, 500);

  // --- FORM STATES ---
  const [customerId, setCustomerId] = useState<string>("");
  const [discountAmount, setDiscountAmount] = useState<string>("0");
  const [paymentType, setPaymentType] = useState<PaymentType>("CASH");
  const [orderStatus, setOrderStatus] = useState<OrderStatus>("PAID");
  const [notes, setNotes] = useState<string>("");
  const [items, setItems] = useState<
    { productId: number; quantity: number; unitPrice: number; stock?: number }[]
  >([{ productId: 0, quantity: 1, unitPrice: 0, stock: 0 }]);

  // --- 1. DATA FETCHING ---

  const { data: productsRes } = useQuery({
    queryKey: ["products-for-order"],
    queryFn: () => dashboardService.getProducts(),
    enabled: mounted,
  });

  const products = (productsRes as any)?.result?.content || [];

  const { data: customersRes } = useQuery({
    queryKey: ["customers-for-order"],
    queryFn: () => customersService.getCustomers({ size: 100 }),
    enabled: mounted,
  });

  const customers = (customersRes as any)?.result?.content || [];

  const {
    data: ordersRes,
    isLoading,
    isError,
  } = useQuery({
    queryKey: ["orders-list", page, debouncedCustomerId, filterStatus],
    queryFn: async () => {
      const response = await orderService.getAllOrders({
        page,
        size: 10,
        sort: "createdAt,desc",
        status: filterStatus === "ALL" ? undefined : filterStatus,
        customerId: debouncedCustomerId
          ? Number(debouncedCustomerId)
          : undefined,
      });
      return response;
    },
    enabled: mounted,
    retry: 1,
  });

  // --- 2. ANALYTICS ---
  const analytics = useMemo(() => {
    const content = ordersRes?.result?.content || [];
    const totalElements = ordersRes?.result?.totalElements ?? content.length;
    const paidRevenue = content
      .filter((o: OrderDTO) => o.status === "PAID" || o.status === "CONFIRMED")
      .reduce((sum: number, o: OrderDTO) => sum + (o.totalAmount || 0), 0);
    const processingCount = content.filter(
      (o: OrderDTO) => o.status === "UNPAID",
    ).length;

    return {
      paidRevenue,
      totalOrders: totalElements,
      processing: processingCount,
    };
  }, [ordersRes]);

  // --- 3. MUTATIONS ---
  const createMutation = useMutation({
    mutationFn: (data: CreateOrderRequest) => orderService.createOrder(data),
    onSuccess: () => {
      toast.success("Tạo đơn hàng thành công!");
      handleCloseSheet();
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
      queryClient.invalidateQueries({ queryKey: ["products-for-order"] });
    },
    onError: (error: any) =>
      toast.error(error.response?.data?.message || "Lỗi khi tạo đơn hàng"),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: CreateOrderRequest }) =>
      orderService.updateOrder(id, data),
    onSuccess: () => {
      toast.success("Cập nhật đơn hàng thành công!");
      handleCloseSheet();
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
      queryClient.invalidateQueries({ queryKey: ["products-for-order"] });
    },
    onError: (error: any) =>
      toast.error(error.response?.data?.message || "Lỗi khi cập nhật"),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => orderService.deleteOrder(id),
    onSuccess: () => {
      toast.success("Đã hủy đơn thành công");
      setOrderToDelete(null);
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
      queryClient.invalidateQueries({ queryKey: ["products-for-order"] });
    },
  });

  // --- HANDLERS ---
  const handleOpenCreate = () => {
    setEditingOrderId(null);
    resetForm();
    setIsSheetOpen(true);
  };

  const handleEdit = (order: OrderDTO) => {
    setEditingOrderId(order.id);
    setCustomerId(order.customerId.toString());
    setDiscountAmount(order.discountAmount?.toString() || "0");
    setPaymentType(order.paymentType);
    setOrderStatus(order.status);
    setNotes(order.notes || "");
    setItems(
      order.items.map((i) => ({
        productId: i.productId,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
      })),
    );
    setIsSheetOpen(true);
  };

  const handleCloseSheet = () => {
    setIsSheetOpen(false);
    setTimeout(() => {
      setEditingOrderId(null);
      resetForm();
    }, 300);
  };

  const resetForm = () => {
    setCustomerId("");
    setItems([{ productId: 0, quantity: 1, unitPrice: 0 }]);
    setDiscountAmount("0");
    setPaymentType("CASH");
    setOrderStatus("PAID");
    setNotes("");
  };

  const handleExportTT88Revenue = async () => {
    if (!exportFrom || !exportTo) {
      toast.error("Vui lòng chọn khoảng thời gian xuất sổ!");
      return;
    }

    try {
      setExporting(true);

      // Sử dụng reportsService để đảm bảo auth headers và base URL
      const blob = await reportsService.exportTT88Revenue(exportFrom, exportTo);
      
      const url = window.URL.createObjectURL(new Blob([blob]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `so-doanh-thu-TT88-${exportFrom}-${exportTo}.xlsx`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      
      toast.success("Đã xuất sổ doanh thu TT88!");
    } catch (error) {
      console.error(error);
      toast.error("Xuất sổ thất bại!");
    } finally {
      setExporting(false);
    }
  };

  const calculateSubtotal = () =>
    items.reduce((sum, i) => sum + i.unitPrice * i.quantity, 0);
  const totalAmount = calculateSubtotal() - Number(discountAmount);

  if (!mounted)
    return (
      <div className="flex items-center justify-center h-screen bg-slate-50">
        <Loader2 className="animate-spin h-12 w-12 text-indigo-600" />
      </div>
    );

  return (
    <div className="p-8 space-y-8 bg-[#f8fafc] min-h-screen font-sans">
      {/* HEADER */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-4 bg-indigo-600 rounded-3xl shadow-xl shadow-indigo-100 rotate-3">
            <FileText className="h-8 w-8 text-white -rotate-3" />
          </div>
          <div>
            <h1 className="text-4xl font-black text-slate-900 uppercase italic tracking-tighter">
              Hệ thống Đơn hàng
            </h1>
            <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mt-1 flex items-center gap-2">
              <Package className="h-3 w-3" /> Quản lý giao dịch nội bộ
            </p>
          </div>
        </div>
        
        {/* ACTION BUTTONS */}
        <div className="flex flex-wrap items-center gap-3">
          {/* FROM */}
          <Input
            type="date"
            value={exportFrom}
            onChange={(e) => setExportFrom(e.target.value)}
            className="h-12 rounded-xl font-bold w-auto"
          />

          {/* TO */}
          <Input
            type="date"
            value={exportTo}
            onChange={(e) => setExportTo(e.target.value)}
            className="h-12 rounded-xl font-bold w-auto"
          />

          {/* EXPORT TT88 */}
          <Button
            onClick={handleExportTT88Revenue}
            disabled={exporting}
            className="bg-emerald-600 hover:bg-emerald-700 h-12 px-6 rounded-xl font-black uppercase shadow-xl"
          >
            {exporting ? (
              <Loader2 className="animate-spin mr-2" />
            ) : (
              <FileText className="mr-2 h-5 w-5" />
            )}
            Xuất TT88
          </Button>

          {/* CREATE ORDER */}
          <Button
            onClick={handleOpenCreate}
            className="bg-indigo-600 hover:bg-indigo-700 h-12 px-8 rounded-xl font-black uppercase shadow-xl"
          >
            <Plus className="mr-2 h-5 w-5" />
            Lên đơn
          </Button>
        </div>
      </div>

      {/* STATS */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard
          title="Doanh thu (Trang này)"
          value={`${analytics.paidRevenue.toLocaleString()}đ`}
          icon={<TrendingUp className="text-emerald-600" />}
          color="bg-emerald-50"
        />
        <StatCard
          title="Tổng số đơn hàng"
          value={analytics.totalOrders}
          icon={<ShoppingBag className="text-blue-600" />}
          color="bg-blue-50"
        />
        <StatCard
          title="Đang xử lý"
          value={String(analytics.processing).padStart(2, "0")}
          icon={<AlertCircle className="text-rose-600" />}
          color="bg-rose-50"
        />
      </div>

      {/* FILTER */}
      <div className="flex flex-col md:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-5 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <Input
            placeholder="Tìm theo ID khách hàng..."
            className="h-14 pl-14 pr-6 rounded-2xl border-none shadow-lg font-bold"
            value={filterCustomerId}
            onChange={(e) => setFilterCustomerId(e.target.value)}
          />
        </div>
        <Select value={filterStatus} onValueChange={setFilterStatus}>
          <SelectTrigger className="w-full md:w-[240px] h-14 rounded-2xl border-none shadow-lg font-black uppercase text-[11px]">
            <div className="flex items-center gap-2">
              <Filter className="h-4 w-4" />
              <SelectValue placeholder="Trạng thái" />
            </div>
          </SelectTrigger>
          <SelectContent className="rounded-xl font-bold">
            <SelectItem value="ALL">Tất cả trạng thái</SelectItem>
            <SelectItem value="PAID">Đã thanh toán</SelectItem>
            <SelectItem value="UNPAID">Chưa thanh toán</SelectItem>
            <SelectItem value="CANCELLED">Đã hủy</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* TABLE AREA */}
      <Card className="border-none shadow-2xl rounded-[3rem] overflow-hidden bg-white">
        <CardContent className="p-0">
          {isLoading ? (
            <div className="p-32 flex flex-col items-center justify-center">
              <Loader2 className="h-16 w-16 animate-spin mb-6 text-indigo-500" />
              <p className="font-black uppercase text-slate-400 italic tracking-widest">
                Đang tải dữ liệu...
              </p>
            </div>
          ) : isError ? (
            <div className="p-32 flex flex-col items-center justify-center text-center">
              <div className="p-6 bg-rose-50 rounded-full mb-6 text-rose-500">
                <WifiOff className="h-12 w-12" />
              </div>
              <h3 className="text-xl font-black text-slate-900 uppercase">
                Lỗi kết nối dữ liệu
              </h3>
              <Button
                onClick={() =>
                  queryClient.invalidateQueries({ queryKey: ["orders-list"] })
                }
                className="mt-6 rounded-xl bg-slate-900"
              >
                Thử lại
              </Button>
            </div>
          ) : (
            <>
              <Table>
                <TableHeader className="bg-slate-50/50">
                  <TableRow>
                    <TableHead className="py-8 px-10 font-black text-slate-400 uppercase text-[11px]">
                      Mã đơn
                    </TableHead>
                    <TableHead className="font-black text-slate-400 uppercase text-[11px] text-center">
                      Khách hàng
                    </TableHead>
                    <TableHead className="font-black text-slate-400 uppercase text-[11px] text-center">
                      Trạng thái
                    </TableHead>
                    <TableHead className="font-black text-slate-400 uppercase text-[11px] text-right px-10">
                      Tổng tiền
                    </TableHead>
                    <TableHead className="w-[180px] px-10 text-center font-black text-slate-400 uppercase text-[11px]">
                      Thao tác
                    </TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {ordersRes?.result?.content?.length === 0 ? (
                    <TableRow>
                      <TableCell
                        colSpan={5}
                        className="py-20 text-center font-bold text-slate-400 uppercase"
                      >
                        Chưa có đơn hàng nào
                      </TableCell>
                    </TableRow>
                  ) : (
                    ordersRes?.result?.content?.map((order: OrderDTO) => (
                      <TableRow
                        key={order.id}
                        className="group hover:bg-slate-50 transition-all border-b border-slate-50"
                      >
                        <TableCell className="px-10 py-7">
                          <div className="flex flex-col">
                            <span className="font-black text-lg text-slate-900 tracking-tighter">
                              {order.orderNumber}
                            </span>
                            <span className="text-[11px] text-slate-400 font-bold uppercase flex items-center mt-1">
                              <Clock className="h-3 w-3 mr-1.5" />{" "}
                              {order.createdAt
                                ? format(
                                    new Date(order.createdAt),
                                    "dd/MM/yyyy",
                                  )
                                : "---"}
                            </span>
                          </div>
                        </TableCell>
                        <TableCell className="text-center">
                          <Badge
                            variant="secondary"
                            className="bg-slate-100 text-slate-600 font-black px-3 py-1"
                          >
                            ID: {order.customerId}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-center">
                          <Badge
                            variant="outline"
                            className={cn(
                              "font-black uppercase text-[10px] px-3 py-1 rounded-lg border",
                              order.status === "PAID" ||
                                order.status === "CONFIRMED"
                                ? "bg-emerald-50 text-emerald-600 border-emerald-200"
                                : order.status === "UNPAID"
                                  ? "bg-rose-50 text-rose-600 border-rose-200"
                                  : "bg-slate-100",
                            )}
                          >
                            {order.status}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right px-10 font-black text-indigo-600 text-xl tracking-tighter">
                          {order.totalAmount?.toLocaleString()}đ
                        </TableCell>
                        <TableCell className="px-10">
                          <div className="flex justify-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                            {/* NÚT CHI TIẾT */}
                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => setViewingOrder(order)}
                              className="rounded-xl hover:bg-indigo-50 hover:text-indigo-600"
                              title="Xem chi tiết"
                            >
                              <Eye className="h-5 w-5" />
                            </Button>

                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => handleEdit(order)}
                              className="rounded-xl hover:bg-orange-50 hover:text-orange-600"
                              title="Sửa đơn"
                            >
                              <Edit3 className="h-5 w-5" />
                            </Button>

                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => setOrderToDelete(order.id)}
                              className="rounded-xl hover:bg-rose-50 hover:text-rose-600"
                              title="Hủy đơn"
                            >
                              <Trash2 className="h-5 w-5" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>

              <div className="p-8 bg-slate-50 flex items-center justify-between border-t">
                <p className="text-[11px] font-black text-slate-400 uppercase">
                  Trang {page + 1} / {ordersRes?.result?.totalPages || 1}
                </p>
                <div className="flex gap-3">
                  <Button
                    variant="outline"
                    size="icon"
                    disabled={page === 0}
                    onClick={() => setPage((p) => p - 1)}
                    className="rounded-2xl h-12 w-12 bg-white shadow-sm"
                  >
                    <ChevronLeft className="h-5 w-5" />
                  </Button>
                  <Button
                    variant="outline"
                    size="icon"
                    disabled={page >= (ordersRes?.result?.totalPages || 1) - 1}
                    onClick={() => setPage((p) => p + 1)}
                    className="rounded-2xl h-12 w-12 bg-white shadow-sm"
                  >
                    <ChevronRight className="h-5 w-5" />
                  </Button>
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>

      {/* VIEW DETAILS SHEET */}
      <Sheet
        open={!!viewingOrder}
        onOpenChange={(open) => !open && setViewingOrder(null)}
      >
        <SheetContent className="w-full sm:max-w-[550px] p-0 border-none flex flex-col h-[100dvh] bg-white">
          {viewingOrder && (
            <>
              <SheetHeader className="p-10 bg-indigo-600 text-white rounded-b-[3.5rem] shadow-xl">
                <div className="flex justify-between items-start">
                  <div>
                    <SheetTitle className="text-white text-3xl font-black uppercase italic tracking-tighter">
                      Chi tiết đơn hàng
                    </SheetTitle>
                    <p className="text-indigo-100 font-bold mt-1">
                      Mã đơn: {viewingOrder.orderNumber}
                    </p>
                  </div>
                  <Badge className="bg-white/20 text-white border-none uppercase font-black px-4 py-2 rounded-xl">
                    {viewingOrder.status}
                  </Badge>
                </div>
              </SheetHeader>

              <ScrollArea className="flex-1 px-10 pb-[200px]">
                <div className="py-10 space-y-10">
                  <div className="bg-slate-50 p-6 rounded-[2rem] border border-slate-100 flex items-center gap-5">
                    <div className="h-14 w-14 bg-white rounded-2xl shadow-sm flex items-center justify-center text-indigo-600">
                      <Package className="h-7 w-7" />
                    </div>
                    <div>
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                        Khách hàng
                      </p>
                      <p className="text-xl font-black text-slate-900">
                        ID: {viewingOrder.customerId}
                      </p>
                    </div>
                  </div>

                  <div className="space-y-4">
                    <h4 className="text-[11px] font-black text-slate-400 uppercase tracking-widest border-b pb-2">
                      Sản phẩm trong đơn
                    </h4>
                    <div className="space-y-3">
                      {viewingOrder.items.map((item, idx) => (
                        <div
                          key={idx}
                          className="flex justify-between items-center p-5 bg-white border border-slate-100 rounded-3xl shadow-sm group hover:border-indigo-200 transition-colors"
                        >
                          <div className="flex items-center gap-4">
                            <div className="h-10 w-10 bg-slate-100 rounded-xl flex items-center justify-center font-black text-slate-500 text-xs">
                              #{item.productId}
                            </div>
                            <div>
                              <p className="font-black text-slate-900">
                                Sản phẩm ID {item.productId}
                              </p>
                              <p className="text-xs text-slate-400 font-bold uppercase">
                                SL: {item.quantity} ×{" "}
                                {item.unitPrice.toLocaleString()}đ
                              </p>
                            </div>
                          </div>
                          <p className="font-black text-slate-900">
                            {(item.quantity * item.unitPrice).toLocaleString()}đ
                          </p>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="p-5 bg-emerald-50 rounded-3xl border border-emerald-100">
                      <p className="text-[10px] font-black text-emerald-600 uppercase mb-1">
                        Thanh toán
                      </p>
                      <p className="font-black text-emerald-900">
                        {viewingOrder.paymentType}
                      </p>
                    </div>
                    <div className="p-5 bg-blue-50 rounded-3xl border border-blue-100">
                      <p className="text-[10px] font-black text-blue-600 uppercase mb-1">
                        Ngày tạo
                      </p>
                      <p className="font-black text-blue-900">
                        {viewingOrder.createdAt
                          ? format(
                              new Date(viewingOrder.createdAt),
                              "dd/MM/yyyy",
                            )
                          : "---"}
                      </p>
                    </div>
                  </div>

                  {viewingOrder.notes && (
                    <div className="p-6 bg-slate-50 rounded-3xl border border-dashed border-slate-200">
                      <p className="text-[10px] font-black text-slate-400 uppercase mb-2">
                        Ghi chú đơn hàng
                      </p>
                      <p className="text-sm font-bold text-slate-600 italic leading-relaxed">
                        "{viewingOrder.notes}"
                      </p>
                    </div>
                  )}
                </div>
              </ScrollArea>

              <SheetFooter className="sticky bottom-0 p-10 bg-white border-t rounded-t-[3.5rem] z-20 pb-[env(safe-area-inset-bottom)]">
                <div className="w-full flex justify-between items-center">
                  <div>
                    <p className="text-[10px] font-black text-slate-400 uppercase">
                      Tổng cộng cuối cùng
                    </p>
                    <p className="text-4xl font-black text-indigo-600 tracking-tighter">
                      {viewingOrder.totalAmount?.toLocaleString()}đ
                    </p>
                  </div>
                  <Button
                    onClick={() => setViewingOrder(null)}
                    className="h-14 px-8 rounded-2xl bg-slate-900 font-black uppercase text-[11px]"
                  >
                    Đóng
                  </Button>
                </div>
              </SheetFooter>
            </>
          )}
        </SheetContent>
      </Sheet>

      {/* FORM SHEET (CREATE/EDIT) */}
      <Sheet
        open={isSheetOpen}
        onOpenChange={(open) => !open && handleCloseSheet()}
      >
        <SheetContent className="w-full sm:max-w-[750px] p-0 border-none flex flex-col h-full bg-[#fcfcfd]">
          <SheetHeader
            className={cn(
              "p-10 text-white rounded-b-[3.5rem]",
              editingOrderId ? "bg-orange-500" : "bg-slate-900",
            )}
          >
            <SheetTitle className="text-white text-3xl font-black uppercase italic tracking-tighter flex items-center gap-4">
              {editingOrderId ? (
                <Edit3 className="h-10 w-10" />
              ) : (
                <ShoppingBag className="h-10 w-10" />
              )}
              {editingOrderId ? `Sửa đơn #${editingOrderId}` : "Tạo đơn mới"}
            </SheetTitle>
          </SheetHeader>

          <div className="flex-1 overflow-hidden">
            <ScrollArea className="h-full px-10">
              <div className="py-10 space-y-10">
                <div className="grid grid-cols-2 gap-6">
                  <div className="space-y-3">
                    <label className="text-[11px] font-black uppercase text-slate-400">
                      ID Khách hàng *
                    </label>
                    <Select
                      value={customerId}
                      onValueChange={(v) => setCustomerId(v)}
                    >
                      <SelectTrigger className="h-14 rounded-2xl font-bold">
                        <SelectValue placeholder="Chọn khách hàng" />
                      </SelectTrigger>

                      <SelectContent>
                        <SelectItem value="0">Khách lẻ</SelectItem>
                        {customers.map((c: any) => (
                          <SelectItem key={c.id} value={c.id.toString()}>
                            {c.fullName} - {c.phone}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-3">
                    <label className="text-[11px] font-black uppercase text-slate-400">
                      Thanh toán
                    </label>
                    <Select
                      value={paymentType}
                      onValueChange={(v: PaymentType) => setPaymentType(v)}
                    >
                      <SelectTrigger className="h-14 rounded-2xl font-bold">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent className="font-bold">
                        <SelectItem value="CASH">Tiền mặt</SelectItem>
                        <SelectItem value="TRANSFER">Chuyển khoản</SelectItem>
                        <SelectItem value="CREDIT">Thẻ/Tín dụng</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex justify-between items-center border-b pb-4">
                    <label className="text-[11px] font-black uppercase text-slate-400">
                      Sản phẩm trong đơn
                    </label>
                    <Button
                      onClick={() =>
                        setItems([
                          ...items,
                          { productId: 0, quantity: 1, unitPrice: 0 },
                        ])
                      }
                      variant="ghost"
                      size="sm"
                      className="text-indigo-600 font-black text-[10px] underline"
                    >
                      + Thêm dòng mới
                    </Button>
                  </div>
                  {items.map((item, idx) => (
                    <div
                      key={idx}
                      className="grid grid-cols-12 gap-3 bg-white p-5 rounded-3xl border border-slate-100 shadow-sm"
                    >
                      <div className="col-span-5">
                        <span className="text-[10px] font-bold text-slate-300 uppercase block mb-1">
                          Mã SP
                        </span>
                        <Select
                          value={
                            item.productId ? item.productId.toString() : ""
                          }
                          onValueChange={(v) => {
                            const product = products.find(
                              (p: any) => p.id.toString() === v,
                            );
                            if (!product) return;

                            const newItems = [...items];
                            newItems[idx] = {
                              ...newItems[idx],
                              productId: product.id,
                              unitPrice: product.price,
                              stock: product.stock,
                              quantity: 1,
                            };
                            setItems(newItems);
                          }}
                        >
                          <SelectTrigger className="h-12 rounded-xl font-bold">
                            <SelectValue placeholder="Chọn sản phẩm" />
                          </SelectTrigger>

                          <SelectContent>
                            {products.map((p: any) => (
                              <SelectItem key={p.id} value={p.id.toString()}>
                                {p.name} — tồn {p.stock}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>

                      {/* --- ĐÃ SỬA: CỘT ĐƠN GIÁ (Readonly) --- */}
                      <div className="col-span-4">
                        <span className="text-[10px] font-bold text-slate-300 uppercase block mb-1">
                          Đơn giá
                        </span>
                        <Input
                          value={
                            item.unitPrice
                              ? item.unitPrice.toLocaleString()
                              : "0"
                          }
                          disabled
                          className="bg-slate-100 text-indigo-600 font-bold text-right"
                        />
                      </div>

                      {/* --- ĐÃ SỬA: CỘT SỐ LƯỢNG (Có validation) --- */}
                      <div className="col-span-2 text-center">
                        <span className="text-[10px] font-bold text-slate-300 uppercase block mb-1">
                          SL
                        </span>
                        <Input
                          type="number"
                          min={1}
                          max={item.stock ?? undefined}
                          value={item.quantity}
                          onChange={(e) => {
                            const qty = Number(e.target.value);
                            if (item.stock && qty > item.stock) {
                              toast.error(
                                `Chỉ còn ${item.stock} sản phẩm trong kho!`,
                              );
                            }
                            const newItems = [...items];
                            newItems[idx].quantity = qty;
                            setItems(newItems);
                          }}
                          className="font-bold text-center"
                        />
                      </div>

                      <div className="col-span-1 flex items-end justify-end">
                        <Button
                          disabled={items.length === 1}
                          onClick={() =>
                            setItems(items.filter((_, i) => i !== idx))
                          }
                          variant="ghost"
                          size="icon"
                          className="h-12 w-12 text-rose-300 hover:text-rose-600"
                        >
                          <Trash2 className="h-5 w-5" />
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </ScrollArea>
          </div>

          <SheetFooter className="p-10 bg-white border-t rounded-t-[4rem]">
            <div className="w-full space-y-6">
              <div className="flex justify-between items-center px-4">
                <span className="font-black text-slate-400 uppercase text-xs">
                  Tổng cộng
                </span>
                <span className="font-black text-4xl text-indigo-600 tracking-tighter">
                  {totalAmount.toLocaleString()}đ
                </span>
              </div>
              <Button
                onClick={() => {
                  // --- ĐÃ SỬA: VALIDATION ---
                  const validItems = items.filter(
                    (i) => i.productId > 0 && i.quantity > 0,
                  );

                  if (validItems.length === 0) {
                    toast.error("Đơn hàng phải có ít nhất 1 sản phẩm hợp lệ!");
                    return;
                  }

                  const payload = {
                    customerId: customerId === "0" ? null : Number(customerId),
                    discountAmount: Number(discountAmount),
                    paymentType,
                    status: orderStatus,
                    notes,
                    // --- ĐÃ SỬA: PAYLOAD (Chỉ gửi productId và quantity) ---
                    items: validItems.map((i) => ({
                      productId: i.productId,
                      quantity: i.quantity,
                      unitPrice: i.unitPrice,
                    })),
                  };

                  editingOrderId
                    ? updateMutation.mutate({
                        id: editingOrderId,
                        data: payload,
                      })
                    : createMutation.mutate(payload);
                }}
                disabled={createMutation.isPending || updateMutation.isPending}
                className={cn(
                  "w-full h-20 rounded-[2rem] font-black uppercase text-xl shadow-2xl transition-all",
                  editingOrderId
                    ? "bg-orange-500 hover:bg-orange-600"
                    : "bg-indigo-600 hover:bg-indigo-700",
                )}
              >
                {(createMutation.isPending || updateMutation.isPending) && (
                  <Loader2 className="animate-spin mr-2" />
                )}
                {editingOrderId ? "Xác nhận cập nhật" : "Xác nhận tạo đơn"}
              </Button>
            </div>
          </SheetFooter>
        </SheetContent>
      </Sheet>

      {/* DELETE ALERT */}
      <AlertDialog
        open={!!orderToDelete}
        onOpenChange={() => setOrderToDelete(null)}
      >
        <AlertDialogContent className="rounded-[3rem] p-10 border-none shadow-2xl">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-3xl font-black uppercase italic tracking-tighter">
              Hủy giao dịch?
            </AlertDialogTitle>
            <AlertDialogDescription className="text-slate-500 text-lg mt-4">
              Hành động này sẽ xóa vĩnh viễn đơn hàng.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-10 gap-4">
            <AlertDialogCancel className="h-14 px-8 rounded-2xl font-black uppercase text-[11px] bg-slate-100 border-none">
              Đóng
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={() =>
                orderToDelete && deleteMutation.mutate(orderToDelete)
              }
              className="h-14 px-8 rounded-2xl bg-rose-600 font-black uppercase text-[11px]"
            >
              Xác nhận hủy
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// StatCard Component
function StatCard({
  title,
  value,
  icon,
  color,
}: {
  title: string;
  value: any;
  icon: any;
  color: string;
}) {
  return (
    <Card className="rounded-[2.5rem] border-none shadow-xl bg-white group hover:scale-[1.02] transition-transform">
      <CardContent className="p-8 flex items-center gap-6">
        <div className={cn("p-4 rounded-2xl", color)}>{icon}</div>
        <div>
          <p className="text-[11px] font-black text-slate-400 uppercase tracking-widest">
            {title}
          </p>
          <h3 className="text-3xl font-black text-slate-900 tracking-tighter">
            {typeof value === "number" ? value.toLocaleString() : value}
          </h3>
        </div>
      </CardContent>
    </Card>
  );
}
