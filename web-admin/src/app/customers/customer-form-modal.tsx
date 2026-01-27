"use client";

import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { customerService, type Customer } from "@/services/customer.service1";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge"; 
import {
  Loader2,
  UserPlus,
  Save,
  User,
  TrendingUp,
  Briefcase
} from "lucide-react";

// Định nghĩa Interface nội bộ cho Form
interface CustomerFormInput {
  fullName: string;
  phone: string;
  email: string;
  address: string;
  type: "RETAIL" | "WHOLESALE" | "CORPORATE";
  status: "ACTIVE" | "INACTIVE";
  taxCode: string;
  contactPerson: string;
  notes: string;
  totalOrders: number;
  totalPurchaseAmount: number;
  totalDebt: number;
}

interface Props {
  customer: Customer | null;
  isOpen: boolean;
  onClose: () => void;
}

export function CustomerFormModal({ customer, isOpen, onClose }: Props) {
  const queryClient = useQueryClient();

  const {
    register,
    handleSubmit,
    reset,
    setValue,
    watch,
    formState: { errors },
  } = useForm<CustomerFormInput>({
    defaultValues: {
      fullName: "",
      phone: "",
      email: "",
      address: "",
      type: "RETAIL",
      status: "ACTIVE",
      taxCode: "",
      contactPerson: "",
      notes: "",
      totalOrders: 0,
      totalPurchaseAmount: 0,
      totalDebt: 0,
    },
  });

  const selectedType = watch("type");

  // Đổ dữ liệu vào form khi mở Modal
  useEffect(() => {
    if (isOpen && customer) {
      reset({
        fullName: customer.fullName || "",
        phone: customer.phone || "",
        email: customer.email || "",
        address: customer.address || "",
        type: customer.type || "RETAIL",
        status: customer.status || "ACTIVE",
        taxCode: customer.taxCode || "",
        contactPerson: customer.contactPerson || "",
        notes: customer.notes || "",
        // Ép kiểu Number để chắc chắn các ô input số nhận đúng giá trị
        totalOrders: Number(customer.totalOrders || 0),
        totalPurchaseAmount: Number(customer.totalPurchaseAmount || 0),
        totalDebt: Number(customer.totalDebt || 0),
      });
    } else if (isOpen && !customer) {
      reset({
        fullName: "",
        phone: "",
        email: "",
        address: "",
        type: "RETAIL",
        status: "ACTIVE",
        taxCode: "",
        contactPerson: "",
        notes: "",
        totalOrders: 0,
        totalPurchaseAmount: 0,
        totalDebt: 0,
      });
    }
  }, [customer, isOpen, reset]);

  const mutation = useMutation({
    mutationFn: (data: CustomerFormInput) => {
      // Làm sạch dữ liệu trước khi gửi lên Backend
      const payload = {
        ...data,
        fullName: data.fullName.trim(),
        phone: data.phone.trim(),
        // Chuyển đổi các trường số
        totalOrders: Number(data.totalOrders || 0),
        totalPurchaseAmount: Number(data.totalPurchaseAmount || 0),
        totalDebt: Number(data.totalDebt || 0),
      };

      return customer
        ? customerService.updateCustomer(customer.id, payload)
        : customerService.createCustomer(payload);
    },
    onSuccess: () => {
      // Invalidate cả list và các query liên quan để cập nhật UI ngay lập tức
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      queryClient.invalidateQueries({ queryKey: ["customers"] });
      toast.success(customer ? "Cập nhật thành công!" : "Đã thêm đối tác mới!");
      onClose();
    },
    onError: (err: any) => {
      const errorMsg = err?.response?.data?.message || "Lỗi lưu dữ liệu. Vui lòng kiểm tra lại.";
      toast.error(errorMsg);
    },
  });

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[850px] max-h-[90vh] overflow-y-auto border-none shadow-2xl rounded-[1.5rem] p-0">
        <DialogHeader className="p-6 bg-slate-50/50 border-b sticky top-0 z-10 backdrop-blur-sm">
          <DialogTitle className="text-indigo-900 text-xl font-black flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-indigo-100 rounded-lg text-indigo-600">
                {customer ? <Save className="h-5 w-5" /> : <UserPlus className="h-5 w-5" />}
              </div>
              <span>{customer ? `CẬP NHẬT ĐỐI TÁC` : "THÊM ĐỐI TÁC MỚI"}</span>
            </div>
            {customer && (
              <Badge variant="outline" className="bg-white border-indigo-200 text-indigo-600 px-3 py-1 font-bold">
                ID: {customer.id}
              </Badge>
            )}
          </DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit((data) => mutation.mutate(data))} className="p-6 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-6">
            
            {/* CỘT 1: THÔNG TIN CƠ BẢN */}
            <div className="space-y-4">
              <h3 className="text-xs font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2">
                <User className="h-4 w-4" /> Thông tin chính
              </h3>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500">Họ và tên *</Label>
                <Input {...register("fullName", { required: "Vui lòng nhập họ tên" })} className="h-11 rounded-xl bg-slate-50/50" />
                {errors.fullName && <p className="text-[10px] text-rose-500 font-bold">{errors.fullName.message}</p>}
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label className="text-[11px] font-bold uppercase text-slate-500">Số điện thoại *</Label>
                  <Input {...register("phone", { required: "Vui lòng nhập số điện thoại" })} className="h-11 rounded-xl bg-slate-50/50" />
                </div>
                <div className="space-y-2">
                  <Label className="text-[11px] font-bold uppercase text-slate-500">Loại khách</Label>
                  <Select value={selectedType} onValueChange={(val: any) => setValue("type", val)}>
                    <SelectTrigger className="h-11 rounded-xl bg-slate-50/50">
                      <SelectValue placeholder="Chọn loại khách" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="RETAIL">Khách lẻ</SelectItem>
                      <SelectItem value="WHOLESALE">Khách sỉ</SelectItem>
                      <SelectItem value="CORPORATE">Doanh nghiệp</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500">Địa chỉ</Label>
                <Input {...register("address")} className="h-11 rounded-xl bg-slate-50/50" />
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500">Người liên hệ</Label>
                <div className="relative">
                    <Briefcase className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                    <Input {...register("contactPerson")} className="pl-10 h-11 rounded-xl bg-slate-50/50" />
                </div>
              </div>
            </div>

            {/* CỘT 2: SỐ LIỆU & CÔNG NỢ */}
            <div className="space-y-4">
              <h3 className="text-xs font-black text-emerald-600 uppercase tracking-widest flex items-center gap-2">
                <TrendingUp className="h-4 w-4" /> Dữ liệu giao dịch & Thuế
              </h3>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500">Mã số thuế</Label>
                <Input {...register("taxCode")} className="h-11 rounded-xl bg-slate-50/50" />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label className="text-[11px] font-bold uppercase text-slate-500">Tổng đơn</Label>
                  <Input type="number" {...register("totalOrders")} className="h-11 rounded-xl bg-slate-50/50 font-bold" />
                </div>
                <div className="space-y-2">
                  <Label className="text-[11px] font-bold uppercase text-slate-500">Công nợ (đ)</Label>
                  <Input type="number" {...register("totalDebt")} className="h-11 rounded-xl bg-rose-50/50 text-rose-600 font-bold" />
                </div>
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500">Tổng mua (đ)</Label>
                <Input type="number" {...register("totalPurchaseAmount")} className="h-11 rounded-xl bg-slate-50/50 font-bold" />
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500">Ghi chú</Label>
                <Textarea {...register("notes")} className="h-20 bg-slate-50/50 rounded-xl resize-none" />
              </div>
            </div>
          </div>

          <DialogFooter className="p-6 bg-slate-50 border-t gap-3 rounded-b-[1.5rem]">
            <Button type="button" variant="ghost" onClick={onClose} className="font-bold text-slate-500">HỦY BỎ</Button>
            <Button type="submit" className="bg-indigo-600 hover:bg-indigo-700 min-w-[160px] font-black rounded-xl" disabled={mutation.isPending}>
              {mutation.isPending ? <Loader2 className="animate-spin" /> : "LƯU DỮ LIỆU"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}