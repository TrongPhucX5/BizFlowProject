"use client";

import { useState, useMemo, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { customerService, type Customer } from "@/services/customer.service1";
import { reportsService } from "@/services/reports.service";
import { CustomerFormModal } from "./customer-form-modal";
import { CustomerDetailModal } from "./customer-detail-modal";
import { toast } from "sonner";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
  DropdownMenuLabel,
  DropdownMenuSeparator,
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
  Sparkles,
  Trash2,
  Eye,
  Wallet,
  BarChart3,
  PieChart as PieIcon,
  FileText,
  Download
} from "lucide-react";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell,
  PieChart,
  Pie,
} from "recharts";

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
  
  // --- States Điều khiển Modal & Dialog ---
  const [modalOpen, setModalOpen] = useState(false);
  const [detailOpen, setDetailOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
  const [customerToDelete, setCustomerToDelete] = useState<Customer | null>(null);
  const [viewingCustomer, setViewingCustomer] = useState<Customer | null>(null);

  // --- States Tìm kiếm & Phân trang ---
  const [page, setPage] = useState(0);
  const [inputValue, setInputValue] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");

  // --- States Xuất báo cáo ---
  const [exportFrom, setExportFrom] = useState("");
  const [exportTo, setExportTo] = useState("");
  const [exporting, setExporting] = useState(false);

  // Debounce tìm kiếm
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(inputValue);
      setPage(0);
    }, 500);
    return () => clearTimeout(timer);
  }, [inputValue]);

  // --- Query lấy danh sách khách hàng ---
  const {
    data: customersRes,
    isLoading,
    isPlaceholderData,
    isError,
  } = useQuery({
    queryKey: ["customers-list", page, debouncedSearch, "ACTIVE"],
    queryFn: () =>
      customerService.getCustomers({
        page,
        size: 10,
        search: debouncedSearch,
        status: "ACTIVE",
      }),
  });

  // Chuẩn hóa dữ liệu trả về từ API
  const pageData = useMemo(() => {
    if (!customersRes) return null;
    const raw = (customersRes as any)?.result || (customersRes as any)?.data || customersRes;

    return {
      content: raw?.content || [],
      totalElements: raw?.totalElements ?? raw?.page?.totalElements ?? 0,
      totalPages: raw?.totalPages ?? raw?.page?.totalPages ?? 1,
      numberOfElements: raw?.numberOfElements ?? raw?.content?.length ?? 0,
      last: raw?.last ?? (raw?.page ? raw.page.number + 1 >= raw.page.totalPages : true),
    } as PageResponse<Customer>;
  }, [customersRes]);

  const customerList = useMemo(() => pageData?.content || [], [pageData]);

  // --- Xử lý dữ liệu biểu đồ ---
  const chartStats = useMemo(() => {
    const top5 = [...customerList]
      .sort((a, b) => Number(b.totalPurchaseAmount) - Number(a.totalPurchaseAmount))
      .slice(0, 5)
      .map((c) => ({
        name: c.fullName?.split(" ").pop() || "N/A",
        fullName: c.fullName,
        "Mua hàng": Number(c.totalPurchaseAmount) || 0,
        "Nợ": Number(c.totalDebt) || 0,
      }));

    const wholesale = customerList.filter((c) => c.type === "WHOLESALE").length;
    const retail = customerList.filter((c) => c.type === "RETAIL").length;
    const pieData = [
      { name: "Khách Sỉ", value: wholesale, color: "#4f46e5" },
      { name: "Khách Lẻ", value: retail, color: "#f43f5e" },
    ];

    return { top5, pieData };
  }, [customerList]);

  // --- Thống kê nhanh ---
  const stats = useMemo(() => {
    const totalCount = pageData?.totalElements || 0;
    const pageDebt = customerList.reduce((sum, c) => sum + (Number(c.totalDebt) || 0), 0);
    const pageSales = customerList.reduce((sum, c) => sum + (Number(c.totalPurchaseAmount) || 0), 0);

    return {
      totalCount,
      pageDebt,
      pageSales,
      currentPageCount: pageData?.numberOfElements || 0,
      totalPages: pageData?.totalPages || 1,
      isLast: pageData?.last ?? true,
    };
  }, [pageData, customerList]);

  // --- Xử lý Xóa ---
  const deleteMutation = useMutation({
    mutationFn: (id: number) => customerService.deleteCustomer(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      toast.success("Đã xóa đối tác thành công");
      setDeleteDialogOpen(false);
    },
    onError: (error: any) => {
      toast.error(error?.response?.data?.message || "Lỗi khi xóa đối tác");
    },
  });

  // --- Xử lý Xuất file Excel TT88 ---
  const handleExportTT88Debt = async () => {
    if (!exportFrom || !exportTo) {
      toast.error("Vui lòng chọn khoảng thời gian xuất sổ!");
      return;
    }

    try {
      setExporting(true);
      const blob = await reportsService.exportTT88Debt(exportFrom, exportTo);
      
      const url = window.URL.createObjectURL(new Blob([blob]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `so-cong-no-TT88-${exportFrom}-${exportTo}.xlsx`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      
      toast.success("Đã xuất sổ công nợ TT88!");
    } catch (error) {
      console.error(error);
      toast.error("Xuất sổ thất bại!");
    } finally {
      setExporting(false);
    }
  };

  return (
    <div className="p-8 space-y-8 bg-[#f8fafc] min-h-screen font-sans">
      {/* --- Header & Search Bar --- */}
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-6">
        <div className="space-y-1">
          <h1 className="text-3xl font-black text-slate-900 uppercase tracking-tight italic">
            Đối tác & Khách hàng
          </h1>
          <p className="text-sm text-slate-500 font-medium flex items-center gap-2">
            <Users className="h-4 w-4 text-indigo-500" /> 
            Hệ thống có <span className="text-indigo-600 font-bold">{stats.totalCount}</span> đối tác hoạt động
          </p>
        </div>

        <div className="flex flex-wrap gap-3 w-full lg:w-auto">
          <div className="relative flex-1 md:w-80 group">
            <Search className={`absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 transition-colors ${inputValue ? "text-indigo-600" : "text-slate-400"}`} />
            <Input
              placeholder="Tìm theo tên, số điện thoại..."
              className="pl-10 bg-white border-slate-200 h-11 rounded-xl shadow-sm focus:ring-2 focus:ring-indigo-500/20"
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
            />
          </div>

          {/* Nút Xuất Báo Cáo */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="outline"
                className="h-11 px-6 rounded-xl font-black uppercase shadow-sm border-none bg-white text-slate-700 hover:bg-slate-50"
              >
                {exporting ? <Loader2 className="mr-2 h-5 w-5 animate-spin" /> : <Download className="mr-2 h-5 w-5" />}
                Xuất sổ TT88
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent className="w-80 p-4 rounded-3xl shadow-2xl border-none">
              <DropdownMenuLabel className="font-black uppercase text-xs text-slate-400 mb-2">Chọn khoảng thời gian</DropdownMenuLabel>
              <div className="grid grid-cols-2 gap-2 mb-4">
                <div className="space-y-1">
                  <span className="text-[10px] font-bold uppercase text-slate-400">Từ ngày</span>
                  <Input type="date" value={exportFrom} onChange={(e) => setExportFrom(e.target.value)} className="h-10 rounded-xl font-bold text-xs" />
                </div>
                <div className="space-y-1">
                  <span className="text-[10px] font-bold uppercase text-slate-400">Đến ngày</span>
                  <Input type="date" value={exportTo} onChange={(e) => setExportTo(e.target.value)} className="h-10 rounded-xl font-bold text-xs" />
                </div>
              </div>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleExportTT88Debt} className="p-3 rounded-xl font-bold cursor-pointer hover:bg-rose-50 hover:text-rose-600">
                <FileText className="mr-2 h-4 w-4" /> Xuất Sổ Công Nợ
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <Button
            className="bg-indigo-600 hover:bg-indigo-700 h-11 px-8 rounded-xl font-bold shadow-lg shadow-indigo-200"
            onClick={() => { setSelectedCustomer(null); setModalOpen(true); }}
          >
            <Plus className="mr-2 h-5 w-5" /> THÊM MỚI
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* --- Cột Chính (Stats & Table & Bar Chart) --- */}
        <div className="lg:col-span-3 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <StatCard title="Tổng đối tác" value={stats.totalCount.toLocaleString()} icon={<Users className="text-blue-600" />} />
            <StatCard title="Nợ trên trang" value={`${stats.pageDebt.toLocaleString()}đ`} icon={<CreditCard className="text-rose-600" />} alert={stats.pageDebt > 0} />
            <StatCard title="Doanh số trang" value={`${stats.pageSales.toLocaleString()}đ`} icon={<TrendingUp className="text-emerald-600" />} />
          </div>

          <Card className="border-none shadow-xl bg-white overflow-hidden rounded-2xl relative">
            {(isLoading || isPlaceholderData) && (
              <div className="absolute inset-0 bg-white/60 z-20 flex items-center justify-center backdrop-blur-[1px]">
                <Loader2 className="h-10 w-10 animate-spin text-indigo-600" />
              </div>
            )}
            <CardContent className="p-0">
              <Table>
                <TableHeader className="bg-slate-50/50">
                  <TableRow className="hover:bg-transparent border-b border-slate-100">
                    <TableHead className="font-bold py-5 px-6 text-slate-600 uppercase text-[11px]">Thông tin khách hàng</TableHead>
                    <TableHead className="font-bold text-center text-slate-600 uppercase text-[11px]">Loại</TableHead>
                    <TableHead className="font-bold text-right text-slate-600 uppercase text-[11px]">Tổng mua</TableHead>
                    <TableHead className="font-bold text-right text-slate-600 uppercase text-[11px]">Công nợ</TableHead>
                    <TableHead className="w-[60px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {isError ? (
                    <TableRow><TableCell colSpan={6} className="text-center py-20 text-rose-500 font-bold">Lỗi kết nối Server!</TableCell></TableRow>
                  ) : customerList.length === 0 && !isLoading ? (
                    <TableRow><TableCell colSpan={6} className="text-center py-20 text-slate-400 font-medium">Không tìm thấy dữ liệu.</TableCell></TableRow>
                  ) : (
                    customerList.map((item) => (
                      <TableRow key={item.id} className="group hover:bg-indigo-50/30 transition-colors border-b border-slate-50">
                        <TableCell className="px-6 py-4">
                          <div className="flex items-center gap-4">
                            <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center text-white font-black text-sm">
                              {item.fullName?.charAt(0).toUpperCase() || "C"}
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
                        <TableCell className="text-right font-black text-sm text-slate-900">{(Number(item.totalPurchaseAmount) || 0).toLocaleString()}đ</TableCell>
                        <TableCell className="text-right font-black text-sm">
                          <span className={Number(item.totalDebt) > 0 ? "text-rose-600" : "text-slate-400"}>
                            {(Number(item.totalDebt) || 0).toLocaleString()}đ
                          </span>
                        </TableCell>
                        <TableCell className="px-4 text-right">
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon" className="h-8 w-8 rounded-lg"><MoreHorizontal className="h-4 w-4" /></Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end" className="w-48 p-2 rounded-xl border-none shadow-2xl">
                              <DropdownMenuItem className="cursor-pointer font-bold text-xs" onClick={() => { setViewingCustomer(item); setDetailOpen(true); }}><Eye className="mr-2 h-4 w-4" /> Chi tiết</DropdownMenuItem>
                              <DropdownMenuItem className="cursor-pointer font-bold text-xs text-rose-600" onClick={() => { setCustomerToDelete(item); setDeleteDialogOpen(true); }}><Trash2 className="mr-2 h-4 w-4" /> Xóa</DropdownMenuItem>
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
                <div className="flex flex-col">
                    <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Trang {page + 1} / {stats.totalPages}</p>
                    <p className="text-[10px] text-slate-400 font-medium italic">Hiển thị {stats.currentPageCount} / {stats.totalCount}</p>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" className="font-bold rounded-lg px-4" disabled={page === 0} onClick={() => setPage((p) => p - 1)}>TRƯỚC</Button>
                  <Button variant="outline" size="sm" className="font-bold rounded-lg px-4" disabled={stats.isLast} onClick={() => setPage((p) => p + 1)}>SAU</Button>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Bar Chart */}
          <Card className="border-none shadow-xl bg-white rounded-3xl p-8">
            <CardHeader className="p-0 mb-8 flex flex-row items-center justify-between">
              <CardTitle className="text-sm font-black uppercase text-slate-400 tracking-widest flex items-center gap-2">
                <BarChart3 className="h-4 w-4 text-indigo-600" /> Top 5 Mua hàng & Nợ (Trang này)
              </CardTitle>
            </CardHeader>
            <div className="h-[350px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartStats.top5}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fontSize: 12, fontWeight: 700, fill: '#64748b'}} dy={10} />
                  <YAxis hide />
                  <Tooltip 
                    contentStyle={{borderRadius: '16px', border: 'none', boxShadow: '0 25px 50px -12px rgb(0 0 0 / 0.15)'}}
                    formatter={(value: any) => [`${value.toLocaleString()}đ`]}
                  />
                  <Bar dataKey="Mua hàng" fill="#6366f1" radius={[8, 8, 0, 0]} barSize={35} />
                  <Bar dataKey="Nợ" fill="#f43f5e" radius={[8, 8, 0, 0]} barSize={35} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </Card>
        </div>

        {/* --- Cột Phụ (Pie Chart & AI Insights) --- */}
        <div className="lg:col-span-1 space-y-6">
          <Card className="border-none shadow-2xl bg-slate-900 text-white overflow-hidden rounded-3xl p-6 relative">
            <h2 className="text-sm font-black tracking-widest uppercase mb-6 flex items-center gap-2">
              <PieIcon className="h-4 w-4 text-indigo-400" /> Tỷ lệ đối tác
            </h2>
            <div className="h-[220px] w-full relative">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={chartStats.pieData} innerRadius={65} outerRadius={85} paddingAngle={10} dataKey="value">
                    {chartStats.pieData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} stroke="none" />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                <span className="text-3xl font-black">{stats.currentPageCount}</span>
                <span className="text-[10px] uppercase font-bold text-slate-400">Trên trang</span>
              </div>
            </div>
            <div className="mt-8 space-y-3">
              {chartStats.pieData.map((item) => (
                <div key={item.name} className="flex justify-between items-center bg-white/5 p-3 rounded-2xl border border-white/5">
                  <div className="flex items-center gap-3">
                    <div className="w-2.5 h-2.5 rounded-full" style={{backgroundColor: item.color}} />
                    <span className="text-xs font-bold">{item.name}</span>
                  </div>
                  <span className="text-xs font-black">{item.value}</span>
                </div>
              ))}
            </div>
          </Card>

          <Card className="border-none shadow-2xl bg-indigo-600 text-white rounded-3xl p-6">
            <h2 className="text-sm font-black uppercase mb-4 flex items-center gap-2">
              <Sparkles className="h-4 w-4" /> AI Phân tích
            </h2>
            <div className="bg-white/10 rounded-2xl p-4 text-[11px] leading-relaxed italic border border-white/10">
              {stats.pageSales > 0 && stats.pageDebt > (stats.pageSales * 0.3) ? (
                <p className="text-rose-100 font-bold">⚠️ Cảnh báo: Tỷ lệ nợ cao ({( (stats.pageDebt / stats.pageSales) * 100).toFixed(0)}%). Cần rà soát nợ quá hạn.</p>
              ) : (
                <p>✅ Chỉ số dòng tiền ổn định. Các khoản nợ nằm trong tầm kiểm soát.</p>
              )}
            </div>
          </Card>

          <div className="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
            <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">Sức khỏe tài chính</h3>
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-xs text-slate-500 font-medium flex items-center gap-1"><Wallet className="h-3 w-3" /> Tỷ lệ nợ/mua:</span>
                <span className={`text-sm font-black ${stats.pageSales > 0 && (stats.pageDebt / stats.pageSales) > 0.25 ? "text-rose-600" : "text-emerald-600"}`}>
                  {stats.pageSales > 0 ? ((stats.pageDebt / stats.pageSales) * 100).toFixed(1) : 0}%
                </span>
              </div>
              <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                 <div 
                    className={`h-full transition-all duration-1000 ${stats.pageSales > 0 && (stats.pageDebt / stats.pageSales) > 0.25 ? "bg-rose-500" : "bg-indigo-600"}`}
                    style={{ width: `${Math.min(100, stats.pageSales > 0 ? (stats.pageDebt / stats.pageSales) * 100 : 0)}%` }}
                 />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* --- Modals & Dialogs --- */}
      <CustomerFormModal isOpen={modalOpen} onClose={() => setModalOpen(false)} customer={selectedCustomer} />
      <CustomerDetailModal isOpen={detailOpen} onClose={() => setDetailOpen(false)} customer={viewingCustomer} />

      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent className="rounded-3xl p-8 max-w-md border-none shadow-2xl">
          <AlertDialogHeader>
            <div className="mx-auto bg-rose-50 w-20 h-20 rounded-3xl flex items-center justify-center mb-6">
              <Trash2 className="h-10 w-10 text-rose-600" />
            </div>
            <AlertDialogTitle className="text-2xl font-black uppercase text-center">Xác nhận xóa?</AlertDialogTitle>
            <AlertDialogDescription className="text-center font-medium py-2">
              Mọi dữ liệu của đối tác <span className="text-indigo-600 font-bold italic">"{customerToDelete?.fullName}"</span> sẽ bị xóa vĩnh viễn.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-8 flex gap-3 sm:justify-center">
            <AlertDialogCancel className="flex-1 rounded-xl font-bold h-12">HỦY</AlertDialogCancel>
            <AlertDialogAction 
              onClick={() => customerToDelete && deleteMutation.mutate(customerToDelete.id)} 
              className="flex-1 rounded-xl font-bold bg-rose-600 h-12 hover:bg-rose-700 shadow-lg"
            >
              {deleteMutation.isPending ? <Loader2 className="animate-spin h-5 w-5" /> : "XÁC NHẬN"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// Sub-component cho StatCard
function StatCard({ title, value, icon, alert }: { title: string; value: string; icon: React.ReactNode; alert?: boolean }) {
  return (
    <Card className="border-none shadow-lg bg-white rounded-2xl overflow-hidden hover:shadow-indigo-100 transition-all group cursor-default">
      <CardContent className="p-6 flex justify-between items-center">
        <div>
          <p className="text-[10px] font-black text-slate-400 uppercase mb-1 tracking-wider">{title}</p>
          <h3 className={`text-2xl font-black tracking-tighter ${alert ? "text-rose-600" : "text-slate-900"}`}>{value}</h3>
        </div>
        <div className="p-3.5 bg-slate-50 rounded-2xl group-hover:bg-indigo-50 transition-colors shadow-sm">{icon}</div>
      </CardContent>
    </Card>
  );
}