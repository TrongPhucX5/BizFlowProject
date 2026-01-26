"use client";

import { useState, useMemo, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { customerService, type Customer } from "@/services/customer.service1";
import { CustomerFormModal } from "./customer-form-modal";
import { CustomerDetailModal } from "./customer-detail-modal";
import { toast } from "sonner";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
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
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Plus,
  Users,
  CreditCard,
  Loader2,
  MoreHorizontal,
  Search,
  TrendingUp,
  UserCircle,
  Sparkles,
  ArrowRight,
  Trash2,
  Eye,
} from "lucide-react";

// --- 1. ĐỊNH NGHĨA KIỂU DỮ LIỆU PHÂN TRANG (Để hết gạch đỏ) ---
interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
  numberOfElements: number;
  last: boolean;
  first: boolean;
  empty: boolean;
}

export default function CustomerPage() {
  const queryClient = useQueryClient();

  const [modalOpen, setModalOpen] = useState(false);
  const [detailOpen, setDetailOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
  const [customerToDelete, setCustomerToDelete] = useState<Customer | null>(null);
  const [viewingCustomer, setViewingCustomer] = useState<Customer | null>(null);

  const [page, setPage] = useState(0);
  const [inputValue, setInputValue] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(inputValue);
      setPage(0); 
    }, 500);
    return () => clearTimeout(timer);
  }, [inputValue]);

  const {
    data: customersRes,
    isLoading,
    isPlaceholderData,
    isError
  } = useQuery({
    queryKey: ["customers-list", page, debouncedSearch],
    queryFn: () => customerService.getCustomers({ page, size: 10, search: debouncedSearch }),
    placeholderData: (previousData) => previousData,
  });

  // --- 2. TRÍCH XUẤT DỮ LIỆU VỚI ÉP KIỂU AN TOÀN ---
  // Ép kiểu result sang PageResponse để truy cập .content, .last, .numberOfElements
  const pageData = customersRes?.result as unknown as PageResponse<Customer>;
  const customerList = pageData?.content || [];

  const stats = useMemo(() => {
    return {
      totalCount: pageData?.totalElements || 0,
      totalDebt: customerList.reduce((sum, c) => sum + (Number(c.totalDebt) || 0), 0),
      totalSales: customerList.reduce((sum, c) => sum + (Number(c.totalPurchaseAmount) || 0), 0),
      newCount: pageData?.numberOfElements || 0,
      isLast: pageData?.last ?? true
    };
  }, [pageData, customerList]);

  const deleteMutation = useMutation({
    mutationFn: (id: number) => customerService.deleteCustomer(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      toast.success("Đã xóa khách hàng thành công");
      setDeleteDialogOpen(false);
    },
    onError: (error: any) => {
      toast.error(error?.response?.data?.message || "Không thể xóa khách hàng");
    },
  });

  return (
    <div className="p-8 space-y-8 bg-[#f8fafc] min-h-screen font-sans">
      {/* Header Section */}
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-6">
        <div className="space-y-1">
          <h1 className="text-3xl font-black text-slate-900 uppercase tracking-tight">Đối tác & Khách hàng</h1>
          <p className="text-sm text-slate-500 font-medium flex items-center gap-2">
            <Users className="h-4 w-4 text-indigo-500" /> Quản lý thông tin và công nợ đối tác chuyên nghiệp
          </p>
        </div>

        <div className="flex flex-wrap gap-3 w-full lg:w-auto">
          <div className="relative flex-1 md:w-80 group">
            <Search className={`absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 ${inputValue ? "text-indigo-600" : "text-slate-400"}`} />
            <Input
              placeholder="Tìm tên, số điện thoại..."
              className="pl-10 bg-white border-slate-200 h-11 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-500/20"
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
            />
          </div>
          <Button
            className="bg-indigo-600 hover:bg-indigo-700 h-11 px-8 rounded-xl font-bold shadow-lg shadow-indigo-200"
            onClick={() => { setSelectedCustomer(null); setModalOpen(true); }}
          >
            <Plus className="mr-2 h-5 w-5" /> THÊM MỚI
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div className="lg:col-span-3 space-y-8">
          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <StatCard title="Tổng đối tác" value={stats.totalCount.toLocaleString()} icon={<Users className="text-blue-600" />} />
            <StatCard title="Nợ phải thu" value={`${stats.totalDebt.toLocaleString()}đ`} icon={<CreditCard className="text-rose-600" />} alert={stats.totalDebt > 0} />
            <StatCard title="Doanh số tổng" value={`${stats.totalSales.toLocaleString()}đ`} icon={<TrendingUp className="text-emerald-600" />} />
          </div>

          {/* Table Section */}
          <Card className="border-none shadow-xl bg-white overflow-hidden rounded-2xl relative">
            {(isLoading || isPlaceholderData) && (
              <div className="absolute inset-0 bg-white/60 z-20 flex items-center justify-center backdrop-blur-[1px]">
                <Loader2 className="h-10 w-10 animate-spin text-indigo-600" />
              </div>
            )}
            <CardContent className="p-0">
              <Table>
                <TableHeader className="bg-slate-50/50">
                  <TableRow>
                    <TableHead className="font-bold py-5 px-6 text-slate-600 uppercase text-[11px]">Khách hàng</TableHead>
                    <TableHead className="font-bold text-center text-slate-600 uppercase text-[11px]">Phân loại</TableHead>
                    <TableHead className="font-bold text-right text-slate-600 uppercase text-[11px]">Tổng mua</TableHead>
                    <TableHead className="font-bold text-right text-slate-600 uppercase text-[11px]">Công nợ</TableHead>
                    <TableHead className="w-[80px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {isError ? (
                    <TableRow><TableCell colSpan={5} className="text-center py-20 text-rose-500 font-bold">Lỗi tải dữ liệu!</TableCell></TableRow>
                  ) : customerList.length === 0 && !isLoading ? (
                    <TableRow><TableCell colSpan={5} className="text-center py-20 text-slate-400 font-medium">Không tìm thấy khách hàng nào.</TableCell></TableRow>
                  ) : (
                    customerList.map((item) => (
                      <TableRow key={item.id} className="group hover:bg-indigo-50/30 transition-colors border-b border-slate-50">
                        <TableCell className="px-6 py-4">
                          <div className="flex items-center gap-4">
                            <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center text-white font-black text-sm">
                              {item.fullName?.charAt(0).toUpperCase()}
                            </div>
                            <div className="flex flex-col">
                              <span className="font-bold text-sm text-slate-900 uppercase cursor-pointer hover:text-indigo-600" onClick={() => {setViewingCustomer(item); setDetailOpen(true);}}>
                                {item.fullName}
                              </span>
                              <span className="text-[11px] text-slate-500 font-medium">{item.phone}</span>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell className="text-center">
                          <Badge className={`px-2.5 py-1 rounded-lg text-[10px] font-black uppercase border-none ${item.type === "WHOLESALE" ? "bg-slate-900 text-white" : "bg-indigo-100 text-indigo-700"}`}>
                            {item.type === "WHOLESALE" ? "Sỉ" : "Lẻ"}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right font-semibold text-sm">{(Number(item.totalPurchaseAmount) || 0).toLocaleString()}đ</TableCell>
                        <TableCell className="text-right">
                          <span className={`font-black text-sm ${Number(item.totalDebt) > 0 ? "text-rose-600" : "text-slate-400"}`}>
                            {(Number(item.totalDebt) || 0).toLocaleString()}đ
                          </span>
                        </TableCell>
                        <TableCell className="px-6">
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon" className="h-9 w-9 rounded-xl"><MoreHorizontal className="h-5 w-5 text-slate-400" /></Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end" className="w-52 p-2 rounded-xl shadow-xl">
                              <DropdownMenuItem className="rounded-lg font-bold text-sm py-2.5 text-indigo-600 bg-indigo-50/50 mb-1 cursor-pointer" onClick={() => { setViewingCustomer(item); setDetailOpen(true); }}><Eye className="mr-2 h-4 w-4" /> Xem chi tiết</DropdownMenuItem>
                              <DropdownMenuItem className="rounded-lg font-bold text-sm py-2.5 cursor-pointer" onClick={() => { setSelectedCustomer(item); setModalOpen(true); }}><UserCircle className="mr-2 h-4 w-4 text-slate-500" /> Chỉnh sửa</DropdownMenuItem>
                              <DropdownMenuItem className="text-rose-600 rounded-lg font-bold text-sm py-2.5 hover:!bg-rose-50 cursor-pointer" onClick={() => { setCustomerToDelete(item); setDeleteDialogOpen(true); }}><Trash2 className="mr-2 h-4 w-4" /> Xóa</DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>

              {/* Phân trang */}
              <div className="p-6 border-t border-slate-50 flex items-center justify-between bg-slate-50/30">
                <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Trang {page + 1}</p>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" className="font-bold" disabled={page === 0} onClick={() => setPage((p) => p - 1)}>TRƯỚC</Button>
                  <Button variant="outline" size="sm" className="font-bold" disabled={stats.isLast} onClick={() => setPage((p) => p + 1)}>SAU</Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* AI Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          <Card className="border-none shadow-2xl bg-indigo-900 text-white overflow-hidden rounded-2xl p-6">
            <h2 className="text-sm font-black tracking-widest uppercase mb-4 flex items-center gap-2"><Sparkles className="h-4 w-4 text-yellow-300" /> AI Insights</h2>
            <div className="space-y-4">
              <div className="bg-white/10 rounded-xl p-4 text-xs italic leading-relaxed">
                Phân tích: {stats.totalCount} khách hàng. {stats.totalDebt > 0 ? "Cần chú ý thu hồi nợ." : "Chỉ số an toàn."}
              </div>
              <Button className="w-full bg-white text-indigo-900 hover:bg-indigo-50 font-black text-xs h-11 rounded-xl shadow-lg">PHÂN TÍCH SÂU <ArrowRight className="ml-2 h-4 w-4" /></Button>
            </div>
          </Card>

          <div className="bg-indigo-50/50 p-6 rounded-2xl border border-indigo-100">
            <h3 className="text-[10px] font-black text-indigo-900 uppercase tracking-widest mb-3">Thông tin nhanh</h3>
            <div className="space-y-3">
              <div className="flex justify-between text-xs font-medium">
                <span className="text-slate-500">Mới thêm (trang):</span>
                <span className="text-indigo-600 font-bold">+{stats.newCount}</span>
              </div>
              <div className="flex justify-between text-xs font-medium">
                <span className="text-slate-500">Tỷ lệ nợ/doanh số:</span>
                <span className="text-rose-600 font-bold">{stats.totalSales > 0 ? ((stats.totalDebt / stats.totalSales) * 100).toFixed(1) : 0}%</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <CustomerFormModal isOpen={modalOpen} onClose={() => setModalOpen(false)} customer={selectedCustomer} />
      <CustomerDetailModal isOpen={detailOpen} onClose={() => setDetailOpen(false)} customer={viewingCustomer} />

      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent className="rounded-3xl p-8 max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-2xl font-black uppercase text-center text-slate-900">Xác nhận xóa?</AlertDialogTitle>
            <AlertDialogDescription className="text-center font-medium py-2">Xóa đối tác <span className="text-indigo-600 font-bold">"{customerToDelete?.fullName}"</span>?</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-6 flex gap-3 sm:justify-center">
            <AlertDialogCancel className="flex-1 rounded-xl font-bold h-12">HỦY BỎ</AlertDialogCancel>
            <AlertDialogAction onClick={() => customerToDelete && deleteMutation.mutate(customerToDelete.id)} className="flex-1 rounded-xl font-bold bg-rose-600 h-12 hover:bg-rose-700">XÁC NHẬN</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

function StatCard({ title, value, icon, alert }: { title: string; value: string; icon: React.ReactNode; alert?: boolean }) {
  return (
    <Card className="border-none shadow-lg bg-white rounded-2xl overflow-hidden hover:shadow-indigo-100 transition-all group">
      <CardContent className="p-6 flex justify-between items-center">
        <div>
          <p className="text-[10px] font-black text-slate-400 uppercase mb-1 tracking-wider">{title}</p>
          <h3 className={`text-2xl font-black tracking-tight ${alert ? "text-rose-600" : "text-slate-900"}`}>{value}</h3>
        </div>
        <div className="p-3 bg-slate-50 rounded-xl group-hover:bg-indigo-50 transition-colors">{icon}</div>
      </CardContent>
    </Card>
  );
}