"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { plansService } from "@/services/plans.service";
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
  Plus,
  Loader2,
  Search,
  MoreHorizontal,
  FileEdit,
  Trash2,
  Zap,
  CheckCircle2,
  Users,
  Server,
  ShieldCheck,
  Package,
  Clock,
  CircleDollarSign,
  Eye,
} from "lucide-react";
import { cn } from "@/lib/utils";
import type { SubscriptionPlan, ApiResponse } from "@/types/api";
import { toast } from "sonner";

export default function PlansPage() {
  const queryClient = useQueryClient();

  // --- STATE ---
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [selectedPlanDetails, setSelectedPlanDetails] = useState<SubscriptionPlan | null>(null);
  const [isUsersDialogOpen, setIsUsersDialogOpen] = useState(false);
  const [subscriptions, setSubscriptions] = useState<any[]>([]);
  const [isLoadingSubs, setIsLoadingSubs] = useState(false);

  const fetchSubscriptions = async (planId: number) => {
    setIsLoadingSubs(true);
    try {
      const response = await plansService.getPlanSubscriptions(planId);
      if (response.data.code === 1000) {
        setSubscriptions(response.data.result || []);
      }
    } catch (error) {
      toast.error("Không thể lấy danh sách người dùng");
    } finally {
      setIsLoadingSubs(false);
    }
  };

  const handleViewUsers = (plan: SubscriptionPlan) => {
    setSelectedPlanDetails(plan);
    fetchSubscriptions(plan.id);
    setIsUsersDialogOpen(true);
  };
  const [currentPlan, setCurrentPlan] = useState<SubscriptionPlan | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    price: 0,
    durationMonths: 1,
    status: "ACTIVE" as "ACTIVE" | "INACTIVE",
    features: "[]",
  });

  // --- DATA FETCHING ---
  const { data, isLoading, isError, refetch } = useQuery<ApiResponse<SubscriptionPlan[]>>({
    queryKey: ["subscription-plans"],
    queryFn: plansService.getPlans,
  });

  const plans = data?.result || [];

  // --- MUTATIONS ---
  const createMutation = useMutation({
    mutationFn: plansService.createPlan,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["subscription-plans"] });
      setIsDialogOpen(false);
      resetForm();
      toast.success("Tạo gói dịch vụ thành công!");
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || "Có lỗi xảy ra");
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) => plansService.updatePlan(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["subscription-plans"] });
      setIsDialogOpen(false);
      resetForm();
      toast.success("Cập nhật thành công!");
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => plansService.deletePlan(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["subscription-plans"] });
      toast.success("Xóa gói dịch vụ thành công!");
    },
  });

  const [featureList, setFeatureList] = useState<string[]>([]);

  const handleAddFeature = () => {
    setFeatureList([...featureList, ""]);
  };

  const handleRemoveFeature = (index: number) => {
    setFeatureList(featureList.filter((_, i) => i !== index));
  };

  const handleFeatureChange = (index: number, value: string) => {
    const newList = [...featureList];
    newList[index] = value;
    setFeatureList(newList);
  };

  // --- ACTIONS ---
  const handleEdit = (plan: SubscriptionPlan) => {
    setCurrentPlan(plan);
    setFormData({
      name: plan.name,
      description: plan.description || "",
      price: plan.price,
      durationMonths: plan.durationMonths,
      status: plan.status,
      features: plan.features || "[]",
    });
    try {
      const parsed = JSON.parse(plan.features || "[]");
      setFeatureList(Array.isArray(parsed) ? parsed : []);
    } catch (e) {
      setFeatureList([]);
    }
    setIsDialogOpen(true);
  };

  const handleDelete = (id: number) => {
    if (confirm("Bạn có chắc muốn xóa gói này?")) {
      deleteMutation.mutate(id);
    }
  };

  const handleAddNew = () => {
    setCurrentPlan(null);
    resetForm();
    setFeatureList([""]);
    setIsDialogOpen(true);
  };

  const resetForm = () => {
    setFormData({
      name: "",
      description: "",
      price: 0,
      durationMonths: 1,
      status: "ACTIVE",
      features: "[]",
    });
    setFeatureList([]);
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validate and Clean Features
    const cleanedFeatures = featureList.filter(f => f.trim() !== "");
    const finalData = {
      ...formData,
      features: JSON.stringify(cleanedFeatures)
    };

    if (currentPlan) {
      updateMutation.mutate({ id: currentPlan.id, data: finalData });
    } else {
      createMutation.mutate(finalData);
    }
  };

  const handleFormChange = (field: string, value: any) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  return (
    <div className="p-8 space-y-10 bg-[#F8F9FC] min-h-screen">
      {/* HEADER */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
        <div className="space-y-1">
          <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 flex items-center gap-3">
            <Zap className="text-indigo-600 h-10 w-10 fill-indigo-600/10" />
            Gói dịch vụ
          </h1>
          <p className="text-slate-500 text-lg">
            Quản lý các gói đăng ký dành cho chủ cửa hàng.
          </p>
        </div>
        <Button
          onClick={handleAddNew}
          className="bg-indigo-600 hover:bg-indigo-700 h-12 px-6 rounded-xl shadow-lg shadow-indigo-200 text-base font-bold transition-all active:scale-95"
        >
          <Plus className="mr-2 h-5 w-5" /> Thêm gói mới
        </Button>
      </div>

      {/* STATS OVERVIEW - REDESIGNED FOR BETTER READABILITY */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {/* Card 1: Tổng số gói */}
        <div className="bg-white rounded-[24px] p-6 border border-slate-100 shadow-sm hover:shadow-md transition-all relative overflow-hidden group">
          <div className="absolute top-0 right-0 w-24 h-24 bg-blue-50/50 rounded-full -mr-12 -mt-12 transition-transform group-hover:scale-110" />
          <div className="relative z-10 flex flex-col gap-4">
            <div className="h-12 w-12 bg-blue-600 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-blue-200">
              <Zap size={22} fill="currentColor" />
            </div>
            <div>
              <h3 className="text-4xl font-black text-slate-900 leading-none">0{plans.length}</h3>
              <p className="text-sm font-bold text-slate-400 uppercase tracking-widest mt-2 px-0.5">Loại gói dịch vụ</p>
            </div>
          </div>
        </div>

        {/* Card 2: Tổng thuê bao */}
        <div className="bg-white rounded-[24px] p-6 border border-slate-100 shadow-sm hover:shadow-md transition-all relative overflow-hidden group">
          <div className="absolute top-0 right-0 w-24 h-24 bg-emerald-50/50 rounded-full -mr-12 -mt-12 transition-transform group-hover:scale-110" />
          <div className="relative z-10 flex flex-col gap-4">
            <div className="h-12 w-12 bg-emerald-500 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-emerald-200">
              <Users size={22} />
            </div>
            <div>
              <h3 className="text-4xl font-black text-slate-900 leading-none">
                {plans.reduce((acc, p) => acc + (p.usageCount || 0), 0)}
              </h3>
              <p className="text-sm font-bold text-slate-400 uppercase tracking-widest mt-2 px-0.5">Cửa hàng đăng ký</p>
            </div>
          </div>
        </div>

        {/* Card 3: Doanh thu dự kiến */}
        <div className="bg-white rounded-[24px] p-6 border border-slate-100 shadow-sm hover:shadow-md transition-all relative overflow-hidden group">
          <div className="absolute top-0 right-0 w-24 h-24 bg-amber-50/50 rounded-full -mr-12 -mt-12 transition-transform group-hover:scale-110" />
          <div className="relative z-10 flex flex-col gap-4">
            <div className="h-12 w-12 bg-amber-500 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-amber-200">
              <CircleDollarSign size={22} />
            </div>
            <div>
              <h3 className="text-3xl font-black text-slate-900 leading-none">
                {(plans.reduce((acc, p) => acc + (p.price * (p.usageCount || 0)), 0)).toLocaleString()}
                <span className="text-base font-bold ml-1 text-slate-400">đ</span>
              </h3>
              <p className="text-sm font-bold text-slate-400 uppercase tracking-widest mt-2 px-0.5">Doanh thu dự kiến/tháng</p>
            </div>
          </div>
        </div>

        {/* Card 4: Gói hot nhất */}
        <div className="bg-white rounded-[24px] p-6 border border-slate-100 shadow-sm hover:shadow-md transition-all relative overflow-hidden group">
          <div className="absolute top-0 right-0 w-24 h-24 bg-indigo-50/50 rounded-full -mr-12 -mt-12 transition-transform group-hover:scale-110" />
          <div className="relative z-10 flex flex-col gap-4">
            <div className="h-12 w-12 bg-indigo-600 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-indigo-200">
              <Package size={22} />
            </div>
            <div>
              <h3 className="text-2xl font-black text-slate-900 leading-none truncate pr-2">
                {plans.length > 0 ? plans.reduce((prev, current) => ((prev.usageCount || 0) > (current.usageCount || 0)) ? prev : current).name : "N/A"}
              </h3>
              <p className="text-sm font-bold text-slate-400 uppercase tracking-widest mt-3 px-0.5">Gói được tin dùng nhất</p>
            </div>
          </div>
        </div>
      </div>

      {/* PREMIUM CARDS GRID */}
      <div className="space-y-6 pt-4">
        <div className="flex items-center gap-3">
          <div className="h-1 w-12 bg-indigo-600 rounded-full" />
          <h2 className="text-xl font-bold text-slate-800">Preview Giao diện khách hàng</h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {plans.length > 0 ? (
            plans.slice(0, 3).map((plan) => (
              <PlanPremiumCard key={plan.id} plan={plan} onEdit={() => handleEdit(plan)} />
            ))
          ) : isLoading ? (
            [1, 2, 3].map((i) => (
              <div key={i} className="h-96 w-full animate-pulse bg-white rounded-3xl border border-slate-100 shadow-sm" />
            ))
          ) : (
            <div className="col-span-full py-12 text-center bg-white rounded-3xl border border-dashed border-slate-300">
              <Package className="h-16 w-16 text-slate-200 mx-auto mb-4" />
              <p className="text-slate-400 font-medium">Chưa có gói dịch vụ nào được cấu hình.</p>
            </div>
          )}
        </div>
      </div>

      {/* MANAGEMENT TABLE */}
      <div className="space-y-6 pt-8">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <h2 className="text-2xl font-bold text-slate-800">Bảng điều khiển hệ thống</h2>
            <Badge variant="outline" className="bg-indigo-50 border-indigo-100 text-indigo-600 font-bold px-3 py-1">
              {plans.length} gói hiện hành
            </Badge>
          </div>
        </div>

        <Card className="border-none shadow-xl shadow-slate-200/50 overflow-hidden bg-white rounded-3xl">
          <CardContent className="p-0">
            <Table>
              <TableHeader className="bg-slate-50/50 border-b border-slate-100">
                <TableRow>
                  <TableHead className="py-6 font-bold text-slate-700 pl-8">Thông tin gói</TableHead>
                  <TableHead className="py-6 font-bold text-slate-700">Giá & Kỳ hạn</TableHead>
                  <TableHead className="py-6 font-bold text-slate-700 text-center">Người dùng</TableHead>
                  <TableHead className="py-6 font-bold text-slate-700">Trạng thái</TableHead>
                  <TableHead className="py-6 font-bold text-slate-700 text-right pr-8">Thao tác</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  <TableRow>
                    <TableCell colSpan={5} className="h-40 text-center">
                      <div className="flex flex-col items-center justify-center text-slate-500">
                        <Loader2 className="h-10 w-10 mb-2 animate-spin text-indigo-600" />
                        <p className="font-medium">Đang truy vấn dữ liệu Master...</p>
                      </div>
                    </TableCell>
                  </TableRow>
                ) : plans.map((plan) => (
                  <TableRow key={plan.id} className="hover:bg-slate-50/50 group transition-colors">
                    <TableCell className="py-6 pl-8">
                      <div className="flex items-center gap-4">
                        <div className={cn(
                          "p-3 rounded-2xl transition-all shadow-sm",
                          plan.usageCount && plan.usageCount > 0 
                            ? "bg-indigo-600 text-white shadow-indigo-200" 
                            : "bg-slate-100 text-slate-400"
                        )}>
                          <Package size={22} />
                        </div>
                        <div>
                          <p className="font-extrabold text-slate-900 text-base">{plan.name}</p>
                          <p className="text-xs text-slate-400 max-w-[200px] truncate mt-0.5">{plan.description}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="py-6">
                      <div className="space-y-1">
                        <p className="font-mono font-black text-indigo-600 text-lg">
                          {plan.price.toLocaleString()}đ
                        </p>
                        <p className="text-[10px] font-bold text-slate-400 uppercase">Kỳ hạn {plan.durationMonths} tháng</p>
                      </div>
                    </TableCell>
                    <TableCell className="py-6 text-center">
                      <div className="flex items-center justify-center gap-2">
                        <Badge variant="secondary" className="bg-slate-100 text-slate-700 font-black px-4 py-1.5 rounded-xl border-none">
                          {plan.usageCount || 0} stores
                        </Badge>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleViewUsers(plan)}
                          className="h-8 w-8 text-slate-400 hover:text-indigo-600 hover:bg-white rounded-lg transition-all"
                          disabled={!plan.usageCount || plan.usageCount === 0}
                        >
                          <Eye size={16} />
                        </Button>
                      </div>
                    </TableCell>
                    <TableCell className="py-6">
                      <div className="flex items-center gap-2">
                         <div className={cn(
                           "h-2 w-2 rounded-full animate-pulse",
                           plan.status === "ACTIVE" ? "bg-emerald-500" : "bg-rose-500"
                         )} />
                        <span className={cn(
                          "font-bold text-sm",
                          plan.status === "ACTIVE" ? "text-emerald-600" : "text-rose-600"
                        )}>
                          {plan.status === "ACTIVE" ? "Đang mở bán" : "Đã đóng"}
                        </span>
                      </div>
                    </TableCell>
                    <TableCell className="py-6 text-right pr-8">
                      <div className="flex justify-end gap-3">
                        <Button
                          variant="ghost"
                          onClick={() => handleEdit(plan)}
                          className="h-11 w-11 p-0 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-2xl transition-all"
                        >
                          <FileEdit className="h-5 w-5" />
                        </Button>
                        <Button
                          variant="ghost"
                          onClick={() => handleDelete(plan.id)}
                          className="h-11 w-11 p-0 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-2xl transition-all"
                        >
                          <Trash2 className="h-5 w-5" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      {/* FORM DIALOG */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-xl rounded-3xl overflow-hidden p-0">
          <form onSubmit={handleSave}>
            <div className="bg-indigo-600 p-8 text-white">
              <DialogHeader>
                <DialogTitle className="text-2xl font-bold flex items-center gap-2">
                  <Zap className="fill-white/20" />
                  {currentPlan ? "Điều chỉnh gói dịch vụ" : "Khởi tạo gói mới"}
                </DialogTitle>
                <DialogDescription className="text-indigo-100 text-base">
                  Thiết lập các thông số và quyền lợi cho gói dịch vụ.
                </DialogDescription>
              </DialogHeader>
            </div>
            
            <div className="grid gap-6 p-8 bg-white">
              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="planName" className="font-bold text-slate-700">Tên gói <span className="text-red-500">*</span></Label>
                  <Input
                    id="planName"
                    value={formData.name}
                    onChange={(e) => handleFormChange("name", e.target.value)}
                    placeholder="VD: Pro Membership"
                    className="h-12 border-slate-200 focus:ring-indigo-500 rounded-xl"
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="planPrice" className="font-bold text-slate-700">Giá bán (VND) <span className="text-red-500">*</span></Label>
                  <div className="relative">
                    <Input
                      id="planPrice"
                      type="number"
                      value={formData.price}
                      onChange={(e) => handleFormChange("price", Number(e.target.value))}
                      className="h-12 border-slate-200 focus:ring-indigo-500 rounded-xl pl-10"
                      required
                    />
                    <CircleDollarSign className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="duration" className="font-bold text-slate-700">Số tháng kỳ hạn</Label>
                  <div className="relative">
                    <Input
                      id="duration"
                      type="number"
                      value={formData.durationMonths}
                      onChange={(e) => handleFormChange("durationMonths", Number(e.target.value))}
                      className="h-12 border-slate-200 focus:ring-indigo-500 rounded-xl pl-10"
                      min={1}
                    />
                    <Clock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label className="font-bold text-slate-700">Trạng thái kinh doanh</Label>
                  <div className="flex gap-4 p-1 bg-slate-50 rounded-xl border border-slate-100 h-12">
                    <button
                      type="button"
                      onClick={() => handleFormChange("status", "ACTIVE")}
                      className={cn(
                        "flex-1 rounded-lg text-sm font-bold transition-all",
                        formData.status === "ACTIVE" 
                          ? "bg-white text-emerald-600 shadow-sm border border-emerald-100" 
                          : "text-slate-400 hover:text-slate-600"
                      )}
                    >
                      Kích hoạt
                    </button>
                    <button
                      type="button"
                      onClick={() => handleFormChange("status", "INACTIVE")}
                      className={cn(
                        "flex-1 rounded-lg text-sm font-bold transition-all",
                        formData.status === "INACTIVE" 
                          ? "bg-white text-rose-600 shadow-sm border border-rose-100" 
                          : "text-slate-400 hover:text-slate-600"
                      )}
                    >
                      Tạm ngưng
                    </button>
                  </div>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="description" className="font-bold text-slate-700">Mô tả gói</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) => handleFormChange("description", e.target.value)}
                  placeholder="Mô tả tóm tắt tính năng..."
                  className="min-h-[100px] border-slate-200 focus:ring-indigo-500 rounded-xl resize-none"
                />
              </div>

              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <Label className="font-bold text-slate-700 border-b-2 border-indigo-500 pb-1">Đặc quyền & Tính năng</Label>
                  <Button 
                    type="button" 
                    variant="outline" 
                    size="sm" 
                    onClick={handleAddFeature}
                    className="h-8 px-2 text-[10px] font-bold border-indigo-200 text-indigo-600 hover:bg-indigo-50 rounded-lg"
                  >
                    <Plus className="mr-1 h-3 w-3" /> Thêm dòng
                  </Button>
                </div>
                
                <div className="space-y-3 max-h-[200px] overflow-y-auto pr-2 custom-scrollbar">
                  {Array.isArray(featureList) && featureList.map((feat, index) => (
                    <div key={index} className="flex gap-2">
                      <div className="relative flex-1">
                        <Input
                          value={feat}
                          onChange={(e) => handleFeatureChange(index, e.target.value)}
                          placeholder="Ví dụ: Tối đa 500 sản phẩm..."
                          className="h-10 border-slate-200 focus:ring-indigo-500 rounded-xl pl-10 text-sm"
                        />
                        <CheckCircle2 className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-emerald-500" />
                      </div>
                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        onClick={() => handleRemoveFeature(index)}
                        className="h-10 w-10 text-slate-300 hover:text-rose-500 hover:bg-rose-50 rounded-xl shrink-0"
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  ))}
                  {(!Array.isArray(featureList) || featureList.length === 0) && (
                    <p className="text-center py-4 text-xs text-slate-400 italic">Chưa có tính năng nào được thêm.</p>
                  )}
                </div>
              </div>
            </div>

            <DialogFooter className="p-8 border-t border-slate-50 bg-slate-50/50">
              <Button
                type="button"
                variant="ghost"
                onClick={() => setIsDialogOpen(false)}
                className="font-bold text-slate-600 h-12 px-6 hover:bg-white hover:text-slate-900 rounded-xl"
              >
                Hủy bỏ
              </Button>
              <Button
                type="submit"
                className="bg-indigo-600 hover:bg-indigo-700 h-12 px-8 rounded-xl font-bold shadow-lg shadow-indigo-100"
                disabled={createMutation.isPending || updateMutation.isPending}
              >
                {(createMutation.isPending || updateMutation.isPending) ? (
                  <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                ) : (
                  currentPlan ? "Cập nhật thay đổi" : "Lưu gói dịch vụ"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* DIALOG: VIEW REGISTERED USERS */}
      <Dialog open={isUsersDialogOpen} onOpenChange={setIsUsersDialogOpen}>
        <DialogContent className="max-w-4xl p-0 overflow-hidden border-none rounded-[32px] shadow-2xl">
          <div className="p-8 bg-indigo-900 text-white relative">
            <div className="absolute top-0 right-0 p-8 opacity-10">
              <Users size={120} />
            </div>
            <h2 className="text-3xl font-black mb-2">Danh sách thuê bao</h2>
            <p className="opacity-70 font-medium">
              Gói dịch vụ: <span className="text-amber-400 font-bold">{selectedPlanDetails?.name}</span>
            </p>
          </div>

          <div className="p-8 max-h-[60vh] overflow-y-auto bg-slate-50">
            {isLoadingSubs ? (
              <div className="py-20 text-center">
                <Loader2 className="h-10 w-10 animate-spin text-indigo-600 mx-auto mb-4" />
                <p className="text-slate-500 font-bold">Đang truy xuất dữ liệu thuê bao...</p>
              </div>
            ) : subscriptions.length > 0 ? (
              <div className="grid gap-4">
                {subscriptions.map((sub, idx) => (
                  <div key={idx} className="bg-white p-5 rounded-[20px] shadow-sm border border-slate-100 flex items-center justify-between hover:border-indigo-200 transition-all group">
                    <div className="flex items-center gap-4">
                      <div className="h-12 w-12 bg-indigo-50 rounded-xl flex items-center justify-center text-indigo-600 font-black text-lg">
                        {sub.storeName?.substring(0, 1).toUpperCase() || "S"}
                      </div>
                      <div>
                        <h4 className="font-bold text-slate-900 text-lg">{sub.storeName || "Cừa hàng chưa đặt tên"}</h4>
                        <div className="flex items-center gap-3 text-sm text-slate-400 font-medium mt-1">
                          <span className="flex items-center gap-1"><Users size={14} /> {sub.storeEmail || "N/A"}</span>
                          <span className="h-1 w-1 bg-slate-300 rounded-full" />
                          <span>Mã: {sub.subscriptionId}</span>
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <Badge className={cn(
                        "font-bold px-3 py-1 rounded-lg mb-2",
                        sub.status === "ACTIVE" ? "bg-emerald-100 text-emerald-700" : "bg-rose-100 text-rose-700"
                      )}>
                        {sub.status === "ACTIVE" ? "Đang hoạt động" : "Đã hết hạn"}
                      </Badge>
                      <p className="text-[11px] font-bold text-slate-400 uppercase">Hết hạn: {new Date(sub.endDate).toLocaleDateString("vi-VN")}</p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="py-20 text-center">
                 <Package className="h-16 w-16 text-slate-200 mx-auto mb-4" />
                 <p className="text-slate-400 font-bold">Chưa có cửa hàng nào đăng ký gói này.</p>
              </div>
            )}
          </div>
          
          <div className="p-6 bg-white border-t border-slate-100 flex justify-end">
            <Button 
              onClick={() => setIsUsersDialogOpen(false)}
              className="bg-slate-900 hover:bg-black text-white px-8 h-12 rounded-xl font-bold"
            >
              Đóng cửa sổ
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// --- SUBMODULAR COMPONENT ---

function PlanPremiumCard({ plan, onEdit }: { plan: SubscriptionPlan, onEdit: () => void }) {
  const isFree = plan.price === 0;
  const features = JSON.parse(plan.features || "[]");

  return (
    <Card className={cn(
      "group relative border-none rounded-[32px] overflow-hidden transition-all duration-300 hover:scale-[1.03] hover:shadow-2xl",
      isFree 
        ? "bg-slate-300 shadow-xl shadow-slate-400/50" 
        : plan.name.toLowerCase().includes("pro") 
          ? "bg-indigo-900 text-white shadow-2xl shadow-indigo-200" 
          : "bg-teal-700 text-white shadow-2xl shadow-teal-200"
    )}>
      {/* GLOW EFFECT */}
      {!isFree && (
        <div className="absolute top-0 right-0 -mr-20 -mt-20 w-64 h-64 bg-white/10 blur-[100px] pointer-events-none rounded-full" />
      )}

      <CardHeader className="pt-10 pb-6 px-8 relative">
        <div className="flex justify-between items-start mb-6">
          <div className={cn(
            "h-14 w-14 rounded-2xl flex items-center justify-center shadow-lg",
            isFree ? "bg-white text-slate-800" : "bg-white/20 text-white backdrop-blur-md"
          )}>
            {plan.name.toLowerCase().includes("free") ? <Server size={30} /> : 
             plan.name.toLowerCase().includes("pro") ? <Zap size={30} fill="currentColor" /> : 
             <ShieldCheck size={30} />}
          </div>
          {plan.status === "ACTIVE" && (
            <Badge className={cn(
              "px-3 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-widest border-none",
              isFree ? "bg-slate-400 text-slate-100" : "bg-white/30 text-white"
            )}>
              {isFree ? "Cơ bản" : "Best Choice"}
            </Badge>
          )}
        </div>
        <CardTitle className={cn(
          "text-3xl font-extrabold pb-1",
          isFree ? "text-slate-950" : "text-white"
        )}>{plan.name}</CardTitle>
        <CardDescription className={cn(
          "text-base font-medium leading-relaxed",
          isFree ? "text-slate-700" : "text-white/70"
        )}>
          {plan.description}
        </CardDescription>
      </CardHeader>

      <CardContent className="px-8 pb-10 space-y-8 relative">
        <div>
          <span className={cn(
            "text-5xl font-black leading-none",
            isFree ? "text-slate-900" : "text-white"
          )}>
            {plan.price.toLocaleString()}
          </span>
          <span className={cn(
            "text-base font-bold ml-2 opacity-60",
            isFree ? "text-slate-500" : "text-white"
          )}>
            đ/tháng
          </span>
        </div>

        <ul className="space-y-4">
          {features.length > 0 ? (
            features.map((feat: string, i: number) => (
              <li key={i} className="flex items-center gap-3">
                <CheckCircle2 className={cn("h-5 w-5 shrink-0", isFree ? "text-slate-600" : "text-white/60")} />
                <span className={cn(
                  "text-sm font-semibold opacity-90",
                  isFree ? "text-slate-700" : "text-white"
                )}>{feat}</span>
              </li>
            ))
          ) : (
            <li className="text-sm italic opacity-50">Không có thông tin tính năng</li>
          )}
        </ul>

        <Button
          onClick={onEdit}
          className={cn(
            "w-full h-14 rounded-2xl font-bold text-lg shadow-xl shadow-black/5 transition-all group-hover:scale-[1.02]",
            "bg-white text-slate-900 hover:bg-slate-50"
          )}
        >
          Cấu hình gói
        </Button>
      </CardContent>
    </Card>
  );
}
