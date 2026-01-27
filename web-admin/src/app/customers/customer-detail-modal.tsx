"use client";

import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import {
  Phone,
  Mail,
  MapPin,
  CreditCard,
  TrendingUp,
  Calendar,
  User,
  FileText,
  Briefcase,
  Hash
} from "lucide-react";
import { type Customer } from "@/services/customer.service1";
import { Button } from "@/components/ui/button";

interface Props {
  isOpen: boolean;
  onClose: () => void;
  customer: Customer | null;
}

export function CustomerDetailModal({ isOpen, onClose, customer }: Props) {
  if (!customer) return null;

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl rounded-3xl p-0 overflow-hidden border-none shadow-2xl">
        {/* Banner Profile */}
        <div className="h-32 bg-gradient-to-r from-indigo-600 via-indigo-700 to-purple-700 p-8 flex items-end">
          <div className="flex gap-4 items-center transform translate-y-4">
            <div className="h-20 w-20 bg-white rounded-2xl shadow-xl flex items-center justify-center text-3xl font-black text-indigo-600 border-4 border-white uppercase">
              {customer.fullName?.charAt(0)}
            </div>
            <div className="pb-2">
              <h2 className="text-xl font-black text-white uppercase tracking-tight drop-shadow-sm">
                {customer.fullName}
              </h2>
              <div className="flex gap-2 items-center mt-1">
                <Badge className="bg-white/20 hover:bg-white/30 border-none text-[10px] font-bold text-white">
                  ID: {customer.id}
                </Badge>
                <Badge className="bg-yellow-400 text-indigo-900 border-none text-[10px] font-black uppercase">
                  {customer.type === "RETAIL" ? "Khách lẻ" : customer.type === "WHOLESALE" ? "Khách sỉ" : "Doanh nghiệp"}
                </Badge>
              </div>
            </div>
          </div>
        </div>

        <div className="p-8 pt-12 space-y-8 bg-white">
          <div className="grid grid-cols-2 gap-12">
            {/* Cột 1: Thông tin liên hệ & Cơ bản */}
            <div className="space-y-6">
              <h3 className="text-[11px] font-black text-slate-400 uppercase tracking-widest border-b pb-2 flex items-center gap-2">
                <User className="h-3.5 w-3.5" /> Thông tin cơ bản
              </h3>
              <div className="space-y-4">
                <InfoRow
                  icon={<Phone className="h-4 w-4 text-indigo-500" />}
                  label="Số điện thoại"
                  value={customer.phone}
                />
                <InfoRow
                  icon={<Mail className="h-4 w-4 text-indigo-500" />}
                  label="Email"
                  value={customer.email || "Chưa cập nhật"}
                />
                <InfoRow
                  icon={<Briefcase className="h-4 w-4 text-indigo-500" />}
                  label="Người liên hệ"
                  value={customer.contactPerson || "---"}
                />
                <InfoRow
                  icon={<Hash className="h-4 w-4 text-indigo-500" />}
                  label="Mã số thuế"
                  value={customer.taxCode || "---"}
                />
                <InfoRow
                  icon={<MapPin className="h-4 w-4 text-indigo-500" />}
                  label="Địa chỉ"
                  value={customer.address || "Chưa cập nhật"}
                />
              </div>
            </div>

            {/* Cột 2: Tài chính & Thống kê */}
            <div className="space-y-6">
              <h3 className="text-[11px] font-black text-slate-400 uppercase tracking-widest border-b pb-2 flex items-center gap-2">
                <TrendingUp className="h-3.5 w-3.5" /> Tài chính & Giao dịch
              </h3>
              <div className="grid grid-cols-1 gap-4">
                <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex justify-between items-center">
                   <div>
                    <p className="text-[9px] font-black text-slate-400 uppercase">Tổng đơn hàng</p>
                    <p className="font-black text-slate-700 text-lg">
                      {Number(customer.totalOrders || 0)} <span className="text-[10px] font-medium text-slate-400">Đơn</span>
                    </p>
                  </div>
                </div>
                
                <div className="p-4 rounded-2xl bg-indigo-50 border border-indigo-100 flex justify-between items-center">
                  <div>
                    <p className="text-[9px] font-black text-indigo-400 uppercase">Tổng doanh số</p>
                    <p className="font-black text-indigo-700 text-lg">
                      {Number(customer.totalPurchaseAmount || 0).toLocaleString()}đ
                    </p>
                  </div>
                  <TrendingUp className="h-8 w-8 text-indigo-200" />
                </div>

                <div className="p-4 rounded-2xl bg-rose-50 border border-rose-100 flex justify-between items-center">
                  <div>
                    <p className="text-[9px] font-black text-rose-400 uppercase">Công nợ hiện tại</p>
                    <p className="font-black text-rose-700 text-lg">
                      {Number(customer.totalDebt || 0).toLocaleString()}đ
                    </p>
                  </div>
                  <CreditCard className="h-8 w-8 text-rose-200" />
                </div>
              </div>
            </div>
          </div>

          {/* PHẦN GHI CHÚ (NOTES) - Cập nhật mới */}
          <div className="space-y-3">
            <h3 className="text-[11px] font-black text-slate-400 uppercase tracking-widest border-b pb-2 flex items-center gap-2">
              <FileText className="h-3.5 w-3.5" /> Ghi chú nội bộ
            </h3>
            <div className="p-4 rounded-2xl bg-amber-50/50 border border-amber-100/50 min-h-[80px]">
              {customer.notes ? (
                <p className="text-sm text-slate-600 leading-relaxed italic">
                  "{customer.notes}"
                </p>
              ) : (
                <p className="text-xs text-slate-400 italic font-medium">
                  Không có ghi chú nào cho đối tác này.
                </p>
              )}
            </div>
          </div>
        </div>

        <div className="p-6 bg-slate-50 flex justify-end gap-3">
          <Button
            variant="outline"
            onClick={onClose}
            className="rounded-xl font-bold border-slate-200 text-slate-500 px-8"
          >
            ĐÓNG
          </Button>
          <Button
            className="rounded-xl font-bold bg-indigo-600 hover:bg-indigo-700 px-8"
            onClick={() => {
              // Bạn có thể thêm logic mở form sửa trực tiếp từ đây nếu muốn
              onClose();
            }}
          >
            CHỈNH SỬA
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

function InfoRow({ icon, label, value }: any) {
  return (
    <div className="flex items-start gap-3">
      <div className="mt-1 p-1.5 bg-slate-50 rounded-lg">{icon}</div>
      <div>
        <p className="text-[9px] font-black text-slate-400 uppercase leading-none mb-1">
          {label}
        </p>
        <p className="text-sm font-bold text-slate-700 break-words">{value}</p>
      </div>
    </div>
  );
}