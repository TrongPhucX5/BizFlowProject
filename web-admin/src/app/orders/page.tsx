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
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetFooter } from "@/components/ui/sheet";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { 
  Plus, FileText, Loader2, Clock, Trash2, ShoppingBag, 
  User, CreditCard, Edit3, ChevronLeft, ChevronRight
} from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
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

// Hook để tránh gọi API liên tục khi gõ filter
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
  
  // --- QUẢN LÝ TRẠNG THÁI SHEET & DIALOG ---
  const [isSheetOpen, setIsSheetOpen] = useState(false);
  const [editingOrderId, setEditingOrderId] = useState<number | null>(null);
  const [orderToDelete, setOrderToDelete] = useState<number | null>(null);

  // --- STATE BỘ LỌC ---
  const [filterStatus, setFilterStatus] = useState<string>("ALL");
  const [filterCustomerId, setFilterCustomerId] = useState<string>("");
  const debouncedCustomerId = useDebounce(filterCustomerId, 500);

  // --- STATE FORM ---
  const [customerId, setCustomerId] = useState<string>("");
  const [discountAmount, setDiscountAmount] = useState<string>("0");
  const [paymentType, setPaymentType] = useState<PaymentType>("CASH");
  const [orderStatus, setOrderStatus] = useState<OrderStatus>("PAID");
  const [notes, setNotes] = useState<string>("");
  const [items, setItems] = useState<OrderItemUI[]>([{ productId: 0, quantity: 1, unitPrice: 0 }]);

  // --- QUERIES ---
  const { data: ordersRes, isLoading } = useQuery({
    queryKey: ["orders-list", page, debouncedCustomerId, filterStatus],
    queryFn: () => orderService.getAllOrders({ 
        page, 
        size: 10, 
        sort: "createdAt,desc",
        status: filterStatus === "ALL" ? undefined : filterStatus,
        customerId: debouncedCustomerId ? Number(debouncedCustomerId) : undefined
    }),
  });

  // --- MUTATIONS ---
  const createMutation = useMutation({
    mutationFn: (data: CreateOrderRequest) => orderService.createOrder(data),
    onSuccess: () => {
      toast.success("Tạo đơn hàng thành công!");
      handleCloseSheet();
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
    },
    onError: (error: any) => toast.error(error.response?.data?.message || "Lỗi khi tạo đơn hàng")
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number, data: CreateOrderRequest }) => orderService.updateOrder(id, data),
    onSuccess: () => {
      toast.success("Cập nhật đơn hàng thành công!");
      handleCloseSheet();
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
    },
    onError: (error: any) => toast.error(error.response?.data?.message || "Lỗi khi cập nhật")
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => orderService.deleteOrder(id),
    onSuccess: () => {
      toast.success("Đã hủy đơn hàng và hoàn kho");
      setOrderToDelete(null);
      queryClient.invalidateQueries({ queryKey: ["orders-list"] });
    },
    onError: () => toast.error("Không thể hủy đơn hàng này")
  });

  // --- LOGIC HANDLERS ---
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
    setItems(order.items.map(i => ({
      productId: i.productId,
      quantity: i.quantity,
      unitPrice: i.unitPrice
    })));
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

  const handleSaveOrder = () => {
    const validItems = items.filter(i => i.productId > 0 && i.quantity > 0);
    if (!customerId) return toast.error("Vui lòng nhập ID khách hàng");
    if (validItems.length === 0) return toast.error("Vui lòng thêm ít nhất 1 sản phẩm");

    const payload: CreateOrderRequest = {
      customerId: Number(customerId),
      discountAmount: Number(discountAmount),
      paymentType,
      status: orderStatus,
      notes: notes.trim(),
      items: validItems
    };

    if (editingOrderId) {
      updateMutation.mutate({ id: editingOrderId, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const calculateSubtotal = () => items.reduce((sum, i) => sum + (i.unitPrice * i.quantity), 0);
  const total = calculateSubtotal() - Number(discountAmount);

  const renderStatusBadge = (status: OrderStatus) => {
    const statusConfig: Record<OrderStatus, { label: string, class: string }> = {
      CONFIRMED: { label: "Đã xác nhận", class: "bg-blue-50 text-blue-600 border-blue-200" },
      PAID: { label: "Đã thanh toán", class: "bg-emerald-50 text-emerald-600 border-emerald-200" },
      PAID_PARTIAL: { label: "Một phần", class: "bg-amber-50 text-amber-600 border-amber-200" },
      UNPAID: { label: "Chưa trả", class: "bg-rose-50 text-rose-600 border-rose-200" },
      CANCELLED: { label: "Đã hủy", class: "bg-slate-100 text-slate-500 border-slate-300" },
    };
    const config = statusConfig[status];
    return (
      <Badge variant="outline" className={cn("font-black uppercase text-[10px] px-3 py-1 rounded-lg border", config?.class)}>
        {config?.label || status}
      </Badge>
    );
  };

  return (
    <div className="p-8 space-y-6 bg-[#f8fafc] min-h-screen font-sans">
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-indigo-600 rounded-2xl shadow-xl">
            <FileText className="h-7 w-7 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-black text-slate-900 uppercase italic tracking-tighter">Hệ thống Đơn hàng</h1>
            <p className="text-xs text-slate-400 font-bold uppercase tracking-widest">Giao dịch & Tồn kho</p>
          </div>
        </div>
        
        <Button onClick={handleOpenCreate} className="bg-indigo-600 hover:bg-indigo-700 h-14 px-8 rounded-2xl font-black uppercase shadow-lg transition-all active:scale-95">
          <Plus className="mr-2 h-6 w-6" /> Lên đơn mới
        </Button>
      </div>

      <Sheet open={isSheetOpen} onOpenChange={(open) => !open && handleCloseSheet()}>
        <SheetContent className="w-full sm:max-w-[700px] p-0 flex flex-col h-full border-none shadow-2xl">
          <SheetHeader className={cn("p-8 text-white rounded-b-[2.5rem]", editingOrderId ? "bg-orange-600" : "bg-slate-900")}>
            <SheetTitle className="text-white flex items-center gap-3 uppercase italic font-black text-2xl">
              {editingOrderId ? <Edit3 className="h-8 w-8 text-orange-200" /> : <ShoppingBag className="h-8 w-8 text-indigo-400" />}
              {editingOrderId ? `Cập nhật đơn #${editingOrderId}` : "Lên đơn hàng mới"}
            </SheetTitle>
          </SheetHeader>

          <div className="flex-1 overflow-hidden">
            <ScrollArea className="h-full px-8">
              <div className="py-8 space-y-8">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <label className="text-[11px] font-black uppercase text-slate-400 flex items-center gap-2"><User className="h-3 w-3"/> ID Khách *</label>
                    <Input type="number" value={customerId} onChange={e => setCustomerId(e.target.value)} placeholder="VD: 4" className="h-12 rounded-xl font-bold border-slate-200" />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[11px] font-black uppercase text-slate-400 flex items-center gap-2"><CreditCard className="h-3 w-3"/> Hình thức</label>
                    <Select value={paymentType} onValueChange={(v: PaymentType) => setPaymentType(v)}>
                      <SelectTrigger className="h-12 rounded-xl font-bold border-slate-200"><SelectValue /></SelectTrigger>
                      <SelectContent className="font-bold">
                        <SelectItem value="CASH">Tiền mặt</SelectItem>
                        <SelectItem value="TRANSFER">Chuyển khoản</SelectItem>
                        <SelectItem value="CREDIT">Thẻ</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <label className="text-[11px] font-black uppercase text-slate-400 flex items-center gap-2"><Clock className="h-3 w-3"/> Trạng thái</label>
                    <Select value={orderStatus} onValueChange={(v: OrderStatus) => setOrderStatus(v)}>
                      <SelectTrigger className="h-12 rounded-xl font-bold border-slate-200"><SelectValue /></SelectTrigger>
                      <SelectContent className="font-bold">
                        <SelectItem value="PAID">Đã thanh toán</SelectItem>
                        <SelectItem value="CONFIRMED">Xác nhận</SelectItem>
                        <SelectItem value="UNPAID">Chưa trả</SelectItem>
                        <SelectItem value="CANCELLED">Hủy đơn</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex justify-between items-end border-b pb-2 border-slate-100">
                    <label className="text-[11px] font-black uppercase text-slate-400">Danh sách mặt hàng</label>
                    <Button onClick={() => setItems([...items, { productId: 0, quantity: 1, unitPrice: 0 }])} variant="ghost" size="sm" className="text-indigo-600 font-black text-[10px] uppercase">+ Thêm hàng</Button>
                  </div>
                  {items.map((item, idx) => (
                    <div key={idx} className="group grid grid-cols-12 gap-3 bg-slate-50 p-4 rounded-2xl border border-slate-100 transition-all hover:border-indigo-200">
                      <div className="col-span-4 space-y-1">
                        <span className="text-[10px] font-black text-slate-400 uppercase">Mã SP</span>
                        <Input type="number" value={item.productId || ""} onChange={e => {
                          const newItems = [...items];
                          newItems[idx].productId = parseInt(e.target.value) || 0;
                          setItems(newItems);
                        }} className="h-10 rounded-lg font-bold bg-white" />
                      </div>
                      <div className="col-span-4 space-y-1">
                        <span className="text-[10px] font-black text-slate-400 uppercase">Giá bán</span>
                        <Input type="number" value={item.unitPrice || ""} onChange={e => {
                          const newItems = [...items];
                          newItems[idx].unitPrice = parseFloat(e.target.value) || 0;
                          setItems(newItems);
                        }} className="h-10 rounded-lg font-bold bg-white" />
                      </div>
                      <div className="col-span-3 space-y-1">
                        <span className="text-[10px] font-black text-slate-400 uppercase text-center block">SL</span>
                        <Input type="number" value={item.quantity} onChange={e => {
                          const newItems = [...items];
                          newItems[idx].quantity = parseFloat(e.target.value) || 0;
                          setItems(newItems);
                        }} className="h-10 rounded-lg font-bold text-center bg-white" />
                      </div>
                      <div className="col-span-1 flex items-end justify-end pb-1">
                        <Button disabled={items.length === 1} onClick={() => setItems(items.filter((_, i) => i !== idx))} variant="ghost" size="icon" className="h-8 w-8 text-rose-400 hover:text-rose-600"><Trash2 className="h-4 w-4" /></Button>
                      </div>
                    </div>
                  ))}
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
              <Button 
                disabled={createMutation.isPending || updateMutation.isPending} 
                onClick={handleSaveOrder} 
                className={cn("w-full h-16 rounded-2xl font-black uppercase text-lg shadow-xl", editingOrderId ? "bg-orange-600 hover:bg-orange-700 shadow-orange-100" : "bg-indigo-600 hover:bg-indigo-700 shadow-indigo-100")}
              >
                {(createMutation.isPending || updateMutation.isPending) ? <Loader2 className="animate-spin mr-2" /> : editingOrderId ? "Lưu cập nhật" : "Xác nhận tạo đơn"}
              </Button>
            </div>
          </SheetFooter>
        </SheetContent>
      </Sheet>

      <Card className="border-none shadow-2xl rounded-[2.5rem] overflow-hidden bg-white">
        <CardContent className="p-0">
          {isLoading ? (
            <div className="p-32 flex flex-col items-center justify-center"><Loader2 className="h-14 w-14 animate-spin mb-6 text-indigo-500" /></div>
          ) : (
            <>
              <Table>
                <TableHeader className="bg-slate-50/70">
                  <TableRow>
                    <TableHead className="font-black py-8 px-10 text-slate-500 uppercase text-[11px]">Đơn hàng</TableHead>
                    <TableHead className="text-center font-black text-slate-500 uppercase text-[11px]">Khách hàng</TableHead>
                    <TableHead className="text-center font-black text-slate-500 uppercase text-[11px]">Trạng thái</TableHead>
                    <TableHead className="text-right font-black text-slate-500 uppercase text-[11px] px-10">Tổng tiền</TableHead>
                    <TableHead className="w-[150px] font-black text-slate-500 uppercase text-[11px] text-center">Thao tác</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {ordersRes?.result?.content?.map((order: OrderDTO) => (
                    <TableRow key={order.id} className="group hover:bg-indigo-50/30 transition-all border-slate-50">
                      <TableCell className="px-10 py-7">
                        <div className="flex flex-col">
                          <span className="font-black text-base text-slate-900">{order.orderNumber}</span>
                          <span className="text-[11px] text-slate-400 flex items-center mt-2 font-bold uppercase tracking-tighter">
                            <Clock className="h-3.5 w-3.5 mr-2" /> {format(new Date(order.createdAt), "dd/MM/yyyy HH:mm")}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="text-center font-bold text-slate-600 underline decoration-indigo-200 underline-offset-4">ID: {order.customerId}</TableCell>
                      <TableCell className="text-center">{renderStatusBadge(order.status)}</TableCell>
                      <TableCell className="text-right px-10 font-black text-indigo-600 text-xl">{order.totalAmount?.toLocaleString()}đ</TableCell>
                      <TableCell className="px-6">
                        <div className="flex items-center justify-center gap-2">
                          <Button variant="ghost" size="icon" onClick={() => handleEdit(order)} className="rounded-xl hover:bg-orange-50 hover:text-orange-600 transition-colors">
                            <Edit3 className="h-4 w-4" />
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            onClick={() => setOrderToDelete(order.id)} 
                            disabled={order.status === 'CANCELLED'}
                            className="rounded-xl hover:bg-rose-50 hover:text-rose-600 transition-colors"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
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

      <AlertDialog open={!!orderToDelete} onOpenChange={() => setOrderToDelete(null)}>
        <AlertDialogContent className="rounded-[2rem] border-none shadow-2xl">
          <AlertDialogHeader>
            <AlertDialogTitle className="font-black uppercase italic text-2xl text-slate-900">Xác nhận hủy đơn?</AlertDialogTitle>
            <AlertDialogDescription className="font-medium text-slate-500">
              Hành động này sẽ hủy đơn hàng và **tự động hoàn trả số lượng sản phẩm** vào lại kho hàng. Bạn không thể hoàn tác.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="gap-3">
            <AlertDialogCancel className="rounded-xl font-bold uppercase text-[11px]">Quay lại</AlertDialogCancel>
            <AlertDialogAction 
              onClick={() => orderToDelete && deleteMutation.mutate(orderToDelete)}
              className="rounded-xl bg-rose-600 hover:bg-rose-700 font-black uppercase text-[11px] shadow-lg shadow-rose-100"
            >
              Hủy đơn & Hoàn kho
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  ); 
}