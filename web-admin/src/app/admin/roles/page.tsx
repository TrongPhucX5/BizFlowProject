"use client";

import { useEffect, useState } from "react";
import { roleService, Role, Permission } from "@/services/role.service";
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
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Checkbox } from "@/components/ui/checkbox";
import { Plus, Pencil, Trash2, Loader2, Shield } from "lucide-react";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";

export default function RolesPage() {
  const [roles, setRoles] = useState<Role[]>([]);
  const [permissions, setPermissions] = useState<Permission[]>([]);
  const [loading, setLoading] = useState(true);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  // Edit mode
  const [currentRole, setCurrentRole] = useState<Role | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    permissions: [] as string[]
  });

  const fetchData = async () => {
    try {
      setLoading(true);
      const [rolesRes, permsRes] = await Promise.all([
        roleService.getRoles(),
        roleService.getPermissions()
      ]);

      if (rolesRes.result) setRoles(rolesRes.result);
      if (permsRes.result) setPermissions(permsRes.result);
    } catch (error) {
      console.error(error);
      toast.error("Không thể tải dữ liệu");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleCreate = () => {
    setCurrentRole(null);
    setFormData({ name: "", description: "", permissions: [] });
    setIsDialogOpen(true);
  };

  const handleEdit = (role: Role) => {
    setCurrentRole(role);
    setFormData({
      name: role.name,
      description: role.description,
      permissions: role.permissions || []
    });
    setIsDialogOpen(true);
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Bạn có chắc chắn muốn xóa vai trò này?")) return;
    try {
      await roleService.deleteRole(id);
      toast.success("Xóa thành công");
      fetchData();
    } catch {
      toast.error("Xóa thất bại");
    }
  };

  const handleSave = async () => {
    try {
      setIsSaving(true);
      if (currentRole) {
        await roleService.updateRole(currentRole.id, formData);
        toast.success("Cập nhật thành công");
      } else {
        await roleService.createRole(formData);
        toast.success("Tạo mới thành công");
      }
      setIsDialogOpen(false);
      fetchData();
    } catch {
      toast.error("Có lỗi xảy ra");
    } finally {
      setIsSaving(false);
    }
  };

  const togglePermission = (permName: string) => {
    setFormData(prev => {
      const exists = prev.permissions.includes(permName);
      if (exists) {
        return { ...prev, permissions: prev.permissions.filter(p => p !== permName) };
      } else {
        return { ...prev, permissions: [...prev.permissions, permName] };
      }
    });
  };

  // Group permissions by module
  const groupedPermissions = permissions.reduce((acc, perm) => {
    const permModule = perm.module || "Other";
    if (!acc[permModule]) acc[permModule] = [];
    acc[permModule].push(perm);
    return acc;
  }, {} as Record<string, Permission[]>);

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Phân quyền Global</h1>
          <p className="text-muted-foreground">Quản lý vai trò và quyền hạn hệ thống</p>
        </div>
        <Button onClick={handleCreate} className="bg-blue-600 hover:bg-blue-700">
          <Plus className="mr-2 h-4 w-4" /> Tạo vai trò mới
        </Button>
      </div>

      <div className="border rounded-lg bg-white shadow-sm">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Tên vai trò</TableHead>
              <TableHead>Mô tả</TableHead>
              <TableHead>Số lượng quyền</TableHead>
              <TableHead className="text-right">Hành động</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                 <TableCell colSpan={4} className="h-24 text-center">
                   <Loader2 className="mr-2 h-4 w-4 animate-spin inline" /> Đang tải...
                 </TableCell>
              </TableRow>
            ) : roles.length === 0 ? (
              <TableRow>
                <TableCell colSpan={4} className="h-24 text-center text-muted-foreground">
                  Chưa có vai trò nào.
                </TableCell>
              </TableRow>
            ) : (
              roles.map((role) => (
                <TableRow key={role.id}>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <Shield className="h-4 w-4 text-blue-500" />
                      {role.name}
                    </div>
                  </TableCell>
                  <TableCell>{role.description}</TableCell>
                  <TableCell>
                    <Badge variant="secondary">{role.permissions?.length || 0} quyền</Badge>
                  </TableCell>
                  <TableCell className="text-right space-x-2">
                    <Button variant="ghost" size="sm" onClick={() => handleEdit(role)}>
                      <Pencil className="h-4 w-4 text-slate-500" />
                    </Button>
                    <Button variant="ghost" size="sm" onClick={() => handleDelete(role.id)}>
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{currentRole ? "Chỉnh sửa vai trò" : "Tạo vai trò mới"}</DialogTitle>
            <DialogDescription>
              Thiết lập thông tin và gán quyền cho vai trò này.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Tên vai trò</Label>
                <Input
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  placeholder="VD: STORE_MANAGER"
                />
              </div>
              <div className="space-y-2">
                <Label>Mô tả</Label>
                <Input
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  placeholder="Mô tả chức năng của vai trò..."
                />
              </div>
            </div>

            <div className="space-y-2 border-t pt-4">
              <Label className="text-base font-semibold">Danh sách quyền hạn</Label>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-2">
                {Object.entries(groupedPermissions).map(([module, perms]) => (
                  <div key={module} className="border p-3 rounded-lg">
                    <h4 className="font-medium text-blue-600 mb-3 uppercase text-sm border-b pb-1">{module}</h4>
                    <div className="space-y-3">
                      {perms.map((perm) => (
                        <div key={perm.id} className="flex items-start space-x-2">
                          <Checkbox
                            id={`perm-${perm.id}`}
                            checked={formData.permissions.includes(perm.name)}
                            onCheckedChange={() => togglePermission(perm.name)}
                          />
                          <div className="grid gap-1.5 leading-none">
                            <label
                              htmlFor={`perm-${perm.id}`}
                              className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
                            >
                              {perm.name}
                            </label>
                            <p className="text-[11px] text-muted-foreground">
                              {perm.description}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setIsDialogOpen(false)}>Hủy</Button>
            <Button onClick={handleSave} disabled={isSaving}>
              {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Lưu thay đổi
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
