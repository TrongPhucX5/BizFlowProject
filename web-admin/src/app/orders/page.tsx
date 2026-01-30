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
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import { Check, ChevronsUpDown, Printer } from "lucide-react";
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

  // --- HÀM IN HÓA ĐƠN CHUYÊN NGHIỆP ---
  const handlePrintReceipt = (order: any) => {
    const printWindow = window.open("", "_blank", "width=900,height=1000");
    if (!printWindow) {
      toast.error("Trình duyệt đã chặn cửa sổ in. Vui lòng cho phép 'Popup' để in hóa đơn.");
      return;
    }

    try {
      const itemsHtml = (order.items || []).map((item: any) => `
        <tr style="border-bottom: 1px solid #e2e8f0;">
          <td style="padding: 15px 10px; font-size: 16px; vertical-align: top;">
            <div style="font-weight: 700; color: #1e293b;">${item.productName || "Sản phẩm #" + item.productId}</div>
            <div style="font-size: 13px; color: #64748b; margin-top: 4px;">Mã SP: #${item.productId}</div>
          </td>
          <td style="padding: 15px 10px; font-size: 16px; text-align: center; vertical-align: top;">
            ${item.quantity}
          </td>
          <td style="padding: 15px 10px; font-size: 16px; text-align: right; vertical-align: top;">
            ${(item.unitPrice || 0).toLocaleString()}đ
          </td>
          <td style="padding: 15px 10px; font-size: 16px; text-align: right; font-weight: 700; color: #1e293b; vertical-align: top;">
            ${((item.quantity || 0) * (item.unitPrice || 0)).toLocaleString()}đ
          </td>
        </tr>
      `).join("");

      const createdAtStr = order.createdAt
        ? format(new Date(order.createdAt), "dd/MM/yyyy HH:mm")
        : format(new Date(), "dd/MM/yyyy HH:mm");

      printWindow.document.write(`
        <!DOCTYPE html>
        <html>
          <head>
            <title>BIZFLOW - ${order.orderCode || order.orderNumber || "#" + order.id}</title>
            <style>
              @page { size: A4; margin: 20mm; }
              * { box-sizing: border-box; }
              body { 
                font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                margin: 0; padding: 0;
                color: #1e293b; line-height: 1.5;
                background: white;
              }
              .invoice-box {
                max-width: 800px;
                margin: auto;
                padding: 30px;
              }
              .header { 
                display: flex; 
                justify-content: space-between; 
                align-items: center;
                border-bottom: 3px solid #4f46e5;
                padding-bottom: 20px;
                margin-bottom: 30px;
              }
              .logo { font-size: 35px; font-weight: 900; color: #4f46e5; }
              .invoice-title { text-align: right; }
              .invoice-title h1 { margin: 0; font-size: 24px; text-transform: uppercase; color: #1e293b; }
              
              .info-grid { 
                display: grid; 
                grid-template-columns: 1fr 1fr; 
                gap: 40px; 
                margin-bottom: 40px;
              }
              .info-section h3 { 
                font-size: 14px; 
                text-transform: uppercase; 
                color: #64748b; 
                margin-bottom: 10px;
                border-bottom: 1px solid #e2e8f0;
                padding-bottom: 5px;
              }
              .info-content { font-size: 15px; }
              .info-row { display: flex; margin-bottom: 5px; }
              .info-label { width: 120px; color: #64748b; }
              .info-value { font-weight: 700; }

              table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
              thead tr { background: #f8fafc; border-bottom: 2px solid #e2e8f0; }
              th { padding: 12px 10px; text-align: left; font-size: 13px; color: #64748b; text-transform: uppercase; }
              
              .totals-area { 
                display: flex; 
                justify-content: flex-end; 
              }
              .totals-box { width: 300px; }
              .total-row { 
                display: flex; 
                justify-content: space-between; 
                padding: 10px 0;
                font-size: 16px;
              }
              .grand-total { 
                border-top: 2px solid #1e293b;
                margin-top: 10px;
                padding-top: 15px;
                font-size: 22px;
                font-weight: 900;
                color: #4f46e5;
              }
              .footer { 
                margin-top: 60px; 
                text-align: center; 
                font-size: 14px; 
                color: #94a3b8;
                border-top: 1px solid #e2e8f0;
                padding-top: 20px;
              }
              @media print {
                .invoice-box { border: none; box-shadow: none; padding: 0; width: 100%; max-width: 100%; }
                body { padding: 0; }
              }
            </style>
          </head>
          <body>
            <div class="invoice-box">
              <div class="header">
                <div class="logo">BIZFLOW</div>
                <div class="invoice-title">
                  <h1>Hóa đơn bán hàng</h1>
                  <div style="font-weight: 700; color: #4f46e5;">#${order.orderCode || order.orderNumber || order.id}</div>
                </div>
              </div>

              <div class="info-grid">
                <div class="info-section">
                  <h3>Đơn hàng</h3>
                  <div class="info-content">
                    <div class="info-row"><span class="info-label">Mã đơn:</span><span class="info-value">${order.orderCode || order.orderNumber}</span></div>
                    <div class="info-row"><span class="info-label">Ngày lập:</span><span class="info-value">${createdAtStr}</span></div>
                    <div class="info-row"><span class="info-label">Trạng thái:</span><span class="info-value">${order.status}</span></div>
                  </div>
                </div>
                <div class="info-section">
                  <h3>Khách hàng</h3>
                  <div class="info-content">
                    <div class="info-row"><span class="info-label">Tên khách:</span><span class="info-value">${order.customerName || "Khách vãng lai"}</span></div>
                    <div class="info-row"><span class="info-label">Hình thức:</span><span class="info-value">${order.paymentType || "Tiền mặt"}</span></div>
                  </div>
                </div>
              </div>

              <table>
                <thead>
                  <tr>
                    <th style="width: 50%;">Sản phẩm / Dịch vụ</th>
                    <th style="text-align: center;">SL</th>
                    <th style="text-align: right;">Đơn giá</th>
                    <th style="text-align: right;">Thành tiền</th>
                  </tr>
                </thead>
                <tbody>
                  ${itemsHtml}
                </tbody>
              </table>

              <div class="totals-area">
                <div class="totals-box">
                  <div class="total-row">
                    <span>Tạm tính:</span>
                    <span>${(order.subtotal || 0).toLocaleString()}đ</span>
                  </div>
                  <div class="total-row">
                    <span>Giảm giá:</span>
                    <span>-${(order.discountAmount || 0).toLocaleString()}đ</span>
                  </div>
                  <div class="total-row grand-total">
                    <span>TỔNG CỘNG:</span>
                    <span>${(order.totalAmount || 0).toLocaleString()}đ</span>
                  </div>
                </div>
              </div>

              <div class="footer">
                <p style="font-weight: 700; color: #1e293b; margin-bottom: 5px;">CẢM ƠN QUÝ KHÁCH ĐÃ TIN TƯỞNG!</p>
                <p>Mọi thắc mắc vui lòng liên hệ hotline: 1900 xxxx</p>
                <p style="margin-top: 20px; font-size: 11px;">Hóa đơn được tạo tự động bởi hệ thống BizFlow</p>
              </div>
            </div>
          </body>
        </html>
      `);
      printWindow.document.close();

      setTimeout(() => {
        printWindow.focus();
        printWindow.print();
        // Cửa sổ in sẽ được người dùng đóng thủ công
      }, 500);

    } catch (err) {
      console.error("Print error:", err);
      toast.error("Có lỗi xảy ra khi tạo bản in.");
      printWindow.close();
    }
  };

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
    { productId: number; quantity: number; unitPrice: number; stock?: number; open?: boolean }[]
  >([{ productId: 0, quantity: 1, unitPrice: 0, stock: 0, open: false }]);
  const [openCustomer, setOpenCustomer] = useState(false);

  // --- 1. DATA FETCHING ---

  const { data: productsRes } = useQuery({
    queryKey: ["products-for-order"],
    queryFn: () => dashboardService.getProducts({ size: 1000 }),
    enabled: mounted,
  });

  const products = (productsRes as any)?.result?.content || [];

  const { data: customersRes } = useQuery({
    queryKey: ["customers-for-order"],
    queryFn: () => customersService.getCustomers({ size: 1000 }),
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
          ? debouncedCustomerId
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
  const quickStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: number; status: OrderStatus }) =>
      orderService.updateOrderStatus(id, status),
    onSuccess: () => {
      toast.success("Đã cập nhật trạng thái đơn hàng!");
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
    },
    onError: (err: any) => toast.error(err.response?.data?.message || "Lỗi cập nhật"),
  });

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
    setItems([{ productId: 0, quantity: 1, unitPrice: 0, open: false }]);
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
      link.setAttribute('download', `so - doanh - thu - TT88 - ${exportFrom} - ${exportTo}.xlsx`);
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
      <div className="flex flex-col lg:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-5 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <Input
            placeholder="Tìm theo ID khách hàng..."
            className="h-14 pl-14 pr-6 rounded-2xl border-none shadow-lg font-bold"
            value={filterCustomerId}
            onChange={(e) => setFilterCustomerId(e.target.value)}
          />
        </div>

        <div className="flex gap-2 p-1 bg-white rounded-2xl shadow-lg">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              const today = new Date().toISOString().split('T')[0];
              setExportFrom(today);
              setExportTo(today);
            }}
            className="rounded-xl font-bold text-[11px] uppercase hover:bg-slate-100"
          >
            Hôm nay
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              const d = new Date();
              d.setDate(d.getDate() - 7);
              setExportFrom(d.toISOString().split('T')[0]);
              setExportTo(new Date().toISOString().split('T')[0]);
            }}
            className="rounded-xl font-bold text-[11px] uppercase hover:bg-slate-100"
          >
            7 ngày qua
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              setExportFrom("");
              setExportTo("");
            }}
            className="rounded-xl font-bold text-[11px] uppercase hover:bg-slate-100"
          >
            Tất cả
          </Button>
        </div>

        <Select value={filterStatus} onValueChange={setFilterStatus}>
          <SelectTrigger className="w-full lg:w-[240px] h-14 rounded-2xl border-none shadow-lg font-black uppercase text-[11px]">
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
            <div className="p-8 space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="flex items-center gap-4 p-4 rounded-3xl bg-slate-50/50 animate-pulse">
                  <div className="h-12 w-[150px] bg-slate-200 rounded-xl" />
                  <div className="h-12 flex-1 bg-slate-200 rounded-xl" />
                  <div className="h-8 w-24 bg-slate-200 rounded-full" />
                  <div className="h-8 w-24 bg-slate-200 rounded-xl" />
                </div>
              ))}
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
                  <TableRow className="border-b border-slate-200">
                    <TableHead className="w-[180px] py-4 px-6 font-bold text-slate-600 uppercase text-xs">
                      Mã đơn
                    </TableHead>
                    <TableHead className="py-4 px-6 font-bold text-slate-600 uppercase text-xs text-center">
                      Khách hàng
                    </TableHead>
                    <TableHead className="py-4 px-6 font-bold text-slate-600 uppercase text-xs text-center">
                      Trạng thái
                    </TableHead>
                    <TableHead className="py-4 px-6 font-bold text-slate-600 uppercase text-xs text-right">
                      Tổng tiền
                    </TableHead>
                    <TableHead className="w-[150px] py-4 px-6 text-center font-bold text-slate-600 uppercase text-xs">
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
                        className="group hover:bg-slate-50 transition-all border-b border-slate-100"
                      >
                        <TableCell className="px-6 py-4">
                          <div className="flex flex-col">
                            <span className="font-bold text-sm text-slate-900">
                              {order.orderCode || order.orderNumber}
                            </span>
                            <span className="text-xs text-slate-500 font-medium flex items-center mt-1">
                              <Clock className="h-3 w-3 mr-1.5" />{" "}
                              {order.createdAt
                                ? format(
                                  new Date(order.createdAt),
                                  "dd/MM/yyyy HH:mm",
                                )
                                : "---"}
                            </span>
                          </div>
                        </TableCell>
                        <TableCell className="text-center px-6 py-4">
                          <div className="flex flex-col items-center gap-1">
                            <span className="font-bold text-sm text-slate-900">
                              {order.customerName || "Khách vãng lai"}
                            </span>
                            <Badge
                              variant="secondary"
                              className="bg-slate-100 text-slate-500 font-bold text-[9px] px-1.5 py-0 h-4 border-none"
                            >
                              ID: {order.customerId}
                            </Badge>
                          </div>
                        </TableCell>
                        <TableCell className="text-center px-6 py-4">
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Badge
                                variant="outline"
                                className={cn(
                                  "font-bold uppercase text-[10px] px-2 py-1 h-6 border-0 cursor-pointer hover:ring-2 ring-indigo-200 transition-all",
                                  order.status === "PAID" || order.status === "CONFIRMED"
                                    ? "bg-emerald-100 text-emerald-700"
                                    : order.status === "UNPAID"
                                      ? "bg-rose-100 text-rose-700"
                                      : "bg-slate-100 text-slate-600",
                                )}
                              >
                                {order.status}
                              </Badge>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent className="rounded-xl font-bold">
                              <DropdownMenuItem onClick={() => quickStatusMutation.mutate({ id: order.id, status: 'PAID' })}>
                                <Check className="h-4 w-4 mr-2 text-emerald-500" /> Đã thanh toán
                              </DropdownMenuItem>
                              <DropdownMenuItem onClick={() => quickStatusMutation.mutate({ id: order.id, status: 'UNPAID' })}>
                                <Clock className="h-4 w-4 mr-2 text-rose-500" /> Chưa thanh toán
                              </DropdownMenuItem>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                variant="destructive"
                                onClick={() => quickStatusMutation.mutate({ id: order.id, status: 'CANCELLED' })}
                              >
                                <Trash2 className="h-4 w-4 mr-2" /> Hủy đơn
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                        <TableCell className="text-right px-6 py-4 font-bold text-indigo-700 text-sm">
                          {order.totalAmount?.toLocaleString()}đ
                        </TableCell>
                        <TableCell className="px-6 py-4">
                          <div className="flex justify-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                            {/* NÚT CHI TIẾT */}
                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => setViewingOrder(order)}
                              className="h-8 w-8 hover:bg-indigo-50 hover:text-indigo-600 rounded-lg"
                              title="Xem chi tiết"
                            >
                              <Eye className="h-4 w-4" />
                            </Button>

                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => handleEdit(order)}
                              className="h-8 w-8 hover:bg-orange-50 hover:text-orange-600 rounded-lg"
                              title="Sửa đơn"
                            >
                              <Edit3 className="h-4 w-4" />
                            </Button>

                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => setOrderToDelete(order.id)}
                              className="h-8 w-8 hover:bg-rose-50 hover:text-rose-600 rounded-lg"
                              title="Hủy đơn"
                            >
                              <Trash2 className="h-4 w-4" />
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
                      Mã đơn: {viewingOrder.orderCode || viewingOrder.orderNumber || "#" + viewingOrder.id}
                    </p>
                  </div>
                  <Badge className="bg-white/20 text-white border-none uppercase font-black px-4 py-2 rounded-xl">
                    {viewingOrder.status}
                  </Badge>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => handlePrintReceipt(viewingOrder)}
                    className="ml-2 text-indigo-100 hover:text-white hover:bg-white/20 rounded-xl hidden sm:flex"
                    title="In hóa đơn"
                  >
                    <Printer className="h-5 w-5" />
                  </Button>
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
                        {viewingOrder.customerName || `ID: ${viewingOrder.customerId}`}
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
                                {item.productName || `Sản phẩm ID ${item.productId}`}
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
                    <Popover open={openCustomer} onOpenChange={setOpenCustomer}>
                      <PopoverTrigger asChild>
                        <Button
                          variant="outline"
                          role="combobox"
                          aria-expanded={openCustomer}
                          className="h-14 w-full justify-between rounded-2xl font-bold bg-white border-slate-200"
                        >
                          {customerId
                            ? customers.find((c: any) => c.id.toString() === customerId)?.fullName
                            : "Chọn khách hàng..."}
                          <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent className="w-[300px] p-0 rounded-xl">
                        <Command>
                          <CommandInput placeholder="Tìm khách hàng..." />
                          <CommandList>
                            <CommandEmpty>Không tìm thấy khách hàng.</CommandEmpty>
                            <CommandGroup>
                              <CommandItem
                                value="0"
                                onSelect={() => {
                                  setCustomerId("0");
                                  setOpenCustomer(false);
                                }}
                              >
                                <Check
                                  className={cn(
                                    "mr-2 h-4 w-4",
                                    customerId === "0" ? "opacity-100" : "opacity-0"
                                  )}
                                />
                                Khách lẻ
                              </CommandItem>
                              {customers.map((c: any) => (
                                <CommandItem
                                  key={c.id}
                                  value={c.id + " " + c.fullName + " " + c.phone}
                                  onSelect={() => {
                                    setCustomerId(c.id.toString());
                                    setOpenCustomer(false);
                                  }}
                                >
                                  <Check
                                    className={cn(
                                      "mr-2 h-4 w-4",
                                      customerId === c.id.toString()
                                        ? "opacity-100"
                                        : "opacity-0",
                                    )}
                                  />
                                  <div className="flex flex-col">
                                    <span className="font-bold text-slate-900">
                                      [#{c.id}] {c.fullName}
                                    </span>
                                    <span className="text-xs text-slate-400">
                                      {c.phone}
                                    </span>
                                  </div>
                                </CommandItem>
                              ))}
                            </CommandGroup>
                          </CommandList>
                        </Command>
                      </PopoverContent>
                    </Popover>
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
                          { productId: 0, quantity: 1, unitPrice: 0, open: false },
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
                        <Popover
                          open={item.open}
                          onOpenChange={(open) => {
                            const newItems = [...items];
                            newItems[idx].open = open;
                            setItems(newItems);
                          }}
                        >
                          <PopoverTrigger asChild>
                            <Button
                              variant="outline"
                              role="combobox"
                              aria-expanded={item.open}
                              className="h-12 w-full justify-between rounded-xl font-bold bg-white text-left px-3"
                            >
                              {item.productId
                                ? products.find((p: any) => p.id === item.productId)?.name
                                : "Chọn sản phẩm..."}
                              <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                            </Button>
                          </PopoverTrigger>
                          <PopoverContent className="w-[400px] p-0 rounded-xl" align="start">
                            <Command>
                              <CommandInput placeholder="Tìm sản phẩm (Tên, SKU)..." />
                              <CommandList>
                                <CommandEmpty>Không tìm thấy sản phẩm.</CommandEmpty>
                                <CommandGroup>
                                  {products.map((p: any) => (
                                    <CommandItem
                                      key={p.id}
                                      value={p.name + " " + p.sku}
                                      onSelect={() => {
                                        const newItems = [...items];
                                        newItems[idx] = {
                                          ...newItems[idx],
                                          productId: p.id,
                                          unitPrice: p.price,
                                          stock: p.stock,
                                          quantity: 1,
                                          open: false,
                                        };
                                        setItems(newItems);
                                      }}
                                    >
                                      <Check
                                        className={cn(
                                          "mr-2 h-4 w-4",
                                          item.productId === p.id ? "opacity-100" : "opacity-0"
                                        )}
                                      />
                                      <div className="flex flex-col w-full">
                                        <div className="flex justify-between">
                                          <span>{p.name}</span>
                                          <span className={cn(
                                            "font-bold text-xs",
                                            (p.stock || 0) <= 0 ? "text-red-500" : "text-emerald-600"
                                          )}>
                                            Kho: {p.stock || 0}
                                          </span>
                                        </div>
                                        <span className="text-xs text-slate-400">SKU: {p.sku} | Giá: {p.price.toLocaleString()}đ</span>
                                      </div>
                                    </CommandItem>
                                  ))}
                                </CommandGroup>
                              </CommandList>
                            </Command>
                          </PopoverContent>
                        </Popover>
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
                    customerId: Number(customerId),
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
