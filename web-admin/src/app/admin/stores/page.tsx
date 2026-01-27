"use client";

import { useEffect, useState } from "react";
import { storeService, Store } from "@/services/store.service";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { MoreHorizontal, Lock, Unlock, Search, Loader2 } from "lucide-react";
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
import { format } from "date-fns";
import { useRouter } from "next/navigation";

export default function StoresPage() {
  const router = useRouter();
  const [stores, setStores] = useState<Store[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [search, setSearch] = useState("");

  // For confirmation dialog
  const [selectedStore, setSelectedStore] = useState<Store | null>(null);
  const [actionType, setActionType] = useState<"LOCK" | "UNLOCK" | null>(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);

  const fetchStores = async () => {
    try {
      setLoading(true);
      const res = await storeService.getStores({ page, size: 10, search });
      if (res && res.result) {
        setStores(res.result.content);
        setTotalPages(res.result.totalPages);
      }
    } catch (error) {
      console.error("Failed to fetch stores:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Debounce search could be added here, for now simple effect
    const timer = setTimeout(() => {
        fetchStores();
    }, 500);
    return () => clearTimeout(timer);
  }, [page, search]);

  const handleStatusChange = async () => {
    if (!selectedStore || !actionType) return;

    try {
      const newStatus = actionType === "LOCK" ? "LOCKED" : "ACTIVE";
      await storeService.updateStoreStatus(selectedStore.id, newStatus);
      fetchStores(); // Refresh list
    } catch (error) {
      console.error("Failed to update status:", error);
      alert("Cập nhật trạng thái thất bại!");
    } finally {
      setIsDialogOpen(false);
      setSelectedStore(null);
      setActionType(null);
    }
  };

  const openConfirmDialog = (store: Store, type: "LOCK" | "UNLOCK") => {
    setSelectedStore(store);
    setActionType(type);
    setIsDialogOpen(true);
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Quản lý Tenant</h1>
          <p className="text-muted-foreground">Danh sách các cửa hàng/doanh nghiệp trên hệ thống.</p>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="flex items-center gap-2">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Tìm kiếm theo tên, mã số thuế..."
            className="pl-8"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      {/* Stores Table */}
      <div className="border rounded-md bg-white">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>ID</TableHead>
              <TableHead>Tên cửa hàng</TableHead>
              <TableHead>Thông tin liên hệ</TableHead>
              <TableHead>MST</TableHead>
              <TableHead>Trạng thái</TableHead>
              <TableHead>Ngày tạo</TableHead>
              <TableHead className="text-right">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={7} className="h-24 text-center">
                  <div className="flex justify-center items-center gap-2">
                    <Loader2 className="h-4 w-4 animate-spin" /> Đang tải dữ liệu...
                  </div>
                </TableCell>
              </TableRow>
            ) : stores.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} className="h-24 text-center">
                  Không tìm thấy dữ liệu.
                </TableCell>
              </TableRow>
            ) : (
              stores.map((store) => (
                <TableRow key={store.id}>
                  <TableCell>{store.id}</TableCell>
                  <TableCell>
                    <div className="font-medium">{store.name}</div>
                    <div className="text-xs text-muted-foreground">{store.address}</div>
                  </TableCell>
                  <TableCell>
                    <div className="text-sm">{store.email}</div>
                    <div className="text-xs text-muted-foreground">{store.phone}</div>
                  </TableCell>
                  <TableCell>{store.taxCode}</TableCell>
                  <TableCell>
                    <Badge variant={store.status === "ACTIVE" ? "default" : store.status === "LOCKED" ? "destructive" : "secondary"}>
                      {store.status === "ACTIVE" ? "Hoạt động" : store.status === "LOCKED" ? "Đã khóa" : store.status}
                    </Badge>
                  </TableCell>
                  <TableCell>{format(new Date(store.createdAt), "dd/MM/yyyy")}</TableCell>
                  <TableCell className="text-right">
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" className="h-8 w-8 p-0">
                          <span className="sr-only">Open menu</span>
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuLabel>Thao tác</DropdownMenuLabel>
                        {store.status === "LOCKED" ? (
                             <DropdownMenuItem onClick={() => openConfirmDialog(store, "UNLOCK")}>
                                <Unlock className="mr-2 h-4 w-4" /> Mở khóa
                             </DropdownMenuItem>
                        ) : (
                             <DropdownMenuItem onClick={() => openConfirmDialog(store, "LOCK")} className="text-red-600">
                                <Lock className="mr-2 h-4 w-4" /> Khóa tài khoản
                             </DropdownMenuItem>
                        )}
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-end space-x-2">
        <Button
          variant="outline"
          size="sm"
          onClick={() => setPage((p) => Math.max(0, p - 1))}
          disabled={page === 0}
        >
          Trước
        </Button>
        <div className="text-sm">
          Trang {page + 1} / {totalPages > 0 ? totalPages : 1}
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
          disabled={page >= totalPages - 1}
        >
          Sau
        </Button>
      </div>

      {/* Confirmation Dialog */}
      <AlertDialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Xác nhận thay đổi trạng thái</AlertDialogTitle>
            <AlertDialogDescription>
              Bạn có chắc chắn muốn {actionType === "LOCK" ? "KHÓA" : "MỞ KHÓA"} cửa hàng{" "}
              <span className="font-bold text-foreground">{selectedStore?.name}</span> không?
              {actionType === "LOCK" && (
                <p className="mt-2 text-red-500 text-sm">
                  Lưu ý: Khi bị khóa, toàn bộ nhân viên của cửa hàng này sẽ không thể truy cập hệ thống.
                </p>
              )}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Hủy bỏ</AlertDialogCancel>
            <AlertDialogAction
                className={actionType === "LOCK" ? "bg-red-600 hover:bg-red-700" : ""}
                onClick={handleStatusChange}
            >
              {actionType === "LOCK" ? "Xác nhận Khóa" : "Xác nhận Mở"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
