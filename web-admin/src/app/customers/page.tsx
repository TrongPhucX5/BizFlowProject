"use client";

import { useState, useMemo, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { customerService, type Customer } from "@/services/customer.service";
import { CustomerFormModal } from "./customer-form-modal";
import { toast } from "sonner";
import { Card, CardContent } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { 
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, 
  AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle 
} from "@/components/ui/alert-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { 
  Plus, Users, CreditCard, Loader2, MoreHorizontal, Search, X, Mail,
  Phone, TrendingUp, UserCircle, Sparkles, ArrowRight, AlertCircle, Trash2, ChevronLeft, ChevronRight, Hash 
} from "lucide-react";

export default function CustomerPage() {
  const queryClient = useQueryClient();
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [customerToDelete, setCustomerToDelete] = useState<Customer | null>(null);

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

  const { data: customersRes, isLoading, isPlaceholderData } = useQuery({
    queryKey: ["customers-list", page, debouncedSearch],
    queryFn: () => customerService.getCustomers({ page, size: 10, search: debouncedSearch }),
    placeholderData: (previousData) => previousData,
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => customerService.deleteCustomer(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      toast.success("Đã xóa khách hàng thành công");
      setDeleteDialogOpen(false);
      setCustomerToDelete(null);
    },
    onError: (error: any) => {
      toast.error(error?.response?.data?.message || "Không thể xóa khách hàng này");
    }
  });

  const confirmDelete = () => {
    if (customerToDelete) {
      deleteMutation.mutate(customerToDelete.id);
    }
  };

  const stats = useMemo(() => {
    const totalCount = customersRes?.result?.totalElements || 0;
    const content = customersRes?.result?.content || [];
    const totalDebt = content.reduce((sum, c) => sum + (Number(c.totalDebt) || 0), 0);
    const totalSales = content.reduce((sum, c) => sum + (Number(c.totalPurchaseAmount) || 0), 0);
    return { totalCount, totalDebt, totalSales };
  }, [customersRes]);

  return (
    <div className="p-8 space-y-8 bg-[#f8fafc] min-h-screen font-sans">
      {/* Header & Search */}
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-6">
        <div className="space-y-1">
          <h1 className="text-3xl font-black text-slate-900 uppercase tracking-tight">Đối tác & Khách hàng</h1>
          <p className="text-sm text-slate-500 font-medium flex items-center gap-2">
            <Users className="h-4 w-4 text-indigo-500" /> 
            Quản lý thông tin, công nợ và phân loại nhóm đối tác kinh doanh
          </p>
        </div>
        
        <div className="flex flex-wrap gap-3 w-full lg:w-auto">
          <div className="relative flex-1 md:w-80 group">
            <Search className={`absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 transition-colors ${inputValue ? 'text-indigo-600' : 'text-slate-400'}`} />
            <Input 
              placeholder="Tìm tên, SĐT hoặc Email..." 
              className="pl-10 bg-white border-slate-200 h-11 text-sm rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-500/20 transition-all"
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
            />
            {inputValue && (
              <X className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 cursor-pointer hover:text-rose-500 transition-colors" 
                 onClick={() => setInputValue("")} />
            )}
          </div>
          <Button className="bg-indigo-600 hover:bg-indigo-700 h-11 px-8 rounded-xl font-bold shadow-lg shadow-indigo-200 transition-all active:scale-95" 
                  onClick={() => { setSelectedCustomer(null); setModalOpen(true); }}>
            <Plus className="mr-2 h-5 w-5" /> THÊM MỚI
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div className="lg:col-span-3 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <StatCard title="Tổng đối tác" value={stats.totalCount.toLocaleString()} icon={<Users className="text-blue-600" />} />
            <StatCard title="Nợ phải thu" value={`${stats.totalDebt.toLocaleString()}đ`} icon={<CreditCard className="text-rose-600" />} alert={stats.totalDebt > 0} />
            <StatCard title="Doanh số tổng" value={`${stats.totalSales.toLocaleString()}đ`} icon={<TrendingUp className="text-emerald-600" />} />
          </div>

          <Card className="border-none shadow-xl shadow-slate-200/50 bg-white overflow-hidden rounded-2xl relative">
            {(isLoading || isPlaceholderData) && (
              <div className="absolute inset-0 bg-white/60 z-20 flex items-center justify-center backdrop-blur-[1px]">
                <div className="flex flex-col items-center gap-3">
                    <Loader2 className="h-10 w-10 animate-spin text-indigo-600" />
                    <span className="text-xs font-bold text-indigo-600 uppercase tracking-widest">Đang tải dữ liệu...</span>
                </div>
              </div>
            )}
            <CardContent className="p-0">
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader className="bg-slate-50/50 border-b border-slate-100">
                    <TableRow>
                      <TableHead className="font-bold py-5 px-6 text-slate-600 uppercase text-[11px] tracking-wider">Thông tin khách hàng</TableHead>
                      <TableHead className="font-bold text-center text-slate-600 uppercase text-[11px] tracking-wider">Phân loại</TableHead>
                      <TableHead className="font-bold text-right text-slate-600 uppercase text-[11px] tracking-wider">Tổng mua</TableHead>
                      <TableHead className="font-bold text-right text-slate-600 uppercase text-[11px] tracking-wider">Công nợ</TableHead>
                      <TableHead className="w-[80px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {customersRes?.result?.content.map((item) => (
                      <TableRow key={item.id} className="group hover:bg-indigo-50/30 transition-colors border-b border-slate-50 last:border-0">
                        <TableCell className="px-6 py-4">
                          <div className="flex items-center gap-4">
                            <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center text-white font-black text-sm shadow-md shadow-indigo-100 uppercase transition-transform group-hover:scale-110">
                              {item.fullName?.charAt(0)}
                            </div>
                            <div className="flex flex-col gap-1">
                              <div className="flex items-center gap-2">
                                <span className="font-bold text-sm text-slate-900 uppercase tracking-tight group-hover:text-indigo-600 transition-colors">
                                  {item.fullName}
                                </span>
                                {/* ID KHÁCH HÀNG HIỂN THỊ TẠI ĐÂY */}
                                <Badge variant="secondary" className="bg-slate-100 text-slate-500 hover:bg-indigo-100 hover:text-indigo-600 border-none px-1.5 py-0 text-[10px] font-bold rounded-md transition-colors">
                                  ID: {item.id}
                                </Badge>
                              </div>
                              <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                                <div className="flex items-center text-[11px] text-slate-500 font-medium">
                                  <Phone className="h-3 w-3 mr-1 text-slate-400" /> {item.phone}
                                </div>
                                {item.email && (
                                  <div className="flex items-center text-[11px] text-indigo-500 font-medium">
                                    <Mail className="h-3 w-3 mr-1 text-indigo-400" /> {item.email}
                                  </div>
                                )}
                              </div>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell className="text-center">
                          <Badge className={`px-2.5 py-1 rounded-lg text-[10px] font-black uppercase tracking-tighter ${
                            item.type === 'WHOLESALE' 
                            ? 'bg-slate-900 text-white hover:bg-slate-800' 
                            : 'bg-indigo-100 text-indigo-700 hover:bg-indigo-200 border-none'
                          }`}>
                            {item.type}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right font-semibold text-slate-700 text-sm">
                          {(Number(item.totalPurchaseAmount) || 0).toLocaleString()}đ
                        </TableCell>
                        <TableCell className="text-right">
                           <span className={`font-black text-sm ${item.totalDebt > 0 ? 'text-rose-600' : 'text-slate-400'}`}>
                             {(Number(item.totalDebt) || 0).toLocaleString()}đ
                           </span>
                        </TableCell>
                        <TableCell className="px-6">
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon" className="h-9 w-9 rounded-xl hover:bg-white hover:shadow-md transition-all">
                                <MoreHorizontal className="h-5 w-5 text-slate-400" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end" className="w-48 p-2 rounded-xl border-slate-100 shadow-xl">
                              <DropdownMenuItem className="rounded-lg font-bold text-sm py-2.5 cursor-pointer" onClick={() => { setSelectedCustomer(item); setModalOpen(true); }}>
                                <UserCircle className="mr-2 h-4 w-4 text-indigo-500" /> Chỉnh sửa
                              </DropdownMenuItem>
                              <DropdownMenuItem className="text-rose-600 rounded-lg font-bold text-sm py-2.5 cursor-pointer hover:!bg-rose-50" onClick={() => { setCustomerToDelete(item); setDeleteDialogOpen(true); }}>
                                <Trash2 className="mr-2 h-4 w-4" /> Xóa đối tác
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>

              <div className="p-6 border-t border-slate-50 flex items-center justify-between bg-slate-50/30">
                <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                  Trang {page + 1} <span className="mx-2 text-slate-200">|</span> Hiển thị {customersRes?.result?.content.length || 0} đối tác
                </p>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" disabled={page === 0} onClick={() => setPage(p => p - 1)} className="h-9 px-4 rounded-lg font-bold border-slate-200 text-slate-600 hover:bg-white hover:border-indigo-500 hover:text-indigo-600 transition-all">
                    <ChevronLeft className="h-4 w-4 mr-1" /> TRƯỚC
                  </Button>
                  <Button variant="outline" size="sm" disabled={!!(customersRes?.result as any)?.last} onClick={() => setPage(p => p + 1)} className="h-9 px-4 rounded-lg font-bold border-slate-200 text-slate-600 hover:bg-white hover:border-indigo-500 hover:text-indigo-600 transition-all">
                    SAU <ChevronRight className="h-4 w-4 ml-1" />
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="lg:col-span-1 space-y-6">
          <Card className="border-none shadow-2xl bg-gradient-to-br from-indigo-700 via-indigo-900 to-slate-900 text-white overflow-hidden relative group rounded-2xl">
            <div className="absolute top-0 right-0 p-8 opacity-10 group-hover:opacity-20 transition-all duration-500 group-hover:rotate-12 group-hover:scale-125">
              <Sparkles className="h-32 w-32" />
            </div>
            <CardContent className="p-6 relative z-10">
              <div className="flex items-center gap-3 mb-6">
                <div className="p-2 bg-white/10 rounded-xl backdrop-blur-md border border-white/20">
                  <Sparkles className="h-5 w-5 text-yellow-300 shadow-sm" />
                </div>
                <h2 className="text-sm font-black tracking-[0.2em] uppercase">Phân tích AI</h2>
              </div>
              <div className="space-y-6">
                <div className="bg-white/5 backdrop-blur-xl rounded-2xl p-4 border border-white/10 shadow-inner">
                  <p className="text-xs leading-relaxed italic text-indigo-100/90 font-medium">
                    "Hệ thống phát hiện <span className="text-yellow-300 font-black underline decoration-indigo-500 underline-offset-4">2 khách hàng sỉ</span> đang có dấu hiệu giảm doanh số."
                  </p>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-black/20 p-3 rounded-xl border border-white/5 flex flex-col gap-1">
                    <TrendingUp className="h-4 w-4 text-emerald-400" />
                    <span className="text-[9px] text-indigo-200 uppercase font-black tracking-widest">Tăng trưởng</span>
                    <span className="text-xs font-black text-white">+5.2%</span>
                  </div>
                  <div className="bg-black/20 p-3 rounded-xl border border-white/5 flex flex-col gap-1">
                    <AlertCircle className="h-4 w-4 text-rose-400" />
                    <span className="text-[9px] text-indigo-200 uppercase font-black tracking-widest">Rủi ro nợ</span>
                    <span className="text-xs font-black text-rose-300">THẤP</span>
                  </div>
                </div>
                <Button className="w-full bg-white text-indigo-900 hover:bg-indigo-50 font-black text-xs h-11 rounded-xl shadow-xl transition-all group/btn uppercase tracking-wider">
                  Tạo đơn bán nhanh
                  <ArrowRight className="ml-2 h-4 w-4 group-hover/btn:translate-x-1 transition-transform" />
                </Button>
              </div>
            </CardContent>
          </Card>

          <Card className="p-5 border-none bg-indigo-50/50 rounded-2xl border border-indigo-100/50 relative overflow-hidden group">
             <div className="absolute -right-4 -bottom-4 text-indigo-100/50 group-hover:scale-110 transition-transform">
                <Mail className="h-20 w-20" />
             </div>
             <h4 className="text-[10px] font-black text-indigo-600 uppercase mb-3 flex items-center tracking-widest leading-none">
                <Mail className="h-3 w-3 mr-1.5" /> Marketing Email
             </h4>
             <p className="text-[11px] text-slate-500 leading-relaxed font-medium relative z-10 italic">
                Bạn có thể lọc danh sách đối tác theo email để gửi các chương trình khuyến mãi hàng tháng tự động.
             </p>
          </Card>
        </div>
      </div>

      <CustomerFormModal isOpen={modalOpen} onClose={() => setModalOpen(false)} customer={selectedCustomer} />

      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent className="rounded-3xl border-none shadow-2xl p-8">
          <AlertDialogHeader className="space-y-4">
            <div className="h-16 w-16 bg-rose-100 rounded-2xl flex items-center justify-center mx-auto mb-2">
                <Trash2 className="h-8 w-8 text-rose-600" />
            </div>
            <AlertDialogTitle className="text-2xl font-black text-slate-900 uppercase text-center tracking-tight">
              Xác nhận xóa đối tác?
            </AlertDialogTitle>
            <AlertDialogDescription className="text-slate-500 text-center text-sm font-medium leading-relaxed">
              Bạn đang chuẩn bị xóa khách hàng <span className="font-black text-slate-900 uppercase">"{customerToDelete?.fullName}"</span>. 
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-8 flex gap-3 sm:justify-center">
            <AlertDialogCancel className="flex-1 rounded-xl font-bold border-none bg-slate-100 hover:bg-slate-200 text-slate-600 h-12 transition-all">
              HỦY BỎ
            </AlertDialogCancel>
            <AlertDialogAction 
              onClick={(e) => { e.preventDefault(); confirmDelete(); }}
              disabled={deleteMutation.isPending}
              className="flex-1 rounded-xl font-bold bg-rose-600 hover:bg-rose-700 text-white shadow-lg shadow-rose-200 h-12 transition-all active:scale-95"
            >
              {deleteMutation.isPending ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : null}
              XÁC NHẬN XÓA
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

function StatCard({ title, value, icon, alert }: any) {
  return (
    <Card className="border-none shadow-lg shadow-slate-100/50 bg-white rounded-2xl group hover:shadow-indigo-100 transition-all duration-300">
      <CardContent className="p-6 flex justify-between items-center">
        <div className="space-y-2">
          <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.15em] leading-none">{title}</p>
          <h3 className={`text-2xl font-black tracking-tight ${alert ? "text-rose-600" : "text-slate-900"}`}>{value}</h3>
        </div>
        <div className="p-3 bg-slate-50 rounded-2xl border border-slate-100 group-hover:bg-indigo-50 group-hover:border-indigo-100 transition-colors">
          {icon}
        </div>
      </CardContent>
    </Card>
  );
}