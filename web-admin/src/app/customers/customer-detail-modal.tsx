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
            <div className="h-20 w-20 bg-white rounded-2xl shadow-xl flex items-center justify-center text-3xl font-black text-indigo-600 border-4 border-white">
              {customer.fullName?.charAt(0)}
            </div>
            <div className="pb-2">
              <h2 className="text-xl font-black text-white uppercase tracking-tight drop-shadow-sm">
                {customer.fullName}
              </h2>
              <Badge className="bg-white/20 hover:bg-white/30 border-none text-[10px] font-bold text-white">
                ID: {customer.id}
              </Badge>
            </div>
          </div>
        </div>

        <div className="p-8 pt-12 grid grid-cols-2 gap-8 bg-white">
          {/* Thông tin liên hệ */}
          <div className="space-y-6">
            <h3 className="text-[11px] font-black text-slate-400 uppercase tracking-widest border-b pb-2">
              Liên hệ & Địa chỉ
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
                icon={<MapPin className="h-4 w-4 text-indigo-500" />}
                label="Địa chỉ"
                value={customer.address || "Chưa cập nhật"}
              />
            </div>
          </div>

          {/* Tài chính */}
          <div className="space-y-6">
            <h3 className="text-[11px] font-black text-slate-400 uppercase tracking-widest border-b pb-2">
              Thống kê mua hàng
            </h3>
            <div className="grid grid-cols-1 gap-4">
              <div className="p-4 rounded-2xl bg-indigo-50 border border-indigo-100 flex justify-between items-center">
                <div>
                  <p className="text-[9px] font-black text-indigo-400 uppercase">
                    Tổng mua
                  </p>
                  <p className="font-black text-indigo-700">
                    {Number(customer.totalPurchaseAmount).toLocaleString()}đ
                  </p>
                </div>
                <TrendingUp className="h-8 w-8 text-indigo-200" />
              </div>
              <div className="p-4 rounded-2xl bg-rose-50 border border-rose-100 flex justify-between items-center">
                <div>
                  <p className="text-[9px] font-black text-rose-400 uppercase">
                    Công nợ
                  </p>
                  <p className="font-black text-rose-700">
                    {Number(customer.totalDebt).toLocaleString()}đ
                  </p>
                </div>
                <CreditCard className="h-8 w-8 text-rose-200" />
              </div>
            </div>
          </div>
        </div>

        <div className="p-6 bg-slate-50 flex justify-end">
          <Button
            onClick={onClose}
            className="rounded-xl font-bold bg-slate-900 px-8"
          >
            ĐÓNG
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

function InfoRow({ icon, label, value }: any) {
  return (
    <div className="flex items-start gap-3">
      <div className="mt-1">{icon}</div>
      <div>
        <p className="text-[9px] font-black text-slate-400 uppercase leading-none mb-1">
          {label}
        </p>
        <p className="text-sm font-bold text-slate-700">{value}</p>
      </div>
    </div>
  );
}
