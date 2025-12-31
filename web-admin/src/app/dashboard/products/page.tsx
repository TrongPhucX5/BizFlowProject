"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { dashboardService } from "@/services/dashboard.service";
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
} from "lucide-react";
import { cn } from "@/lib/utils";
import type { Product, ApiResponse, PageResponse } from "@/types/api";

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
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [currentProduct, setCurrentProduct] =
    useState<Partial<ExtendedProduct> | null>(null);

  // --- DATA FETCHING ---
  // QUAN TRỌNG: Lấy thêm hàm refetch để ép tải lại trang khi cần
  const { data, isLoading, refetch } = useQuery<
    ApiResponse<PageResponse<ExtendedProduct>>
  >({
    queryKey: ["products-list"],
    queryFn: async () => {
      const res = await dashboardService.getProducts();
      return res as unknown as ApiResponse<PageResponse<ExtendedProduct>>;
    },
  });

  // --- MUTATIONS ---
  const createMutation = useMutation({
    mutationFn: dashboardService.createProduct,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products-list"] });
      await refetch(); // Ép tải lại dữ liệu ngay lập tức
      setIsDialogOpen(false);
      alert("Thêm mới thành công!");
    },
    onError: (error) => {
      console.error(error);
      alert("Có lỗi xảy ra khi thêm mới.");
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      dashboardService.updateProduct(id, data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products-list"] });
      await refetch(); // Ép tải lại dữ liệu ngay lập tức
      setIsDialogOpen(false);
      alert("Cập nhật thành công!");
    },
    onError: (error) => {
      console.error(error);
      alert("Có lỗi xảy ra khi cập nhật.");
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => dashboardService.deleteProduct(id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["products-list"] });
      await refetch(); // Ép tải lại dữ liệu ngay lập tức
      alert("Xóa sản phẩm thành công!");
    },
    onError: () => {
      alert("Không thể xóa sản phẩm này (có thể do ràng buộc dữ liệu).");
    },
  });

  // --- ACTIONS ---
  const handleDelete = (id: number) => {
    if (confirm("Bạn có chắc chắn muốn xóa sản phẩm này không?")) {
      deleteMutation.mutate(id);
    }
  };

  const handleAddNew = () => {
    setCurrentProduct({ status: "ACTIVE", unitId: 1, stock: 0 });
    setIsDialogOpen(true);
  };

  const handleEdit = (product: ExtendedProduct) => {
    setCurrentProduct(product);
    setIsDialogOpen(true);
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

  // --- XUẤT EXCEL ---
  const handleExportExcel = () => {
    const productsToExport = data?.result?.content || [];
    if (productsToExport.length === 0) {
      alert("Không có dữ liệu để xuất!");
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
      `danh_sach_san_pham_${new Date().toISOString().slice(0, 10)}.csv`
    );
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // --- LOGIC LỌC ---
  const products = data?.result?.content || [];
  const filteredProducts = products.filter((item) => {
    const sTerm = searchTerm.toLowerCase();
    const matchesSearch =
      (item.name?.toLowerCase() || "").includes(sTerm) ||
      (item.sku?.toLowerCase() || "").includes(sTerm);
    const matchesStatus =
      statusFilter === "ALL" || item.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  if (isLoading) {
    return (
      <div className="flex flex-col items-center justify-center h-[80vh]">
        <Loader2 className="h-10 w-10 animate-spin text-indigo-600 mb-4" />
        <p className="text-slate-500 font-medium animate-pulse">
          Đang đồng bộ dữ liệu kho...
        </p>
      </div>
    );
  }

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
          <Button
            variant="outline"
            className="bg-white"
            onClick={handleExportExcel}
          >
            <Download className="mr-2 h-4 w-4" /> Xuất Excel
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
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <div className="flex items-center gap-2 border-r pr-4 mr-2">
            <Filter className="h-4 w-4 text-slate-500" />
            <span className="text-sm text-slate-600 font-medium hidden sm:inline">
              Lọc:
            </span>
          </div>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
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
              {filteredProducts.length > 0 ? (
                filteredProducts.map((item) => (
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
                              : "text-emerald-600"
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

      {/* DIALOG FORM */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-[600px]">
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
                <Label htmlFor="unit">Đơn vị tính (ID)</Label>
                <Input
                  id="unit"
                  type="number"
                  value={currentProduct?.unitId || ""}
                  onChange={(e) =>
                    setCurrentProduct({
                      ...currentProduct,
                      unitId: Number(e.target.value),
                    })
                  }
                  placeholder="VD: 1"
                />
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
                disabled={createMutation.isPending || updateMutation.isPending}
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
