"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { settingsService } from "@/services/settings.service";
import { userService } from "@/services/user.service";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Settings,
  Users,
  Store,
  Shield,
  Bell,
  Globe,
  Save,
  Plus,
  FileEdit,
  Trash2,
  Mail,
  Phone,
  User,
  Key,
  Loader2,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";

export default function SettingsPage() {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState("store");
  const [isUserDialogOpen, setIsUserDialogOpen] = useState(false);
  const [currentUser, setCurrentUser] = useState<any>(null);

  // Fetch dữ liệu
  const { data: storeInfo, isLoading: isLoadingStore } = useQuery({
    queryKey: ["store-info"],
    queryFn: settingsService.getStoreInfo,
  });

  const { data: usersData, isLoading: isLoadingUsers } = useQuery({
    queryKey: ["users-list"],
    queryFn: userService.getUsers,
  });

  const { data: systemSettings, isLoading: isLoadingSystem } = useQuery({
    queryKey: ["system-settings"],
    queryFn: settingsService.getSystemSettings,
  });

  // Mutations
  const updateStoreMutation = useMutation({
    mutationFn: settingsService.updateStoreInfo,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["store-info"] });
      alert("Cập nhật thông tin cửa hàng thành công!");
    },
  });

  const updateSystemMutation = useMutation({
    mutationFn: settingsService.updateSystemSettings,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["system-settings"] });
      alert("Cập nhật cài đặt hệ thống thành công!");
    },
  });

  const createUserMutation = useMutation({
    mutationFn: settingsService.createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users-list"] });
      setIsUserDialogOpen(false);
      setCurrentUser(null);
      alert("Tạo người dùng thành công!");
    },
  });

  const updateUserMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      settingsService.updateUser(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users-list"] });
      setIsUserDialogOpen(false);
      setCurrentUser(null);
      alert("Cập nhật người dùng thành công!");
    },
  });

  const deleteUserMutation = useMutation({
    mutationFn: (id: number) => settingsService.deleteUser(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users-list"] });
      alert("Xóa người dùng thành công!");
    },
  });

  // Form states
  const [storeForm, setStoreForm] = useState({
    name: "BizFlow Store",
    address: "123 Đường Lê Lợi, Quận 1, TP.HCM",
    phone: "028 3823 4567",
    email: "contact@bizflow.com",
    taxCode: "0312345678",
    description: "Chuyên cung cấp vật liệu xây dựng chất lượng cao",
  });

  const [systemForm, setSystemForm] = useState({
    invoicePrefix: "HD",
    invoiceStartNumber: 1001,
    lowStockThreshold: 10,
    enableNotifications: true,
    enableEmailAlerts: true,
    currency: "VND",
    timezone: "Asia/Ho_Chi_Minh",
    language: "vi",
  });

  const [userForm, setUserForm] = useState({
    username: "",
    password: "",
    fullName: "",
    email: "",
    phone: "",
    role: "EMPLOYEE",
  });

  // Handlers
  const handleStoreSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateStoreMutation.mutate(storeForm);
  };

  const handleSystemSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateSystemMutation.mutate(systemForm);
  };

  const handleUserSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (currentUser) {
      updateUserMutation.mutate({ id: currentUser.id, data: userForm });
    } else {
      createUserMutation.mutate(userForm);
    }
  };

  const handleEditUser = (user: any) => {
    setCurrentUser(user);
    setUserForm({
      username: user.username,
      password: "", // Không hiển thị password cũ
      fullName: user.fullName,
      email: user.email || "",
      phone: user.phone || "",
      role: user.role,
    });
    setIsUserDialogOpen(true);
  };

  const handleAddUser = () => {
    setCurrentUser(null);
    setUserForm({
      username: "",
      password: "",
      fullName: "",
      email: "",
      phone: "",
      role: "EMPLOYEE",
    });
    setIsUserDialogOpen(true);
  };

  const handleDeleteUser = (id: number) => {
    if (confirm("Bạn có chắc muốn xóa người dùng này?")) {
      deleteUserMutation.mutate(id);
    }
  };

  const isLoading = isLoadingStore || isLoadingUsers || isLoadingSystem;

  if (isLoading) {
    return (
      <div className="flex flex-col items-center justify-center h-[80vh]">
        <Loader2 className="h-10 w-10 animate-spin text-indigo-600 mb-4" />
        <p className="text-slate-500 font-medium animate-pulse">
          Đang tải cài đặt hệ thống...
        </p>
      </div>
    );
  }

  const users = usersData?.result || [];

  return (
    <div className="p-8 space-y-8 bg-slate-50/50 min-h-screen">
      {/* HEADER */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">
            Cài đặt hệ thống
          </h1>
          <p className="text-slate-500 mt-1">
            Quản lý cấu hình và thông tin cửa hàng
          </p>
        </div>
      </div>

      {/* MAIN TABS */}
      <Tabs
        value={activeTab}
        onValueChange={setActiveTab}
        className="space-y-6"
      >
        <TabsList className="grid grid-cols-4 w-full max-w-2xl">
          <TabsTrigger value="store" className="flex items-center gap-2">
            <Store className="h-4 w-4" /> Cửa hàng
          </TabsTrigger>
          <TabsTrigger value="users" className="flex items-center gap-2">
            <Users className="h-4 w-4" /> Người dùng
          </TabsTrigger>
          <TabsTrigger value="system" className="flex items-center gap-2">
            <Settings className="h-4 w-4" /> Hệ thống
          </TabsTrigger>
          <TabsTrigger value="security" className="flex items-center gap-2">
            <Shield className="h-4 w-4" /> Bảo mật
          </TabsTrigger>
        </TabsList>

        {/* STORE SETTINGS */}
        <TabsContent value="store">
          <Card>
            <CardHeader>
              <CardTitle>Thông tin cửa hàng</CardTitle>
              <CardDescription>
                Cập nhật thông tin hiển thị trên hóa đơn và báo cáo
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleStoreSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <Label htmlFor="store-name">
                      Tên cửa hàng <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="store-name"
                      value={storeForm.name}
                      onChange={(e) =>
                        setStoreForm({ ...storeForm, name: e.target.value })
                      }
                      placeholder="Nhập tên cửa hàng"
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="tax-code">Mã số thuế</Label>
                    <Input
                      id="tax-code"
                      value={storeForm.taxCode}
                      onChange={(e) =>
                        setStoreForm({ ...storeForm, taxCode: e.target.value })
                      }
                      placeholder="Nhập mã số thuế"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="store-phone">
                      Số điện thoại <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="store-phone"
                      value={storeForm.phone}
                      onChange={(e) =>
                        setStoreForm({ ...storeForm, phone: e.target.value })
                      }
                      placeholder="Nhập số điện thoại"
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="store-email">Email liên hệ</Label>
                    <Input
                      id="store-email"
                      type="email"
                      value={storeForm.email}
                      onChange={(e) =>
                        setStoreForm({ ...storeForm, email: e.target.value })
                      }
                      placeholder="Nhập email"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="store-address">Địa chỉ</Label>
                  <Textarea
                    id="store-address"
                    value={storeForm.address}
                    onChange={(e) =>
                      setStoreForm({ ...storeForm, address: e.target.value })
                    }
                    placeholder="Nhập địa chỉ cửa hàng"
                    rows={3}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="store-description">Mô tả cửa hàng</Label>
                  <Textarea
                    id="store-description"
                    value={storeForm.description}
                    onChange={(e) =>
                      setStoreForm({
                        ...storeForm,
                        description: e.target.value,
                      })
                    }
                    placeholder="Mô tả về cửa hàng"
                    rows={3}
                  />
                </div>

                <div className="flex justify-end pt-4">
                  <Button
                    type="submit"
                    className="bg-indigo-600 hover:bg-indigo-700"
                    disabled={updateStoreMutation.isPending}
                  >
                    {updateStoreMutation.isPending ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang
                        lưu
                      </>
                    ) : (
                      <>
                        <Save className="mr-2 h-4 w-4" /> Lưu thay đổi
                      </>
                    )}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* USERS MANAGEMENT */}
        <TabsContent value="users">
          <div className="space-y-6">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle>Quản lý người dùng</CardTitle>
                  <CardDescription>
                    Thêm, sửa, xóa người dùng và phân quyền
                  </CardDescription>
                </div>
                <Button
                  onClick={handleAddUser}
                  className="bg-green-600 hover:bg-green-700"
                >
                  <Plus className="mr-2 h-4 w-4" /> Thêm người dùng
                </Button>
              </CardHeader>
              <CardContent>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Người dùng</TableHead>
                      <TableHead>Liên hệ</TableHead>
                      <TableHead>Vai trò</TableHead>
                      <TableHead>Trạng thái</TableHead>
                      <TableHead>Ngày tạo</TableHead>
                      <TableHead className="text-right">Thao tác</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {users.map((user: any) => (
                      <TableRow key={user.id}>
                        <TableCell>
                          <div>
                            <div className="font-medium">{user.fullName}</div>
                            <div className="text-sm text-slate-500">
                              @{user.username}
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="space-y-1">
                            {user.email && (
                              <div className="flex items-center gap-1 text-sm">
                                <Mail className="h-3 w-3 text-slate-400" />
                                {user.email}
                              </div>
                            )}
                            {user.phone && (
                              <div className="flex items-center gap-1 text-sm">
                                <Phone className="h-3 w-3 text-slate-400" />
                                {user.phone}
                              </div>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          <RoleBadge role={user.role} />
                        </TableCell>
                        <TableCell>
                          <StatusBadge status={user.status} />
                        </TableCell>
                        <TableCell className="text-sm text-slate-500">
                          {new Date(user.createdAt).toLocaleDateString("vi-VN")}
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleEditUser(user)}
                              className="h-8 px-2"
                            >
                              <FileEdit className="h-4 w-4 text-blue-500" />
                            </Button>
                            {user.role !== "OWNER" && (
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleDeleteUser(user.id)}
                                className="h-8 px-2 text-red-600 hover:text-red-700"
                              >
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>

            {/* USER PERMISSIONS */}
            <Card>
              <CardHeader>
                <CardTitle>Phân quyền hệ thống</CardTitle>
                <CardDescription>Quyền hạn theo từng vai trò</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b">
                        <th className="text-left py-3 px-4 font-medium">
                          Chức năng
                        </th>
                        <th className="text-center py-3 px-4 font-medium">
                          Chủ cửa hàng
                        </th>
                        <th className="text-center py-3 px-4 font-medium">
                          Quản lý
                        </th>
                        <th className="text-center py-3 px-4 font-medium">
                          Nhân viên
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {[
                        {
                          feature: "Xem báo cáo",
                          owner: true,
                          admin: true,
                          employee: false,
                        },
                        {
                          feature: "Tạo/sửa đơn hàng",
                          owner: true,
                          admin: true,
                          employee: true,
                        },
                        {
                          feature: "Xóa đơn hàng",
                          owner: true,
                          admin: true,
                          employee: false,
                        },
                        {
                          feature: "Quản lý sản phẩm",
                          owner: true,
                          admin: true,
                          employee: false,
                        },
                        {
                          feature: "Quản lý khách hàng",
                          owner: true,
                          admin: true,
                          employee: true,
                        },
                        {
                          feature: "Quản lý người dùng",
                          owner: true,
                          admin: false,
                          employee: false,
                        },
                        {
                          feature: "Cài đặt hệ thống",
                          owner: true,
                          admin: false,
                          employee: false,
                        },
                      ].map((item, index) => (
                        <tr key={index} className="border-b hover:bg-slate-50">
                          <td className="py-3 px-4">{item.feature}</td>
                          <td className="text-center py-3 px-4">
                            <div className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-emerald-100 text-emerald-700">
                              ✓
                            </div>
                          </td>
                          <td className="text-center py-3 px-4">
                            {item.admin ? (
                              <div className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-emerald-100 text-emerald-700">
                                ✓
                              </div>
                            ) : (
                              <div className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-slate-100 text-slate-400">
                                ✗
                              </div>
                            )}
                          </td>
                          <td className="text-center py-3 px-4">
                            {item.employee ? (
                              <div className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-emerald-100 text-emerald-700">
                                ✓
                              </div>
                            ) : (
                              <div className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-slate-100 text-slate-400">
                                ✗
                              </div>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* SYSTEM SETTINGS */}
        <TabsContent value="system">
          <Card>
            <CardHeader>
              <CardTitle>Cài đặt hệ thống</CardTitle>
              <CardDescription>
                Cấu hình các thông số hoạt động của hệ thống
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSystemSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <Label htmlFor="invoice-prefix">Tiền tố hóa đơn</Label>
                    <Input
                      id="invoice-prefix"
                      value={systemForm.invoicePrefix}
                      onChange={(e) =>
                        setSystemForm({
                          ...systemForm,
                          invoicePrefix: e.target.value,
                        })
                      }
                      placeholder="VD: HD"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="invoice-start">Số hóa đơn bắt đầu</Label>
                    <Input
                      id="invoice-start"
                      type="number"
                      value={systemForm.invoiceStartNumber}
                      onChange={(e) =>
                        setSystemForm({
                          ...systemForm,
                          invoiceStartNumber: parseInt(e.target.value),
                        })
                      }
                      placeholder="VD: 1001"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="low-stock">Ngưỡng cảnh báo tồn kho</Label>
                    <Input
                      id="low-stock"
                      type="number"
                      value={systemForm.lowStockThreshold}
                      onChange={(e) =>
                        setSystemForm({
                          ...systemForm,
                          lowStockThreshold: parseInt(e.target.value),
                        })
                      }
                      placeholder="Số lượng tối thiểu"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="currency">Đơn vị tiền tệ</Label>
                    <Select
                      value={systemForm.currency}
                      onValueChange={(value) =>
                        setSystemForm({ ...systemForm, currency: value })
                      }
                    >
                      <SelectTrigger id="currency">
                        <SelectValue placeholder="Chọn đơn vị tiền tệ" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="VND">VNĐ - Đồng Việt Nam</SelectItem>
                        <SelectItem value="USD">USD - Đô la Mỹ</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="timezone">Múi giờ</Label>
                    <Select
                      value={systemForm.timezone}
                      onValueChange={(value) =>
                        setSystemForm({ ...systemForm, timezone: value })
                      }
                    >
                      <SelectTrigger id="timezone">
                        <SelectValue placeholder="Chọn múi giờ" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Asia/Ho_Chi_Minh">
                          Asia/Ho_Chi_Minh (GMT+7)
                        </SelectItem>
                        <SelectItem value="UTC">UTC</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="language">Ngôn ngữ</Label>
                    <Select
                      value={systemForm.language}
                      onValueChange={(value) =>
                        setSystemForm({ ...systemForm, language: value })
                      }
                    >
                      <SelectTrigger id="language">
                        <SelectValue placeholder="Chọn ngôn ngữ" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="vi">Tiếng Việt</SelectItem>
                        <SelectItem value="en">Tiếng Anh</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-4 pt-4">
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label className="text-base">Thông báo hệ thống</Label>
                      <p className="text-sm text-slate-500">
                        Gửi thông báo khi có đơn hàng mới, tồn kho thấp
                      </p>
                    </div>
                    <Switch
                      checked={systemForm.enableNotifications}
                      onCheckedChange={(checked) =>
                        setSystemForm({
                          ...systemForm,
                          enableNotifications: checked,
                        })
                      }
                    />
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label className="text-base">Cảnh báo qua email</Label>
                      <p className="text-sm text-slate-500">
                        Gửi email khi có sự kiện quan trọng
                      </p>
                    </div>
                    <Switch
                      checked={systemForm.enableEmailAlerts}
                      onCheckedChange={(checked) =>
                        setSystemForm({
                          ...systemForm,
                          enableEmailAlerts: checked,
                        })
                      }
                    />
                  </div>
                </div>

                <div className="flex justify-end pt-4">
                  <Button
                    type="submit"
                    className="bg-indigo-600 hover:bg-indigo-700"
                    disabled={updateSystemMutation.isPending}
                  >
                    {updateSystemMutation.isPending ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang
                        lưu
                      </>
                    ) : (
                      <>
                        <Save className="mr-2 h-4 w-4" /> Lưu cài đặt
                      </>
                    )}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* SECURITY SETTINGS */}
        <TabsContent value="security">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Key className="h-5 w-5" /> Đổi mật khẩu
                </CardTitle>
                <CardDescription>
                  Cập nhật mật khẩu đăng nhập của bạn
                </CardDescription>
              </CardHeader>
              <CardContent>
                <form className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="current-password">Mật khẩu hiện tại</Label>
                    <Input
                      id="current-password"
                      type="password"
                      placeholder="••••••••"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="new-password">Mật khẩu mới</Label>
                    <Input
                      id="new-password"
                      type="password"
                      placeholder="••••••••"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirm-password">
                      Xác nhận mật khẩu mới
                    </Label>
                    <Input
                      id="confirm-password"
                      type="password"
                      placeholder="••••••••"
                    />
                  </div>
                  <Button
                    type="submit"
                    className="w-full bg-indigo-600 hover:bg-indigo-700"
                  >
                    <Save className="mr-2 h-4 w-4" /> Cập nhật mật khẩu
                  </Button>
                </form>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Shield className="h-5 w-5" /> Phiên đăng nhập
                </CardTitle>
                <CardDescription>
                  Quản lý các thiết bị đã đăng nhập
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="p-4 border rounded-lg">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="font-medium">Chrome - Windows</p>
                        <p className="text-sm text-slate-500">
                          Đăng nhập lúc: 15:30 27/10/2024
                        </p>
                      </div>
                      <Badge
                        variant="outline"
                        className="bg-emerald-50 text-emerald-700"
                      >
                        Hiện tại
                      </Badge>
                    </div>
                  </div>
                  <div className="p-4 border rounded-lg">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="font-medium">Safari - iPhone</p>
                        <p className="text-sm text-slate-500">
                          Đăng nhập lúc: 14:20 26/10/2024
                        </p>
                      </div>
                      <Button variant="outline" size="sm">
                        Đăng xuất
                      </Button>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="md:col-span-2">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Globe className="h-5 w-5" /> Hoạt động đăng nhập
                </CardTitle>
                <CardDescription>Lịch sử đăng nhập gần đây</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b">
                        <th className="text-left py-3 px-4 font-medium">
                          Thời gian
                        </th>
                        <th className="text-left py-3 px-4 font-medium">
                          Thiết bị
                        </th>
                        <th className="text-left py-3 px-4 font-medium">
                          Địa chỉ IP
                        </th>
                        <th className="text-left py-3 px-4 font-medium">
                          Vị trí
                        </th>
                        <th className="text-left py-3 px-4 font-medium">
                          Trạng thái
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {[
                        {
                          time: "27/10/2024 15:30",
                          device: "Chrome, Windows 11",
                          ip: "192.168.1.100",
                          location: "TP.HCM, Vietnam",
                          status: "Thành công",
                        },
                        {
                          time: "26/10/2024 14:20",
                          device: "Safari, iPhone 14",
                          ip: "192.168.1.101",
                          location: "TP.HCM, Vietnam",
                          status: "Thành công",
                        },
                        {
                          time: "25/10/2024 09:15",
                          device: "Firefox, MacOS",
                          ip: "103.221.222.123",
                          location: "Hà Nội, Vietnam",
                          status: "Thất bại",
                        },
                      ].map((item, index) => (
                        <tr key={index} className="border-b hover:bg-slate-50">
                          <td className="py-3 px-4">{item.time}</td>
                          <td className="py-3 px-4">{item.device}</td>
                          <td className="py-3 px-4">{item.ip}</td>
                          <td className="py-3 px-4">{item.location}</td>
                          <td className="py-3 px-4">
                            <Badge
                              variant={
                                item.status === "Thành công"
                                  ? "default"
                                  : "destructive"
                              }
                            >
                              {item.status}
                            </Badge>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>

      {/* USER DIALOG */}
      <Dialog open={isUserDialogOpen} onOpenChange={setIsUserDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>
              {currentUser ? "Cập nhật người dùng" : "Thêm người dùng mới"}
            </DialogTitle>
            <DialogDescription>
              {currentUser
                ? `Cập nhật thông tin cho ${currentUser.fullName}`
                : "Tạo tài khoản người dùng mới cho hệ thống"}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleUserSubmit}>
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="user-username">
                    Tên đăng nhập <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    id="user-username"
                    value={userForm.username}
                    onChange={(e) =>
                      setUserForm({ ...userForm, username: e.target.value })
                    }
                    placeholder="username"
                    required
                  />
                </div>
                {!currentUser && (
                  <div className="space-y-2">
                    <Label htmlFor="user-password">
                      Mật khẩu <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="user-password"
                      type="password"
                      value={userForm.password}
                      onChange={(e) =>
                        setUserForm({ ...userForm, password: e.target.value })
                      }
                      placeholder="••••••••"
                      required={!currentUser}
                    />
                  </div>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="user-fullname">
                  Họ và tên <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="user-fullname"
                  value={userForm.fullName}
                  onChange={(e) =>
                    setUserForm({ ...userForm, fullName: e.target.value })
                  }
                  placeholder="Nguyễn Văn A"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="user-email">Email</Label>
                  <Input
                    id="user-email"
                    type="email"
                    value={userForm.email}
                    onChange={(e) =>
                      setUserForm({ ...userForm, email: e.target.value })
                    }
                    placeholder="user@email.com"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="user-phone">Số điện thoại</Label>
                  <Input
                    id="user-phone"
                    value={userForm.phone}
                    onChange={(e) =>
                      setUserForm({ ...userForm, phone: e.target.value })
                    }
                    placeholder="0901234567"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Vai trò</Label>
                <Select
                  value={userForm.role}
                  onValueChange={(value) =>
                    setUserForm({ ...userForm, role: value })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn vai trò" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="EMPLOYEE">Nhân viên</SelectItem>
                    <SelectItem value="ADMIN">Quản lý</SelectItem>
                    <SelectItem value="OWNER">Chủ cửa hàng</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsUserDialogOpen(false)}
              >
                Hủy
              </Button>
              <Button
                type="submit"
                className="bg-indigo-600 hover:bg-indigo-700"
                disabled={
                  createUserMutation.isPending || updateUserMutation.isPending
                }
              >
                {createUserMutation.isPending ||
                updateUserMutation.isPending ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Đang xử lý
                  </>
                ) : currentUser ? (
                  "Cập nhật người dùng"
                ) : (
                  "Tạo người dùng"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function RoleBadge({ role }: { role: string }) {
  const getRoleConfig = (role: string) => {
    switch (role) {
      case "OWNER":
        return {
          label: "Chủ cửa hàng",
          className: "bg-purple-100 text-purple-700",
        };
      case "ADMIN":
        return { label: "Quản lý", className: "bg-blue-100 text-blue-700" };
      case "EMPLOYEE":
        return { label: "Nhân viên", className: "bg-slate-100 text-slate-700" };
      default:
        return { label: role, className: "bg-slate-100 text-slate-700" };
    }
  };

  const config = getRoleConfig(role);
  return (
    <Badge className={cn("px-2 py-1 text-xs font-medium", config.className)}>
      {config.label}
    </Badge>
  );
}

function StatusBadge({ status }: { status: string }) {
  const getStatusConfig = (status: string) => {
    switch (status) {
      case "ACTIVE":
        return {
          label: "Hoạt động",
          className: "bg-emerald-100 text-emerald-700",
        };
      case "INACTIVE":
        return {
          label: "Ngừng hoạt động",
          className: "bg-red-100 text-red-700",
        };
      default:
        return { label: status, className: "bg-slate-100 text-slate-700" };
    }
  };

  const config = getStatusConfig(status);
  return (
    <Badge className={cn("px-2 py-1 text-xs font-medium", config.className)}>
      {config.label}
    </Badge>
  );
}
