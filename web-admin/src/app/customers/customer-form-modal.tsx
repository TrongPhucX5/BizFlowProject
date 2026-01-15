"use client";

import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { customerService, type Customer } from "@/services/customer.service";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge"; // Thêm Badge để hiển thị ID chuyên nghiệp
import { Loader2, UserPlus, Save, Phone, User, Mail, MapPin, FileText, Hash } from "lucide-react";

interface CustomerFormInput {
  fullName: string;
  phone: string;
  email: string;
  address: string;
  type: "RETAIL" | "WHOLESALE";
  taxCode: string;
  contactPerson: string;
  notes: string;
}

interface Props {
  customer: Customer | null;
  isOpen: boolean;
  onClose: () => void;
}

export function CustomerFormModal({ customer, isOpen, onClose }: Props) {
  const queryClient = useQueryClient();
  
  const { register, handleSubmit, reset, setValue, watch, formState: { errors } } = useForm<CustomerFormInput>({
    defaultValues: {
      fullName: "",
      phone: "",
      email: "",
      address: "",
      type: "RETAIL",
      taxCode: "",
      contactPerson: "",
      notes: ""
    }
  });

  const selectedType = watch("type");

  useEffect(() => {
    if (isOpen) {
      reset({
        fullName: customer?.fullName || "",
        phone: customer?.phone || "",
        email: customer?.email || "",
        address: customer?.address || "",
        type: (customer?.type as any) || "RETAIL",
        taxCode: customer?.taxCode || "",
        contactPerson: customer?.contactPerson || "",
        notes: customer?.notes || ""
      });
    }
  }, [customer, isOpen, reset]);

  const mutation = useMutation({
    mutationFn: (data: CustomerFormInput) => {
      const cleanData: any = {
        ...data,
        fullName: data.fullName.trim(),
        phone: data.phone.trim(),
        email: data.email?.trim() || null,
        taxCode: data.taxCode?.trim() || null
      };
      
      return customer 
        ? customerService.updateCustomer(customer.id, cleanData) 
        : customerService.createCustomer(cleanData);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers-list"] });
      toast.success(customer ? "Cập nhật thành công!" : "Đã thêm đối tác mới!");
      onClose();
    },
    onError: (err: any) => {
      const serverError = err?.response?.data;
      const errorMsg = serverError?.message || "Không thể kết nối đến máy chủ.";
      
      if (serverError?.code === 4009 || errorMsg.includes("đã tồn tại")) {
        toast.error("Số điện thoại này đã được sử dụng bởi một khách hàng khác.");
      } else {
        toast.error(errorMsg);
      }
    }
  });

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[700px] max-h-[90vh] overflow-y-auto border-none shadow-2xl rounded-[1.5rem] p-0">
        <DialogHeader className="p-6 bg-slate-50/50 border-b sticky top-0 z-10 backdrop-blur-sm">
          <DialogTitle className="text-indigo-900 text-xl font-black flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-indigo-100 rounded-lg text-indigo-600">
                {customer ? <Save className="h-5 w-5" /> : <UserPlus className="h-5 w-5" />}
              </div>
              <span>{customer ? `CẬP NHẬT ĐỐI TÁC` : "THÊM ĐỐI TÁC MỚI"}</span>
            </div>
            
            {/* HIỂN THỊ ID KHI CHỈNH SỬA */}
            {customer && (
              <Badge variant="outline" className="ml-auto bg-white border-indigo-200 text-indigo-600 px-3 py-1 rounded-full flex items-center gap-1 font-bold">
                <Hash className="h-3 w-3" /> ID: {customer.id}
              </Badge>
            )}
          </DialogTitle>
        </DialogHeader>
        
        <form onSubmit={handleSubmit((data) => mutation.mutate(data))} className="p-6 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
            
            {/* CỘT 1: THÔNG TIN CƠ BẢN */}
            <div className="space-y-4">
              <h3 className="text-xs font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2 mb-2">
                <User className="h-4 w-4" /> Thông tin chính
              </h3>
              
              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500 ml-1">Họ và tên *</Label>
                <Input 
                  {...register("fullName", { required: "Vui lòng nhập họ tên" })} 
                  placeholder="Nguyễn Văn A..."
                  className={`h-11 rounded-xl transition-all ${errors.fullName ? "border-red-500 bg-red-50/30 shadow-none" : "bg-slate-50/50 focus:bg-white"}`}
                />
                {errors.fullName && <p className="text-[10px] text-red-500 font-bold ml-1">{errors.fullName.message}</p>}
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500 ml-1">Số điện thoại *</Label>
                <div className="relative">
                  <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                  <Input 
                    {...register("phone", { 
                      required: "Vui lòng nhập SĐT",
                      pattern: { value: /^[0-9+]*$/, message: "SĐT không đúng định dạng" }
                    })} 
                    placeholder="09xxx..."
                    className={`pl-10 h-11 rounded-xl ${errors.phone ? "border-red-500 bg-red-50/30" : "bg-slate-50/50"}`}
                  />
                </div>
                {errors.phone && <p className="text-[10px] text-red-500 font-bold ml-1">{errors.phone.message}</p>}
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500 ml-1">Phân loại khách hàng</Label>
                <Select value={selectedType} onValueChange={(val: any) => setValue("type", val)}>
                  <SelectTrigger className="h-11 rounded-xl bg-slate-50/50 border-slate-200">
                    <SelectValue placeholder="Chọn loại khách" />
                  </SelectTrigger>
                  <SelectContent className="rounded-xl border-slate-200 shadow-xl">
                    <SelectItem value="RETAIL" className="font-medium">Khách lẻ (RETAIL)</SelectItem>
                    <SelectItem value="WHOLESALE" className="font-medium">Khách sỉ (WHOLESALE)</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* CỘT 2: CHI TIẾT LIÊN HỆ */}
            <div className="space-y-4">
              <h3 className="text-xs font-black text-indigo-600 uppercase tracking-widest flex items-center gap-2 mb-2">
                <Mail className="h-4 w-4" /> Liên hệ & Ghi chú
              </h3>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500 ml-1">Mã số thuế</Label>
                <Input {...register("taxCode")} placeholder="MST doanh nghiệp..." className="h-11 rounded-xl bg-slate-50/50" />
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500 ml-1">Địa chỉ</Label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
                  <Input {...register("address")} className="pl-10 h-11 rounded-xl bg-slate-50/50" />
                </div>
              </div>

              <div className="space-y-2">
                <Label className="text-[11px] font-bold uppercase text-slate-500 ml-1 flex items-center gap-1">
                  <FileText className="h-3 w-3" /> Ghi chú
                </Label>
                <Textarea 
                  {...register("notes")} 
                  className="h-[100px] bg-slate-50/50 rounded-xl resize-none focus:bg-white transition-all text-sm" 
                  placeholder="Ghi chú sở thích, công nợ..."
                />
              </div>
            </div>
          </div>

          <DialogFooter className="p-6 bg-slate-50 border-t flex-row sm:justify-end gap-3 rounded-b-[1.5rem] mt-4">
            <Button 
              type="button" 
              variant="ghost" 
              onClick={onClose} 
              disabled={mutation.isPending}
              className="rounded-xl font-bold text-slate-500 hover:bg-slate-200"
            >
              HỦY BỎ
            </Button>
            <Button 
              type="submit" 
              className="bg-indigo-600 hover:bg-indigo-700 min-w-[160px] font-black rounded-xl shadow-lg shadow-indigo-100" 
              disabled={mutation.isPending}
            >
              {mutation.isPending ? (
                <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> ĐANG LƯU...</>
              ) : (
                <><Save className="mr-2 h-4 w-4" /> LƯU DỮ LIỆU</>
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}