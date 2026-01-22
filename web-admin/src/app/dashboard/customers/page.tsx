"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { customersService } from "@/services/customers.service";
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
import { Textarea } from "@/components/ui/textarea";
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
  User,
  Phone,
  Mail,
  MapPin,
  CreditCard,
  Download,
  TrendingUp,
  AlertCircle,
} from "lucide-react";
import { format } from "date-fns";
import { vi } from "date-fns/locale";
import { cn } from "@/lib/utils";
import type { Customer, ApiResponse, PageResponse } from "@/types/api";

export default function CustomersPage() {
  const queryClient = useQueryClient();

  // --- STATE ---
  const [searchTerm, setSearchTerm] = useState("");
  const [typeFilter, setTypeFilter] = useState("ALL");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false);
  const [currentCustomer, setCurrentCustomer] = useState<Customer | null>(null);
  const [formData, setFormData] = useState({
    fullName: "",
    phone: "",
    email: "",
    address: "",
    customerType: "REGULAR",
  });

  // --- DATA FETCHING ---
  const { data, isLoading, isError, refetch } = useQuery<
    ApiResponse<PageResponse<Customer>>
  >({
    queryKey: ["customers-list", typeFilter, statusFilter],
    queryFn: async () => {
      const params: any = { size: 50 };
      if (typeFilter !== "ALL") params.type = typeFilter;
      if (statusFilter !== "ALL") params.status = statusFilter;

      const res = await customersService.getCustomers(params);
      return res as ApiResponse<PageResponse<Customer>>;
    },
    retry: 1,
  });

  // --- MUTATIONS ---
  const createMutation = useMutation({
    mutationFn: customersService.createCustomer,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      setIsDialogOpen(false);
      resetForm();
      alert("Tạo khách hàng thành công!");
    },
    onError: (error: any) => {
      alert(
        error.response?.data?.message || "Có lỗi xảy ra khi tạo khách hàng"
      );
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      customersService.updateCustomer(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      setIsDialogOpen(false);
      resetForm();
      alert("Cập nhật khách hàng thành công!");
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => customersService.deleteCustomer(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      alert("Xóa khách hàng thành công!");
    },
  });

  // --- ACTIONS ---
  const handleViewCustomer = (customer: Customer) => {
    setCurrentCustomer(customer);
    setIsViewDialogOpen(true);
  };

  const handleEditCustomer = (customer: Customer) => {
    setCurrentCustomer(customer);
    setFormData({
      fullName: customer.fullName,
      phone: customer.phone,
      email: customer.email || "",
      address: customer.address || "",
      customerType: customer.customerType,
    });
    setIsDialogOpen(true);
  };

  const handleDelete = (id: number) => {
    if (confirm("Bạn có chắc muốn xóa khách hàng này?")) {
      deleteMutation.mutate(id);
    }
  };

  const handleAddNew = () => {
    setCurrentCustomer(null);
    resetForm();
    setIsDialogOpen(true);
  };

  const resetForm = () => {
    setFormData({
      fullName: "",
      phone: "",
      email: "",
      address: "",
      customerType: "REGULAR",
    });
  };

  const handleSaveCustomer = (e: React.FormEvent) => {
    e.preventDefault();

    const customerData = {
      fullName: formData.fullName,
      phone: formData.phone,
      email: formData.email || null,
      address: formData.address || null,
      customerType: formData.customerType,
      // Thêm các trường bắt buộc khác nếu cần
      storeId: 1, // Lấy từ user hiện tại
    };

    if (currentCustomer) {
      updateMutation.mutate({ id: currentCustomer.id, data: customerData });
    } else {
      createMutation.mutate(customerData);
    }
  };

  const handleFormChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  // --- FILTER LOGIC ---
  const customers = data?.result?.content || [];
  const filteredCustomers = customers.filter((customer) => {
    const searchLower = searchTerm.toLowerCase();
    const matchesSearch =
      customer.fullName.toLowerCase().includes(searchLower) ||
      customer.phone.includes(searchTerm) ||
      customer.code.toLowerCase().includes(searchLower) ||
      customer.email?.toLowerCase().includes(searchLower);

    const matchesType =
      typeFilter === "ALL" || customer.customerType === typeFilter;
    const matchesStatus =
      statusFilter === "ALL" || customer.status === statusFilter;

    return matchesSearch && matchesType && matchesStatus;
  });

  // --- STATS ---
  const stats = {
    totalCustomers: customers.length,
    totalDebt: customers.reduce(
      (sum, customer) => sum + customer.debtAmount,
      0
    ),
    vipCustomers: customers.filter((c) => c.customerType === "VIP").length,
    activeCustomers: customers.filter((c) => c.status === "ACTIVE").length,
  };

  return (
    <div className="p-8 space-y-8 bg-slate-50/50 min-h-screen">
      {/* HEADER */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">
            Quản lý Khách hàng
          </h1>
          <p className="text-slate-500 mt-1">
            Quản lý thông tin khách hàng và theo dõi công nợ.
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
            className="bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-200"
          >
            <Plus className="mr-2 h-4 w-4" /> Thêm khách hàng
          </Button>
        </div>
      </div>

      {/* STATS CARDS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Tổng khách hàng</p>
                <p className="text-2xl font-bold text-slate-900">
                  {stats.totalCustomers}
                </p>
              </div>
              <div className="p-2 bg-blue-50 rounded-lg">
                <User className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Tổng công nợ</p>
                <p className="text-2xl font-bold text-amber-600">
                  {stats.totalDebt.toLocaleString()}đ
                </p>
              </div>
              <div className="p-2 bg-amber-50 rounded-lg">
                <CreditCard className="h-6 w-6 text-amber-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Khách VIP</p>
                <p className="text-2xl font-bold text-purple-600">
                  {stats.vipCustomers}
                </p>
              </div>
              <div className="p-2 bg-purple-50 rounded-lg">
                <TrendingUp className="h-6 w-6 text-purple-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white border-none shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-500">Đang hoạt động</p>
                <p className="text-2xl font-bold text-emerald-600">
                  {stats.activeCustomers}
                </p>
              </div>
              <div className="p-2 bg-emerald-50 rounded-lg">
                <User className="h-6 w-6 text-emerald-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* TOOLBAR */}
      <div className="flex flex-col sm:flex-row gap-4 items-center justify-between bg-white p-4 rounded-xl border shadow-sm">
        <div className="relative w-full sm:w-96">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Tìm theo tên, SĐT, mã KH..."
            className="pl-9 bg-slate-50 border-slate-200 focus-visible:ring-indigo-500"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="flex items-center gap-3 w-full sm:w-auto">
          <Select value={typeFilter} onValueChange={setTypeFilter}>
            <SelectTrigger className="w-[140px]">
              <SelectValue placeholder="Loại KH" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">Tất cả loại</SelectItem>
              <SelectItem value="REGULAR">Thường</SelectItem>
              <SelectItem value="VIP">VIP</SelectItem>
              <SelectItem value="WHOLESALE">Sỉ</SelectItem>
            </SelectContent>
          </Select>

          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-[140px]">
              <SelectValue placeholder="Trạng thái" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">Tất cả</SelectItem>
              <SelectItem value="ACTIVE">Đang hoạt động</SelectItem>
              <SelectItem value="INACTIVE">Ngừng hoạt động</SelectItem>
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
                <TableHead>Mã KH</TableHead>
                <TableHead>Khách hàng</TableHead>
                <TableHead>Liên hệ</TableHead>
                <TableHead>Tổng mua</TableHead>
                <TableHead>Công nợ</TableHead>
                <TableHead>Loại KH</TableHead>
                <TableHead>Trạng thái</TableHead>
                <TableHead className="text-right">Thao tác</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={8} className="h-32 text-center">
                    <div className="flex flex-col items-center justify-center text-slate-500">
                      <Loader2 className="h-8 w-8 mb-2 animate-spin text-indigo-600" />
                      <p>Đang tải dữ liệu...</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : isError ? (
                <TableRow>
                  <TableCell colSpan={8} className="h-32 text-center">
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
              ) : filteredCustomers.length > 0 ? (
                filteredCustomers.map((customer) => (
                  <TableRow key={customer.id} className="hover:bg-slate-50/50">
                    <TableCell className="font-mono font-bold text-slate-900">
                      {customer.code}
                    </TableCell>
                    <TableCell>
                      <div className="font-medium">{customer.fullName}</div>
                      {customer.address && (
                        <div className="text-xs text-slate-500 truncate max-w-[200px]">
                          {customer.address}
                        </div>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="space-y-1">
                        <div className="flex items-center gap-1 text-sm">
                          <Phone className="h-3 w-3 text-slate-400" />
                          {customer.phone}
                        </div>
                        {customer.email && (
                          <div className="flex items-center gap-1 text-sm">
                            <Mail className="h-3 w-3 text-slate-400" />
                            <span className="truncate max-w-[150px]">
                              {customer.email}
                            </span>
                          </div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell className="font-bold text-slate-900">
                      {(customer.totalPurchaseAmount || 0).toLocaleString()}đ
                    </TableCell>
                    <TableCell>
                      <div
                        className={cn(
                          "font-bold",
                          customer.debtAmount > 0
                            ? "text-amber-600"
                            : "text-emerald-600"
                        )}
                      >
                        {(customer.totalDebt || 0).toLocaleString()}đ
                      </div>
                    </TableCell>
                    <TableCell>
                      <CustomerTypeBadge type={customer.customerType} />
                    </TableCell>
                    <TableCell>
                      <CustomerStatusBadge status={customer.status} />
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleViewCustomer(customer)}
                          className="h-8 px-2"
                        >
                          <Eye className="h-4 w-4 text-blue-500" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleEditCustomer(customer)}
                          className="h-8 px-2"
                        >
                          <FileEdit className="h-4 w-4 text-indigo-500" />
                        </Button>
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuLabel>Hành động</DropdownMenuLabel>
                            <DropdownMenuItem
                              onClick={() => handleViewCustomer(customer)}
                            >
                              <Eye className="mr-2 h-4 w-4" /> Xem chi tiết
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => handleEditCustomer(customer)}
                            >
                              <FileEdit className="mr-2 h-4 w-4" /> Chỉnh sửa
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                              className="text-red-600"
                              onClick={() => handleDelete(customer.id)}
                            >
                              <Trash2 className="mr-2 h-4 w-4" /> Xóa khách hàng
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={8} className="h-32 text-center">
                    <div className="flex flex-col items-center justify-center text-slate-500">
                      <User className="h-8 w-8 mb-2 opacity-20" />
                      <p>Không tìm thấy khách hàng nào.</p>
                      <Button
                        variant="link"
                        onClick={handleAddNew}
                        className="mt-2"
                      >
                        Thêm khách hàng mới
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* CUSTOMER FORM DIALOG */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-[550px]">
          <DialogHeader>
            <DialogTitle>
              {currentCustomer ? "Cập nhật khách hàng" : "Thêm khách hàng mới"}
            </DialogTitle>
            <DialogDescription>
              {currentCustomer
                ? `Cập nhật thông tin cho ${currentCustomer.fullName}`
                : "Nhập thông tin khách hàng mới"}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSaveCustomer}>
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="fullName">
                    Họ tên <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    id="fullName"
                    value={formData.fullName}
                    onChange={(e) =>
                      handleFormChange("fullName", e.target.value)
                    }
                    placeholder="Nguyễn Văn A"
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">
                    Số điện thoại <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    id="phone"
                    value={formData.phone}
                    onChange={(e) => handleFormChange("phone", e.target.value)}
                    placeholder="0901234567"
                    required
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleFormChange("email", e.target.value)}
                  placeholder="customer@email.com"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="address">Địa chỉ</Label>
                <Textarea
                  id="address"
                  value={formData.address}
                  onChange={(e) => handleFormChange("address", e.target.value)}
                  placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố"
                  rows={2}
                />
              </div>

              <div className="space-y-2">
                <Label>Loại khách hàng</Label>
                <Select
                  value={formData.customerType}
                  onValueChange={(value) =>
                    handleFormChange("customerType", value)
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn loại khách hàng" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="REGULAR">Khách thường</SelectItem>
                    <SelectItem value="VIP">Khách VIP</SelectItem>
                    <SelectItem value="WHOLESALE">Khách sỉ</SelectItem>
                  </SelectContent>
                </Select>
              </div>
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
                disabled={createMutation.isPending || updateMutation.isPending}
              >
                {createMutation.isPending || updateMutation.isPending ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang xử lý
                  </>
                ) : currentCustomer ? (
                  "Cập nhật khách hàng"
                ) : (
                  "Thêm khách hàng"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* VIEW CUSTOMER DIALOG */}
      <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
        <DialogContent className="sm:max-w-[600px]">
          <DialogHeader>
            <DialogTitle>Thông tin khách hàng</DialogTitle>
            <DialogDescription>
              Chi tiết khách hàng #{currentCustomer?.code}
            </DialogDescription>
          </DialogHeader>
          {currentCustomer && (
            <div className="space-y-6">
              {/* Basic Info */}
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label className="text-slate-500">Mã khách hàng</Label>
                  <p className="font-mono font-bold">{currentCustomer.code}</p>
                </div>
                <div className="space-y-2">
                  <Label className="text-slate-500">Loại khách hàng</Label>
                  <div>
                    <CustomerTypeBadge type={currentCustomer.customerType} />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label className="text-slate-500">Họ tên</Label>
                  <p className="font-bold text-lg">
                    {currentCustomer.fullName}
                  </p>
                </div>
                <div className="space-y-2">
                  <Label className="text-slate-500">Trạng thái</Label>
                  <div>
                    <CustomerStatusBadge status={currentCustomer.status} />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label className="text-slate-500">Số điện thoại</Label>
                  <p className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-slate-400" />
                    {currentCustomer.phone}
                  </p>
                </div>
                {currentCustomer.email && (
                  <div className="space-y-2">
                    <Label className="text-slate-500">Email</Label>
                    <p className="flex items-center gap-2">
                      <Mail className="h-4 w-4 text-slate-400" />
                      {currentCustomer.email}
                    </p>
                  </div>
                )}
              </div>

              {/* Address */}
              {currentCustomer.address && (
                <div className="space-y-2">
                  <Label className="text-slate-500">Địa chỉ</Label>
                  <p className="flex items-start gap-2 p-3 bg-slate-50 rounded-lg">
                    <MapPin className="h-4 w-4 text-slate-400 mt-0.5" />
                    {currentCustomer.address}
                  </p>
                </div>
              )}

              {/* Financial Summary */}
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label className="text-slate-500">Tổng mua hàng</Label>
                  <p className="text-2xl font-bold text-slate-900">
                    {currentCustomer.totalPurchaseAmount.toLocaleString()}đ
                  </p>
                </div>
                <div className="space-y-2">
                  <Label className="text-slate-500">Công nợ hiện tại</Label>
                  <p
                    className={cn(
                      "text-2xl font-bold",
                      currentCustomer.debtAmount > 0
                        ? "text-amber-600"
                        : "text-emerald-600"
                    )}
                  >
                    {currentCustomer.debtAmount.toLocaleString()}đ
                  </p>
                </div>
              </div>

              {/* Dates */}
              <div className="grid grid-cols-2 gap-6 pt-4 border-t">
                <div className="space-y-2">
                  <Label className="text-slate-500">Ngày tạo</Label>
                  <p>
                    {format(
                      new Date(currentCustomer.createdAt),
                      "dd/MM/yyyy HH:mm",
                      {
                        locale: vi,
                      }
                    )}
                  </p>
                </div>
                <div className="space-y-2">
                  <Label className="text-slate-500">Cập nhật cuối</Label>
                  <p>
                    {format(
                      new Date(currentCustomer.updatedAt),
                      "dd/MM/yyyy HH:mm",
                      {
                        locale: vi,
                      }
                    )}
                  </p>
                </div>
              </div>
            </div>
          )}
          <DialogFooter className="pt-4">
            <Button
              variant="outline"
              onClick={() => setIsViewDialogOpen(false)}
            >
              Đóng
            </Button>
            {currentCustomer && (
              <Button
                onClick={() => {
                  setIsViewDialogOpen(false);
                  handleEditCustomer(currentCustomer);
                }}
                className="bg-indigo-600 hover:bg-indigo-700"
              >
                <FileEdit className="mr-2 h-4 w-4" /> Chỉnh sửa
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function CustomerTypeBadge({ type }: { type: string }) {
  const getTypeConfig = (type: string) => {
    switch (type) {
      case "VIP":
        return {
          label: "VIP",
          className: "bg-purple-100 text-purple-700 border-purple-200",
        };
      case "WHOLESALE":
        return {
          label: "Khách sỉ",
          className: "bg-blue-100 text-blue-700 border-blue-200",
        };
      default:
        return {
          label: "Thường",
          className: "bg-slate-100 text-slate-700 border-slate-200",
        };
    }
  };

  const config = getTypeConfig(type);
  return (
    <Badge className={cn("px-2 py-1 text-xs font-medium", config.className)}>
      {config.label}
    </Badge>
  );
}

function CustomerStatusBadge({ status }: { status: string }) {
  const getStatusConfig = (status: string) => {
    switch (status) {
      case "ACTIVE":
        return {
          label: "Đang hoạt động",
          className: "bg-emerald-100 text-emerald-700 border-emerald-200",
        };
      case "INACTIVE":
        return {
          label: "Ngừng hoạt động",
          className: "bg-red-100 text-red-700 border-red-200",
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
