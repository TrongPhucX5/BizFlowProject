"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { customerService, CustomerRequest } from "@/services/customer.service";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
    Plus, Users, Loader2, MoreVertical, Search, MapPin, Mail, Phone,
    TrendingUp, PackageSearch, AlertTriangle, CheckCircle2, Pencil, Trash2
} from "lucide-react";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { toast } from "sonner";

export default function CustomersPage() {
    const router = useRouter();
    const queryClient = useQueryClient();
    const [isChecking, setIsChecking] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");

    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [isUpdateDialogOpen, setIsUpdateDialogOpen] = useState(false);
    const [selectedId, setSelectedId] = useState<number | null>(null);

    const [formData, setFormData] = useState<CustomerRequest>({
        name: "",
        phone: "",
        email: "",
        address: "",
        type: "RETAIL",
        status: "ACTIVE",
        storeId: 1
    });

    useEffect(() => {
        const token = localStorage.getItem("accessToken");
        if (!token) router.push("/auth/login");
        else setIsChecking(false);
    }, [router]);

    // 1. Lấy danh sách khách hàng (Đã hỗ trợ cấu trúc Page từ Backend)
    const { data: customersRes, isLoading } = useQuery({
        queryKey: ["customers-list"],
        queryFn: () => customerService.getCustomers(0, 100),
        enabled: !isChecking,
    });

    // 2. Mutation thêm khách hàng
    const createMutation = useMutation({
        mutationFn: (data: CustomerRequest) => customerService.createCustomer(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["customers-list"] });
            toast.success("Thêm khách hàng thành công!");
            setIsDialogOpen(false);
            resetForm();
        },
        onError: (error: any) => {
            // Hiển thị lỗi cụ thể từ Validation của Backend (ví dụ: Tên quá ngắn)
            const errMsg = error?.response?.data?.message || "Không thể thêm khách hàng";
            toast.error(errMsg);
        }
    });

    // 3. Mutation cập nhật khách hàng
    const updateMutation = useMutation({
        mutationFn: ({ id, data }: { id: number, data: CustomerRequest }) => 
            customerService.updateCustomer(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["customers-list"] });
            toast.success("Cập nhật thông tin thành công!");
            setIsUpdateDialogOpen(false);
            resetForm();
        },
        onError: (error: any) => {
            toast.error(error?.response?.data?.message || "Lỗi khi cập nhật thông tin");
        }
    });

    // 4. Mutation xóa khách hàng
    const deleteMutation = useMutation({
        mutationFn: (id: number) => customerService.deleteCustomer(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["customers-list"] });
            toast.success("Đã xóa khách hàng khỏi hệ thống");
        },
        onError: () => {
            toast.error("Không thể xóa khách hàng này");
        }
    });

    const resetForm = () => {
        setFormData({ name: "", phone: "", email: "", address: "", type: "RETAIL", status: "ACTIVE", storeId: 1 });
        setSelectedId(null);
    };

    // Hàm kiểm tra ràng buộc dữ liệu trước khi gửi lên Backend
    const validateData = () => {
        if (!formData.name || formData.name.length < 6) {
            toast.error("Tên khách hàng phải có ít nhất 6 ký tự");
            return false;
        }
        const nameRegex = /^[\p{L} ]+$/u;
        if (!nameRegex.test(formData.name)) {
            toast.error("Tên khách hàng chỉ được chứa chữ cái");
            return false;
        }
        if (!formData.phone) {
            toast.error("Vui lòng nhập số điện thoại");
            return false;
        }
        return true;
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (validateData()) {
            createMutation.mutate(formData);
        }
    };

    const handleUpdateSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (selectedId && validateData()) {
            updateMutation.mutate({ id: selectedId, data: formData });
        }
    };

    const openEditModal = (customer: any) => {
        setSelectedId(customer.id);
        setFormData({
            name: customer.name,
            phone: customer.phone,
            email: customer.email || "",
            address: customer.address || "",
            type: customer.type,
            status: customer.status,
            storeId: customer.storeId || 1
        });
        setIsUpdateDialogOpen(true);
    };

    // FIX LỖI HIỂN THỊ: Trích xuất content từ Page object
    const filteredCustomers = useMemo(() => {
        // Backend mới trả về ApiResponse<Page<Customer>>, dữ liệu nằm trong result.content
        const allCustomers = customersRes?.result?.content || []; 
        
        if (!searchTerm.trim()) return allCustomers;
        return allCustomers.filter((customer: any) =>
            customer.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            customer.phone?.includes(searchTerm)
        );
    }, [customersRes, searchTerm]);

    const getTypeBadge = (type: string) => {
        switch (type) {
            case 'WHOLESALE': return <Badge className="bg-amber-100 text-amber-700 hover:bg-amber-100 border-none px-3 font-bold">Bán buôn</Badge>;
            case 'RETAIL': return <Badge className="bg-emerald-100 text-emerald-700 hover:bg-emerald-100 border-none px-3 font-bold">Bán lẻ</Badge>;
            case 'CORPORATE': return <Badge className="bg-blue-100 text-blue-700 hover:bg-blue-100 border-none px-3 font-bold">Doanh nghiệp</Badge>;
            default: return <Badge variant="outline">{type}</Badge>;
        }
    };

    if (isChecking || isLoading) {
        return (
            <div className="flex flex-col items-center justify-center h-[60vh]">
                <Loader2 className="h-8 w-8 animate-spin text-indigo-600 mb-2" />
                <p className="text-slate-500 font-medium">Đang tải danh sách khách hàng...</p>
            </div>
        );
    }

    return (
        <div className="p-6 md:p-8 space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-black text-slate-900 tracking-tight">Khách hàng</h1>
                    <p className="text-slate-500 text-sm font-medium">Quản lý mạng lưới đối tác BizFlow</p>
                </div>

                <Dialog open={isDialogOpen} onOpenChange={(open) => { setIsDialogOpen(open); if(!open) resetForm(); }}>
                    <DialogTrigger asChild>
                        <Button className="bg-[#6366f1] hover:bg-indigo-700 shadow-lg font-bold py-6 px-6 rounded-2xl transition-all active:scale-95">
                            <Plus className="mr-2 h-5 w-5" /> Thêm khách hàng
                        </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-[500px] rounded-[32px] border-none shadow-2xl p-8">
                        <DialogHeader>
                            <DialogTitle className="text-2xl font-black text-slate-800">Khách hàng mới</DialogTitle>
                        </DialogHeader>
                        <CustomerForm 
                            formData={formData} 
                            setFormData={setFormData} 
                            onSubmit={handleSubmit} 
                            isPending={createMutation.isPending} 
                            buttonText="Lưu khách hàng"
                        />
                    </DialogContent>
                </Dialog>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <StatCard title="Tổng khách" value={filteredCustomers.length.toString()} icon={<Users className="text-indigo-600" />} trend="Khách hàng trong danh sách" />
                <StatCard title="Bán buôn" value={filteredCustomers.filter((c:any) => c.type === 'WHOLESALE').length.toString()} icon={<PackageSearch className="text-amber-600" />} trend="Đại lý cấp 1" />
                <StatCard title="Bán lẻ" value={filteredCustomers.filter((c:any) => c.type === 'RETAIL').length.toString()} icon={<TrendingUp className="text-emerald-600" />} trend="Khách hàng cá nhân" />
                <StatCard title="Công nợ" value="0đ" icon={<AlertTriangle className="text-red-600" />} trend="Cần thu hồi ngay" />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="lg:col-span-2 shadow-sm border-none bg-white rounded-[24px] overflow-hidden">
                    <CardHeader className="flex flex-row items-center justify-between border-b pb-4 px-6 bg-white">
                        <CardTitle className="text-sm font-black uppercase tracking-widest text-slate-400">Danh sách chi tiết</CardTitle>
                        <div className="relative w-64">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                            <Input 
                                placeholder="Tìm tên, số điện thoại..." 
                                className="pl-10 rounded-xl bg-slate-50 border-none h-10 focus-visible:ring-1 focus-visible:ring-indigo-500"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                        </div>
                    </CardHeader>
                    <CardContent className="p-0">
                        <Table>
                            <TableHeader className="bg-slate-50/50">
                                <TableRow className="border-slate-100">
                                    <TableHead className="font-bold pl-6 py-4 text-slate-700">Khách hàng</TableHead>
                                    <TableHead className="font-bold text-slate-700">Loại & Trạng thái</TableHead>
                                    <TableHead className="font-bold text-slate-700">Liên hệ</TableHead>
                                    <TableHead className="text-right font-bold pr-6 text-slate-700">Thao tác</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {filteredCustomers.length > 0 ? (
                                    filteredCustomers.map((item: any) => (
                                        <TableRow key={item.id} className="border-slate-50 hover:bg-slate-50/50 transition-colors group">
                                            <TableCell className="py-4 pl-6">
                                                <div className="flex flex-col">
                                                    <span className="font-bold text-slate-800 tracking-tight">{item.name}</span>
                                                    <div className="flex items-center text-[11px] text-slate-400 mt-0.5">
                                                        <Mail className="h-3 w-3 mr-1" /> {item.email || "N/A"}
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <div className="flex flex-col gap-1.5">
                                                    {getTypeBadge(item.type)}
                                                    <div className="flex items-center gap-1.5 px-1">
                                                        <div className={`h-1.5 w-1.5 rounded-full ${item.status === 'ACTIVE' ? 'bg-emerald-500' : 'bg-slate-300'}`} />
                                                        <span className="text-[10px] font-bold uppercase text-slate-400">
                                                            {item.status === 'ACTIVE' ? 'Hoạt động' : 'Tạm khóa'}
                                                        </span>
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <div className="flex flex-col gap-1">
                                                    <div className="flex items-center text-sm font-bold text-slate-600">
                                                        <Phone className="h-3 w-3 mr-1.5 text-slate-400" />
                                                        <span className="font-mono">{item.phone}</span>
                                                    </div>
                                                    <div className="flex items-center text-xs text-slate-400 max-w-[150px] truncate">
                                                        <MapPin className="h-3 w-3 mr-1.5 text-slate-400 flex-shrink-0" />
                                                        {item.address || "N/A"}
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell className="text-right pr-6">
                                                <DropdownMenu>
                                                    <DropdownMenuTrigger asChild>
                                                        <Button variant="ghost" size="icon" className="rounded-full">
                                                            <MoreVertical className="h-4 w-4 text-slate-400" />
                                                        </Button>
                                                    </DropdownMenuTrigger>
                                                    <DropdownMenuContent align="end" className="rounded-2xl border-none shadow-2xl p-2 w-40">
                                                        <DropdownMenuItem 
                                                            onClick={() => openEditModal(item)}
                                                            className="rounded-xl cursor-pointer font-bold text-indigo-600 focus:bg-indigo-50"
                                                        >
                                                            <Pencil className="mr-2 h-4 w-4" /> Chỉnh sửa
                                                        </DropdownMenuItem>
                                                        <DropdownMenuItem 
                                                            onClick={() => {
                                                                if(confirm(`Xóa khách hàng ${item.name}?`)) deleteMutation.mutate(item.id);
                                                            }}
                                                            className="rounded-xl cursor-pointer font-bold text-red-600 focus:bg-red-50"
                                                        >
                                                            <Trash2 className="mr-2 h-4 w-4" /> Xóa bỏ
                                                        </DropdownMenuItem>
                                                    </DropdownMenuContent>
                                                </DropdownMenu>
                                            </TableCell>
                                        </TableRow>
                                    ))
                                ) : (
                                    <TableRow><TableCell colSpan={4} className="h-32 text-center text-slate-400 italic">Không tìm thấy khách hàng nào...</TableCell></TableRow>
                                )}
                            </TableBody>
                        </Table>
                    </CardContent>
                </Card>

                <Card className="shadow-2xl border-none bg-[#1e1b4b] text-white rounded-[32px] p-2 h-fit">
                    <CardHeader>
                        <CardTitle className="text-sm font-bold flex items-center tracking-widest uppercase">
                            <span className="mr-2 text-lg">✨</span> Phân tích AI
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-6">
                        <div className="p-4 bg-white/5 rounded-2xl border border-white/10 backdrop-blur-sm">
                            <p className="text-sm italic font-medium leading-relaxed text-indigo-100">
                                "Ghi nhận khách hàng mới. Hệ thống gợi ý bạn nên gửi email chào mừng và giới thiệu chính sách ưu đãi cho loại khách {formData.type}."
                            </p>
                        </div>
                        <Button className="w-full bg-white text-indigo-900 hover:bg-indigo-50 font-black py-6 rounded-2xl shadow-xl transition-all active:scale-95">
                            Gửi ưu đãi hàng loạt
                        </Button>
                    </CardContent>
                </Card>
            </div>

            <Dialog open={isUpdateDialogOpen} onOpenChange={(open) => { setIsUpdateDialogOpen(open); if(!open) resetForm(); }}>
                <DialogContent className="sm:max-w-[500px] rounded-[32px] border-none shadow-2xl p-8">
                    <DialogHeader>
                        <DialogTitle className="text-2xl font-black text-slate-800">Cập nhật thông tin</DialogTitle>
                    </DialogHeader>
                    <CustomerForm 
                        formData={formData} 
                        setFormData={setFormData} 
                        onSubmit={handleUpdateSubmit} 
                        isPending={updateMutation.isPending} 
                        buttonText="Lưu thay đổi"
                        showStatus={true}
                    />
                </DialogContent>
            </Dialog>
        </div>
    );
}

// COMPONENT FORM DÙNG CHUNG (Giữ nguyên giao diện của bạn)
function CustomerForm({ formData, setFormData, onSubmit, isPending, buttonText, showStatus = false }: any) {
    return (
        <form onSubmit={onSubmit} className="space-y-5 pt-4">
            <div className="space-y-2">
                <label className="text-xs font-black uppercase text-slate-400 ml-1">Tên khách hàng * (Trên 5 ký tự)</label>
                <Input 
                    placeholder="Ví dụ: Nguyễn Văn A" 
                    className="rounded-xl border-slate-100 bg-slate-50 h-12"
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                />
            </div>
            <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                    <label className="text-xs font-black uppercase text-slate-400 ml-1">Số điện thoại *</label>
                    <Input 
                        placeholder="09xxx" 
                        className="rounded-xl border-slate-100 bg-slate-50 h-12"
                        value={formData.phone}
                        onChange={(e) => setFormData({...formData, phone: e.target.value})}
                    />
                </div>
                <div className="space-y-2">
                    <label className="text-xs font-black uppercase text-slate-400 ml-1">Loại khách</label>
                    <Select value={formData.type} onValueChange={(v) => setFormData({...formData, type: v})}>
                        <SelectTrigger className="rounded-xl border-slate-100 bg-slate-50 h-12">
                            <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="rounded-xl">
                            <SelectItem value="RETAIL">Bán lẻ</SelectItem>
                            <SelectItem value="WHOLESALE">Bán buôn</SelectItem>
                            <SelectItem value="CORPORATE">Doanh nghiệp</SelectItem>
                        </SelectContent>
                    </Select>
                </div>
            </div>

            {showStatus && (
                <div className="space-y-2">
                    <label className="text-xs font-black uppercase text-slate-400 ml-1">Trạng thái tài khoản</label>
                    <Select value={formData.status} onValueChange={(v) => setFormData({...formData, status: v})}>
                        <SelectTrigger className="rounded-xl border-slate-100 bg-slate-50 h-12">
                            <SelectValue />
                        </SelectTrigger>
                        <SelectContent className="rounded-xl">
                            <SelectItem value="ACTIVE">Đang hoạt động</SelectItem>
                            <SelectItem value="INACTIVE">Đang tạm khóa</SelectItem>
                        </SelectContent>
                    </Select>
                </div>
            )}

            <div className="space-y-2">
                <label className="text-xs font-black uppercase text-slate-400 ml-1">Email & Địa chỉ</label>
                <Input 
                    placeholder="Email..." 
                    className="rounded-xl border-slate-100 bg-slate-50 h-12 mb-2"
                    value={formData.email}
                    onChange={(e) => setFormData({...formData, email: e.target.value})}
                />
                <Input 
                    placeholder="Địa chỉ giao hàng..." 
                    className="rounded-xl border-slate-100 bg-slate-50 h-12"
                    value={formData.address}
                    onChange={(e) => setFormData({...formData, address: e.target.value})}
                />
            </div>
            <DialogFooter className="pt-4">
                <Button 
                    type="submit" 
                    disabled={isPending}
                    className="w-full bg-[#6366f1] hover:bg-indigo-700 text-white font-bold h-14 rounded-2xl shadow-lg transition-all"
                >
                    {isPending ? <Loader2 className="animate-spin h-5 w-5" /> : <><CheckCircle2 className="mr-2 h-5 w-5" /> {buttonText}</>}
                </Button>
            </DialogFooter>
        </form>
    );
}

function StatCard({ title, value, icon, trend }: any) {
    return (
        <Card className="shadow-sm border-none bg-white rounded-[24px] hover:shadow-md transition-all group">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-[10px] font-black text-slate-400 uppercase tracking-widest">{title}</CardTitle>
                <div className="p-2.5 bg-slate-50 rounded-xl group-hover:bg-indigo-50 transition-colors">{icon}</div>
            </CardHeader>
            <CardContent>
                <div className="text-3xl font-black text-slate-800">{value}</div>
                <p className="text-[11px] mt-1 text-slate-400 font-medium italic">{trend}</p>
            </CardContent>
        </Card>
    );
}