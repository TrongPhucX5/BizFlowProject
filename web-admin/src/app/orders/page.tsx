"use client";

import { useState, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { 
  orderService, 
  type OrderDTO, 
  type CreateOrderRequest,
  type PaymentType,
  type OrderStatus 
} from "@/services/order.service";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger, SheetFooter } from "@/components/ui/sheet";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { 
  Plus, FileText, Loader2, Clock, Eye, Trash2, ShoppingBag, 
  Calendar as CalendarIcon, FilterX, User,
  ChevronLeft, ChevronRight, Tag, CreditCard
} from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { cn } from "@/lib/utils";
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";

// --- CUSTOM HOOK: DEBOUNCE ---
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(handler);
  }, [value, delay]);
  return debouncedValue;
}

interface OrderItemUI {
  productId: number;
  quantity: number;
  unitPrice: number; 
}

export default function OrderPage() {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [isSheetOpen, setIsSheetOpen] = useState(false);

  // --- STATE LỌC ---
  const [filterStatus, setFilterStatus] = useState<string>("ALL");
  const [filterCustomerId, setFilterCustomerId] = useState<string>("");
  const [filterDate, setFilterDate] = useState<Date | undefined>(undefined);
  const debouncedCustomerId = useDebounce(filterCustomerId, 500);

  // --- STATE FORM TẠO ĐƠN ---
  const [customerId, setCustomerId] = useState<string>("");
  const [discountAmount, setDiscountAmount] = useState<string>("0");
  const [paymentType, setPaymentType] = useState<PaymentType>("CASH");
  const [orderStatus, setOrderStatus] = useState<OrderStatus>("PENDING");
  const [notes, setNotes] = useState<string>("");
  const [items, setItems] = useState<OrderItemUI[]>([{ productId: 0, quantity: 1, unitPrice: 0 }]);

  // --- API: LẤY DANH SÁCH ---
  const { data: ordersRes, isLoading } = useQuery({
    queryKey: ["orders-list", page, debouncedCustomerId, filterStatus, filterDate],
    queryFn: () => {
      const formattedDate = filterDate ? format(filterDate, "yyyy-MM-dd") : undefined;
      return orderService.getAllOrders({ 
        page, 
        size: 10,
        sort: "id,desc", 
        status: filterStatus === "ALL" ? undefined : filterStatus,
        customerId: debouncedCustomerId ? Number(debouncedCustomerId) : undefined,
        startDate: formattedDate,
        endDate: formattedDate,
      });
    },
  });

  const handleResetFilters = () => {
    setFilterCustomerId("");
    setFilterStatus("ALL");
    setFilterDate(undefined);
    setPage(0);
  };

  // --- API: TẠO ĐƠN ---
  const createMutation = useMutation({
    mutationFn: (data: CreateOrderRequest) => orderService.createOrder(data),
    onSuccess: () => {
      toast.success("Tạo đơn hàng thành công!");
      setIsSheetOpen(false);
      resetForm();
      handleResetFilters();
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || "Lỗi khi tạo đơn hàng");
    }
  });

  const resetForm = () => {
    setCustomerId("");
    setItems([{ productId: 0, quantity: 1, unitPrice: 0 }]);
    setDiscountAmount("0");
    setPaymentType("CASH");
    setOrderStatus("PENDING");
    setNotes("");
  };

  const handleAddItem = () => setItems([...items, { productId: 0, quantity: 1, unitPrice: 0 }]);
  const handleRemoveItem = (index: number) => setItems(items.filter((_, i) => i !== index));
  
  const updateItem = (index: number, field: keyof OrderItemUI, value: number) => {
    const newItems = [...items];
    newItems[index] = { ...newItems[index], [field]: value };
    setItems(newItems);
  };

  const handleSaveOrder = () => {
    const validItems = items.filter(i => i.productId > 0 && i.quantity > 0);
    if (!customerId) return toast.error("Vui lòng nhập ID khách hàng");
    if (validItems.length === 0) return toast.error("Vui lòng thêm ít nhất 1 sản phẩm hợp lệ");

    createMutation.mutate({
      customerId: Number(customerId),
      discountAmount: Number(discountAmount),
      paymentType,
      status: orderStatus,
      notes: notes.trim(),
      items: validItems.map(i => ({ 
        productId: i.productId, 
        quantity: i.quantity,
        unitPrice: i.unitPrice 
      }))
    });
  };

  const calculateSubtotal = () => items.reduce((sum, i) => sum + (i.unitPrice * i.quantity), 0);
  const total = calculateSubtotal() - Number(discountAmount);

  const renderStatusBadge = (status: OrderStatus) => {
    const statusConfig: Record<OrderStatus, { label: string, class: string }> = {
      PENDING: { label: "Chờ xử lý", class: "bg-amber-50 text-amber-600 border-amber-200" },
      CONFIRMED: { label: "Đã xác nhận", class: "bg-blue-50 text-blue-600 border-blue-200" },
      PAID: { label: "Đã thanh toán", class: "bg-emerald-50 text-emerald-600 border-emerald-200" },
      PAID_PARTIAL: { label: "Thanh toán một phần", class: "bg-cyan-50 text-cyan-600 border-cyan-200" },
      UNPAID: { label: "Chưa thanh toán", class: "bg-rose-50 text-rose-600 border-rose-200" },
      CANCELLED: { label: "Đã hủy", class: "bg-slate-50 text-slate-500 border-slate-200" },
    };
    const config = statusConfig[status] || { label: status, class: "" };
    return <Badge variant="outline" className={cn("font-black uppercase text-[10px] px-3 py-1 rounded-lg", config.class)}>{config.label}</Badge>;
  };

  return (
    <div className="p-8 space-y-6 bg-[#f8fafc] min-h-screen font-sans">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-indigo-600 rounded-2xl shadow-xl shadow-indigo-100">
            <FileText className="h-7 w-7 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-black text-slate-900 uppercase italic tracking-tighter">Quản lý đơn hàng</h1>
            <p className="text-xs text-slate-400 font-bold uppercase tracking-widest">Hệ thống ghi nhận giao dịch</p>
          </div>
        </div>
        
        <Sheet open={isSheetOpen} onOpenChange={(open) => { setIsSheetOpen(open); if(!open) resetForm(); }}>
          <SheetTrigger asChild>
            <Button className="bg-indigo-600 hover:bg-indigo-700 h-14 px-8 rounded-2xl font-black uppercase shadow-lg transition-all active:scale-95">
              <Plus className="mr-2 h-6 w-6" /> Lên đơn mới
            </Button>
          </SheetTrigger>
          <SheetContent className="w-full sm:max-w-[700px] p-0 flex flex-col h-full border-none shadow-2xl">
            <SheetHeader className="p-8 bg-slate-900 text-white rounded-b-[2.5rem]">
              <SheetTitle className="text-white flex items-center gap-3 uppercase italic font-black text-2xl">
                <ShoppingBag className="h-8 w-8 text-indigo-400" /> Lên đơn hàng mới
              </SheetTitle>
            </SheetHeader>

            <div className="flex-1 overflow-hidden">
              <ScrollArea className="h-full px-8">
                <div className="py-8 space-y-8">
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div className="space-y-2">
                      <label className="text-[11px] font-black uppercase text-slate-400 flex items-center gap-2"><User className="h-3 w-3"/> ID Khách hàng *</label>
                      <Input 
                        type="number"
                        value={customerId} 
                        onChange={e => setCustomerId(e.target.value)}
                        placeholder="VD: 4" 
                        className="h-12 rounded-xl font-bold border-slate-200"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-[11px] font-black uppercase text-slate-400 flex items-center gap-2"><CreditCard className="h-3 w-3"/> Thanh toán</label>
                      <Select value={paymentType} onValueChange={(v: PaymentType) => setPaymentType(v)}>
                        <SelectTrigger className="h-12 rounded-xl font-bold border-slate-200">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="font-bold">
                          <SelectItem value="CASH">Tiền mặt</SelectItem>
                          <SelectItem value="BANK_TRANSFER">Chuyển khoản</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <label className="text-[11px] font-black uppercase text-slate-400 flex items-center gap-2"><Clock className="h-3 w-3"/> Trạng thái</label>
                      <Select value={orderStatus} onValueChange={(v: OrderStatus) => setOrderStatus(v)}>
                        <SelectTrigger className="h-12 rounded-xl font-bold border-slate-200">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="font-bold">
                          <SelectItem value="PENDING">Chờ xử lý</SelectItem>
                          <SelectItem value="CONFIRMED">Đã xác nhận</SelectItem>
                          <SelectItem value="PAID">Đã thanh toán</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-4">
                    <div className="flex justify-between items-end">
                      <label className="text-[11px] font-black uppercase text-slate-400 tracking-widest">Sản phẩm đơn hàng</label>
                      <Button onClick={handleAddItem} variant="ghost" size="sm" className="text-indigo-600 font-black text-[10px] uppercase">+ Thêm dòng</Button>
                    </div>
                    
                    {items.map((item, idx) => (
                      <div key={idx} className="group relative grid grid-cols-12 gap-3 bg-slate-50 p-4 rounded-2xl border border-slate-100 transition-all hover:border-indigo-200">
                        <div className="col-span-4 space-y-1">
                          <span className="text-[10px] font-black text-slate-400 uppercase">Mã SP</span>
                          <Input type="number" value={item.productId || ""} onChange={e => updateItem(idx, "productId", parseInt(e.target.value) || 0)} className="h-10 rounded-lg font-bold bg-white" />
                        </div>
                        <div className="col-span-5 space-y-1">
                          <span className="text-[10px] font-black text-slate-400 uppercase">Đơn giá</span>
                          <Input 
                            type="number" 
                            step="any"
                            value={item.unitPrice || ""} 
                            onChange={e => updateItem(idx, "unitPrice", parseFloat(e.target.value) || 0)} 
                            className="h-10 rounded-lg font-bold bg-white" 
                          />
                        </div>
                        <div className="col-span-2 space-y-1">
                          <span className="text-[10px] font-black text-slate-400 uppercase text-center block">SL</span>
                          <Input 
                            type="number" 
                            step="any"
                            value={item.quantity} 
                            onChange={e => updateItem(idx, "quantity", parseFloat(e.target.value) || 0)} 
                            className="h-10 rounded-lg font-bold text-center bg-white" 
                          />
                        </div>
                        <div className="col-span-1 flex items-end justify-end pb-1">
                          <Button disabled={items.length === 1} onClick={() => handleRemoveItem(idx)} variant="ghost" size="icon" className="h-8 w-8 text-rose-400 hover:text-rose-600 hover:bg-rose-50"><Trash2 className="h-4 w-4" /></Button>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="space-y-6 pt-4 border-t border-dashed">
                    <div className="flex justify-between items-center">
                      <label className="text-[11px] font-black uppercase text-slate-400 flex items-center gap-2"><Tag className="h-3 w-3"/> Giảm giá trực tiếp</label>
                      <div className="relative w-40">
                        <Input 
                          type="number" 
                          step="any"
                          value={discountAmount} 
                          onChange={e => setDiscountAmount(e.target.value)} 
                          className="h-11 rounded-xl font-black text-right pr-8 text-rose-600 border-slate-200" 
                        />
                        <span className="absolute right-3 top-1/2 -translate-y-1/2 font-bold text-slate-400 text-xs">đ</span>
                      </div>
                    </div>
                  </div>
                </div>
              </ScrollArea>
            </div>

            <SheetFooter className="p-8 bg-slate-50 border-t rounded-t-[3rem]">
              <div className="w-full space-y-4">
                <div className="flex justify-between items-center px-2">
                  <span className="font-bold text-slate-400 uppercase text-xs">Tổng tiền:</span>
                  <span className="font-black text-2xl text-indigo-600">{total.toLocaleString()}đ</span>
                </div>
                <Button disabled={createMutation.isPending} onClick={handleSaveOrder} className="w-full bg-indigo-600 h-16 rounded-2xl font-black uppercase text-lg shadow-xl">
                  {createMutation.isPending ? <Loader2 className="animate-spin mr-2" /> : "Xác nhận tạo đơn"}
                </Button>
              </div>
            </SheetFooter>
          </SheetContent>
        </Sheet>
      </div>

      {/* Filter Section */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 bg-white p-6 rounded-[2rem] shadow-sm border border-slate-100">
        <div className="relative">
          <User className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input placeholder="ID Khách hàng..." value={filterCustomerId} onChange={(e) => { setFilterCustomerId(e.target.value); setPage(0); }} className="pl-11 h-12 rounded-xl bg-slate-50 border-none font-bold" />
        </div>
        <Select value={filterStatus} onValueChange={(val) => { setFilterStatus(val); setPage(0); }}>
          <SelectTrigger className="h-12 rounded-xl bg-slate-50 border-none font-bold"><SelectValue placeholder="Trạng thái" /></SelectTrigger>
          <SelectContent className="font-bold">
            <SelectItem value="ALL">Tất cả</SelectItem>
            <SelectItem value="PENDING">Chờ xử lý</SelectItem>
            <SelectItem value="CONFIRMED">Đã xác nhận</SelectItem>
            <SelectItem value="PAID">Đã thanh toán</SelectItem>
          </SelectContent>
        </Select>
        <Popover>
          <PopoverTrigger asChild>
            <Button variant="outline" className="h-12 justify-start font-bold rounded-xl bg-slate-50 border-none">
              <CalendarIcon className="mr-2 h-4 w-4 text-slate-400" />
              {filterDate ? format(filterDate, "dd/MM/yyyy") : <span>Chọn ngày...</span>}
            </Button>
          </PopoverTrigger>
          <PopoverContent className="w-auto p-0" align="start">
            <Calendar mode="single" selected={filterDate} onSelect={(date) => { setFilterDate(date); setPage(0); }} />
          </PopoverContent>
        </Popover>
        <Button variant="ghost" onClick={handleResetFilters} className="h-12 text-rose-500 font-black uppercase text-[10px] tracking-widest"><FilterX className="mr-2 h-4 w-4" /> Xóa bộ lọc</Button>
      </div>

      {/* Table Section */}
      <Card className="border-none shadow-2xl rounded-[2.5rem] overflow-hidden bg-white">
        <CardContent className="p-0">
          {isLoading ? (
            <div className="p-32 flex flex-col items-center justify-center">
              <Loader2 className="h-14 w-14 animate-spin mb-6 text-indigo-500" />
              <p className="font-black uppercase text-[11px] tracking-[0.4em] text-slate-300">Đang đồng bộ...</p>
            </div>
          ) : (
            <>
              <Table>
                <TableHeader className="bg-slate-50/70">
                  <TableRow>
                    <TableHead className="font-black py-8 px-10 text-slate-500 uppercase text-[11px]">Mã đơn / Ngày tạo</TableHead>
                    <TableHead className="text-center font-black text-slate-500 uppercase text-[11px]">Khách hàng</TableHead>
                    <TableHead className="text-center font-black text-slate-500 uppercase text-[11px]">Trạng thái</TableHead>
                    <TableHead className="text-right font-black text-slate-500 uppercase text-[11px] px-10">Tổng tiền</TableHead>
                    <TableHead className="w-[80px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {!ordersRes?.result?.content?.length ? (
                    <TableRow><TableCell colSpan={5} className="py-20 text-center font-bold text-slate-400 uppercase text-xs">Không có dữ liệu</TableCell></TableRow>
                  ) : (
                    ordersRes.result.content.map((order: OrderDTO) => (
                      <TableRow key={order.id} className="group hover:bg-indigo-50/30 transition-all border-slate-50">
                        <TableCell className="px-10 py-7">
                          <div className="flex flex-col">
                            <span className="font-black text-base text-slate-900">{order.orderNumber}</span>
                            <span className="text-[11px] text-slate-400 flex items-center mt-2 font-bold uppercase"><Clock className="h-3.5 w-3.5 mr-2" /> {order.createdAt ? format(new Date(order.createdAt), "dd/MM/yyyy HH:mm") : "---"}</span>
                          </div>
                        </TableCell>
                        <TableCell className="text-center">
                          <span className="text-[10px] font-black text-slate-500 bg-slate-100 px-4 py-2 rounded-xl border border-slate-200">ID: {order.customerId}</span>
                        </TableCell>
                        <TableCell className="text-center">{renderStatusBadge(order.status)}</TableCell>
                        <TableCell className="text-right px-10 font-black text-indigo-600 text-xl">{order.totalAmount?.toLocaleString()}đ</TableCell>
                        <TableCell className="px-6 text-right">
                          <Button variant="ghost" size="icon" className="rounded-2xl hover:bg-white hover:shadow-lg"><Eye className="h-5 w-5 text-slate-300 group-hover:text-indigo-600" /></Button>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
              
              <div className="p-6 bg-slate-50/50 border-t flex items-center justify-between">
                <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">Trang {page + 1} / {ordersRes?.result?.totalPages || 1}</p>
                <div className="flex gap-2">
                  <Button variant="outline" size="icon" disabled={page === 0} onClick={() => setPage(p => p - 1)} className="rounded-xl h-10 w-10"><ChevronLeft className="h-4 w-4" /></Button>
                  <Button variant="outline" size="icon" disabled={page >= (ordersRes?.result?.totalPages || 1) - 1} onClick={() => setPage(p => p + 1)} className="rounded-xl h-10 w-10"><ChevronRight className="h-4 w-4" /></Button>
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  ); 
}