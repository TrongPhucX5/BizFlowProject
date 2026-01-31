"use client";

import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { logsService, AuditLog } from "@/services/logs.service";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { 
  Activity, 
  Search, 
  Loader2, 
  Eye, 
  Filter, 
  Calendar,
  Terminal,
  User as UserIcon,
  ShieldCheck,
  Trash2,
  Edit3,
  PlusSquare,
  Globe,
  Package,
  Tag,
  RefreshCw,
  Clock,
  Database
} from "lucide-react";
import { cn } from "@/lib/utils";
import { format } from "date-fns";
import { vi } from "date-fns/locale";

export default function SystemLogsPage() {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedLog, setSelectedLog] = useState<AuditLog | null>(null);
  const [isDetailsOpen, setIsDetailsOpen] = useState(false);
  const [page, setPage] = useState(0);
  const [actionFilter, setActionFilter] = useState("ALL");
  const [entityFilter, setEntityFilter] = useState("ALL");
  const [now, setNow] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const { data, isLoading, refetch, isFetching } = useQuery({
    queryKey: ["audit-logs", page],
    queryFn: () => logsService.getLogs(page, 50),
    refetchInterval: 30000, 
  });

  const logs = data?.result || [];
  const limit = 50; 

  // Hàm dịch hành động sang tiếng Việt
  const translateActionName = (action: string): string => {
    const act = action.toUpperCase();
    if (act.includes("CREATE_PRODUCT")) return "Thêm sản phẩm";
    if (act.includes("UPDATE_PRODUCT")) return "Cập nhật sản phẩm";
    if (act.includes("DELETE_PRODUCT")) return "Xóa sản phẩm";
    if (act.includes("CREATE_CUSTOMER")) return "Thêm khách hàng";
    if (act.includes("UPDATE_CUSTOMER")) return "Cập nhật khách hàng";
    if (act.includes("DELETE_CUSTOMER")) return "Xóa khách hàng";
    if (act.includes("CREATE_ORDER")) return "Tạo đơn hàng";
    if (act.includes("UPDATE_ORDER")) return "Cập nhật đơn hàng";
    if (act.includes("CANCEL_ORDER")) return "Hủy đơn hàng";
    if (act.includes("IMPORT_STOCK")) return "Nhập kho";
    if (act.includes("LOGIN")) return "Đăng nhập";
    
    // Fallback translations for generic types
    if (act.includes("CREATE")) return "Thêm mới";
    if (act.includes("UPDATE")) return "Cập nhật";
    if (act.includes("DELETE")) return "Xóa bỏ";
    
    return action;
  };

  const getActionBadge = (action: string) => {
    const act = action.toUpperCase();
    const label = translateActionName(action).toUpperCase();
    
    if (act.includes("CREATE")) return <Badge className="bg-emerald-50 text-emerald-600 border border-emerald-200 hover:bg-emerald-100 px-4 py-1 rounded-full font-bold shadow-none"><PlusSquare size={12} className="mr-1.5" /> {label}</Badge>;
    if (act.includes("UPDATE")) return <Badge className="bg-amber-50 text-amber-600 border border-amber-200 hover:bg-amber-100 px-4 py-1 rounded-full font-bold shadow-none"><Edit3 size={12} className="mr-1.5" /> {label}</Badge>;
    if (act.includes("DELETE")) return <Badge className="bg-rose-50 text-rose-600 border border-rose-200 hover:bg-rose-100 px-4 py-1 rounded-full font-bold shadow-none"><Trash2 size={12} className="mr-1.5" /> {label}</Badge>;
    if (act.includes("LOGIN")) return <Badge className="bg-blue-50 text-blue-600 border border-blue-200 hover:bg-blue-100 px-4 py-1 rounded-full font-bold shadow-none"><ShieldCheck size={12} className="mr-1.5" /> {label}</Badge>;
    return <Badge variant="secondary" className="px-4 py-1 rounded-full font-bold bg-slate-100 text-slate-500 border-none">{label}</Badge>;
  };

  // Hàm dịch tên trường sang tiếng Việt
  const translateFieldName = (fieldName: string): string => {
    const translations: Record<string, string> = {
      // User fields
      'username': 'Tên đăng nhập',
      'userName': 'Tên đăng nhập',
      'password': 'Mật khẩu',
      'email': 'Email',
      'phone': 'Số điện thoại',
      'fullName': 'Họ và tên',
      'role': 'Vai trò',
      'status': 'Trạng thái',
      
      // Product fields
      'name': 'Tên sản phẩm',
      'productName': 'Tên sản phẩm',
      'sku': 'Mã SKU',
      'price': 'Giá bán',
      'costPrice': 'Giá vốn',
      'description': 'Mô tả',
      'categoryId': 'Danh mục',
      'stockQuantity': 'Số lượng tồn',
      'reorderLevel': 'Mức đặt lại',
      'unitName': 'Đơn vị tính',
      'imageUrl': 'Hình ảnh',
      'trackStock': 'Theo dõi tồn kho',
      'storeId': 'Cửa hàng',
      
      // Customer fields
      'customerName': 'Tên khách hàng',
      'address': 'Địa chỉ',
      'segment': 'Phân khúc',
      'loyaltyPoints': 'Điểm thưởng',
      
      // Order & Debt fields
      'totalAmount': 'Tổng tiền',
      'subtotal': 'Tạm tính',
      'discountAmount': 'Chiết khấu',
      'paymentType': 'Hình thức thanh toán',
      'orderNumber': 'Mã đơn hàng',
      'orderCode': 'Mã đơn hàng',
      'paidAmount': 'Số tiền đã trả',
      'unpaidAmount': 'Số tiền còn nợ',
      'dueDate': 'Hạn thanh toán',
      'amount': 'Số tiền giao dịch',
      
      // Inventory fields
      'quantity': 'Số lượng',
      'unitCost': 'Giá vốn đơn vị',
      'unitPrice': 'Giá bán đơn vị',
      'availableQuantity': 'Số lượng khả dụng',
      'reservedQuantity': 'Số lượng đặt trước',
      
      // Common fields
      'id': 'Mã định danh',
      'createdAt': 'Ngày tạo',
      'updatedAt': 'Ngày cập nhật',
      'createdBy': 'Người tạo',
      'updatedBy': 'Người cập nhật',
      'isActive': 'Đang hoạt động',
      'isDeleted': 'Đã xóa',

      // Order specific
      'orderStatus': 'Trạng thái đơn hàng',
      'paymentStatus': 'Trạng thái thanh toán',
      'shippingAddress': 'Địa chỉ giao hàng',
      'billingAddress': 'Địa chỉ thanh toán',
      'note': 'Ghi chú',
      'customer': 'Khách hàng',
      'items': 'Sản phẩm',

      // Debt specific
      'referenceCode': 'Mã tham chiếu',
      'referenceType': 'Loại tham chiếu',
    };
    
    return translations[fieldName] || fieldName;
  };

  // Hàm dịch loại thực thể sang tiếng Việt
  const translateEntityName = (entityType: string): string => {
    const translations: Record<string, string> = {
      'PRODUCT': 'SẢN PHẨM',
      'CUSTOMER': 'KHÁCH HÀNG',
      'USER': 'NGƯỜI DÙNG',
      'ORDER': 'ĐƠN HÀNG',
      'CATEGORY': 'DANH MỤC',
      'INVENTORY': 'KHO HÀNG',
      'DEBT': 'CÔNG NỢ',
    };
    
    return translations[entityType.toUpperCase()] || entityType;
  };

  const uniqueEntities = Array.from(new Set(logs.map(log => log.entityType))).filter(Boolean);

  const filteredLogs = logs.filter(log => {
    const searchLower = searchTerm.toLowerCase();
    const performer = (log.userFullName || "").toLowerCase();
    const username = (log.userName || "").toLowerCase();
    const action = (log.action || "").toLowerCase();
    const translatedAction = translateActionName(log.action).toLowerCase();
    const entityType = (log.entityType || "").toLowerCase();
    const entityId = (log.entityId?.toString() || "").toLowerCase();

    const matchesSearch = searchTerm === "" ||
      performer.includes(searchLower) ||
      username.includes(searchLower) ||
      action.includes(searchLower) ||
      translatedAction.includes(searchLower) ||
      entityType.includes(searchLower) ||
      entityId.includes(searchLower);
    
    const matchesAction = actionFilter === "ALL" || log.action?.toUpperCase().includes(actionFilter.toUpperCase());
    const matchesEntity = entityFilter === "ALL" || log.entityType === entityFilter;
    
    return matchesSearch && matchesAction && matchesEntity;
  });

  const formatJSON = (jsonStr: string | null) => {
    if (!jsonStr) return null;
    try {
      const obj = JSON.parse(jsonStr);
      return JSON.stringify(obj, null, 2);
    } catch (e) {
      return jsonStr;
    }
  };

  const safeParse = (jsonStr: string | null) => {
    if (!jsonStr) return {};
    try {
      const trimmed = jsonStr.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) || (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        return JSON.parse(jsonStr);
      }
      return { _is_plain_text: true, message: jsonStr };
    } catch (e) {
      return { _is_plain_text: true, message: jsonStr };
    }
  };

  return (
    <div className="p-4 md:p-8 space-y-8 bg-[#F4F7FA] min-h-screen font-sans">
       {/* TIÊU ĐỀ SECTION */}
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-6">
        <div className="flex items-center gap-5">
          <div className="p-4 bg-white rounded-[24px] shadow-sm border border-slate-100 text-slate-700">
             <Terminal className="h-8 w-8" />
          </div>
          <div>
            <h1 className="text-3xl font-bold tracking-tight text-slate-800 leading-none">
              Nhật ký Hệ thống
            </h1>
            <p className="text-slate-500 font-medium mt-2">
              Giám sát trung tâm và theo dõi hoạt động toàn sàn
            </p>
          </div>
        </div>
        
        <div className="flex flex-wrap items-center gap-3">
           <Button
             onClick={() => refetch()}
             disabled={isFetching}
             variant="outline"
             className="bg-white border-slate-200 rounded-2xl h-11 px-5 font-bold text-slate-600 hover:bg-slate-50 transition-all shadow-sm"
           >
              <RefreshCw size={16} className={cn("mr-2", isFetching && "animate-spin")} />
              Làm mới
           </Button>
           
           <div className="flex items-center gap-3 px-4 h-11 bg-white border border-blue-100 rounded-2xl text-blue-600 font-bold text-sm shadow-sm transition-all hover:bg-slate-50 group shrink-0">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-blue-500"></span>
              </span>
              <div className="flex items-center gap-2">
                 <Clock size={16} className="text-blue-500/70" />
                 <span className="text-base font-black font-mono tracking-tight tabular-nums leading-none">
                    {format(now, "HH:mm:ss")}
                 </span>
              </div>
           </div>
        </div>
      </div>

      {/* TỔNG QUAN THỐNG KÊ */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
         {[
           { label: "Tổng hoạt động", val: logs.length, icon: Activity, color: "slate", desc: "Bản ghi hiện có" },
           { label: "Thêm mới", val: logs.filter(l => l.action.includes("CREATE")).length, icon: PlusSquare, color: "emerald", desc: "Khởi tạo dữ liệu" },
           { label: "Cập nhật", val: logs.filter(l => l.action.includes("UPDATE")).length, icon: Edit3, color: "amber", desc: "Sửa đổi thông tin" },
           { label: "Đăng nhập", val: logs.filter(l => l.action.includes("LOGIN")).length, icon: ShieldCheck, color: "blue", desc: "Phiên người dùng" }
         ].map((stat, i) => (
           <Card key={i} className="border border-slate-200/60 shadow-sm bg-white rounded-2xl group hover:shadow-md transition-all duration-300">
             <CardContent className="p-4">
                <div className="flex items-center gap-4">
                   <div className={cn(
                     "h-12 w-12 rounded-xl flex items-center justify-center transition-colors",
                     stat.color === 'slate' && "bg-slate-100 text-slate-500 group-hover:bg-slate-900 group-hover:text-white",
                     stat.color === 'emerald' && "bg-emerald-50 text-emerald-600 group-hover:bg-emerald-600 group-hover:text-white",
                     stat.color === 'amber' && "bg-amber-50 text-amber-600 group-hover:bg-amber-600 group-hover:text-white",
                     stat.color === 'blue' && "bg-blue-50 text-blue-600 group-hover:bg-blue-600 group-hover:text-white",
                   )}>
                     <stat.icon size={20} />
                   </div>
                   <div className="flex flex-col min-w-0">
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none mb-1.5">{stat.label}</p>
                      <div className="flex items-baseline gap-2">
                         <span className="text-xl font-black text-slate-800 tabular-nums leading-none">{stat.val}</span>
                         <span className="text-[10px] text-slate-400 font-medium truncate">{stat.desc}</span>
                      </div>
                   </div>
                </div>
             </CardContent>
           </Card>
         ))}
      </div>

      {/* BỘ LỌC & TÌM KIẾM */}
      <div className="bg-white p-4 rounded-[24px] border border-slate-200 shadow-sm flex flex-col xl:flex-row gap-4 items-center">
        <div className="relative flex-1 w-full">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-5 w-5" />
          <Input 
            placeholder="Tìm theo tên, hành động hoặc thực thể..." 
            className="pl-12 h-12 bg-slate-50/50 border-slate-100 rounded-xl focus:ring-0 focus:border-blue-400 transition-all font-medium w-full text-slate-700"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full xl:w-auto">
          <Select value={actionFilter} onValueChange={setActionFilter}>
            <SelectTrigger className="h-12 min-w-[170px] bg-white border-slate-200 rounded-xl font-bold text-slate-600 px-5">
              <div className="flex items-center gap-2">
                <Filter size={16} className="text-slate-400" />
                <SelectValue placeholder="Hành động" />
              </div>
            </SelectTrigger>
            <SelectContent className="rounded-xl border-slate-200">
              <SelectItem value="ALL">Tất cả hành động</SelectItem>
              <SelectItem value="CREATE">Thêm mới</SelectItem>
              <SelectItem value="UPDATE">Cập nhật</SelectItem>
              <SelectItem value="DELETE">Xóa bỏ</SelectItem>
              <SelectItem value="LOGIN">Đăng nhập</SelectItem>
            </SelectContent>
          </Select>

          <Select value={entityFilter} onValueChange={setEntityFilter}>
            <SelectTrigger className="h-12 min-w-[170px] bg-white border-slate-200 rounded-xl font-bold text-slate-600 px-5">
              <div className="flex items-center gap-2">
                <Activity size={16} className="text-slate-400" />
                <SelectValue placeholder="Thực thể" />
              </div>
            </SelectTrigger>
            <SelectContent className="rounded-xl border-slate-200">
              <SelectItem value="ALL">Tất cả thực thể</SelectItem>
              {uniqueEntities.map(entity => (
                <SelectItem key={entity} value={entity}>{translateEntityName(entity)}</SelectItem>
              ))}
            </SelectContent>
          </Select>

          <div className="flex items-center bg-slate-50 p-1.5 rounded-2xl border border-slate-200 gap-1.5 shrink-0 shadow-inner">
             <div className="flex items-center gap-3 px-3 py-1.5 bg-white rounded-xl shadow-sm border border-slate-100 transition-all hover:bg-blue-50/30 group">
                <div className="h-7 w-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 group-hover:bg-blue-100 group-hover:text-blue-600">
                   <Database size={14} />
                </div>
                <div className="flex flex-col">
                   <span className="text-[8px] font-black text-slate-400 uppercase leading-none mb-1">Giới hạn</span>
                   <span className="text-[11px] font-black text-slate-700 leading-none">50 bản ghi</span>
                </div>
             </div>

             <div className="w-px h-4 bg-slate-200 mx-0.5" />

             <div className="flex items-center gap-3 px-3 py-1.5 bg-white rounded-xl shadow-sm border border-slate-100 transition-all hover:bg-emerald-50/30 group">
                <div className="h-7 w-7 rounded-lg bg-slate-100 flex items-center justify-center text-slate-500 group-hover:bg-emerald-100 group-hover:text-emerald-600">
                   <Filter size={14} />
                </div>
                <div className="flex flex-col">
                   <span className="text-[8px] font-black text-slate-400 uppercase leading-none mb-1">Kết quả</span>
                   <span className="text-[11px] font-black text-emerald-600 leading-none">{filteredLogs.length} kết quả</span>
                </div>
             </div>
          </div>
        </div>
      </div>

      {/* BẢNG DỮ LIỆU CHÍNH */}
      <Card className="border border-slate-200 shadow-sm overflow-hidden bg-white rounded-[24px]">
        <CardContent className="p-0">
          <Table>
            <TableHeader className="bg-slate-50/50 border-b border-slate-200">
              <TableRow>
                <TableHead className="py-5 font-bold text-slate-500 text-[11px] uppercase tracking-wider pl-8">Thời Gian</TableHead>
                <TableHead className="py-5 font-bold text-slate-500 text-[11px] uppercase tracking-wider">Người thực hiện</TableHead>
                <TableHead className="py-5 font-bold text-slate-500 text-[11px] uppercase tracking-wider text-center">Hành động</TableHead>
                <TableHead className="py-5 font-bold text-slate-500 text-[11px] uppercase tracking-wider">Đối tượng tác động</TableHead>
                <TableHead className="py-5 font-bold text-slate-500 text-[11px] uppercase tracking-wider text-right pr-8">Chi tiết</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={5} className="h-80 text-center">
                    <div className="flex flex-col items-center justify-center space-y-4">
                      <div className="p-4 bg-slate-50 rounded-full">
                        <Loader2 className="h-10 w-10 animate-spin text-blue-500" />
                      </div>
                      <p className="font-bold text-slate-600">Đang đồng bộ nhật ký từ máy chủ...</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : filteredLogs.length > 0 ? (
                filteredLogs.map((log: AuditLog) => (
                  <TableRow key={log.id} className="hover:bg-slate-50/50 transition-colors border-b border-slate-100 last:border-0 group">
                    <TableCell className="py-5 pl-8">
                       <div className="flex flex-col">
                          <span className="font-bold text-slate-800 font-mono text-base">
                            {log.createdAt ? format(new Date(log.createdAt), "HH:mm:ss", { locale: vi }) : "--:--:--"}
                          </span>
                          <span className="text-[11px] font-medium text-slate-400">
                            {log.createdAt ? format(new Date(log.createdAt), "dd/MM/yyyy", { locale: vi }) : "--/--/----"}
                          </span>
                       </div>
                    </TableCell>
                    <TableCell className="py-5">
                      <div className="flex items-center gap-3">
                         <div className="h-9 w-9 rounded-xl bg-slate-100 flex items-center justify-center text-slate-500 group-hover:bg-blue-50 group-hover:text-blue-600 transition-colors">
                            <UserIcon size={18} />
                         </div>
                         <div>
                            <p className="font-bold text-slate-700 leading-tight">{log.userFullName || log.userName}</p>
                            <p className="text-[10px] font-medium text-slate-400 uppercase mt-0.5">@{log.userName}</p>
                         </div>
                      </div>
                    </TableCell>
                    <TableCell className="py-5 text-center">
                       {getActionBadge(log.action)}
                    </TableCell>
                    <TableCell className="py-5">
                       <div className="flex flex-col">
                          <span className="text-xs font-bold text-slate-600 bg-slate-100 px-2 py-0.5 rounded-md border border-slate-200 self-start mb-1 uppercase tracking-tighter">
                            {translateEntityName(log.entityType)}
                          </span>
                          <span className="text-[10px] font-semibold text-slate-400 ml-0.5">ID: {log.entityId || "N/A"}</span>
                       </div>
                    </TableCell>
                    <TableCell className="py-5 text-right pr-8">
                       <Button 
                         variant="ghost" 
                         size="icon" 
                         className="h-10 w-10 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all"
                         onClick={() => {
                           setSelectedLog(log);
                           setIsDetailsOpen(true);
                         }}
                       >
                         <Eye size={18} />
                       </Button>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                   <TableCell colSpan={5} className="h-80 text-center">
                      <div className="flex flex-col items-center py-12">
                         <div className="p-6 bg-slate-50 rounded-full mb-4">
                            <Terminal size={48} className="text-slate-200" />
                         </div>
                         <p className="text-slate-800 font-bold text-lg">Không tìm thấy bản ghi</p>
                         <p className="text-slate-500 text-sm mt-1 max-w-xs mx-auto">
                           Vui lòng điều chỉnh bộ lọc hoặc thử lại sau khi có hoạt động mới.
                         </p>
                      </div>
                   </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* DIALOG CHI TIẾT */}
      <Dialog open={isDetailsOpen} onOpenChange={setIsDetailsOpen}>
        <DialogContent className="sm:max-w-[650px] w-full p-0 overflow-hidden border-none rounded-[24px] shadow-2xl bg-white">
           <div className="p-6 border-b border-slate-100 bg-slate-50/30">
              <div className="flex justify-between items-center">
                <div className="space-y-1.5">
                   <div className="flex items-center gap-2.5 text-blue-600 font-bold text-xs uppercase tracking-widest">
                      <div className="p-1.5 bg-blue-100 rounded-lg">
                        <Clock size={14} />
                      </div>
                      Bản ghi sự kiện #{selectedLog?.id}
                   </div>
                   <DialogTitle className="text-2xl font-black text-slate-900 tracking-tight">Chi tiết thay đổi hệ thống</DialogTitle>
                   <DialogDescription className="text-slate-500 font-medium text-sm">
                     Người thực hiện: <span className="text-slate-900 font-bold">{selectedLog?.userFullName || selectedLog?.userName}</span> 
                     <span className="mx-2 text-slate-300">|</span> 
                     Thời gian: <span className="text-slate-900 font-bold">{selectedLog?.createdAt && format(new Date(selectedLog.createdAt), "HH:mm:ss - dd/MM/yyyy", { locale: vi })}</span>
                   </DialogDescription>
                </div>
                <div className="scale-105">
                  {selectedLog?.action && getActionBadge(selectedLog.action)}
                </div>
              </div>
           </div>

           <div className="p-6 space-y-6 bg-white max-h-[60vh] overflow-y-auto custom-scrollbar">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                 <div className="space-y-4">
                    <div className="flex items-center gap-3 ml-1">
                      <div className="h-5 w-1.5 bg-slate-300 rounded-full" />
                      <Label className="text-slate-500 font-black uppercase tracking-wider text-[11px]">Dữ liệu gốc (Trước)</Label>
                    </div>
                    <div className="p-6 bg-slate-50/50 border border-slate-200 rounded-[20px] shadow-sm min-h-[320px]">
                       {selectedLog?.oldValue ? (
                         <div className="grid grid-cols-1 gap-3">
                           {Object.entries(safeParse(selectedLog.oldValue))
                             .filter(([_, value]) => value !== null && value !== "" && value !== undefined)
                             .map(([key, value]: [string, any]) => (
                             <div key={key} className="bg-white p-4 rounded-xl border border-slate-100 transition-all hover:shadow-sm">
                               <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">{translateFieldName(key)}</p>
                               <p className="text-[15px] font-bold text-slate-800 break-words">
                                 {key === '_error' ? (
                                   <div className="text-rose-500 text-xs font-bold bg-rose-50 p-3 rounded-lg border border-rose-100 mb-2">
                                     ⚠️ {value}
                                   </div>
                                 ) : key === '_raw' ? (
                                   <pre className="text-[10px] text-slate-400 max-h-32 overflow-y-auto bg-slate-100 p-2 rounded">
                                     {String(value).substring(0, 1000)}...
                                   </pre>
                                 ) : typeof value === 'boolean' ? (value ? 'ĐÚNG' : 'SAI') :
                                  Array.isArray(value) ? (
                                    <div className="space-y-2 mt-2">
                                      {value.map((item: any, idx: number) => (
                                        <div key={idx} className="p-3 bg-slate-50 rounded-lg border border-slate-100 text-sm">
                                          <div className="flex justify-between items-start mb-1">
                                            <span className="font-bold text-blue-600">{item.productName || `SP #${item.productId}`}</span>
                                            <span className="font-bold">x{item.quantity}</span>
                                          </div>
                                          {item.unitPrice && (
                                            <div className="text-[11px] text-slate-500">
                                              Đơn giá: {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.unitPrice)}
                                              <span className="mx-1">|</span>
                                              Thành tiền: {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.totalAmount || item.subtotal || (item.unitPrice * item.quantity))}
                                            </div>
                                          )}
                                        </div>
                                      ))}
                                    </div>
                                  ) :
                                  (typeof value === 'string' && (value.startsWith('data:image') || key.toLowerCase().includes('image'))) ? (
                                    <span className="text-slate-500 italic font-medium">[Đã cập nhật hình ảnh]</span>
                                  ) :
                                  typeof value === 'object' && value !== null ? (
                                    <pre className="text-xs bg-slate-50 p-2 rounded overflow-x-auto">
                                      {JSON.stringify(value, null, 2)}
                                    </pre>
                                  ) : String(value)}
                               </p>
                             </div>
                           ))}
                         </div>
                       ) : (
                         <div className="flex flex-col items-center justify-center h-full text-slate-300 py-10">
                           <Terminal size={40} className="mb-2 opacity-20" />
                           <p className="italic font-medium">Không có dữ liệu gốc</p>
                         </div>
                       )}
                    </div>
                 </div>
                 <div className="space-y-4">
                    <div className="flex items-center gap-3 ml-1">
                      <div className="h-5 w-1.5 bg-blue-500 rounded-full" />
                      <Label className="text-blue-600 font-black uppercase tracking-wider text-[11px]">Dữ liệu mới (Sau)</Label>
                    </div>
                    <div className="p-6 bg-blue-50/30 border border-blue-200 rounded-[20px] shadow-sm min-h-[320px]">
                       {selectedLog?.newValue ? (
                         <div className="grid grid-cols-1 gap-3">
                           {Object.entries(safeParse(selectedLog.newValue))
                             .filter(([_, value]) => value !== null && value !== "" && value !== undefined)
                             .map(([key, value]: [string, any]) => (
                             <div key={key} className="bg-white p-4 rounded-xl border border-blue-100 transition-all hover:shadow-md hover:border-blue-200">
                               <p className="text-[10px] font-bold text-blue-500 uppercase tracking-wider mb-1.5">{translateFieldName(key)}</p>
                               <p className="text-[15px] font-bold text-blue-700 break-words">
                                 {key === '_error' ? (
                                   <div className="text-rose-600 text-xs font-bold bg-rose-50 p-3 rounded-lg border border-rose-100 mb-2">
                                     ⚠️ {value}
                                   </div>
                                 ) : key === '_raw' ? (
                                   <pre className="text-[10px] text-blue-400 max-h-32 overflow-y-auto bg-blue-50/50 p-2 rounded">
                                     {String(value).substring(0, 1000)}...
                                   </pre>
                                 ) : typeof value === 'boolean' ? (value ? 'ĐÚNG' : 'SAI') :
                                  Array.isArray(value) ? (
                                    <div className="space-y-2 mt-2">
                                      {value.map((item: any, idx: number) => (
                                        <div key={idx} className="p-3 bg-blue-50/50 rounded-lg border border-blue-100 text-sm">
                                          <div className="flex justify-between items-start mb-1">
                                            <span className="font-bold text-blue-700">{item.productName || `SP #${item.productId}`}</span>
                                            <span className="font-bold">x{item.quantity}</span>
                                          </div>
                                          {item.unitPrice && (
                                            <div className="text-[11px] text-blue-600/70">
                                              Đơn giá: {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.unitPrice)}
                                              <span className="mx-1">|</span>
                                              Thành tiền: {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.totalAmount || item.subtotal || (item.unitPrice * item.quantity))}
                                            </div>
                                          )}
                                        </div>
                                      ))}
                                    </div>
                                  ) :
                                  (typeof value === 'string' && (value.startsWith('data:image') || key.toLowerCase().includes('image'))) ? (
                                    <span className="text-blue-600 italic font-medium">[Đã cập nhật hình ảnh]</span>
                                  ) :
                                  typeof value === 'object' && value !== null ? (
                                    <pre className="text-xs bg-blue-50/50 p-2 rounded overflow-x-auto">
                                      {JSON.stringify(value, null, 2)}
                                    </pre>
                                  ) : String(value)}
                               </p>
                             </div>
                           ))}
                         </div>
                       ) : (
                         <div className="flex flex-col items-center justify-center h-full text-blue-200 py-10">
                           <Activity size={40} className="mb-2 opacity-20" />
                           <p className="italic font-medium">Dữ liệu đã bị xóa hoặc không còn tồn tại</p>
                         </div>
                       )}
                    </div>
                 </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-5 pt-6 border-t border-slate-100">
                 {[
                   { label: "Thực thể tác động", val: translateEntityName(selectedLog?.entityType || ""), icon: Package, color: "slate" },
                   { label: "Mã định danh (ID)", val: selectedLog?.entityId, icon: Tag, color: "blue" },
                   { label: "Loại hành động", val: translateActionName(selectedLog?.action || ""), icon: Activity, color: "indigo" }
                 ].map((box, i) => (
                   <div key={i} className="bg-slate-50/50 p-5 rounded-2xl border border-slate-100 flex items-center gap-5 transition-all hover:bg-white hover:shadow-md">
                      <div className={cn(
                        "h-12 w-12 rounded-xl flex items-center justify-center shadow-sm",
                        box.color === 'slate' && "bg-white text-slate-500",
                        box.color === 'blue' && "bg-blue-50 text-blue-600",
                        box.color === 'indigo' && "bg-indigo-50 text-indigo-600",
                      )}>
                         {box.icon && <box.icon size={22} />}
                      </div>
                      <div>
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">{box.label}</p>
                        <p className="font-black text-slate-800 text-base leading-none">{box.val || "N/A"}</p>
                      </div>
                   </div>
                 ))}
              </div>
           </div>

            <div className="p-8 bg-slate-50 border-t border-slate-100 flex justify-end">
               <Button 
                 onClick={() => setIsDetailsOpen(false)}
                 className="bg-slate-900 hover:bg-black text-white px-12 h-14 rounded-2xl font-black transition-all active:scale-95 shadow-xl shadow-slate-900/20"
               >
                 Đóng thông tin chi tiết
               </Button>
            </div>
         </DialogContent>
      </Dialog>
    </div>
  );
}
