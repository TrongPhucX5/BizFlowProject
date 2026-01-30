"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { dashboardService } from "@/services/dashboard.service";
import { reportsService } from "@/services/reports.service";
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
  FileEdit,
  Trash2,
  Package,
  AlertCircle,
  Download,
  ArrowDownToLine,
  ClipboardCheck,
  UploadCloud,
  FileText,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import type { Product, ApiResponse, PageResponse } from "@/types/api";
import { toast } from "sonner"; // Ensure correct import

interface Unit {
  id: number;
  name: string;
}

// --- BỔ SUNG TYPE ĐỂ TRÁNH LỖI ĐỎ ---
interface ExtendedProduct extends Product {
  unitName?: string;
  stock?: number;
  reorderLevel?: number;
}

export default function ProductsPage() {
  const queryClient = useQueryClient();

  // --- STATE ---
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(50);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isImportDialogOpen, setIsImportDialogOpen] = useState(false);

  // --- TT88 EXPORT STATES ---
  const [exportFrom, setExportFrom] = useState("");
  const [exportTo, setExportTo] = useState("");
  const [exporting, setExporting] = useState(false);

  const [currentProduct, setCurrentProduct] =
    useState<Partial<ExtendedProduct> | null>(null);
  // const [selectedFile, setSelectedFile] = useState<File | null>(null); // Không cần nữa

  const [importData, setImportData] = useState({
    productId: 0,
    quantity: 0,
    unitCost: 0,
    note: "",
  });

  // --- DATA FETCHING ---
  // --- DATA FETCHING ---
  const { data: unitsData, error: unitsError } = useQuery({
    queryKey: ["units-list"],
    queryFn: dashboardService.getUnits,
  });

  if (unitsError) {
    console.error("Units Error:", unitsError);
  }

  const units = (unitsData as any)?.result || [];
  console.log("Loaded Units:", units);

  const { data, isLoading, isError, refetch } = useQuery<
    ApiResponse<PageResponse<ExtendedProduct>>
  >({
    queryKey: ["products-list", page, size, searchTerm, statusFilter],
    queryFn: async () => {
      const params: any = { page, size };
      if (searchTerm) params.search = searchTerm;
      if (statusFilter !== "ALL") params.status = statusFilter;
      const res = await dashboardService.getProducts(params);
      return res as unknown as ApiResponse<PageResponse<ExtendedProduct>>;
    },
    // keepPreviousData: true, // Use placeholderData in v5 if needed, but simple refetch is fine
  });

  // --- MUTATIONS ---
  // Xóa uploadImageMutation vì không cần API upload riêng biệt nữa
  // const uploadImageMutation = useMutation({
  //   mutationFn: (file: File) => dashboardService.uploadImage(file),
  //   onSuccess: (data) => {
  //     console.log("Upload API Response:", data);
  //     const imageUrl = data.result?.url;

  //     if (imageUrl) {
  //       setCurrentProduct((prev) => ({ ...prev, imageUrl }));
  //       toast.success("Tải ảnh lên thành công!");
  //     } else {
  //       console.error("imageUrl is missing in the response", data);
  //       toast.error("Lỗi: Không nhận được URL ảnh từ server.");
  //     }
  //   },
  //   onError: (error) => {
  //     console.error("Upload API Error:", error);
  //     toast.error("Có lỗi xảy ra khi tải ảnh lên.");
  //   },
  // });

  const createMutation = useMutation({
    mutationFn: dashboardService.createProduct,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products-list"] });
      await refetch();
      setIsDialogOpen(false);
      toast.success("Thêm mới thành công!");
    },
    onError: (error) => {
      console.error(error);
      toast.error("Có lỗi xảy ra khi thêm mới.");
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      dashboardService.updateProduct(id, data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products-list"] });
      await refetch();
      setIsDialogOpen(false);
      toast.success("Cập nhật thành công!");
    },
    onError: (error) => {
      console.error(error);
      toast.error("Có lỗi xảy ra khi cập nhật.");
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => dashboardService.deleteProduct(id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products-list"] });
      await refetch();
      toast.success("Xóa sản phẩm thành công!");
    },
    onError: (error: any) => {
      if (error?.response?.status === 403) {
        toast.error("Bạn không có quyền thực hiện hành động này.");
      } else {
        toast.error("Không thể xóa sản phẩm này (có thể do ràng buộc dữ liệu hoặc lỗi server).");
      }
    },
  });

  const importMutation = useMutation({
    mutationFn: dashboardService.importInventory,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products-list"] });
      await refetch();
      setIsImportDialogOpen(false);
      toast.success("Nhập kho thành công!");
    },
    onError: (error) => {
      console.error(error);
      toast.error("Có lỗi xảy ra khi nhập kho.");
    },
  });

  // --- ACTIONS ---
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      // Đọc file và chuyển đổi sang Base64
      const reader = new FileReader();
      reader.onloadend = () => {
        // reader.result sẽ là chuỗi Base64 (data:image/jpeg;base64,...)
        setCurrentProduct((prev) => ({
          ...prev,
          imageUrl: reader.result as string,
        }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleDelete = (id: number) => {
    if (confirm("Bạn có chắc chắn muốn xóa sản phẩm này không?")) {
      deleteMutation.mutate(id);
    }
  };

  const handleAddNew = () => {
    setCurrentProduct({ status: "ACTIVE", unitId: 1, stock: 0, imageUrl: "" }); // Reset imageUrl
    // setSelectedFile(null); // Không cần nữa
    setIsDialogOpen(true);
  };

  const handleEdit = (product: ExtendedProduct) => {
    setCurrentProduct(product);
    // setSelectedFile(null); // Không cần nữa
    setIsDialogOpen(true);
  };

  const handleImport = (product: ExtendedProduct) => {
    setImportData({
      productId: product.id,
      quantity: 0,
      unitCost: product.costPrice || 0,
      note: "Nhập hàng",
    });
    setIsImportDialogOpen(true);
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    const formData = currentProduct as ExtendedProduct;

    const payload = {
      ...formData,
      storeId: 1,
      categoryId: formData.categoryId || 1,
      unitId: formData.unitId || 1,
      status: formData.status || "ACTIVE",
      price: Number(formData.price),
      costPrice: Number(formData.costPrice),
      stock: Number(formData.stock || 0),
    };

    if (formData.id) {
      updateMutation.mutate({ id: formData.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const handleSaveImport = (e: React.FormEvent) => {
    e.preventDefault();
    importMutation.mutate(importData);
  };

  // --- XUẤT EXCEL ---
  const handleExportExcel = () => {
    const productsToExport = data?.result?.content || [];
    if (productsToExport.length === 0) {
      toast.warning("Không có dữ liệu để xuất!");
      return;
    }

    const headers = [
      "ID",
      "SKU",
      "Tên sản phẩm",
      "Đơn vị",
      "Giá vốn",
      "Giá bán",
      "Tồn kho",
      "Trạng thái",
    ];
    const rows = productsToExport.map((p) => [
      p.id,
      p.sku,
      `"${p.name}"`,
      p.unitName || p.unitId || "",
      p.costPrice,
      p.price,
      p.stock || 0,
      p.status,
    ]);

    const csvContent =
      "data:text/csv;charset=utf-8,\uFEFF" +
      [headers.join(","), ...rows.map((e) => e.join(","))].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute(
      "download",
      `danh_sach_san_pham_${new Date().toISOString().slice(0, 10)}.csv`,
    );
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleExportTT88Stock = async () => {
    if (!exportFrom || !exportTo) {
      toast.error("Vui lòng chọn khoảng thời gian xuất sổ!");
      return;
    }

    try {
      setExporting(true);
      const blob = await reportsService.exportTT88Stock(exportFrom, exportTo);

      const url = window.URL.createObjectURL(new Blob([blob]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `so-ton-kho-TT88-${exportFrom}-${exportTo}.xlsx`);
      document.body.appendChild(link);
      link.click();
      link.remove();

      toast.success("Đã xuất sổ tồn kho TT88!");
    } catch (error) {
      console.error(error);
      toast.error("Xuất sổ thất bại!");
    } finally {
      setExporting(false);
    }
  };

  // --- LOGIC LỌC Client-side removed in favor of Server-side ---
  const products = data?.result?.content || [];
  const totalPages = data?.result?.totalPages || 0;
  // const filteredProducts = products; // Handled by server params

  return (
    <div className="p-8 space-y-8 bg-slate-50/50 min-h-screen">
      {/* HEADER */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">
            Sản phẩm
          </h1>
          <p className="text-slate-500 mt-1">
            Quản lý danh mục hàng hóa, giá cả và tồn kho.
          </p>
        </div>
        <div className="flex gap-3">
          {/* EXPORT TT88 STOCK */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="outline"
                className="bg-white"
              >
                {exporting ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Download className="mr-2 h-4 w-4" />
                )}
                Xuất sổ TT88
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent className="w-80 p-4 rounded-xl shadow-xl border-none">
              <DropdownMenuLabel className="font-bold uppercase text-xs text-slate-400 mb-2">
                Chọn khoảng thời gian
              </DropdownMenuLabel>
              <div className="grid grid-cols-2 gap-2 mb-4">
                <div className="space-y-1">
                  <span className="text-[10px] font-bold uppercase text-slate-400">Từ ngày</span>
                  <Input
                    type="date"
                    value={exportFrom}
                    onChange={(e) => setExportFrom(e.target.value)}
                    className="h-9 rounded-lg font-bold text-xs"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-[10px] font-bold uppercase text-slate-400">Đến ngày</span>
                  <Input
                    type="date"
                    value={exportTo}
                    onChange={(e) => setExportTo(e.target.value)}
                    className="h-9 rounded-lg font-bold text-xs"
                  />
                </div>
              </div>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                onClick={handleExportTT88Stock}
                className="p-2 rounded-lg font-bold cursor-pointer hover:bg-emerald-50 hover:text-emerald-600"
              >
                <FileText className="mr-2 h-4 w-4" /> Xuất Sổ Tồn Kho
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <Button
            variant="outline"
            className="bg-white"
            onClick={handleExportExcel}
          >
            <Download className="mr-2 h-4 w-4" /> Xuất Excel (Thường)
          </Button>
          <Button
            onClick={handleAddNew}
            className="bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-200"
          >
            <Plus className="mr-2 h-4 w-4" /> Thêm sản phẩm
          </Button>
        </div>
      </div>

      {/* TOOLBAR */}
      <div className="flex flex-col sm:flex-row gap-4 items-center justify-between bg-white p-4 rounded-xl border shadow-sm">
        <div className="relative w-full sm:w-96">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Tìm kiếm theo tên, mã SKU..."
            className="pl-9 bg-slate-50 border-slate-200 focus-visible:ring-indigo-500"
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setPage(0); // Reset page on search
            }}
          />
        </div>
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <div className="flex items-center gap-2 border-r pr-4 mr-2">
            <Filter className="h-4 w-4 text-slate-500" />
            <span className="text-sm text-slate-600 font-medium hidden sm:inline">
              Lọc:
            </span>
          </div>
          <Select
            value={statusFilter}
            onValueChange={(val) => {
              setStatusFilter(val);
              setPage(0); // Reset page
            }}
          >
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Trạng thái" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">Tất cả trạng thái</SelectItem>
              <SelectItem value="ACTIVE">Đang kinh doanh</SelectItem>
              <SelectItem value="INACTIVE">Ngừng kinh doanh</SelectItem>
              <SelectItem value="DISCONTINUED">Bỏ mẫu</SelectItem>
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
                <TableHead className="w-[300px]">Sản phẩm</TableHead>
                <TableHead>Đơn vị</TableHead>
                <TableHead>Giá vốn</TableHead>
                <TableHead>Giá bán</TableHead>
                <TableHead>Tồn kho</TableHead>
                <TableHead>Trạng thái</TableHead>
                <TableHead className="text-right">Thao tác</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center">
                    <div className="flex flex-col items-center justify-center text-slate-500">
                      <Loader2 className="mr-2 h-4 w-4 animate-spin text-indigo-600" />
                      <p>Đang tải dữ liệu...</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : isError ? (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center">
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
              ) : products.length > 0 ? (
                products.map((item) => (
                  <TableRow
                    key={item.id}
                    className="group hover:bg-slate-50/50 transition-colors"
                  >
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-lg bg-slate-100 border flex items-center justify-center text-slate-400 shrink-0">
                          {item.imageUrl ? (
                            <img
                              src={item.imageUrl}
                              alt={item.name}
                              className="h-full w-full object-cover rounded-lg"
                            />
                          ) : (
                            <Package className="h-5 w-5" />
                          )}
                        </div>
                        <div>
                          <div className="font-semibold text-slate-900">
                            {item.name}
                          </div>
                          <div className="text-xs text-slate-500 font-mono mt-0.5 flex items-center gap-1">
                            <span className="px-1.5 py-0.5 rounded bg-slate-100 text-slate-600 border">
                              SKU: {item.sku}
                            </span>
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      {/* LOGIC HIỂN THỊ ID MỚI: Xử lý trường hợp null */}
                      {item.unitName ? (
                        <Badge
                          variant="secondary"
                          className="font-normal bg-slate-100 text-slate-600 hover:bg-slate-200"
                        >
                          {item.unitName}
                        </Badge>
                      ) : (
                        <span className="text-slate-400 text-sm italic">
                          {item.unitId
                            ? `ID: ${item.unitId}`
                            : "Chưa thiết lập"}
                        </span>
                      )}
                    </TableCell>
                    <TableCell className="text-slate-600 font-medium">
                      {item.costPrice?.toLocaleString()}đ
                    </TableCell>
                    <TableCell className="text-indigo-600 font-bold">
                      {item.price?.toLocaleString()}đ
                    </TableCell>
                    <TableCell>
                      {item.stock !== undefined && (
                        <div
                          className={cn(
                            "flex items-center gap-2 font-medium",
                            item.stock <= (item.reorderLevel || 10)
                              ? "text-red-600"
                              : "text-emerald-600",
                          )}
                        >
                          {item.stock}
                          {item.stock <= (item.reorderLevel || 10) && (
                            <AlertCircle className="h-3 w-3" />
                          )}
                        </div>
                      )}
                    </TableCell>
                    <TableCell>
                      <StatusBadge status={item.status} />
                    </TableCell>
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          {/* Đã xóa class opacity-0 để nút luôn hiện */}
                          <Button variant="ghost" className="h-8 w-8 p-0">
                            <span className="sr-only">Open menu</span>
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Hành động</DropdownMenuLabel>
                          <DropdownMenuItem onClick={() => handleImport(item)}>
                            <ArrowDownToLine className="mr-2 h-4 w-4 text-green-600" />{" "}
                            Nhập kho
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handleEdit(item)}>
                            <FileEdit className="mr-2 h-4 w-4 text-blue-500" />{" "}
                            Chỉnh sửa
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-red-600 focus:text-red-600 cursor-pointer"
                            onClick={() => handleDelete(item.id)}
                          >
                            <Trash2 className="mr-2 h-4 w-4" /> Xóa sản phẩm
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center">
                    <div className="flex flex-col items-center justify-center text-slate-500">
                      <Package className="h-8 w-8 mb-2 opacity-20" />
                      <p>Không tìm thấy sản phẩm nào.</p>
                    </div>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* PAGINATION */}
      <div className="flex items-center justify-between mt-4">
        <div className="text-sm text-slate-500 font-medium">
          Hiển thị {(page * size) + 1} - {Math.min((page + 1) * size, data?.result?.totalElements || 0)} trên tổng {data?.result?.totalElements || 0} sản phẩm
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setPage((old) => Math.max(0, old - 1))}
            disabled={page === 0}
            className="h-8 w-8 p-0"
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => {
              if (!data?.result?.totalPages) return;
              if (page >= data.result.totalPages - 1) return;
              setPage((old) => old + 1);
            }}
            disabled={page >= (totalPages || 1) - 1}
            className="h-8 w-8 p-0"
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* DIALOG FORM */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {currentProduct?.id ? "Cập nhật thông tin" : "Thêm sản phẩm mới"}
            </DialogTitle>
            <DialogDescription>
              Nhập đầy đủ thông tin chi tiết cho hàng hóa. Nhấn lưu để hoàn tất.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSave} className="grid gap-6 py-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="sku">
                  Mã SKU <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="sku"
                  value={currentProduct?.sku || ""}
                  onChange={(e) =>
                    setCurrentProduct({
                      ...currentProduct,
                      sku: e.target.value,
                    })
                  }
                  placeholder="VD: XM-HT-001"
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="unit">Đơn vị tính</Label>
                <Select
                  value={currentProduct?.unitId ? currentProduct.unitId.toString() : ""}
                  onValueChange={(val) =>
                    setCurrentProduct({
                      ...currentProduct,
                      unitId: Number(val),
                    })
                  }
                >
                  <SelectTrigger id="unit">
                    <SelectValue placeholder="Chọn đơn vị" />
                  </SelectTrigger>
                  <SelectContent>
                    {units.length > 0 ? (
                      units.map((u: Unit) => (
                        <SelectItem key={u.id} value={u.id.toString()}>
                          {u.name}
                        </SelectItem>
                      ))
                    ) : (
                      // Fallback if no units loaded or empty
                      <>
                        <SelectItem value="1">Cái</SelectItem>
                        <SelectItem value="2">Hộp</SelectItem>
                        <SelectItem value="3">Thùng</SelectItem>
                        <SelectItem value="4">Bao</SelectItem>
                      </>
                    )}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="name">
                Tên sản phẩm <span className="text-red-500">*</span>
              </Label>
              <Input
                id="name"
                value={currentProduct?.name || ""}
                onChange={(e) =>
                  setCurrentProduct({ ...currentProduct, name: e.target.value })
                }
                placeholder="VD: Xi măng Hà Tiên Đa Dụng"
                required
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="cost">Giá vốn (VNĐ)</Label>
                <Input
                  id="cost"
                  type="number"
                  value={currentProduct?.costPrice || ""}
                  onChange={(e) =>
                    setCurrentProduct({
                      ...currentProduct,
                      costPrice: Number(e.target.value),
                    })
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="price">
                  Giá bán (VNĐ) <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="price"
                  type="number"
                  value={currentProduct?.price || ""}
                  onChange={(e) =>
                    setCurrentProduct({
                      ...currentProduct,
                      price: Number(e.target.value),
                    })
                  }
                  required
                  className="font-bold text-indigo-600"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="stock">Tồn kho hiện tại</Label>
                <Input
                  id="stock"
                  type="number"
                  value={currentProduct?.stock || 0}
                  onChange={(e) =>
                    setCurrentProduct({
                      ...currentProduct,
                      stock: Number(e.target.value),
                    })
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="reorderLevel">
                  Mức báo động (Reorder Level)
                </Label>
                <Input
                  id="reorderLevel"
                  type="number"
                  value={currentProduct?.reorderLevel || 10}
                  onChange={(e) =>
                    setCurrentProduct({
                      ...currentProduct,
                      reorderLevel: Number(e.target.value),
                    })
                  }
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="desc">Mô tả thêm</Label>
              <Input
                id="desc"
                value={currentProduct?.description || ""}
                onChange={(e) =>
                  setCurrentProduct({
                    ...currentProduct,
                    description: e.target.value,
                  })
                }
                placeholder="Mô tả về đặc tính, công dụng..."
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="image">Hình ảnh sản phẩm</Label>
              <Input
                id="image"
                type="file"
                accept="image/*"
                onChange={handleFileChange}
                className="file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100"
              />
              {/* Không cần uploadImageMutation.isPending nữa */}
              {/* {uploadImageMutation.isPending && (
                <div className="flex items-center text-sm text-slate-500 mt-2">
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Đang tải ảnh lên...
                </div>
              )} */}
              {currentProduct?.imageUrl && (
                <div className="mt-2">
                  <img
                    src={currentProduct.imageUrl}
                    alt="Preview"
                    className="h-20 w-20 object-cover rounded-lg border"
                  />
                </div>
              )}
            </div>

            <div className="space-y-2">
              <Label>Trạng thái</Label>
              <Select
                value={currentProduct?.status}
                onValueChange={(val: any) =>
                  setCurrentProduct({ ...currentProduct, status: val })
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Chọn trạng thái" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ACTIVE">Đang kinh doanh</SelectItem>
                  <SelectItem value="INACTIVE">Tạm ngưng</SelectItem>
                  <SelectItem value="DISCONTINUED">Bỏ mẫu</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <DialogFooter className="mt-4">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsDialogOpen(false)}
              >
                Hủy bỏ
              </Button>
              <Button
                type="submit"
                className="bg-indigo-600 hover:bg-indigo-700"
                disabled={createMutation.isPending || updateMutation.isPending} // Xóa uploadImageMutation.isPending
              >
                {createMutation.isPending || updateMutation.isPending ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang xử lý
                  </>
                ) : (
                  "Lưu sản phẩm"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* IMPORT DIALOG */}
      <Dialog open={isImportDialogOpen} onOpenChange={setIsImportDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Nhập kho sản phẩm</DialogTitle>
            <DialogDescription>
              Nhập số lượng hàng mới về kho.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSaveImport} className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="import-quantity">Số lượng nhập</Label>
              <Input
                id="import-quantity"
                type="number"
                value={importData.quantity}
                onChange={(e) =>
                  setImportData({
                    ...importData,
                    quantity: Number(e.target.value),
                  })
                }
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="import-cost">Giá vốn nhập vào (VNĐ)</Label>
              <Input
                id="import-cost"
                type="number"
                value={importData.unitCost}
                onChange={(e) =>
                  setImportData({
                    ...importData,
                    unitCost: Number(e.target.value),
                  })
                }
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="import-note">Ghi chú</Label>
              <Input
                id="import-note"
                value={importData.note}
                onChange={(e) =>
                  setImportData({ ...importData, note: e.target.value })
                }
              />
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsImportDialogOpen(false)}
              >
                Hủy
              </Button>
              <Button
                type="submit"
                className="bg-green-600 hover:bg-green-700"
                disabled={importMutation.isPending}
              >
                {importMutation.isPending ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang xử lý
                  </>
                ) : (
                  "Xác nhận nhập kho"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function StatusBadge({ status }: { status: string | undefined }) {
  switch (status) {
    case "ACTIVE":
      return (
        <Badge className="bg-emerald-100 text-emerald-700 hover:bg-emerald-100 border-emerald-200">
          Đang bán
        </Badge>
      );
    case "INACTIVE":
      return (
        <Badge variant="secondary" className="bg-slate-100 text-slate-500">
          Tạm ngưng
        </Badge>
      );
    case "DISCONTINUED":
      return (
        <Badge
          variant="destructive"
          className="bg-red-100 text-red-700 hover:bg-red-100 border-red-200"
        >
          Bỏ mẫu
        </Badge>
      );
    default:
      return <Badge variant="outline">{status}</Badge>;
  }
}
